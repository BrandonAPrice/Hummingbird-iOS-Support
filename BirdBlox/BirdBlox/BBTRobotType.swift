//
//  BBTRobotType.swift
//  BirdBlox
//
//  Created by Kristina Lauwers on 5/2/18.
//  Copyright © 2018 Birdbrain Technologies LLC. All rights reserved.
//MB9680E MB9680E MB9680E

import Foundation
import CoreBluetooth

enum BBTRobotType {
    case Hummingbird, Flutter, Finch, HummingbirdBit, MicroBit, Hatchling
    
    //MARK: UUIDs
    //UUID for the BLE adapter
    var scanningUUID: CBUUID {
        switch self {
        case .Hummingbird, .Finch, .HummingbirdBit, .MicroBit:
            return CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
        case .Hatchling:
            return CBUUID(string: "BB37A001-B922-4018-8E74-E14824B3A638")
        case .Flutter: return CBUUID(string: "BC2F4CC6-AAEF-4351-9034-D66268E328F0")
        }
    }
    
    //UART Service UUID
    var SERVICE_UUID: CBUUID {
        switch self {
        case .Hummingbird, .Finch, .HummingbirdBit, .MicroBit:
            return CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
        case .Hatchling:
            return CBUUID(string: "BB37A001-B922-4018-8E74-E14824B3A638")
        case .Flutter: return CBUUID(string: "BC2F4CC6-AAEF-4351-9034-D66268E328F0")
        }
    }
    
    //sending
    var TX_UUID: CBUUID {
        switch self {
        case .Hummingbird, .Finch, .HummingbirdBit, .MicroBit:
            return CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
        case .Hatchling:
            return CBUUID(string: "bb37a002-b922-4018-8e74-e14824b3a638")
        case .Flutter: return CBUUID(string: "06D1E5E7-79AD-4A71-8FAA-373789F7D93C")
        }
    }
    
    //receiving
    var RX_UUID: CBUUID {
        switch self {
        case .Hummingbird, .Finch, .HummingbirdBit, .MicroBit:
            return CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
        case .Hatchling:
            return CBUUID(string: "bb37a003-b922-4018-8e74-e14824b3a638")
        case .Flutter: return CBUUID(string: "818AE306-9C5B-448D-B51A-7ADD6A5D314D")
        }
    }
    
    var RX_CONFIG_UUID: CBUUID {
        switch self {
        case .Hummingbird, .Finch, .HummingbirdBit, .MicroBit, .Hatchling:
            return CBUUID(string: "00002902-0000-1000-8000-00805f9b34fb")
        case .Flutter: return CBUUID(string: "00002902-0000-1000-8000-00805f9b34fb")
        }
    }
    
    //MARK: Firmware
    var minimumFirmware: String {
        return "2.2a"
    }
    
    var latestFirmware: String {
        return "2.2b"
    }
    
