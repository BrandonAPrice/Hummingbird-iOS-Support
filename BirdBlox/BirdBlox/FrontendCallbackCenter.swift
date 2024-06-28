//
//  FrontendCallbackCenter.swift
//  BirdBlox
//
//  Created by Jeremy Huang on 2017-06-20.
//  Copyright © 2017年 Birdbrain Technologies LLC. All rights reserved.
//

import Foundation
import WebKit


/*
A central location for all the javascript callbacks.
 */
class FrontendCallbackCenter {
	private static let singleton: FrontendCallbackCenter = FrontendCallbackCenter()
	
	private let wvLock = NSCondition()
	
	public static var shared: FrontendCallbackCenter {
		return singleton
	}
	
	public static func safeString(from: String) -> String {
		return from.addingPercentEncoding(withAllowedCharacters: CharacterSet()) ?? ""
	}
	
	public static func jsonString(from: Any) -> String? {
		do {
			let data = try JSONSerialization.data(withJSONObject: from, options: [.prettyPrinted])
			return String(data: data, encoding: .utf8)
		} catch {
			return nil
		}
	}
	
	var webView: WKWebView? = nil
	
	
	//MARK: Internal Method
	private func runJS(function: String, parameters: [String]) -> Bool {
		guard let wv = self.webView else {
			return false
		}
		
		let parametersStr = "(" + parameters.map({"'\($0)'"}).joined(separator: ", ") + ")"
		
		let js = function + parametersStr
		
//		self.wvLock.lock()
		
		//This might get run from the main thread. Might will crash if main.sync is called from
		//the main thread.
		DispatchQueue.main.async {
			wv.evaluateJavaScript(js, completionHandler: { ret, error in
				if let error = error {
					NSLog("Error '\(error)' while running '\(js)'")
					return
				}
				
				//print("Ran '\(js)', got \(String(describing: ret))")
				#if DEBUG
					//print("Ran '\(js)', got \(String(describing: ret))")
				#endif
			})
		}
		
//		self.wvLock.unlock()
		
		return true
	}
	
	
	//MARK: Dialog Responses
	private func boolToJSString(_ b: Bool) -> String {
		return b ? "true" : "" //empty string evaluates to false in Javascript
	}
	
	public func dialogPromptResponded(cancelled: Bool, response: String?) -> Bool {
		let safeResponse = FrontendCallbackCenter.safeString(from: response ?? "")
		
		let function = "CallbackManager.dialog.promptResponded"
		let parameters = [boolToJSString(cancelled), safeResponse]
		
		return self.runJS(function: function, parameters: parameters)
	}
	
	func choiceResponded(cancelled: Bool, firstSelected: Bool) -> Bool {
		let function = "CallbackManager.dialog.choiceResponded"
		let parameters = [boolToJSString(cancelled), boolToJSString(firstSelected)]
		
		return self.runJS(function: function, parameters: parameters)
	}
	
	//MARK: Robot Related
    public func robotUpdateHLState(state: [UInt8]) -> Bool {
        //NSLog("setHLState")
        //NSLog(state.map({String($0)}).joined(separator: ",")) 
        let function = "CallbackManager.robot.setHLState"
        let parameters = [state.map({ String($0) }).joined(separator: ", ")]

        return self.runJS(function: function, parameters: parameters)
    }
	public func robotUpdateStatus(id: String, connected: Bool) -> Bool {
		let safeResponse = FrontendCallbackCenter.safeString(from: id)
		let function = "CallbackManager.robot.updateStatus"
		let parameters = [safeResponse, boolToJSString(connected)]
		
		return self.runJS(function: function, parameters: parameters)
	}
    public func robotUpdateHasV2Microbit(id: String, hasV2: Bool) -> Bool {
        let safeResponse = FrontendCallbackCenter.safeString(from: id)
        
        let function = "CallbackManager.robot.updateHasV2Microbit"
        let parameters = [safeResponse, boolToJSString(hasV2)]
        
        return self.runJS(function: function, parameters: parameters)
    }
    public func robotUpdateBattery(id: String, batteryStatus: Int) -> Bool {
        NSLog("Updating battery for \(id) to \(batteryStatus)")
        let safeResponse = FrontendCallbackCenter.safeString(from: id)
        
        let function = "CallbackManager.robot.updateBatteryStatus"
        let parameters = [safeResponse, String(batteryStatus)]
        
        return self.runJS(function: function, parameters: parameters)
    }
    public func robotCalibrationComplete(id: String, success: Bool) -> Bool {
        let function = "CallbackManager.robot.compassCalibrationResult"
        let parameters = [id, String(success)]
        return self.runJS(function: function, parameters: parameters)
    }
	
