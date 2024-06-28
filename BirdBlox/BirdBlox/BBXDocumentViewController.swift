//
//  BBXDocumentViewController.swift
//  BirdBlox
//
//  Created by Jeremy Huang on 2017-06-28.
//  Copyright © 2017年 Birdbrain Technologies LLC. All rights reserved.
//

import Foundation
import UIKit
import WebKit
//import Swifter
import SafariServices
//import MobileCoreServices

/*
BBXDocumentViewController
A view controller meant to display a BBXDocument to the user.
Repurposed as the root view controller for versions of iOS before iOS 11. 
So the design is intentionally similar to ViewController.swift.
 */

class BBXDocumentViewController: UIViewController, BBTWebViewController, UIDocumentPickerDelegate,
SFSafariViewControllerDelegate, WKNavigationDelegate {
	
	var webView = WKWebView()
	var webUILoaded = false
	
	let server = BBTBackendServer()
	
	//This is unecessary since the server will definitely be started by the time the page is loaded
//	var reloadTimer = Timer()
	var stopTimer = Timer()
	var utilTimer = Timer()
    var docIsClosing = false
    
    static var needsFullScreen = true
	
	override func viewDidLoad() {
		NSLog("Document View Controller viewDidLoad")
		
		super.viewDidLoad()
		
		self.view.backgroundColor = UIColor.black
		
		self.setNeedsStatusBarAppearanceUpdate()
		
		//Setup Server
		
		self.addHandlersToServer(self.server)
		
		(UIApplication.shared.delegate as! AppDelegate).backendServer = self.server
		
		self.server["/ui/contentLoaded"] = { request in
//			self.reloadTimer.invalidate()
			
			self.webUILoaded = true
			
			if let name = UserDefaults.standard.string(forKey: self.curDocNameKey) ?? UserDefaults.standard.string(forKey: self.lastDocNameKey) {
				//let _ = self.openProgram(byName: name)
                if FrontendCallbackCenter.shared.setFilePreference(name) {
                    NSLog("Successfully set the filename to \(name)")
                } else {
                    NSLog("Failed to set the filename to \(name)")
                }
            } else {
                NSLog("Failed to find a current filename.")
            }
            /*
            if let lang = NSLocale.preferredLanguages.first?.prefix(2) {
                let language = String(lang)
                NSLog("Setting frontend language to \(language)")
                if FrontendCallbackCenter.shared.setLanguage(language) {
                    NSLog("Successfully set language to \(language)")
                }
            }
            */
			
			return .ok(.text("Hello webpage! I am a server."))
		}
		self.server["/ui/translatedStrings"] = { request in
            //This request is to set some text for popups handled by the backend.
            // Currently only used in Android
            return .ok(.text("Message received."))
        }
        
		self.server.start()
		
		//Setup webview
		//Connect native calls
		
		let config = WKWebViewConfiguration()
		let contentController = WKUserContentController()
		contentController.add(self.server, name: "serverSubstitute")
		config.userContentController = contentController
		
		self.webView = WKWebView(frame: self.barRespectingRect(from: self.view.bounds),
		                         configuration: config)
        //webView.navigationDelegate = self
        //webView.uiDelegate = self
		
        if #available(macCatalyst 16.4, iOS 16.4, *) {
                self.webView.isInspectable = true
        } 
        self.webView.navigationDelegate = self
		self.webView.contentMode = UIView.ContentMode.scaleToFill
		self.webView.backgroundColor = UIColor.gray
		
		let htmlLoc = DataModel.shared.frontendPageLoc
		let frontLoc = DataModel.shared.frontendLoc
		
		self.webView.loadFileURL(htmlLoc, allowingReadAccessTo: frontLoc)
		
		self.view.addSubview(self.webView)
		
		//Setup callback center
		FrontendCallbackCenter.shared.webView = webView
        
        //To capture key presses from the when key pressed block, the webView must be the first responder.
        self.webView.becomeFirstResponder()
		
		NSLog("Document View Controller exiting viewDidLoad")
	}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        #if targetEnvironment(macCatalyst)
            //Make full screen for macOS
    /*    if Self.needsFullScreen {
            NSLog("Entering full screen.")
            (NSClassFromString("NSApplication")?.value(forKeyPath: "sharedApplication.windows") as? [AnyObject])?.first?.perform(Selector("toggleFullScreen:"))
            Self.needsFullScreen = false
        }*/
        
        //Dynamic.NSApplication.sharedApplication.windows.firstObject.toggleFullScreen(nil)
        
        //Very stupid results
        /*if let f = UIApplication.shared.windows.first {
            NSLog("macCatalyst another way")
            var w = f.frame
            let newWidth: CGFloat = 800
            let newHeight: CGFloat = 600
            w.size = NSMakeSize(newWidth, newHeight)
            f.frame = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
        }*/
        
        
        /*if  let NSApplication = NSClassFromString("NSApplication") as? NSObject.Type,
                let sharedApplication = NSApplication.value(forKeyPath: "sharedApplication") as? NSObject,
                let windows = sharedApplication.value(forKeyPath: "windows") as? [NSObject]//,
                //let first = windows.first as? UIWindow //, first.responds(to: Selector("toggleFullScreen:"))
                //let first = windows.first, let wFrame = first.frame?
            {
            /*if let first = windows.first, first.responds(to: Selector("frame")) {
                NSLog("LLLLLLLLLLLLLLL")
            }*/
            NSLog("macCatalyst entering full screen")
            if let first = windows.first as? UIWindow  {
                NSLog("macCatalyst entering full screen for real")
                var wFrame = first.frame
                let newWidth: CGFloat = 800
                let newHeight: CGFloat = 600
                wFrame.size = NSMakeSize(newWidth, newHeight)
                first.frame = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
            } else {
                NSLog("macCatalyst fail to cast as UIWindow")
            }
            
            //first.perform(Selector("toggleFullScreen:"))
            /*var windowFrame = first.frame
            let newWidth: CGFloat = 800
            let newHeight: CGFloat = 600
            windowFrame.size = NSMakeSize(newWidth, newHeight)
            first.frame = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)//.setFrame(windowFrame, display: true)
            */
        } else {
            NSLog("macCatalyst failed to enter full screen")
        }*/
        #endif
    }
	
	//MARK: Document Handling
	static let curDocNeedsNameKey = "CurrentDocumentNeedsName"
	static let curDocNameKey = "CurrentDocumentName"
    static let lastDocNameKey = "LastDocumentName"
	let curDocNeedsNameKey = "CurrentDocumentNeedsName"
	let curDocNameKey = "CurrentDocumentName"
    let lastDocNameKey = "LastDocumentName"
	
	private var realDoc = BBXDocument(fileURL: URL(
		fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory,
		                                                     .userDomainMask,
		                                                     true)[0])
		.appendingPathComponent("empty.bbx"))
	
	private func updateDisplayFromXML(completion: @escaping ((Bool) -> Void)) {
		guard self.webUILoaded else {
			return
		}
		
		//For some reason this always opens the last document
		let eset = CharacterSet()
		let name = self.document.localizedName.addingPercentEncoding(withAllowedCharacters: eset)!
		let xml = self.document.currentXML.addingPercentEncoding(withAllowedCharacters: eset)!
		let needsName = UserDefaults.standard.bool(forKey: self.curDocNeedsNameKey)
		let js = "CallbackManager.data.open('\(name)', '\(xml)', \(!needsName))"
		
		
		DispatchQueue.main.async {
			self.webView.evaluateJavaScript(js) { succeeded, error in
				if let error = error {
					NSLog("JS exception (\(error)) while opening data. ")
					return
				}
				
				NSLog("ran JS update XML")
				if let suc = (succeeded as? Bool) {
					completion(suc)
				}
			}
		}
	}
	
	var document: BBXDocument {
		get {
			return self.realDoc
		}
		
		set (doc) {
			self.realDoc.close(completionHandler: nil) //Doesn't this take a while?
			self.realDoc = doc
            
			if self.webUILoaded {
				self.updateDisplayFromXML(completion: { (succeeded: Bool) in
					// Only set this document as our document if it is valid
					//Relies on no more requests while the js is still parsing the document
					if succeeded {
						let notificationName = UIDocument.stateChangedNotification
						NotificationCenter.default.addObserver(forName: notificationName,
						                                       object: self.realDoc, queue: nil,
						                                       using: { notification in
																
							self.handleDocumentStateChangeNotification(notification)
						})
					}
					else {
						doc.close(completionHandler: nil)
					}
				})
			}
		}
	}
	
	func handleDocumentStateChangeNotification(_ notification: Notification) {
		switch self.document.documentState {
		case UIDocument.State.inConflict:
			let v = NSFileVersion.unresolvedConflictVersionsOfItem(at: self.document.fileURL)
			guard let versions = v else {
				print("Invalid URL")
				return
			}
			print("Conflict. Number of conflict versions \(versions.count)")
			return
		default:
			return
		}
	}
	
	//Returns false if no program by that name exists
	private func openProgram(byName name: String, completion: ((Bool) -> Void)? = nil) -> Bool {
		let fileURL = DataModel.shared.getBBXFileLoc(byName: name)
		
		guard FileManager.default.fileExists(atPath: fileURL.path) else {
			NSLog("Asked to open file that does not exist.")
			return false
		}
		
		let doc = BBXDocument(fileURL: fileURL)
		doc.open(completionHandler: {suc in
			print("open handler suc: \(suc)")
			if suc {
				self.document = doc
				if let comp = completion {
					comp(suc)
				}
			}
//			else {
//				//Wait a bit and try once more
//				//TODO: make each document create and destroy its own temp directory so a document
//				Thread.sleep(forTimeInterval: 0.3)
//				doc.open(completionHandler: { (suc2) in
//					if suc2 {
//						self.document = doc
//					}
//					if let comp = completion {
//						comp(suc2)
//					}
//				})
//			}
			
			//Uncomment (see above)
//			if let comp = completion {
//				comp(suc)
//			}
		})
		
		return true
	}
	
	private func closeCurrentProgram(completion: ((Bool) -> Void)? = nil) {
        self.docIsClosing = true;
		self.document.close(completionHandler: { suc in
            self.docIsClosing = false;
            let curDocName = DataModel.shared.getSetting(self.curDocNameKey)
            UserDefaults.standard.set(curDocName, forKey: self.lastDocNameKey)
			UserDefaults.standard.set(nil, forKey: self.curDocNameKey)
			if let completion = completion {
				completion(suc)
			}
		})
	}
	
	
	//MARK: View configuration
	override var prefersStatusBarHidden : Bool {
		if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
			return true
		}
		
		return false
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	var statusBarHeight: CGFloat {
		//let barSize: CGSize = UIApplication.shared.statusBarFrame.size
        var barSize: CGSize = CGSize()
        if #available(iOS 13.1, *) {
            barSize = view.window?.windowScene?.statusBarManager?.statusBarFrame.size ?? CGSize()
        } else {
            barSize = UIApplication.shared.statusBarFrame.size
        }
		return min(barSize.width, barSize.height)
	}
	
	func barRespectingRect(from screenRect: CGRect) -> CGRect {
		let height = self.statusBarHeight
		var ss = screenRect
		ss.size.height -= height
		ss.origin.y += height
		return ss
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		var frame = self.view.bounds
		frame = self.barRespectingRect(from: frame)
		self.webView.frame = frame
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
		print("Did receive memory warning")
	}
	
	override func viewWillTransition(to size: CGSize,
	                                 with coordinator: UIViewControllerTransitionCoordinator) {
		
		let nSize = self.barRespectingRect(from: CGRect(origin: CGPoint(x: 0, y: 0),
		                                                size: size)).size
		print("New size: \(nSize)")
		
		let rsJS = "GuiElements.updateDimsPreview(\(nSize.width), \(nSize.height))"
		self.webView.evaluateJavaScript(rsJS, completionHandler: {
			print("Updated dims. Error: \(($0, $1))")
		})
	}
	
	//Shaken Sensor
	var timeLastShaken = Date(timeIntervalSince1970: 0)
	var shakeExpireInterval = TimeInterval(5) //seconds
	
	override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		if motion == .motionShake {
			self.timeLastShaken = Date(timeIntervalSinceNow: 0)
		}
	}
	
	//MARK: Setup Sever

	let robotRequests = RobotRequests()
	let soundManager = SoundManager()
	let settingsManager = SettingsManager()
	let propertiesManager = PropertiesManager()
	
	var dataRequests: DataManager? = nil
	var hostDeviceManager: HostDeviceManager? = nil
	
	func addHandlersToServer(_ server: BBTBackendServer) {
        #if !HATCHLING
		hostDeviceManager = (hostDeviceManager != nil ?
			hostDeviceManager : HostDeviceManager(view_controller: self))
        #endif
		dataRequests = dataRequests != nil ? dataRequests :  DataManager(view_controller: self)
		
		//Requests to load parts of the frontend
		server["/DragAndDrop/:path1/:path2/:path3"] = BBTHandleFrontEndRequest
		server["/DragAndDrop/:path1/:path2"] = BBTHandleFrontEndRequest
		server["/DragAndDrop/:path1"] = BBTHandleFrontEndRequest
		
		//Heartbeat
		server["/server/ping"] = {r in return .ok(.text("pong"))}
		
//		hummingbirdManager.loadRequests(server: server)
//		flutterManager.loadRequests(server: server)
		robotRequests.loadRequests(server: server)
		dataRequests!.loadRequests(server: server)
		hostDeviceManager?.loadRequests(server: server)
		soundManager.loadRequests(server: server)
		settingsManager.loadRequests(server: server)
		propertiesManager.loadRequests(server: server)
		
		self.server["/tablet/shake"] = { (request: HttpRequest) -> HttpResponse in
			let interval = Date(timeIntervalSinceNow: 0).timeIntervalSince(self.timeLastShaken)
			let respStr = (interval < self.shakeExpireInterval) ? "1" : "0"
			self.timeLastShaken = Date(timeIntervalSince1970: 0)
			return .ok(.text(respStr))
		}
        
		self.server["/cloud/showPicker"] = { (request: HttpRequest) -> HttpResponse in
			let docTypes = [DataModel.bbxUTI, "public.xml"]
			//let picker = UIDocumentPickerViewController(documentTypes: docTypes, in: .open)
            let picker = UIDocumentPickerViewController(documentTypes: docTypes, in: .import)
			picker.delegate = self
			
			DispatchQueue.main.sync {
				self.present(picker, animated: true, completion: nil)
			}
			
			return .ok(.text("Showing picker"))
		}
		
		self.server["/data/close"] = { (request: HttpRequest) -> HttpResponse in
			self.closeCurrentProgram()
			return .ok(.text(""))
		}
		
		self.server["/data/new"] = { (request: HttpRequest) -> HttpResponse in
			let queries = BBTSequentialQueryArrayToDict(request.queryParams)
			
			guard let xml = String(bytes: request.body, encoding: .utf8) else {
				return .badRequest(.text("POST body not encoded in utf8."))
			}
			
			let reqName = queries["filename"] ?? "New Program"
			
			let name = DataModel.shared.availableName(from: reqName)!
			NSLog("Created file named \(name)")
			let fileURL = DataModel.shared.getBBXFileLoc(byName: name)
			
			guard DataModel.shared.emptyCurrentDocument() else {
				return .internalServerError
			}
			
			let doc = BBXDocument(fileURL: fileURL)
			doc.currentXML = xml
			doc.save(to: fileURL, for: .forCreating, completionHandler: { succeeded in
				if succeeded {
//					self.webUILoaded = false
					print(doc.documentState)
					self.document = doc
//					self.webUILoaded = true
					let _ = FrontendCallbackCenter.shared.documentSetName(name: name)
				} else {
					NSLog("Creating new document failed.")
				}
			})
			
			UserDefaults.standard.set(true, forKey: self.curDocNeedsNameKey)
			UserDefaults.standard.set(name, forKey: self.curDocNameKey)
			
			return .raw(201, "Created", ["Location" : "/data/load?filename=\(name)"]) {
				(writer) throws -> Void in
				try writer.write([UInt8](name.utf8))
			}
		}
		
		self.server["/data/open"] = { (request: HttpRequest) -> HttpResponse in
			let queries = BBTSequentialQueryArrayToDict(request.queryParams)
			print("Open request")
			
			guard let name = queries["filename"] else {
				return .badRequest(.text("Missing Parameters"))
			}
			
			let openBlock = {
				let _ = self.openProgram(byName: name)
				print(name)
//				if !fileExists {
//					return .internalServerError
//				}
				UserDefaults.standard.set(false, forKey: self.curDocNeedsNameKey)
				UserDefaults.standard.set(name, forKey: self.curDocNameKey)
			}
			
			if self.document.documentState == .closed {
				print("Running open block now!")
				openBlock()
			} else {
                //TODO: Actually try to close the file here? What if it is already in the process of closing?
                if (self.docIsClosing) {
                    if #available(iOS 10.0, *) {
                        DispatchQueue.main.sync {
                            self.utilTimer = Timer.scheduledTimer(withTimeInterval: 0.75,
                                                                  repeats: false,
                                                                  block: { t in
                                if self.document.documentState == .closed {
                                    openBlock()
                                } else {
                                    NSLog("Unable to open file \(name).")
                                }
                            })
                        }
                    }
                } else {
                    self.closeCurrentProgram(completion: { suc in
                        if !suc || self.document.documentState != .closed  {
                            NSLog("Unable to close current document to open a new one")
                            return
                        }
                        
                        openBlock()
                    })
                }
			}
			
			return .ok(.text(""))
		}
		
		
		self.server["/data/save"] = { (request: HttpRequest) in
			return HttpResponse.ok(.text("Using UIDocument Autosave instead"))
		}
		
		self.server["/data/autoSave"] = { (request: HttpRequest) -> HttpResponse in
			guard let xml = String(bytes: request.body, encoding: .utf8) else {
				return .badRequest(.text("POST body not encoded in utf8."))
			}
			
			self.document.currentXML = xml
			
			return .ok(.text("Success"))
		}
		
		//TOOD: Add a file closed callback so we can get rid of these wrappers.
		// Once there is a file closed callback, no delete or rename command will happen to
		// an open file.
		let renameHandler = self.dataRequests!.renameRequest
		self.server["/data/rename"] = { (request: HttpRequest) -> HttpResponse in
			let queries = BBTSequentialQueryArrayToDict(request.queryParams)
			
			guard let typeStr = queries["type"],
				let newFilename = queries["newFilename"],
				let oldFilename = queries["oldFilename"] else {
					return .badRequest(.text("Missing Parameters"))
			}
			guard let type = self.dataRequests?.fileType(fromParameter: typeStr) else {
				return .badRequest(.text("Invalid type argument"))
			}
			
			let curDocName = DataModel.shared.getSetting(self.curDocNameKey)
			if type == .BirdBloxProgram && oldFilename == curDocName {
				self.closeCurrentProgram(completion: { suc in
					if !suc {
						NSLog("Unable to close current document for renaming")
						return
					}
					
					let resp = renameHandler(request)
					
					switch (resp) {
					case .ok(_):
                       DispatchQueue.main.async{ self.webView.evaluateJavaScript("CallbackManager.data.filesChanged()") {
							result, error in
							UserDefaults.standard.set(newFilename, forKey: self.curDocNameKey)
							UserDefaults.standard.set(false, forKey: self.curDocNeedsNameKey)
							let _ = self.openProgram(byName: newFilename)
                            }
						}
					default:
                        DispatchQueue.main.async{
                            self.webView.evaluateJavaScript("CallbackManager.data.close()")
                        }
						return
					}
				})
				
				return .ok(.text("We'll see"))
			}
			else {
				return renameHandler(request)
			}
		}
		
		let deleteHandler = self.dataRequests!.deleteRequest
		self.server["/data/delete"] = { (request: HttpRequest) -> HttpResponse in
			let queries = BBTSequentialQueryArrayToDict(request.queryParams)
			guard let filename = queries["filename"],
				let typeStr = queries["type"] else {
					return .badRequest(.text("Missing Parameters"))
			}
			guard let type = self.dataRequests?.fileType(fromParameter: typeStr) else {
				return .badRequest(.text("Invalid type argument"))
			}
			
			let curDocName = DataModel.shared.getSetting(self.curDocNameKey)
			guard (filename != curDocName || (type != .BirdBloxProgram) ||
				(self.document.documentState == .closed)) else {
				print("delete open \(filename) \(curDocName ?? "no current doc") \(type) \(self.document.documentState == .closed)")
				self.closeCurrentProgram(completion: { suc in
					if suc {
						let _ = deleteHandler(request)
                        DispatchQueue.main.async{
                            self.wv.evaluateJavaScript("CallbackManager.data.close()")
                            self.wv.evaluateJavaScript("CallbackManager.data.filesChanged()")
                        }
					}
				})
				return .ok(.text("We'll see"))
			}
			
			return deleteHandler(request)
		}
		
        if let stopAll = server["/robot/stopAll"] {
            server["/robot/stopAll"] = { req in
    //			server.clearBackgroundQueue(completion: {
    //				server.backgroundQueue.async {
    //					let _ = stopAll(req)
    //				}
    //			}) //This won't help much because there are still ≤30 threads settings outputs
                
                //TODO: Add ability for output threads to abort based on a check to a boolean whenever
                //they wake from sleep (when they are waiting to write out). Then delete this timer.
                if #available(iOS 10.0, *) {
                    DispatchQueue.main.sync {
                        self.stopTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) {
                            t in
                            
                            let _ = stopAll(req)
                            print("stopping again")
                        }
                    }
                }
                return stopAll(req)
            }
        }
		
		server["/data/markAsNamed"] = { request in
			UserDefaults.standard.set(false, forKey: self.curDocNeedsNameKey)
			return .ok(.text("set"))
		}
		
		server["/robot/showUpdateInstructions"] = { request in
			DispatchQueue.main.sync {
				let str =  "http://www.hummingbirdkit.com/learning/installing-birdblox#BurnFirmware"
                guard let url = URL(string:str) else {
                    return
                }
				let websiteVC = SFSafariViewController(url: url)
				self.present(websiteVC, animated: true, completion: nil)
				websiteVC.delegate = self
				
				
				if #available(iOS 10.0, *) {
					if let dele = UIApplication.shared.delegate as? AppDelegate {
						let tint = dele.tintColor
//						websiteVC.preferredBarTintColor = tint
						websiteVC.preferredControlTintColor = tint
				}
				}
			}
			return .ok(.text("Presenting webpage"))
		}
	}
	
	
	//MARK: UIDocumentPickerDelegate
    
	
	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        print("File picked! \(url.absoluteString)")
        print("save loc: \(DataModel.shared.bbxSaveLoc)")
        let filename = url.deletingPathExtension().lastPathComponent
        print("File name! \(filename)")
        var saveName = filename + ".bbx"
        var fileUrl = DataModel.shared.bbxSaveLoc.appendingPathComponent(saveName)
        var i = 1
        let fileManager = FileManager.default
        while fileManager.fileExists(atPath: fileUrl.path) {
            saveName = "\(filename)_\(i).bbx"
            fileUrl = DataModel.shared.bbxSaveLoc.appendingPathComponent(saveName)
            i += 1
        }
        print("Saving \(fileUrl.absoluteString)")
        do {
            try fileManager.moveItem(at: url.standardizedFileURL, to: fileUrl)
        } catch {
            print(error)
        }
        
        //Once the file is saved, open automatically
        let req = "data/open?filename=\(saveName.dropLast(4))"
        let _ = FrontendCallbackCenter.shared.echo(getRequestString: req)
        
        
        /* In the version below, we show the downloaded file in the dialog and give a message
         * about how that file was named. However, this text was not translated. It seems
         * more clear to just open the file, than to have the user guess where it went.
        let _ = FrontendCallbackCenter.shared.reloadOpenDialog()
        
        let text = FrontendCallbackCenter.safeString(from: "File imported as\n\'\(saveName)\'")
        let _ = FrontendCallbackCenter.shared.echo(getRequestString:
            "/tablet/choice?question=\(text)&button1=Dismiss")
        return
        */
        
        /*
		let doc = BBXDocument(fileURL: url)
		let _ = FrontendCallbackCenter.shared.markLoadingDocument()
		doc.open(completionHandler: { suc in
			print("open handler suc: \(suc)")
			if suc {
				self.document = doc
				print("State 1 (from picker): \(self.document.documentState)")
				
				UserDefaults.standard.set(nil, forKey: self.curDocNameKey)
				UserDefaults.standard.set(nil, forKey: self.curDocNeedsNameKey)
			} else {
				let docName = url.lastPathComponent
				let alert = UIAlertController(title: "Unable to Open File",
				                              message: "\(docName) is not a valid .bbx file",
											  preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "Okay", style: .default))
				
				self.present(alert, animated: true, completion: nil)
			}
		})*/
	}
	
	//MARK: SFSafariViewControllerDelegate
	func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
		controller.dismiss(animated: true, completion: nil)
	}
	
	//MARK: BBTWebViewController
	var wv: WKWebView {
		return self.webView
	}
    
    //MARK: WKNavigationDelegate methods
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //if let lang = NSLocale.preferredLanguages.first?.prefix(2) {
        if let lang = NSLocale.preferredLanguages.first {
            //let language = String(lang)
            NSLog("Setting frontend language to \(lang)")
            if FrontendCallbackCenter.shared.setLanguage(lang) {
                NSLog("Successfully set language to \(lang)")
            }
        }
    }
    
}

/*
Created to make switching to BBXDocumentView Controller easier. 
Some of the older request handlers still need access to the view
 */

protocol BBTWebViewController {
	var wv: WKWebView { get }
	var webUILoaded: Bool { get }
	
	
	//MARK: UIViewController methods that we need
	var view: UIView! { get set }
	
	func present(_ viewControllerToPresent: UIViewController,
	             animated flag: Bool, completion: (() -> Void)?)
}