    //MARK: Battery Thresholds
    var batteryVoltageIndex: Int? {
        switch self{
        case .Hummingbird: return 4
        case .HummingbirdBit: return 3
        case .Finch: return 6
        case .Flutter, .MicroBit: return nil
        case .Hatchling: return 2
        }
    }
    var rawToBatteryVoltage: Double {
        switch self {
        case .Finch: return 0.00937
        default: return 0.0406
        }
    }
    var batteryConstant: Double { //value to add to raw before conversion
        switch self {
        case .Finch: return 320
        default: return 0
        }
    }
    var batteryGreenThreshold: Double? { //battery must be > this value for green status
        switch self {
        case .HummingbirdBit, .Hummingbird: return 4.75
        case .Finch, .Hatchling: return 3.51375 //3.385
        case .Flutter, .MicroBit: return nil
        }
    }
    var batteryYellowThreshold: Double? { //battery must be > this value for yellow status
        switch self {
        //case .HummingbirdBit, .Hummingbird: return 4.63
        case .HummingbirdBit: return 4.4
        case .Finch, .Hatchling: return 3.3732 //3.271
        case .Hummingbird: return 4.63
        case .Flutter, .MicroBit: return nil
        }
    }
    
    
    //MARK: Outputs
    var triledCount: UInt {
        switch self {
        case .Hummingbird: return 2
        case .Flutter: return 2
        case .Finch: return 5 //Beak, then tail
        case .HummingbirdBit: return 2
        case .MicroBit: return 0
        case .Hatchling: return 6
        }
    }
    var ledCount: UInt {
        switch self {
        case .Hummingbird: return 4
        case .Flutter: return 0
        case .Finch: return 0
        case .HummingbirdBit: return 3
        case .MicroBit: return 0
        case .Hatchling: return 6
        }
    }
    var servoCount: UInt {
        switch self {
        case .Hummingbird: return 4
        case .Flutter: return 3
        case .Finch: return 0
        case .HummingbirdBit: return 4
        case .MicroBit: return 0
        case .Hatchling: return 6
        }
    }
    var motorCount: UInt {
        switch self {
        case .Hummingbird: return 2
        case .Flutter: return 0
        case .Finch: return 2
        case .HummingbirdBit: return 0
        case .MicroBit: return 0
        case .Hatchling: return 0
        }
    }
    var vibratorCount: UInt {
        switch self {
        case .Hummingbird: return 2
        case .Flutter: return 0
        case .Finch: return 0
        case .HummingbirdBit: return 0
        case .MicroBit: return 0
        case .Hatchling: return 0
        }
    }
    var buzzerCount: UInt {
        switch self {
        case .Hummingbird: return 0
        case .Flutter: return 1
        case .Finch: return 1
        case .HummingbirdBit: return 1
        case .MicroBit: return 1
        case .Hatchling: return 1
        }
    }
    var ledArrayCount: UInt {
        switch self {
        case .Hummingbird, .Flutter: return 0
        case .Finch, .HummingbirdBit, .MicroBit, .Hatchling: return 1
        }
    }
    var pinCount: UInt {
        switch self {
        case .Hummingbird, .Flutter, .Finch, .HummingbirdBit, .Hatchling: return 0
        case .MicroBit: return 3
        }
    }
    
    //MARK: Inputs
    var sensorPortCount: UInt {
        switch self {
        case .Hummingbird: return 4
        case .HummingbirdBit, .MicroBit: return 3
        case .Finch, .Flutter: return 0
        case .Hatchling: return 6
        }
    }
    var accXindex: Int {
        switch self {
        case .HummingbirdBit, .MicroBit: return 4
        case .Finch: return 13
        case .Hummingbird, .Flutter: return 0 //not used
        case .Hatchling: return 3
        }
    }
    var buttonShakeIndex: Int {
        switch self {
        case .HummingbirdBit, .MicroBit: return 7
        case .Finch: return 16
        case .Hummingbird, .Flutter: return 0 //not used
        case .Hatchling: return 6
        }
    }
    
    //MARK: Strings
    var description: String {
        switch self {
        case .Hummingbird: return "Duo"
        case .Flutter: return "Flutter"
        case .Finch: return "Finch"
        case .HummingbirdBit: return "Bit"
        case .MicroBit: return "micro:bit"
        case .Hatchling: return "Hatch"
        }
    }
    
    static func fromString(_ s: String) -> BBTRobotType? {
        //Hatchling has a different service uuid and does not follow the regular naming conventions.
        #if HATCHLING
        return .Hatchling
        #endif
        //Usually should determine type from the first 2 letters of the
        //peripheral name.
        switch s.prefix(2) {
        case "BB": return .HummingbirdBit
        case "MB": return .MicroBit
        case "FN": return .Finch
        case "HB", "HM": return .Hummingbird
        case "FL": return .Flutter
        case "HL": return .Hatchling
        default:
            switch s {
            case "hummingbird",
                 "Hummingbird":
                return .Hummingbird
            case "Flutter",
                 "flutter",
                 "fl":
                return .Flutter
            case "Finch",
                 "finch":
                return .Finch
            case "HummingbirdBit",
                 "hummingbirdbit":
                return .HummingbirdBit
            case "MicroBit",
                 "microbit":
                return .MicroBit
            case "Hatchling",
                "hatchling":
                return .Hatchling
            default:
                return nil
            }
        }
    }
    
