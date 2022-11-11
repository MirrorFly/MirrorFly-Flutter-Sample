//
//  FlyMethodChannel.swift
//  Runner
//
//  Created by ManiVendhan on 10/11/22.
//

import Foundation

class FlyMethodChannel{
    
    static func prepareMethodHandler(methodChannel: FlutterMethodChannel){
        methodChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch call.method {
            case "register_user":
                FlySdkMethodCalls.registerUser(call: call, result: result)
            case "authtoken":
                FlySdkMethodCalls.refreshAndGetAuthToken(call: call, result: result)
            case "get_user_jid":
                FlySdkMethodCalls.getJid(call: call, result: result)
            case "send_text_msg":
                FlySdkMethodCalls.sendTextMessage(call: call, result: result)
            case "sentLocationMessage":
                FlySdkMethodCalls.sendLocationMessage(call: call, result: result)
            case "get_user_list":
                FlySdkMethodCalls.getUserList(call: call, result: result)
            case "getProfile":
                FlySdkMethodCalls.getUserProfile(call: call, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
            
        })
    }
    
    //get_image_path
    
}