    //TODO: Make this for every type of robot
    public func robotFirmwareIncompatible(robotType: BBTRobotType, id: String, firmware: String) -> Bool {
		let safeID = FrontendCallbackCenter.safeString(from: id)
		let safeFirmware = FrontendCallbackCenter.safeString(from: firmware)
		
		let function = "CallbackManager.robot.disconnectIncompatible"
		let parameters = [safeID, safeFirmware, robotType.minimumFirmware]
		
        let safeMin = FrontendCallbackCenter.safeString(from: robotType.minimumFirmware)
        print("Firmware incompatible: \(id), \(firmware), \(safeMin), \(parameters)")
		return self.runJS(function: function, parameters: parameters)
	}

    public func robotDisconnected(name: String) -> Bool {
        let function = "CallbackManager.robot.connectionFailure"
        let parameters = [name]
        return self.runJS(function: function, parameters: parameters)
    }
	
	public func robotFirmwareStatus(id: String, status: String) -> Bool {
		let safeID = FrontendCallbackCenter.safeString(from: id)
		let safeSatus = FrontendCallbackCenter.safeString(from: status)
		
		let function = "CallbackManager.robot.updateFirmwareStatus"
		let parameters = [safeID, safeSatus]
		
		return self.runJS(function: function, parameters: parameters)
	}
	
	public func scanHasStopped() -> Bool {
		//let safeType = FrontendCallbackCenter.safeString(from: typeStr)
		NSLog("Scan has stopped. Notifying frontend.")
		let function = "CallbackManager.robot.stopDiscover"
        let parameters: [String] = []
		
		return self.runJS(function: function, parameters: parameters)
	}
	
	public func updateDiscoveredRobotList(robotList: [[String: String]]) -> Bool {
		//let safeType = FrontendCallbackCenter.safeString(from: typeStr)
		
		guard let jsonList = FrontendCallbackCenter.jsonString(from: robotList) else {
			return false
		}
		let safeList = FrontendCallbackCenter.safeString(from: jsonList)
		
		let function = "CallbackManager.robot.discovered"
		let parameters = [safeList]
		
		return self.runJS(function: function, parameters: parameters)
	}
	
	
	//MARK: Updating UI
	func documentSetName(name: String) -> Bool {
		let safeName = FrontendCallbackCenter.safeString(from: name)
		
		let function = "CallbackManager.data.setName"
		let parameters = [safeName]
		
		return self.runJS(function: function, parameters: parameters)
	}
	
	func markLoadingDocument() -> Bool {
		let function = "CallbackManager.data.markLoading"
		let parameters: [String] = []
		
		return self.runJS(function: function, parameters: parameters)
	}
    
    func reloadOpenDialog() -> Bool {
        let function = "OpenDialog.currentDialog.reloadDialog"
        let parameters: [String] = []
        
        return self.runJS(function: function, parameters: parameters)
    }
	
	func recordingEnded() -> Bool {
		let function = "CallbackManager.sounds.recordingEnded"
		let parameters: Array<String> = []
		
		return self.runJS(function: function, parameters: parameters)
	}
    
	
	//MARK: misc., utility
	func echo(getRequestString: String) -> Bool {
		let function = "CallbackManager.echo"
		let parameters = [FrontendCallbackCenter.safeString(from: getRequestString)]
		
		return self.runJS(function: function, parameters: parameters)
	}
	
	func sendFauxHTTPResponse(id: String, status: Int, obody: String?) -> Bool {
		let body = obody ?? ""
		let function = "CallbackManager.httpResponse"
		let parameters = [id, status.description, FrontendCallbackCenter.safeString(from: body)]
		
		return self.runJS(function: function, parameters: parameters)
	}
    
    //When the app is sent to the background, we need to stop any running code
    func stopExecution() ->  Bool {
        return self.runJS(function: "CodeManager.stop", parameters: [])
    }
    
    func setLanguage(_ lang: String) -> Bool {
        let function = "CallbackManager.tablet.getLanguage"
        let parameters = [lang]
        
        return self.runJS(function: function, parameters: parameters)
    }
    
    func setFilePreference(_ fileName: String) -> Bool {
        let function = "CallbackManager.setFilePreference"
        let parameters = [fileName]
        print("setting file \(parameters)")
        return self.runJS(function: function, parameters: parameters)
    }
}