    //MARK: Sensor polling
    //func sensorCommand(_ commandName: String) -> Data {
    func sensorCommand(_ commandName: String) -> [UInt8] {
        var letter: UInt8 = 0
        var num: UInt8 = 0
        
        switch self {
        case .Hummingbird:
            letter = 0x47
            if commandName == "pollStart" {
                num = getUnicode(UInt8(5))
            } else { num = getUnicode(UInt8(6)) } //pollStop
        case .Flutter: ()
        case .Finch, .HummingbirdBit, .MicroBit, .Hatchling:
            letter = 0x62
            if commandName == "pollStart" {
                num = 0x67
            } else if commandName == "V2pollStart" {
                num = 0x70
            } else { num = 0x73 }//pollStop
        }
        //return Data(bytes: UnsafePointer<UInt8>([letter,num] as [UInt8]), count: 2)
        return [letter, num]
    }
    var sensorByteCount: Int {
        switch self {
        case .Hummingbird: return 5
        case .Flutter: return 1
        case .Finch: return 20
        case .HummingbirdBit: return 16 //14 for V1
        case .MicroBit: return 16 //14 for V1
        case .Hatchling: return 512 //Hatchling returns much more than sensor data.
        }
    }
    
    //MARK: output commands
    /*func ledCommand(_ port: UInt8, intensity: UInt8) -> Data? {
        let bounded_intensity = bound(intensity, min: 0, max: 100)
        let real_intensity = UInt8(floor(Double(bounded_intensity)*2.55))
        switch self {
        case .Hummingbird:
            let real_port: UInt8 = getUnicode(port-1)
            let letter: UInt8 = 0x4C
            return Data(bytes: UnsafePointer<UInt8>([letter, real_port, real_intensity] as [UInt8]), count: 3)
        case .HummingbirdBit:
            //TODO: Test this
            let letter: UInt8 = 0xC0 + port
            return Data(bytes: UnsafePointer<UInt8>([letter, real_intensity, 0xFF, 0xFF] as [UInt8]), count: 4)
        case .Finch, .Flutter, .MicroBit: return nil
        }
    }*/
    
    /*func triLEDCommand (_ port: UInt8, red_val: UInt8, green_val: UInt8, blue_val: UInt8) ->Data? {
        let bounded_red = bound(red_val, min: 0, max: 100)
        let real_red = UInt8(floor(Double(bounded_red)*2.55))
        let bounded_green = bound(green_val, min: 0, max: 100)
        let real_green = UInt8(floor(Double(bounded_green)*2.55))
        let bounded_blue = bound(blue_val, min: 0, max: 100)
        let real_blue = UInt8(floor(Double(bounded_blue)*2.55))
        switch self {
        case .Hummingbird:
            let real_port: UInt8 = getUnicode(port-1)
            let letter: UInt8 = 0x4F
            return Data(bytes: UnsafePointer<UInt8>([letter, real_port, real_red, real_green, real_blue] as [UInt8]), count: 5)
        case .HummingbirdBit:
        //TODO: Test this
            let letter: UInt8 = 0xC4 + port
            return Data(bytes: UnsafePointer<UInt8>([letter, real_red, real_green, real_blue] as [UInt8]), count: 4)
        case .Finch:
            //TODO: Test
            //Beak
            return Data(bytes: UnsafePointer<UInt8>([0xD0, real_red, real_green, real_blue, 0xFF, 0xFF, 0xFF] as [UInt8]), count: 7)
        case .Flutter:
            return nil
        case .MicroBit: return nil
            
        }
    }*/
    
    /*func motorCommand (_ port: UInt8, speed: Int) -> Data? {
        
        switch self {
        case .Hummingbird:
            var direction: UInt8 = 0
            let real_port: UInt8 = getUnicode(port-1)
            let letter: UInt8 = 0x4D
            var real_speed: UInt8 = 0
            let bounded_speed: Int = bound(abs(speed), min: 0, max: 100)
            if (speed < 0){
                direction = 1
                real_speed = UInt8(floor(Double(bounded_speed)*2.55))
            }
            else{
                real_speed = UInt8(floor(Double(bounded_speed)*2.55))
            }
            let real_direction: UInt8 = getUnicode(direction)
            return Data(bytes: UnsafePointer<UInt8>([letter, real_port, real_direction, real_speed] as [UInt8]), count: 4)
        case .Finch:
        //TODO: implement something here
            //0xD2, L_Dir--Speed(0-100), L_TicksMSB, L_TicksLSB, R_Dir--Speed(0-100), R_TicksMSB, R_TicksLSB
            return nil
        case .Flutter, .HummingbirdBit, .MicroBit: return nil
        }
    }*/
    
