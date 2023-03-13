//
//  UserDefaults.swift
//  MirrorFly
//
//  Created by User on 18/05/21.
//

import UIKit
import FlyCommon
import FlyCore
import Alamofire
import CommonCrypto
import FlyCore

class Utility: NSObject{
    
    class func saveInPreference (key : String , value : Any) {
        var stringaValue = ""
        if let boolString = value as? Bool{
            stringaValue = boolString ? "true" : "false"
        }else if let value = value as? String{
            stringaValue  = value
        }
        if let encryptedData = encryptDecryptFlyDefaults(key: key, data:  Data(stringaValue.utf8), encrypt: true){
            UserDefaults.standard.setValue(encryptedData, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
    
    class func getStringFromPreference(key : String) -> String {
        if let value =  UserDefaults.standard.object(forKey: key) {
            if let encryptedData = value as? Data{
                if let decryptedData = encryptDecryptFlyDefaults(key: key, data:  encryptedData, encrypt: false){
                    return String(data: decryptedData, encoding: .utf8)!
                }
            }else if let oldValue = value as? String {
                saveInPreference(key: key, value: oldValue)
                return oldValue
            }
        }
        return ""
    }
    
    class func getBoolFromPreference(key : String) -> Bool {
        if let value = UserDefaults.standard.object(forKey: key) {
            if let encryptedData =  value as? Data{
                if let decryptedData = encryptDecryptFlyDefaults(key: key, data:  encryptedData, encrypt: false){
                    return (String(data: decryptedData, encoding: .utf8)! == "true" )
                }
            } else if let oldValue = value as? Bool {
                saveInPreference(key: key, value: oldValue)
                return oldValue
            }
        }
        return false
    }
    
   

    public class func refreshToken(onCompletion: @escaping (_ isSuccess: Bool) -> Void) {
        ChatManager.refreshToken { isSuccess, error, data in
            onCompletion(isSuccess)
        }
    }

  
    
    public static func generateUniqueId() -> String {
        return UUID.init().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
    }
    
    
    class func clearUserDefaults(){
        let defaults = UserDefaults.standard
        let dictionary =  defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
    class func encryptDecryptFlyDefaults(key:String, data : Data, encrypt : Bool, iv : String = "ddc0f15cc2c90fca") -> Data?{
        guard let key = FlyEncryption.sha256(key, length: 32) else {
            return data
        }
        guard let flyEncryption = FlyEncryption(encryptionKey: key, initializationVector: iv ) else {
            return data
        }
        
        if encrypt {
            guard let encryptedData  = flyEncryption.crypt(data: data, option: CCOperation(kCCEncrypt)) else {
                return data
            }
            print("#ud encrypt \(key)  \(encryptedData)")
            return encryptedData
        } else {
            guard let decryptedData  = flyEncryption.crypt(data: data, option:  CCOperation(kCCDecrypt)) else {
                return nil
            }
            print("#ud decrypt \(key)  \(decryptedData)")
            return decryptedData
        }
    }
    
}
