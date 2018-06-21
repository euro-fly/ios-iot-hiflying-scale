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

    static func asciiToHex(ascii: String) -> Array<Byte> {
        var byteArray = [Byte]()
        //let array = ascii.ascii
        for x in ascii.utf8 {
            byteArray += [x]
        }
        return byteArray
        
    }
    
    @objc static func ConnectToDevice() {
        let client = TCPClient(address: "api.swiftechie.com", port: Int32(7799))
        switch client.connect(timeout: 10) {
        case .success:
            print("Connected to host \(client.address)")
            if let response = TCPHelper.sendRequest(string: "GET / HTTP/1.0\n\n", using: client) {
                print("Response:")
                print(response)
            }
        case .failure(let error):
            print(String(describing: error))
        }
        
    }

    static private func sendRequest(string: String, using client: TCPClient) -> String? {
        print("Sending data ... ")
        var cmd:[Byte] = [0x12] + TCPHelper.asciiToHex(ascii: "F0FE6B790583") + // command id
            [0x01, // type: 0x01:register   0x02:unregister
                0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // userid
                0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] // org
        switch client.send(data: cmd) {
        case .success:
            print("Got a response...")
            return TCPHelper.readResponse(from: client)
        case .failure(let error):
            print("Error: " + String(describing: error))
            return nil
        }
    }
    
    static private func readResponse(from client: TCPClient) -> String? {
        let response = client.read(1024*10, timeout: 10)
        print("Read response...")
        
        let res = response == nil ? -1 : Int(response![1])
        print(response as Any)
        return String(bytes: response!, encoding: .utf8)
    }
    
}