    /*func vibrationCommand(_ port: UInt8, intensity: UInt8) -> Data? {
        switch self{
        case .Hummingbird:
            let real_port: UInt8 = getUnicode(port-1)
            let letter: UInt8 = 0x56
            let bounded_intensity = bound(intensity, min: 0, max: 100)
            let real_intensity: UInt8 = UInt8(floor(Double(bounded_intensity)*2.55))
            return Data(bytes: UnsafePointer<UInt8>([letter, real_port, real_intensity] as [UInt8]), count: 3)
        case .Flutter, .Finch, .HummingbirdBit, .MicroBit: return nil
        }
    }*/
    
    /*func servoCommand(_ port: UInt8, angle: UInt8) -> Data? {
        switch self{
        case .Hummingbird://TODO: fix this? scaled when message received
            let real_port: UInt8 = getUnicode(port-1)
            let letter: UInt8 = 0x53
            let bounded_angle = bound(angle, min: 0, max: 180)
            let real_angle = UInt8(floor(Double(bounded_angle)*1.25))
            return Data(bytes: UnsafePointer<UInt8>([letter, real_port, real_angle] as [UInt8]), count: 3)
        case .HummingbirdBit:
        //TODO: implement something here
            return nil
        case .Flutter:
            return nil
        case .Finch, .MicroBit: return nil
        }
    }*/
    
    /*func buzzerCommand(period: UInt16, dur: UInt16) -> Data? {
        var letter: UInt8 = 0
        switch self{
        case .Finch:
            letter = 0xD3
        case .HummingbirdBit:
            letter = 0xCD
        case .Flutter, .Hummingbird, .MicroBit: ()
        }
        switch self{
        case .Flutter:
        //TODO:
            return nil
        case .HummingbirdBit, .Finch: //TODO: test
            let buzzer = BBTBuzzer(period: period, duration: dur)
            let buzzerArray = buzzer.array()
            return Data(bytes: UnsafePointer<UInt8>([letter, buzzerArray[0], buzzerArray[1], buzzerArray[2], buzzerArray[3]] as [UInt8]), count: 5)
        case .Hummingbird, .MicroBit: return nil
        }
    }*/
    
    //func ledArrayCommand(_ status: String) -> Data? {
    func ledArrayCommand(_ status: String) -> [UInt8]? {
   
        switch self {
        case .Hummingbird, .Flutter: return nil
        case .HummingbirdBit, .Finch, .MicroBit, .Hatchling:
            let letter: UInt8 = 0xCC
            let ledStatusChars = Array(status)
            
            switch ledStatusChars[0] {
            case "S": //Set a symbol
                let symbol: UInt8 = 0x80
                
                var led8to1String = ""
                for i in 1 ..< 9 {
                    led8to1String = String(ledStatusChars[i]) + led8to1String
                }
        
                var led16to9String = ""
                for i in 9 ..< 17 {
                    led16to9String = String(ledStatusChars[i]) + led16to9String
                }
                
                var led24to17String = ""
                for i in 17 ..< 25 {
                    led24to17String = String(ledStatusChars[i]) + led24to17String
                }
                
                guard let leds8to1 = UInt8(led8to1String, radix: 2),
                    let led16to9 = UInt8(led16to9String, radix: 2),
                    let led24to17 = UInt8(led24to17String, radix: 2),
                    let led25 = UInt8(String(ledStatusChars[25])) else {
                        return nil
                }
                
                NSLog("Symbol command \([letter, symbol, led25, led24to17, led16to9, leds8to1])")
                //return Data(bytes: UnsafePointer<UInt8>([letter, symbol, led25, led24to17, led16to9, leds8to1] as [UInt8]), count: 6)
                return [letter, symbol, led25, led24to17, led16to9, leds8to1]
                
            case "F": //flash a string
                let length = ledStatusChars.count - 1
                let flash = UInt8(64 + length)
                var commandArray = [letter, flash]
                if (length > 0) {
                    for i in 1 ... length {
                        commandArray.append(getUnicode(ledStatusChars[i]))
                    }
                }
                
                NSLog("Flash command \(commandArray)")
                //return Data(bytes: UnsafePointer<UInt8>(commandArray), count: length + 2)
                return commandArray
            default: return nil
            }
        }
    }
    
