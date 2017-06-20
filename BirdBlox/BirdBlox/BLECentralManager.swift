//
//  BLECentralManager.swift
//  BirdBlox
//
//  Created by birdbrain on 3/23/17.
//  Copyright © 2017 Birdbrain Technologies LLC. All rights reserved.
//
import Foundation
import CoreBluetooth

// This wraps the method of getting the state in iOS versions prior to iOS10
extension CBCentralManager {
	internal var centralManagerState: CBCentralManagerState  {
		get {
			return CBCentralManagerState(rawValue: state.rawValue) ?? .unknown
		}
	}
}


class BLECentralManager: NSObject, CBCentralManagerDelegate {
	
	enum BLECentralManagerScanState {
		case notScanning
		case searchingScan
		case countingScan
	}
	
	public static let manager: BLECentralManager = BLECentralManager()
	
	var centralManager: CBCentralManager!
	var discoveredDevices: [String: CBPeripheral]
	var scanState: BLECentralManagerScanState
	var discoverTimer: Timer
	var deviceCount: UInt
	var connectedFlutters: [String: FlutterPeripheral]
	
	override init() {
		
		self.discoveredDevices = [String: CBPeripheral]()
		self.scanState = .notScanning
		self.discoverTimer = Timer()
		self.deviceCount = 0
		self.connectedFlutters = Dictionary()
		
		super.init();
		
		let centralQueue = DispatchQueue(label: "com.BirdBrainTech", attributes: [])
		centralManager = CBCentralManager(delegate: self, queue: centralQueue)
	}
	
	var isScanning: Bool {
		return self.scanState == .searchingScan
	}
	
	var devicesInVicinity: UInt {
		return self.deviceCount
	}
	
	func startScan(serviceUUIDs: [CBUUID]) {
		if self.scanState == .countingScan {
			self.stopScan()
		}
		if !self.isScanning && (self.centralManager.centralManagerState == .poweredOn) {
			discoveredDevices.removeAll()
			centralManager.scanForPeripherals(withServices: serviceUUIDs, options: nil)
			discoverTimer = Timer.scheduledTimer(timeInterval: TimeInterval(30), target: self,
			                                     selector: #selector(BLECentralManager.stopScan),
			                                     userInfo: nil, repeats: false)
			self.scanState = .searchingScan
			NSLog("Stated bluetooth scan")
		}
	}
	
	func startCountingScan() {
		self.deviceCount = 0
		self.centralManager.scanForPeripherals(withServices: nil, options: nil)
		self.scanState = .countingScan
		if #available(iOS 10.0, *) {
			self.discoverTimer = Timer.scheduledTimer(withTimeInterval: 120, repeats: false) {
				t in self.stopScan()
			}
		} else {
			discoverTimer = Timer.scheduledTimer(timeInterval: TimeInterval(120), target: self,
			                                     selector: #selector(BLECentralManager.stopScan),
			                                     userInfo: nil, repeats: false)
		}
	}
	
	func stopScan() {
		if isScanning {
			centralManager.stopScan()
			self.scanState = .notScanning
			discoverTimer.invalidate()
			NSLog("Stopped bluetooth scan")
		}
	}
	
	var foundDevices: [String: CBPeripheral] {
		return self.discoveredDevices
	}
	
	
	/**
	* If a device is discovered, it is given a unique name and added to our
	* discovered list. If the device was connected in this session and had
	* lost connection, it is automatically connected to again
	*/
	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
	                    advertisementData: [String : Any], rssi RSSI: NSNumber) {
		switch self.scanState {
		case .countingScan:
			self.deviceCount += 1
		case .searchingScan:
			self.discoveredDevices[peripheral.identifier.uuidString] = peripheral
		default:
			return
		}
	}
	
	/**
	* If we connected to a peripheral, we add it to our services and stop
	* discovering new devices
	*/
	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		if discoveredDevices.keys.contains(peripheral.name!) {
			discoveredDevices.removeValue(forKey: peripheral.name!)
		}
		if !self.connectedFlutters.contains(where: { (k, v) in v.peripheral == peripheral }) {
			self.disconnect(peripheral: peripheral)
		}
	}
	
	/**
	* If we disconnected from a peripheral
	*/
	func centralManager(_ central: CBCentralManager,
	                    didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
		print("Error disconnecting: \(error)")
		
	}
	/**
	* We failed to connect to a peripheral, we could notify the user here?
	*/
	func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral,
	                    error: Error?) {
		
	}
	
	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		
		switch (central.centralManagerState) {
		case CBCentralManagerState.poweredOff:
			break
			
		case CBCentralManagerState.unauthorized:
			// Indicate to user that the iOS device does not support BLE.
			break
			
		case CBCentralManagerState.unknown:
			// Wait for another event
			break
			
		case CBCentralManagerState.poweredOn:
			//startScanning
			break
			
		case CBCentralManagerState.resetting:
			//nothing to do
			break
			
		case CBCentralManagerState.unsupported:
			break
		}
		
	}
	
	func disconnect(peripheral: CBPeripheral) {
		self.connectedFlutters.removeValue(forKey: peripheral.identifier.uuidString)
		centralManager.cancelPeripheralConnection(peripheral)
	}
	
	func connectToHummingbird(peripheral: CBPeripheral) -> HummingbirdPeripheral {
		centralManager?.connect(peripheral,
		                        options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey:
									NSNumber(value: true as Bool)])
		
		return HummingbirdPeripheral(peripheral: peripheral)
	}
	
	func connectToFlutter(peripheral: CBPeripheral) -> FlutterPeripheral {
		centralManager?.connect(peripheral,
		                        options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey:
									NSNumber(value: true as Bool)])
		
		let flutter = FlutterPeripheral(peripheral: peripheral)
		
		self.connectedFlutters[peripheral.identifier.uuidString] = flutter
		
		return flutter
	}
}
