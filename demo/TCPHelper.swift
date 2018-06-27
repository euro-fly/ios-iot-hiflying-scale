import UIKit
import Foundation
import SwiftSocket

extension StringProtocol {
    var ascii: [UInt32] {
        return unicodeScalars.filter{$0.isASCII}.map{$0.value}
    }
}
extension Character {
    var ascii: UInt32? {
        return String(self).unicodeScalars.filter{$0.isASCII}.first?.value
    }
}

@objc class TCPHelper: NSObject {

    //var client: TCPClient?
    static func asciiToHex(ascii: String, len: Int32) -> Array<Byte> {
        var byteArray = [Byte]()
        //let array = ascii.ascii
        for x in ascii.utf8 {
            byteArray += [x]
        }
        while (byteArray.count < len) {
            byteArray += [0x00]
        }
        return byteArray
    }
    
    @objc static func ConnectToDevice() {
        let client = TCPClient(address: "api.swiftechie.com", port: Int32(7799))
        switch client.connect(timeout: 10) {
        case .success:
            print("Connected to host \(client.address)")
            if let response = TCPHelper.sendRequest(using: client) {
                print("Response:")
                print(response)
            }
        case .failure(let error):
            print(String(describing: error))
        }
        client.close()
    }
    
    @objc static func ReadData() {
        let client = TCPClient(address: "api.swiftechie.com", port: Int32(7799))
        switch client.connect(timeout: 10) {
        case .success:
            print("Connected to host \(client.address)")
            if let response = TCPHelper.sendRequestTwo(using: client) {
                print("Response received.")
                //print(response)
            }
        case .failure(let error):
            print(String(describing: error))
        }
        client.close()
    }
    
    @objc static func KillData() {
        let client = TCPClient(address: "api.swiftechie.com", port: Int32(7799))
        switch client.connect(timeout: 10) {
        case .success:
            print("Connected to host \(client.address)")
            if let response = TCPHelper.sendRequestThree(using: client) {
                print("Response:")
                print(response)
            }
        case .failure(let error):
            print(String(describing: error))
        }
        client.close()
    }
    
    static private func unixTimeToNSDate(time: Int32) -> NSDate {
        return NSDate(timeIntervalSince1970: Double(time))
    }
    
    static private func NSDateToUnixTime(date: NSDate) -> [Byte] {
        var unixTime = date.timeIntervalSince1970
        var array: [UInt8] = []
        var n = Int32(unixTime)
        while n > 0
        {
            array.append(UInt8(n & 0xff))
            n >>= 8
        }
        return array
    }
    
    static private func byteArrayToInt(bytes: Array<Byte>) -> Int32 {
        let array = bytes
        let data = Data(bytes: array)
        let value = UInt32(bigEndian: data.withUnsafeBytes { $0.pointee })
        return Int32(value);
    }
    
    static private func sendRequest(using client: TCPClient) -> Array<Byte>? {
        print("Sending data ... ")
        var cmd:[Byte] = [0x12] + TCPHelper.asciiToHex(ascii: "F0FE6BAFB1DB", len: 12) + // command id
            [0x01] + // type: 0x01:register   0x02:unregister
            TCPHelper.asciiToHex(ascii: "152894137336597697", len: 20) + // userid
                [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] // org
        switch client.send(data: cmd) {
        case .success:
            print("Got a response...")
            return TCPHelper.readResponse(from: client)
        case .failure(let error):
            print("Error: " + String(describing: error))
            return nil
        }
    }
    
    static private func sendRequestTwo(using client: TCPClient) -> Array<Byte>? {
        print("Sending data ... ")
        var cmd:[Byte] = [0x11] + TCPHelper.asciiToHex(ascii: "F0FE6BAFB1DB", len: 12) + // command
            TCPHelper.asciiToHex(ascii: "152894137336597697", len: 20) + // userid
            [0x00, 0x00, 0x00, 0x00] // get ALL data...
        switch client.send(data: cmd) {
        case .success:
            print("Got a response...")
            return TCPHelper.parseWeightData(data: TCPHelper.readResponse(from: client)!)
        case .failure(let error):
            print("Error: " + String(describing: error))
            return nil
        }
    }
    
    static private func sendRequestThree(using client: TCPClient) -> Array<Byte>? {
        print("Sending data ... ")
        var cmd:[Byte] = [0x14] + TCPHelper.asciiToHex(ascii: "F0FE6BAFB1DB", len: 12)
        switch client.send(data: cmd) {
        case .success:
            print("Got a response...")
            return TCPHelper.readResponse(from: client)
        case .failure(let error):
            print("Error: " + String(describing: error))
            return nil
        }
    }
    
    static private func readResponse(from client: TCPClient) -> Array<Byte>? {
        let response = client.read(1024*10, timeout: 600)
        print("Read response...")
        let res = response == nil ? -1 : Int32(response![1])
        //print(response as Any)
        return response
    }
    
    //TODO: Parse the response data...
    //ASSUMING we only get the last weight data...
    static private func parseWeightData(data: Array<Byte>) -> Array<Byte>? {
    
        //var byteCount : Array<Byte> = [0x00, 0x00, 0x00, data[1]]
        //var number = byteArrayToInt(bytes: byteCount)   -- we can skip using the second byte as a counter, because... we know that the data will always be sent over in groups of 11.
        let instance = HTPeopleGeneral()
        var x = 2
        while x < data.count {
            let dateBytes : Array<Byte> = [data[x], data[x+1],data[x+2],data[x+3]]
            let impedanceBytes : Array<Byte> = [data[x+4], data[x+5],data[x+6],data[x+7]]
            let weightBytes : Array<Byte> = [0x00,0x00,data[x+8],data[x+9]]
            let timestamp = byteArrayToInt(bytes: dateBytes)
            let date = unixTimeToNSDate(time: timestamp)
            let impedance = byteArrayToInt(bytes: impedanceBytes)
            let weight = CGFloat(byteArrayToInt(bytes: weightBytes)) / 10
            let fat = instance.getBodyfatWithweightKg(weight, heightCm: 168, sex: HTSexType.male, age: 30, impedance: Int(impedance))
            print("DATA:")
            print(date)
            print(weight)
            switch(fat) {
            case HTBodyfatErrorType.none:
                print(instance.htBodyfatPercentage)
                break
            case HTBodyfatErrorType.age:
                print("Error occurred due to age being outside 6..99 range")
                break
            case HTBodyfatErrorType.impedance:
                print("Error occurred due to invalid impedance data.")
                break
            case HTBodyfatErrorType.weight:
                print("Error occurred due to weight being outside 50..200kg range")
                break
            default:
                print("An unexpected error occurred.")
            }
            x+=11
        }
        return data
    }
    
}

