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

// SEND OUT NOTIFICATIONS PER FAILURE EVENT...
// the notifications will only send a boolean as the object... true if the attempt succeeded, false if not
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
        return Array(byteArray.prefix(Int(len)))
    }
    
    @objc static func ConnectToDevice(_ mac: String, state: Bool) { //0x12 - register device
        let client = TCPClient(address: "api.swiftechie.com", port: Int32(7799))
        switch client.connect(timeout: 10) {
        case .success:
            print("Connected to host \(client.address)")
            if let response = TCPHelper.sendRequest(using: client, mac: mac, state:state) {
                print("Response:")
                print(response)
                if (response[1] == 0x02) {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "0x12"), object: NSNumber.init(value: false))
                }
                else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "0x12"), object: NSNumber.init(value: true))
                }
            }
        case .failure(let error):
            print(String(describing: error))
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "0x12"), object: NSNumber.init(value: false))
        }
        client.close()
    }
    
    @objc static func ReadData(_ mac: String) { //0x11 - request data
        let client = TCPClient(address: "api.swiftechie.com", port: Int32(7799))
        switch client.connect(timeout: 10) {
        case .success:
            print("Connected to host \(client.address)")
            if let response = TCPHelper.sendRequestTwo(using: client, mac: mac) {
                print("Response received.")
                //print(response)
            }
        case .failure(let error):
            print(String(describing: error))
        }
        client.close()
    }
    
    @objc static func KillData(_ mac: String) { //0x14 - net clear
        print("[LOG] NetClear function called...");
        let client = TCPClient(address: "api.swiftechie.com", port: Int32(7799))
        switch client.connect(timeout: 10) {
        case .success:
            print("Connected to host \(client.address)")
            if let response = TCPHelper.sendRequestThree(using: client, mac: mac) {
                print("Response:")
                print(response)
            }
        case .failure(let error):
            print(String(describing: error))
        }
        client.close()
    }
    
    @objc static func DeviceSecretMode(_ mac: String, state: Bool) { //0x12 - register device
        let client = TCPClient(address: "api.swiftechie.com", port: Int32(7799))
        switch client.connect(timeout: 10) {
        case .success:
            print("Connected to host \(client.address)")
            if let response = TCPHelper.sendRequestFour(using: client, mac: mac, state: state) {
                print("Response:")
                print(response)
                if (response[1] == 0x02) {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "0x12"), object: NSNumber.init(value: false))
                }
                else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "0x12"), object: NSNumber.init(value: true))
                }
            }
        case .failure(let error):
            print(String(describing: error))
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "0x12"), object: NSNumber.init(value: false))
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
    
    static private func sendRequest(using client: TCPClient, mac: String, state: Bool) -> Array<Byte>? {
        print("Sending data ... ")
        var bit:[Byte] = []
        if (state) {
            bit = [0x01]
        }
        else {
            bit = [0x02]
        }
        var cmd:[Byte] = [0x12] + TCPHelper.asciiToHex(ascii: mac, len: 12) + // command id
            bit +
            TCPHelper.asciiToHex(ascii: UserDefaults.standard.string(forKey: "userID")!, len: 20) + // userid
            [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] // org -- actually curious if the organization does anything. it does not seem as though this affects 秘密モード so i'm not entirely sure what this is supposed to do...
        switch client.send(data: cmd) {
        case .success:
            print("Got a response...")
            return TCPHelper.readResponse(from: client)
        case .failure(let error):
            print("Error: " + String(describing: error))
            return nil
        }
    }
    
    static private func sendRequestTwo(using client: TCPClient, mac: String) -> Array<Byte>? {
        print("Sending data ... ")
        var cmd:[Byte] = [0x11] + TCPHelper.asciiToHex(ascii: mac, len: 12) + // command
            TCPHelper.asciiToHex(ascii: UserDefaults.standard.string(forKey: "userID")!, len: 20) + // userid
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
    
    static private func sendRequestThree(using client: TCPClient, mac: String) -> Array<Byte>? {
        print("Sending data ... ")
        var cmd:[Byte] = [0x14] + TCPHelper.asciiToHex(ascii: mac, len: 12)
        switch client.send(data: cmd) {
        case .success:
            print("Got a response...")
            return TCPHelper.readResponse(from: client)
        case .failure(let error):
            print("Error: " + String(describing: error))
            return nil
        }
    }
    
    static private func sendRequestFour(using client: TCPClient, mac: String, state: Bool) -> Array<Byte>? {
        print("Sending data ... ")
        var lastBit:[Byte] = []
        if (state == true) {
            print("Secret mode on!")
            lastBit = [0x01]
        }
        else {
            print("Secret mode off!")
            lastBit = [0x02]
        }
        var cmd:[Byte] = [0x15] + TCPHelper.asciiToHex(ascii: mac, len: 12) + // command
            TCPHelper.asciiToHex(ascii: UserDefaults.standard.string(forKey: "userID")!, len: 20) + // userid
        lastBit
        switch client.send(data: cmd) {
        case .success:
            print("Got a response...")
            return TCPHelper.parseWeightData(data: TCPHelper.readResponse(from: client)!)
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
    // REWRITE THIS to return an array of an array of strings...
    static private func parseWeightData(data: Array<Byte>) -> Array<Byte>? {
        
        //var byteCount : Array<Byte> = [0x00, 0x00, 0x00, data[1]]
        //var number = byteArrayToInt(bytes: byteCount)   -- we can skip using the second byte as a counter, because... we know that the data will always be sent over in groups of 11.
        let instance = HTPeopleGeneral()
        var x = 2
        var myData : Array<Array<String>> = []
        while x < data.count {
            var dataSet : Array<String> = []
            let dateBytes : Array<Byte> = [data[x], data[x+1],data[x+2],data[x+3]]
            let impedanceBytes : Array<Byte> = [data[x+4], data[x+5],data[x+6],data[x+7]]
            let weightBytes : Array<Byte> = [0x00,0x00,data[x+8],data[x+9]]
            let timestamp = byteArrayToInt(bytes: dateBytes)
            let date = unixTimeToNSDate(time: timestamp)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = formatter.string(from: date as Date)
            let impedance = byteArrayToInt(bytes: impedanceBytes)
            let weight = CGFloat(byteArrayToInt(bytes: weightBytes)) / 10
            let fat = instance.getBodyfatWithweightKg(weight, heightCm: 168, sex: HTSexType.male, age: 30, impedance: Int(impedance))
            print("DATA:")
            dataSet.append(dateString)
            dataSet.append(weight.description)
            print(date)
            print(weight)
            var myFat : String
            switch(fat) {
            case HTBodyfatErrorType.none:
                print(instance.htBodyfatPercentage)
                let fatRounded = Double(round(instance.htBodyfatPercentage * 100)/100)
                // round to two decimal places
                myFat = String(fatRounded)
                break
            case HTBodyfatErrorType.age:
                // age outside 6-99 y/o range
                myFat = "(エラー：年齢)"
                break
            case HTBodyfatErrorType.impedance:
                // unexpected impedance value (e.g., wearing socks)
                myFat = "(エラー：電気抵抗)"
                break
            case HTBodyfatErrorType.weight:
                // weight outside 50-200kg range
                myFat = "(エラー：体重)"
                break
            default:
                // unidentified error type
                myFat = "(エラー：未確認)"
            }
            dataSet.append(myFat)
            myData.append(dataSet)
            
            x+=11
        }
        UserDefaults.standard.set(myData, forKey: "dataSet")
        return data
    }
    
}