    //func clearLedArrayCommand() -> Data? {
    func clearLedArrayCommand() -> [UInt8]? {
        //To stop flashing or clearing the screen use
        //0xCC 0x00 0xFF 0xFF 0xFF
        switch self {
        case .Finch, .HummingbirdBit, .MicroBit, .Hatchling:
            //return Data(bytes: UnsafePointer<UInt8>([0xCC, 0x00, 0xFF, 0xFF, 0xFF] as [UInt8]), count: 5)
            return [0xCC, 0x00, 0xFF, 0xFF, 0xFF]
        case .Flutter, .Hummingbird: return nil
        }
    }
    
    //func turnOffCommand() -> Data{
    func turnOffCommand() -> [UInt8] {
        switch self {
        case .Hummingbird, .Flutter:
            let letter: UInt8 = 0x58
            //return Data(bytes: UnsafePointer<UInt8>([letter] as [UInt8]), count: 1)
            return [letter]
        case .HummingbirdBit:
            let letter: UInt8 = 0xCB
            //return Data(bytes: UnsafePointer<UInt8>([letter, 0xFF, 0xFF, 0xFF] as [UInt8]), count: 4)
            return [letter, 0xFF, 0xFF, 0xFF]
        case .Finch, .Hatchling:
            //return Data(bytes: UnsafePointer<UInt8>([0xDF] as [UInt8]), count: 1)
            return [0xDF]
        case .MicroBit:
            //return Data(bytes: UnsafePointer<UInt8>([0xCB, 0xFF, 0xFF, 0xFF] as [UInt8]), count: 4)
            return [0xCB, 0xFF, 0xFF, 0xFF]
        }
    }
    
    //MARK: Other commands
    //func calibrateMagnetometerCommand() -> Data? {
    func calibrateMagnetometerCommand() -> [UInt8]? {
        //Calibrate Magnetometer: 0xCE 0xFF 0xFF 0xFF
        switch self {
        case .HummingbirdBit, .MicroBit, .Finch, .Hatchling:
            //return Data(bytes: UnsafePointer<UInt8>([0xCE, 0xFF, 0xFF, 0xFF] as [UInt8]), count: 4)
            return [0xCE, 0xFF, 0xFF, 0xFF]
        case .Flutter, .Hummingbird: return nil
        }
    }
    
    //func resetEncodersCommand() -> Data? {
    func resetEncodersCommand() -> [UInt8]? {
        switch self {
        case .Finch:
            //return Data(bytes: UnsafePointer<UInt8>([0xD5] as [UInt8]), count: 1)
            return [0xD5]
        case .HummingbirdBit, .MicroBit, .Flutter, .Hummingbird, .Hatchling: return nil
        }
    }
    
    //func hardwareFirmwareVersionCommand() -> Data? {
    func hardwareFirmwareVersionCommand() -> [UInt8]? {
        switch self {
        case .Hummingbird:
            //return "G4".data(using: .utf8)!
            return Array("G4".utf8)
        case .HummingbirdBit, .MicroBit, .Hatchling:
            //return Data(bytes: UnsafePointer<UInt8>([0xCF, 0xFF, 0xFF, 0xFF] as [UInt8]), count: 4)
            return [0xCF, 0xFF, 0xFF, 0xFF]
        case .Finch:
            //return Data(bytes: UnsafePointer<UInt8>([0xD4] as [UInt8]), count: 1)
            return [0xD4]
        case .Flutter: return nil
        }
    }
}
