//
//  FlySDKMethodCalls.swift
//  Runner
//
//  Created by User on 10/11/22.
//

import Foundation
import FlyCore
import FlyCommon
import Flutter

class FlySdkMethodCalls{
    
    static func registerUser(call: FlutterMethodCall, result: @escaping FlutterResult){

        let args = call.arguments as! Dictionary<String, Any>
        
        let userIdentifier = args["userIdentifier"] as? String ?? nil
        
        if(userIdentifier == nil){
            result(FlutterError(code: "500",
                                message: "User Name is Empty",
                                    details: nil))
            return
        }
        
        try! ChatManager.registerApiService(for:  userIdentifier!) { isSuccess, flyError, flyData in
                var data = flyData
                if isSuccess {

                    print("Register Response")
                
                    let firstCategory = [
                        "data": data,
                        "is_new_user": data["newLogin"],
                        "message" : "Register Trial API Success"
                    ] as [String : Any]
                    
                    result(Commons.json(from: firstCategory))
                    
                }else{
                    let error = data.getMessage()
                    result(FlutterError(code: "500",
                                        message: error as? String,
                                            details: nil))
                    print("#chatSDK \(error)")
                }
            }
    }
    
    static func refreshAndGetAuthToken(call: FlutterMethodCall, result: @escaping FlutterResult){
        //Need to check iOS Side.
    }
    static func getJid(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        let userName = args["username"] as! String
        if(userName == nil){
            result(FlutterError(code: "500",
                                message: "User Name is Empty",
                                    details: nil))
            return
        }
        do{
            try result(FlyUtils.getJid(from: userName))
        }catch let jidError{
            result(FlutterError(code: "500", message: "Unable to get JID", details: jidError.localizedDescription))
        }
        
    }
    
    
    static func sendTextMessage(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        let txtMessage = args["message"] as? String ?? nil
        let receiverJID = args["JID"] as? String ?? nil
        let replyMessageID = args["replyMessageId"] as? String ?? ""
        
        if(txtMessage == nil || receiverJID == nil){
            result(FlutterError(code: "500", message: "Parameters Missing", details: nil))
            return
        }
        
        FlyMessenger.sendTextMessage(toJid: receiverJID!, message: txtMessage!, replyMessageId: replyMessageID) { isSuccess,error,chatMessage in
             if isSuccess {
                 result(Commons.json(from: chatMessage as Any))
             }else{
                 result(FlutterError(code: "500", message: Commons.json(from: error as Any), details: nil))
             }
         }

    }
    
    static func sendLocationMessage(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        let latitude = args["latitude"] as? Double ?? 00.0
        let longitude = args["longitude"] as? Double ?? 00.0
        let userJid = args["jid"] as? String ?? nil
        let replyMessageID = args["replyMessageId"] as? String ?? ""
        
        if(latitude == 00.0 || longitude == 00.0){
            result(FlutterError(code: "500", message: "Location is Empty", details: nil))
            return
        }
        if(userJid == nil){
            result(FlutterError(code: "500", message: "Location is Empty", details: nil))
            return
        }
        
        FlyMessenger.sendLocationMessage(toJid: userJid!, latitude: latitude, longitude: longitude, replyMessageId: replyMessageID) { isSuccess,error,chatMessage in
             if isSuccess {
                 result(Commons.json(from: chatMessage as Any))
             }else{
                 result(FlutterError(code: "500", message: Commons.json(from: error as Any), details: nil))
             }
         }
    }
    
    static func getUserList(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let pageNumber = args["page"] as? Int ?? 1
        let searchTerm = args["search"] as? String ?? ""
        
        ContactManager.shared.getUsersList(pageNo: pageNumber, pageSize: 20, search: searchTerm){ isSuccess,flyError,flyData in
            if isSuccess {
                result(Commons.json(from: flyData as Any))
            }else{
                result(FlutterError(code: "500", message: Commons.json(from: flyError as Any), details: nil))
            }
        }
        
    }
    
    static func verifyToken(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let userName = args["userName"] as? String
        let token = args["googleToken"] as? String ?? ""
        
        result("")
        
    }
    
    static func getUserProfile(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let jid = args["jid"] as? String ?? nil
        let server = args["server"] as? Bool ?? false
        
        try? ContactManager.shared.getUserProfile(for: jid!,fetchFromServer: server,saveAsFriend: false){ isSuccess, flyError, flyData in
          
                if isSuccess {
//                      let profileDetail = data.getData() as! [ProfileDetails]
                    result(Commons.json(from: flyData as Any))
                } else{
                      print(flyError!.localizedDescription)
                    result(FlutterError(code: "500", message: flyError!.localizedDescription, details: nil))
                }
        }
        
    }
    
   
}
