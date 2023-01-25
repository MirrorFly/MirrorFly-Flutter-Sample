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
import Photos
import FlyDatabase
//import DSON

@objc class FlySdkMethodCalls : NSObject{
    
    
    static func registerUser(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        let args = call.arguments as! Dictionary<String, Any>
        
        let userIdentifier = args["userIdentifier"] as? String ?? nil
        
        
        let deviceToken = Utility.getStringFromPreference(key: googleToken)
        var voipToken = Utility.getStringFromPreference(key: voipToken)
        
        voipToken = voipToken.isEmpty ? deviceToken : voipToken
        
        if(userIdentifier == nil){
            result(FlutterError(code: "500",
                                message: "User Name is Empty",
                                details: nil))
            return
        }
        
        
        
        try! ChatManager.registerApiService(for:  userIdentifier!, deviceToken: deviceToken, voipDeviceToken: voipToken, isExport: false) { isSuccess, flyError, flyData in
            var data = flyData
            if isSuccess {
                
                print("Register Response")
                
                let registerResponse = [
                    "data": data,
                    "is_new_user": data["newLogin"] as Any,
                    "message" : "Register Trial API Success"
                ] as [String : Any]
                
                FlyDefaults.isLoggedIn = true
                Utility.saveInPreference(key: isLoggedIn, value: true)
                FlyDefaults.myXmppPassword = data["password"] as! String
                FlyDefaults.myXmppUsername = data["username"] as! String
                FlyDefaults.myMobileNumber = userIdentifier!
                FlyDefaults.isProfileUpdated = data["isProfileUpdated"] as! Int == 1
                
                
                ChatManager.connect()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                    result(Commons.json(from: registerResponse))
                }
                
                
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
        ChatManager.refreshToken { (isSuccess, flyError, resultDict) in
                  if (isSuccess) {
                      var resp = resultDict
                      let tokendata = resp.getData()
                      let refreshToken = tokendata as AnyObject
                      
                      let newToken = refreshToken["token"] as Any
                      
                      print("ios refreshAndGetAuthToken-->\(newToken)")
                      
                      result(newToken)
                   
                  } else {
                      result(FlutterError(code: "500", message: "Unable to refresh token", details: flyError?.description))

                  }
            }
    }
    
    static func getJid(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        let userName = args["username"] as? String
        if(userName == nil){
            result(FlutterError(code: "500",
                                message: "User Name is Empty",
                                details: nil))
            return
        }
        do{
            try result(FlyUtils.getJid(from: userName!))
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
                let chatMsg = JSONSerializer.toJson(chatMessage as Any)
                
                result(chatMsg)
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
                var locationResponse = JSONSerializer.toJson(chatMessage as Any)
                
                locationResponse = locationResponse.replacingOccurrences(of: "{\"some\":", with: "")
                locationResponse = locationResponse.replacingOccurrences(of: "}}", with: "}")
                print(locationResponse)
                
                result(locationResponse)
            }else{
                result(FlutterError(code: "500", message: Commons.json(from: error as Any), details: nil))
            }
        }
    }
    
    static func sendImageMessage(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        let userJid = args["jid"] as? String ?? nil
        let filePath = args["filePath"] as? String ?? ""
        let replyMessageId = args["replyMessageId"] as? String ?? ""
        
        let caption = args["caption"] as? String ?? ""
        print("====File Path====")
        
        print(filePath)
        print("====File Path====")
        
        let imagefileUrl = URL(fileURLWithPath: filePath)
        
        print("====imagefileUrl Path====")
        
        print(imagefileUrl)
        print("====imagefileUrl Path====")
        
        var selectedImage : UIImage?
        
        
        let selectedImageData = NSData(contentsOf: imagefileUrl)
        
        if(selectedImageData != nil){
            selectedImage = UIImage(data: selectedImageData! as Data)
        }else{
            print("Selected Image Data is null")
        }
        
        
        if(userJid == nil){
            result(FlutterError(code: "500", message: "Location is Empty", details: nil))
            return
        }
        
        var media = MediaData()
        
        if let (_, fileName ,localFilePath,fileKey,fileSize) = MediaUtils.compressImage(imageData : selectedImageData! as Data){
            print("#media size after \(fileSize)")
            media.mediaType = .image
            media.fileURL = localFilePath
            media.fileName = fileName
            media.fileSize = fileSize
            media.fileKey = fileKey
            media.base64Thumbnail = MediaUtils.convertImageToBase64(img: selectedImage!)
            media.caption = caption
            
        }
        
        FlyMessenger.sendImageMessage(toJid: userJid!, mediaData: media, replyMessageId: replyMessageId){isSuccess,error,message in
            if isSuccess {
                print("Send Image--->")
                print(message as Any)
                
                var response = JSONSerializer.toJson(message as Any)
                response = response.replacingOccurrences(of: "{\"some\":", with: "")
                response = response.replacingOccurrences(of: "}}", with: "}")
                print(response)
                result(response)
            }else{
                print("<---Send Image Failed--->")
            }
        }
    }
    
    static func sendAudioMessage(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        let userJid = args["jid"] as? String ?? ""
        let replyMessageId = args["replyMessageId"] as? String ?? ""
        let isRecorded = args["isRecorded"] as? Bool ?? false
        let audiofilePath = args["filePath"] as? String ?? ""
        let audiofileUrl = URL(fileURLWithPath: audiofilePath)
        
        print("audio File URL")
        print(audiofilePath)
        print(audiofileUrl.absoluteString as Any)
        
        MediaUtils.processAudio(url: audiofileUrl) { isSuccess, fileName ,localPath, fileSize, duration, fileKey  in
            print("#media \(duration)")
            if let localPathURL = localPath, isSuccess{
                var mediaData = MediaData()
                mediaData.fileName = fileName
                mediaData.fileURL = localPathURL
                mediaData.fileSize = fileSize
                mediaData.duration = duration
                mediaData.fileKey = fileKey
                mediaData.mediaType = .audio
                
                FlyMessenger.sendAudioMessage(toJid:  userJid, mediaData: mediaData, replyMessageId :  replyMessageId, isRecorded : isRecorded) { isSuccess,error,message in
                    if message != nil {
                        print("CAPTURE_RESPONSE")
                        print("sendAudioMessage")
                        dump(message)
                        
                        var audioResponse = JSONSerializer.toJson(message as Any)
                        
                        audioResponse = audioResponse.replacingOccurrences(of: "{\"some\":", with: "")
                        audioResponse = audioResponse.replacingOccurrences(of: "}}", with: "}")
                        print(audioResponse)
                        
                        result(audioResponse)
                        
                    }
                }
            }
        }
        
    }
    
    static func isArchivedSettingsEnabled(call: FlutterMethodCall, result: @escaping FlutterResult){
        result(FlyDefaults.isArchivedChatEnabled)
    }
    
    static func cancelNotifications(call: FlutterMethodCall, result: @escaping FlutterResult){
        result("")
    }
    
    static func getUserList(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let pageNumber = args["page"] as? Int ?? 1
        let searchTerm = args["search"] as? String ?? ""
        
        ContactManager.shared.getUsersList(pageNo: pageNumber, pageSize: 20, search: searchTerm){ isSuccess,flyError,flyData in
            if isSuccess {
                var userlist = flyData
                print(userlist)
                print("-----")
                dump(userlist)
                let userData = JSONSerializer.toJson(userlist.getData())
                print("==========")
                print("Json data--->\(userData)")
                print("==========")
                
                let totalPages = userlist["totalPages"] as! Int
                let message = userlist["message"] as! String
                var userlistJson = "{\"total_pages\": " + String(totalPages) + ",\"message\" : \"" + message + "\",\"status\" : true,\"data\":" + userData + "}"
                
                userlistJson = userlistJson.replacingOccurrences(of: "{\"some\": {}}", with: "\"\"")
                userlistJson = userlistJson.replacingOccurrences(of: "\"nickName\": {}", with: "\"nickName\": \"\"")
                
                
                print("userlist json after replacing---> \(userlistJson)")
                result(userlistJson)
            }else{
                //                result(FlutterError(code: "500", message: flyError?.description, details: nil))
            }
        }
        
    }
    
    static func getRegisteredUsers(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as? Dictionary<String, Any>
        let fromServer = args?["server"] as? Bool ?? false
        
        ContactManager.shared.getRegisteredUsers(fromServer: fromServer) {  isSuccess, flyError, flyData in
            var data  = flyData
            if isSuccess {
                
                print(data.getData())
                let userData = (data.getData() as? [ProfileDetails])?.count == 0 ? "[]" : JSONSerializer.toJson(data.getData())
                //                let  userData = data.getData()
                print("user data---> \(userData)")
                
                
                
                let message = data["message"] as! String
                var userlistJson = "{\"message\" : \"" + message + "\",\"status\" : true,\"data\":" + userData + "}"
                
                userlistJson = userlistJson.replacingOccurrences(of: "{\"some\": {}}", with: "\"\"")
                userlistJson = userlistJson.replacingOccurrences(of: "\"nickName\": {}", with: "\"nickName\": \"\"")
                
                print("getRegisteredUsers---> \(userlistJson)")
                result(userlistJson)
            } else{
                //data.getMessage()
                result(FlutterError(code: "500", message: flyError?.description, details: nil))
            }
        }
    }
    
    static func sendVideoMessage(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        let userJid = args["jid"] as? String ?? ""
        let caption = args["caption"] as? String ?? ""
        
        let filePath = args["filePath"] as? String ?? ""
        
        let replyMessageId = args["replyMessageId"] as? String ?? ""
        
        print("====File Path====")
        
        print(filePath)
        print("====File Path====")
        
        let videoFileUrl = URL(fileURLWithPath: filePath)
        print("====File URL====")
        print(videoFileUrl)
        print("====File URL====")
        var thumbnail : UIImage?
        do {
            let asset = AVURLAsset(url: videoFileUrl, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            thumbnail = UIImage(cgImage: cgImage)
            //            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            //            return nil
        }
        
        let base64Img = MediaUtils.convertImageToBase64(img: thumbnail!)
        
        
        var media = MediaData()
        
        MediaUtils.compressVideo(videoURL: videoFileUrl) { isSuccess, url, fileName, fileKey, fileSize , duration in
            if let compressedURL = url{
                
                media.mediaType = .video
                media.fileURL = compressedURL
                media.fileName = fileName
                media.fileSize = fileSize
                media.fileKey = fileKey
                media.duration = duration
                media.base64Thumbnail = base64Img
                media.caption = caption
                print("=====MEDIA DATA======")
                print(compressedURL)
                print(fileName)
                print(fileSize)
                print(fileKey)
                print(duration)
                print(base64Img)
                print(caption)
                FlyMessenger.sendVideoMessage(toJid: userJid, mediaData: media, replyMessageId: replyMessageId){ isSuccess,error,message in
                    if let chatMessage = message {
                        print("CAPTURE_RESPONSE")
                        print("sendVideoMessage")
                        dump(message)
                        
                        var sendVideoResposne = JSONSerializer.toJson(chatMessage)
                        
                        sendVideoResposne = sendVideoResposne.replacingOccurrences(of: "{\"some\":", with: "")
                        sendVideoResposne = sendVideoResposne.replacingOccurrences(of: "}}", with: "}")
                        print(sendVideoResposne)
                        result(sendVideoResposne)
                        
                    }
                }
            }else{
                print("Video Compression Error")
            }
        }
        
        
    }
    
    func generateVideoThumnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func sendContactMessage(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        let args = call.arguments as! Dictionary<String, Any>
        let userJid = args["jid"] as? String ?? ""
        let contactName = args["contact_name"] as? String ?? ""
        let replyMessageId = args["replyMessageId"] as? String ?? ""
        let contactList = args["contact_list"] as? [String] ?? []
        
        FlyMessenger.sendContactMessage(toJid: userJid, contactName: contactName, contactNumbers: contactList, replyMessageId: replyMessageId){ isSuccess,error,message  in
            if isSuccess {
                
                var contactMessageResponse = JSONSerializer.toJson(message as Any)
                
                contactMessageResponse = contactMessageResponse.replacingOccurrences(of: "{\"some\":", with: "")
                contactMessageResponse = contactMessageResponse.replacingOccurrences(of: "}}", with: "}")
                
                print("sendContactMessage \(contactMessageResponse)")
                
                result(contactMessageResponse)
                
            }
        }
    }
    
    
    static func sendDocumentMessage(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        let args = call.arguments as! Dictionary<String, Any>
        let userJid = args["jid"] as? String ?? ""
        
        let replyMessageId = args["replyMessageId"] as? String ?? ""
        
        let documentFilePath = args["file"] as? String ?? ""
        let documentFileUrl = URL(fileURLWithPath: documentFilePath)
        
        
        MediaUtils.processDocument(url: documentFileUrl){ isSuccess,localPath,fileSize,fileName, errorMessage in
            if !isSuccess {
                if !errorMessage.isEmpty {
                    print("Document Processing Issue")
                }
                return
            }
            if let localPathURL = localPath, isSuccess {
                var mediaData = MediaData()
                mediaData.fileName = fileName
                mediaData.fileURL = localPathURL
                mediaData.fileSize = fileSize
                mediaData.mediaType = .document
                
                FlyMessenger.sendDocumentMessage(toJid: userJid,mediaData: mediaData,replyMessageId: replyMessageId) { isSuccess, error, message in
                    if message != nil {
                        print("CAPTURE_RESPONSE")
                        print("sendDocumentMessage")
                        dump(message)
                        print(JSONSerializer.toJson(message as Any))
                        result(JSONSerializer.toJson(message as Any))
                        
                    }
                    
                }
                
            } else {
                
            }
        }
    }
    
    static func getProfileStatusList(call: FlutterMethodCall, result: @escaping FlutterResult){
        let profileStatus = ChatManager.getAllStatus()
        print("Status list -->\(profileStatus)")
        let profileStatusJson = JSONSerializer.toJson(profileStatus)
        print(profileStatusJson)
        result(profileStatusJson)
        
    }
    static func insertDefaultStatus(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let status = args["status"] as? String ?? ""
        
        
        print("Insert Status-->\(String(describing: index)) ---> \(status)")
//        var insertStatus = ChatManager.updateStatus(statusId: index, statusText: status)
        let insertStatus: () = ChatManager.saveProfileStatus(statusText: status, currentStatus: false)
        print("Insert Status Result-->\(insertStatus)")
    
        
    }
    static func isUserUnArchived(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        let args = call.arguments as! Dictionary<String, Any>
        
        let userJid = args["jid"] as? String ?? ""
        
        let isUserUnarchived : Bool = ChatManager.shared.isUserUnArchived(jid: userJid)
        result(isUserUnarchived)
        
    }
    static func forwardMessagesToMultipleUsers(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        let args = call.arguments as! Dictionary<String, Any>
        
        let messageIDList = args["message_ids"] as? [String] ?? []
        let userList = args["userList"] as? [String] ?? []
        
        FlyMessenger.composeForwardMessage(messageIds: messageIDList, toJidList: userList)
        
        result("Message Forward Success")
        
    }
    
    static func isMemberOfGroup(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        let args = call.arguments as! Dictionary<String, Any>
        
        let groupJid = args["jid"] as? String ?? ""
        let currentJid = FlyDefaults.myXmppUsername + "@" + FlyDefaults.xmppDomain
        let participantJid = args["userjid"] as? String ?? currentJid
        
        
        let isMember = GroupManager.shared.isParticiapntExistingIn(groupJid: groupJid,
                                                                   participantJid: participantJid)
        
        print("isMemberOfGroup--> \(isMember.doesExist)")
        result(isMember.doesExist)
        
    }
    static func getGroupMembersList(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        let groupJid = args["jid"] as? String ?? ""
        var groupMembers = [GroupParticipantDetail]()
        
        groupMembers = GroupManager.shared.getGroupMemebersFromLocal(groupJid: groupJid).participantDetailArray.filter({$0.memberJid != FlyDefaults.myJid})
        
        let myJid = GroupManager.shared.getGroupMemebersFromLocal(groupJid: groupJid).participantDetailArray.filter({$0.memberJid == FlyDefaults.myJid})
        groupMembers = groupMembers.sorted(by: { $0.profileDetail?.name.lowercased() ?? "" < $1.profileDetail?.name.lowercased() ?? "" })
        groupMembers.insert(contentsOf: myJid, at: 0)
        
        print("get group member list==>\(groupMembers)")
        
        var groupMemberResponse = [String: Any]()

        print("group member count-->\(groupMembers.count)")
        groupMembers.forEach{groupMember in
//            groupMember.profileDetail = JSONSerializer.toJson(groupMember.profileDetail)
            var profileDetailJson = JSONSerializer.toJson(groupMember.profileDetail as Any)
            profileDetailJson = profileDetailJson.replacingOccurrences(of: "{\"some\":", with: "")
            profileDetailJson = profileDetailJson.replacingOccurrences(of: "}}", with: "}")
            
            var profileDetailDict: NSDictionary
            do{
                try profileDetailDict = JSONSerializer.toDictionary(profileDetailJson)
                groupMemberResponse.addData(data: [
                    "groupMemberId": groupMember.groupMemberId as String,
                    "groupJid": groupMember.groupJid as String,
                    "memberJid": groupMember.memberJid,
                    "memberItemId": groupMember.memberItemId,
                    "time": groupMember.time,
                    "stanzaId": groupMember.stanzaId as Any,
                    "isAdminMember": groupMember.isAdminMember,
                    "profileDetail" : profileDetailDict
                ] as [String : Any])
            }catch{
                print("Error while Parsing User Profile Details")
            }
            
            
        }
        
        print("get group member list json==>\(JSONSerializer.toJson(groupMemberResponse))")
//        var groupMemberJson = JSONSerializer.toJson(groupMembers)
//        print("get group member list json==>\(groupMemberJson)")
        
        result(groupMemberResponse)
    }
    static func enableDisableArchivedSettings(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        let enableArchive = args["enable"] as? Bool ?? false
        ChatManager.enableDisableArchivedSettings(enableArchive) { isSuccess, error, data in
            if isSuccess {
                FlyDefaults.isArchivedChatEnabled = !FlyDefaults.isArchivedChatEnabled
                result(isSuccess)
            }
        }
        
    }
    static func clearAllConversation(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        ChatManager.shared.clearAllConversation{ isSuccess, error, data in
            
            result(isSuccess)
            
        }
        
    }
    
    static func getRingtoneName(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        result("[]")
        
    }
    
    static func verifyToken(call: FlutterMethodCall, result: @escaping FlutterResult){
//        let args = call.arguments as! Dictionary<String, Any>
        
//        let userName = args["userName"] as? String
//        let token = args["googleToken"] as? String ?? ""
        
        result("")
        
    }
    
    static func getUserProfile(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let server = args["server"] as? Bool ?? false
        let userjid = args["jid"] as? String ?? ""
        //        let JID = FlyDefaults.myXmppUsername + "@" + FlyDefaults.xmppDomain
        
        do {
            try ContactManager.shared.getUserProfile(for: userjid, fetchFromServer: server, saveAsFriend: true){ isSuccess, flyError, flyData in
                var data  = flyData
                if isSuccess {
                    
                    let profileJSON = "{\"data\" : " + JSONSerializer.toJson(data.getData() as Any) + ",\"status\": true}"
                    print(profileJSON)
                    result(profileJSON)
                } else{
                    print(flyError!.localizedDescription)
                    result(FlutterError(code: "500", message: flyError!.localizedDescription, details: nil))
                }
            }
        }catch{
            print("Error while calling User Profile Details")
        }
        
    }
    
    static func updateMyProfile(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        //        let jid = args["jid"] as? String ?? ""
        let email = args["email"] as? String ?? ""
        let mobile = args["mobile"] as? String ?? ""
        let nickName = args["name"] as? String ?? ""
        let status = args["status"] as? String ?? ""
        let image = args["image"] as? String ?? nil
        let userJid = FlyDefaults.myXmppUsername + "@" + FlyDefaults.xmppDomain
        print("=====Response Capture=====")
        print("jid===>" + userJid)
        print("email===>" + email)
        print("mobile===>" + mobile)
        print("nickName===>" + nickName)
        print("status===>" + status)
        print("image===>" + (image ?? "Image is Nil"))
        
//        var isImagePicked = false
        
        var myProfile = FlyProfile(jid: userJid)
        
        myProfile.email = email
        
        myProfile.mobileNumber = mobile
        
        myProfile.nickName = nickName
        myProfile.name = nickName
        
        myProfile.status = status
        
        if(image != nil){
            print("Image is not null if condition")
            myProfile.image = image!//xyaz.jpeg
//            isImagePicked = false
        }else{
            print("Image is null else condition")
//            isImagePicked = false
        }
        
        print("Profile json ===>" + JSONSerializer.toJson(myProfile))
        
        ContactManager.shared.updateMyProfile(for: myProfile){ isSuccess, flyError, flyData in
            if isSuccess {
                var data = flyData
                
                data["status"] = true
                print(Commons.json(from: data) as Any)
                //need to compare the contact sync when contact sync is enabled. //ProfileViewController//line-> 292
                
                saveMyProfileDataToUserDefaults(profile: myProfile)
                
                result(Commons.json(from: data as Any))
            } else{
                print("Update Profile Issue==> " + flyError!.localizedDescription)
            }
        }
        
    }
    
    static func removeProfileImage(call: FlutterMethodCall, result: @escaping FlutterResult){
        ContactManager.shared.removeProfileImage(){ isSuccess, flyError, flyData in
                if isSuccess {
                    print("removeProfileImage raw data\(flyData)")
                    var data = flyData
                    data["status"] = true
                    var responseJson = Commons.json(from: data) as Any
                    print(responseJson)
                    result(responseJson)
                } else{
                    print(flyError!.localizedDescription)
                }
        }
    }
    
    static func saveMyProfileDataToUserDefaults(profile : FlyProfile){
        FlyDefaults.myName = profile.name
        FlyDefaults.myImageUrl = profile.image
        FlyDefaults.myMobileNumber = profile.mobileNumber
        FlyDefaults.myStatus = profile.status
        FlyDefaults.myEmail = profile.email
        
        self.saveMyJidAsContacts()
    }
    
    static func saveMyJidAsContacts() {
        print("saveMyJidAsContacts jid -->\(FlyDefaults.myJid)")
        let profileData = ProfileDetails(jid: FlyDefaults.myJid)
        profileData.name = FlyDefaults.myName
        profileData.nickName = FlyDefaults.myNickName
        profileData.mobileNumber  = FlyDefaults.myMobileNumber
        profileData.email = FlyDefaults.myEmail
        profileData.status = FlyDefaults.myStatus
        profileData.image = FlyDefaults.myImageUrl
        
        FlyDatabaseController.shared.rosterManager.saveContact(profileDetailsArray: [profileData], chatType: .singleChat, contactType: .live, saveAsTemp: false, calledBy: "")
    }
    
    static func getMediaEndPoint(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        let urlString = FlyDefaults.baseURL + "" + "media" + "/"
        
        result(urlString)
        
    }
    
    static func syncContacts(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        ContactSyncManager.shared.syncContacts(){ isSuccess, flyError, flyData in
            var data  = flyData
            if isSuccess {
                // Contact synced successfully update the UI
            } else{
                print(data.getMessage() as! String)
            }
        }
        
    }
    static func updateMyProfileImage(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        let profileImage = args["image"] as? String ?? ""
       
        ContactManager.shared.updateMyProfileImage(image: profileImage){ isSuccess, flyError, flyData in
                if isSuccess {
                    var data = flyData
                    data["status"] = isSuccess
                    print("updateMyProfileImage-->\(data)")
                    let jsonResponse = Commons.json(from: data)
                    result(jsonResponse)
                } else{
                    print("updateMyProfileImage Error-->\(flyError!.localizedDescription)")
                    result(FlutterError(code: "500", message: flyError!.localizedDescription, details: nil))
                }
        }
        
    }
    
    static func contactSyncStateValue(call: FlutterMethodCall, result: @escaping FlutterResult){
        
    }
    
    static func contactSyncState(call: FlutterMethodCall, result: @escaping FlutterResult){
        //        NotificationCenter.default.addObserver(self, selector: #selector(self.contactSyncCompleted(notification:)), name: NSNotification.Name(FlyConstants.contactSyncState), object: nil)
        //        @objc func contactSyncCompleted(notification: Notification){
        //             if let contactSyncState = notification.userInfo?[FlyConstants.contactSyncState] as? String {
        //                switch ContactSyncState(rawValue: contactSyncState) {
        //                    case .inprogress:
        //                        //Update the UI
        //                    case .success:
        //                        //Update the UI
        //                    case .failed:
        //                        //Update the UI
        //                }
        //            }
        //        }
        
    }
    
    
    static func revokeContactSync(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        
    }
    static func getUsersWhoBlockedMe(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        let args = call.arguments as! Dictionary<String, Any>
        
        let isFetchFromServer = args["server"] as? Bool ?? false
        
        ContactManager.shared.getUsersWhoBlockedMe(fetchFromServer: isFetchFromServer){ isSuccess, flyError, flyData in
            
            var data  = flyData
            
            if isSuccess {
                let blockedprofileDetailsArray = data.getData() as! [ProfileDetails]
                print("blockedprofileDetailsArray-->\(blockedprofileDetailsArray)")
            } else{
                print(flyError!.localizedDescription)
            }
        }
    }
    static func getUnKnownUserProfiles(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        
    }
    static func getMyProfileStatus(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        
    }
    static func getMyBusyStatus(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        
    }
    static func setMyBusyStatus(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        
    }
    static func enableDisableBusyStatus(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        
    }
    
    static func getBusyStatusList(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        
    }
    static func deleteProfileStatus(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        
    }
    static func deleteBusyStatus(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        
    }
    static func enableDisableHideLastSeen(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        
        let args = call.arguments as! Dictionary<String, Any>
        
        let enableLastSeen = args["enable"] as? Bool ?? false
        
        ChatManager.enableDisableHideLastSeen(EnableLastSeen: enableLastSeen) { isSuccess, flyError, flyData in
            var data  = flyData
            if isSuccess {
                print(data.getMessage() as! String )
            } else{
                print(data.getMessage() as! String )
            }
        }
    }
    static func isHideLastSeenEnabled(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        result(ChatManager.isLastSeenEnabled())
    }
    static func deleteMessagesForMe(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        let jid = args["jid"] as? String ?? ""
        let chatType = args["chat_type"] as? String ?? ""
        let isMediaDelete = args["isMediaDelete"] as? Bool ?? false
        let messageIDList = args["message_ids"] as? [String] ?? []
        
        var deleteChatType : ChatType
        if(chatType == "chat"){
            deleteChatType = .singleChat
        }else{
            deleteChatType = .groupChat
        }
        
        ChatManager.deleteMessagesForMe(toJid: jid, messageIdList: messageIDList, deleteChatType: deleteChatType,isRevokeMediaAccess: isMediaDelete) { (isSuccess, error, data) in
            
            result(isSuccess)
        }
        
    }
    static func deleteMessagesForEveryone(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        let jid = args["jid"] as? String ?? ""
        let chatType = args["chat_type"] as? String ?? ""
        let isMediaDelete = args["isMediaDelete"] as? Bool ?? false
        let messageIDList = args["message_ids"] as? [String] ?? []
        
        var deleteChatType : ChatType
        if(chatType == "chat"){
            deleteChatType = .singleChat
        }else{
            deleteChatType = .groupChat
        }
        
        ChatManager.deleteMessagesForEveryone(toJid: jid, messageIdList: messageIDList, deleteChatType: deleteChatType,isRevokeMediaAccess: isMediaDelete) { (isSuccess, error, data) in
            
            result(isSuccess)
            
        }
        
    }
    static func markAsRead(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let jid = args["jid"] as? String ?? ""
        ChatManager.markConversationAsRead(for: [jid])
        result(true)
    }
    static func getMessagesOfJid(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let userJid = args["JID"] as? String ?? ""
        print("Get Messages of JID --->")
        print(userJid)
        let messages : [ChatMessage] = FlyMessenger.getMessagesOf(jid: userJid)
        print("Get Messages of JID --->")
        var userChatHistory = JSONSerializer.toJson(messages)
        
        userChatHistory = userChatHistory.replacingOccurrences(of: "{\"some\":", with: "")
        userChatHistory = userChatHistory.replacingOccurrences(of: "}}", with: "}")
        
//        let json = try! DSON.
//        print("====DSON=====")
//        print(json)
//        print("====DSON=====")
        
//        userChatHistory = userChatHistory.replacingOccurrences(of: "\"messageStatus\":", with: "\"iosMessageStatus\":")
        print(userChatHistory)
        result(userChatHistory)
        
    }
    
    static func markAsReadDeleteUnreadSeparator(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let jid = args["jid"] as? String ?? ""

        ChatManager.markConversationAsRead(for: [jid])
//        FlyMessenger.deleteUnreadMessageSeparatorOfAConversation(receiverJID)//not found need to implement here after adding
        result(true)
    }
    
    static func deleteUnreadMessageSeparatorOfAConversation(call: FlutterMethodCall, result: @escaping FlutterResult){
//        let args = call.arguments as! Dictionary<String, Any>
        
//        let jid = args["jid"] as? String ?? nil
        
        
    }
    static func getRecalledMessagesOfAConversation(call: FlutterMethodCall, result: @escaping FlutterResult){
//        let args = call.arguments as! Dictionary<String, Any>
        
//        let jid = args["jid"] as? String ?? nil
        
        
    }
    static func uploadMedia(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let messageid = args["messageid"] as? String ?? ""
        
        FlyMessenger.uploadMedia(messageId: messageid) { isSuccess, error, chatMessage in
            if isSuccess{
                result(true)
            }else{
                result(false)
            }
        }
        
       
        
        
    }
    static func getMessagesUsingIds(call: FlutterMethodCall, result: @escaping FlutterResult){
//        let args = call.arguments as! Dictionary<String, Any>
        
//        var messages : [ChatMessage] = FlyMessenger.getMessagesUsingIds(MESSAGE_MIDS)
        
        
    }
    static func updateMediaDownloadStatus(call: FlutterMethodCall, result: @escaping FlutterResult){
//        let args = call.arguments as! Dictionary<String, Any>
        
        
    }
    static func updateMediaUploadStatus(call: FlutterMethodCall, result: @escaping FlutterResult){
//        let args = call.arguments as! Dictionary<String, Any>
        
        
    }
    static func cancelMediaUploadOrDownload(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        let messageId = args["messageId"] as? String ?? ""
        
        FlyMessenger.cancelMediaUploadOrDownload(messageId: messageId){ isSuccess in
            if isSuccess{
                result(true)
            }else{
                result(false)
            }
        }
        

    }
    static func setMediaEncryption(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let isEncryptionEnable = args["encryption"] as? Bool ?? true
        
        ChatManager.setMediaEncryption(isEnable: isEncryptionEnable)
    }
    static func deleteAllMessages(call: FlutterMethodCall, result: @escaping FlutterResult){
        _ = call.arguments as! Dictionary<String, Any>
        
    }
    static func getGroupJid(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        let groupId = args["groupId"] as? String ?? ""
    
        do
        {
            let groupIDResponse = try FlyUtils.getGroupJid(groupId: groupId)
            result(groupIDResponse)
            
        }catch let sdkError{
            result(FlutterError(code: "500", message: "Unable to get JID", details: sdkError.localizedDescription))
        }
        
    }
    static func updateRecentChatPinStatus(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let userJID = args["jid"] as? String ?? ""
        let pin_recent_chat = args["pin_recent_chat"] as? Bool ?? false
        
        ChatManager.updateRecentChatPinStatus(jid: userJID, pinRecentChat: pin_recent_chat)
    }
    
    static func updateChatMuteStatus(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        let args = call.arguments as! Dictionary<String, Any>
        
        let userJID = args["jid"] as? String ?? ""
        let muteStatus = args["mute_status"] as? Bool ?? false
        ChatManager.updateChatMuteStatus(jid: userJID, muteStatus: muteStatus)
    }
    static func sendTypingStatus(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        let args = call.arguments as! Dictionary<String, Any>
        
        let toJid = args["to_jid"] as? String ?? ""
        let chattype = args["chattype"] as? String ?? ""
        
        var chatType : ChatType
        if(chattype == "chat"){
            chatType = .singleChat
        }else{
            chatType = .groupChat
        }
            
        ChatManager.sendTypingStatus(to: toJid, chatType: chatType)
    }
    
    static func sendTypingGoneStatus(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        let args = call.arguments as! Dictionary<String, Any>
        
        let toJid = args["to_jid"] as? String ?? ""
        let chattype = args["chattype"] as? String ?? ""
        
        var chatType : ChatType
        if(chattype == "chat"){
            chatType = .singleChat
        }else{
            chatType = .groupChat
        }
            
        ChatManager.sendTypingGoneStatus(to: toJid, chatType: chatType)
    }
    
    static func deleteRecentChat(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let jid = args["jid"] as? String ?? nil
        
        ChatManager.deleteRecentChat(jid: jid!)
    }
    static func setNotificationSound(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let notification_sound = args["enable"] as? Bool ?? false
        
        Utility.saveInPreference(key: muteNotification, value: notification_sound)
    }
    static func isBusyStatusEnabled(call: FlutterMethodCall, result: @escaping FlutterResult){
       result(ChatManager.shared.isBusyStatusEnabled())
    }
    static func getUserLastSeenTime(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let jid = args["jid"] as? String ?? ""
        
        ChatManager.getUserLastSeen( for: jid) { isSuccess, flyError, flyData in
              var data  = flyData
              if isSuccess {
                  print(data.getMessage() as! String )
                  print(data.getData() as! String )
              } else{
                  print(data.getMessage() as! String )
              }
          }
    }
    static func getRecentChatList(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        ChatManager.getRecentChatList { (isSuccess, flyError, resultDict) in
                  if (isSuccess) {
                      var recentChatList = resultDict
                      
                      let recentChatJson = JSONSerializer.toJson(recentChatList.getData())
                      
                      print(recentChatJson)
                      
                      
                      let recentChatListJson = "{\"data\":" + recentChatJson + "}"
                     
                      print(recentChatListJson)
                      result(recentChatListJson)
                   
                  } else {
                     //Fetching recent chat list failed

                  }
            }
    }
   
    static func getRecentChatListIncludingArchived(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        let recentChatList = ChatManager.getRecentChatListIncludingArchived()
        print("recent chat list including archived ---> \(recentChatList)")
        print("recent chat list including archived ---> \(JSONSerializer.toJson(recentChatList))")
        result(JSONSerializer.toJson(recentChatList))
    }
    static func getRecentChatOf(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let jid = args["jid"] as? String ?? nil
        let recentChat = ChatManager.getRecentChatOf(jid:jid!)
        
        var recentChatJson = JSONSerializer.toJson(recentChat as Any)
        recentChatJson = recentChatJson.replacingOccurrences(of: "{\"some\":", with: "")
        recentChatJson = recentChatJson.replacingOccurrences(of: "}}", with: "}")
        result(recentChatJson)
    }
    static func recentChatPinnedCount(call: FlutterMethodCall, result: @escaping FlutterResult){
        let recentPinCount = ChatManager.recentChatPinnedCount()
        result(recentPinCount)
    }
    
    static func setOnGoingChatUser(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let userJid = args["jid"] as? String ?? ""
        ChatManager.setOnGoingChatUser(jid: userJid)
    }
    static func reportUserOrMessages(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        let userJid = args["jid"] as? String ?? ""
        
        let reportMessage : ReportMessage? = ChatManager.getMessagesForReporting(chatUserJid: userJid, messagesCount: 5)
        
        var reportMessageJson = JSONSerializer.toJson(reportMessage as Any)
        reportMessageJson = reportMessageJson.replacingOccurrences(of: "{\"some\":", with: "")
        reportMessageJson = reportMessageJson.replacingOccurrences(of: "}}", with: "}")
        print("reportMessageJson=====>")
        print(reportMessageJson)
        result(reportMessageJson)
        
    }
    static func blockUser(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        let userJid = args["userJID"] as? String ?? ""
        
        do{
            
            try ContactManager.shared.blockUser(for: userJid){ isSuccess, flyError, flyData in

                    if isSuccess {
                        var blockUserResponseJson = JSONSerializer.toJson(flyData as Any)
                        print("before blockUserResponseJson===>")
                        print(blockUserResponseJson)
                        blockUserResponseJson = blockUserResponseJson.replacingOccurrences(of: "{\"some\":", with: "")
                        blockUserResponseJson = blockUserResponseJson.replacingOccurrences(of: "}}", with: "}")
                        print("blockUserResponseJson=====>")
                        print(blockUserResponseJson)
                        result(blockUserResponseJson)
                    } else{
                        print(flyError!.localizedDescription)
                        result(FlutterError(code: "500", message: "Unable to Block User", details: flyError?.localizedDescription))
                    }
            }
        }catch let error{
            
                result(FlutterError(code: "500", message: "Unable to Block User", details: error.localizedDescription))
        }
        
    }
    static func unblockUser(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        let userJid = args["userJID"] as? String ?? ""
        
        do{
            
            try ContactManager.shared.unblockUser(for: userJid){ isSuccess, flyError, flyData in

                    if isSuccess {
                        result(true)
                    } else{
                        print(flyError!.localizedDescription)
                        result(FlutterError(code: "500", message: "Unable to Un-Block User", details: flyError?.localizedDescription))
                    }
            }
        }catch let error{
            result(FlutterError(code: "500", message: "Unable to Un-Block User", details: error.localizedDescription))
        }
        
    }
    static func createGroup(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        let groupName = args["group_name"] as? String ?? ""
        let file = args["file"] as? String ?? ""
        let members = args["members"] as? [String] ?? []
        do{
            
            try GroupManager.shared.createGroup(groupName: groupName, participantJidList: members, groupImageFileUrl: file, completionHandler: { isSuccess, flyError, flyData in
                if isSuccess {
                    var createGroupResponseJson = JSONSerializer.toJson(flyData as Any)
                    print("before createGroupResponseJson===>")
                    print(createGroupResponseJson)
                    createGroupResponseJson = createGroupResponseJson.replacingOccurrences(of: "{\"some\":", with: "")
                    createGroupResponseJson = createGroupResponseJson.replacingOccurrences(of: "}}", with: "}")
                    print("createGroupResponseJson=====>")
                    print(createGroupResponseJson)
                    result(createGroupResponseJson)
                } else{
                    result(FlutterError(code: "500", message: "Unable to Create Group", details: flyError?.localizedDescription))
                }
            })
        }catch let error{
            result(FlutterError(code: "500", message: "Unable to Create Group", details: error.localizedDescription))
        }
        
    }
    
    static func clearChat(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        let userJid = args["jid"] as? String ?? ""
        let userChatType = args["chat_type"] as? String ?? ""
        let clearExceptStarred = args["clear_except_starred"] as? Bool ?? false
        
        var chatType : ChatType?
        if(userChatType == "chat"){
            chatType = .singleChat
        }else{
            chatType = .groupChat
        }
        
        ChatManager.clearChat(toJid: userJid, chatType: chatType!, clearChatExceptStarred: clearExceptStarred) { (isSuccess, flyerror, resultDict) in
            
            if(isSuccess){
                result(true)
            }else{
                result(false)
            }
        }
               
    }
    static func getUsersIBlocked(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let fetchFromServer = args["serverCall"] as? Bool ?? false
        
      
        ContactManager.shared.getUsersIBlocked(fetchFromServer: fetchFromServer){ isSuccess, flyError, flyData in

                var data  = flyData
          
                if isSuccess {
                    let blockedprofileDetailsArray = data.getData() as! [ProfileDetails]
                    let blockedProfileJson = JSONSerializer.toJson(blockedprofileDetailsArray as Any)
                    print("Blocked Profile --> \(blockedProfileJson)")
                    result(blockedProfileJson)
                } else{
                    print(flyError!.localizedDescription)
                    result(FlutterError(code: "500", message: "Unable to Get Blocked List", details: flyError?.localizedDescription))
                }
        }
               
    }
    static func getMediaMessages(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let userJid = args["jid"] as? String ?? ""
    
        let mediaMessages : [ChatMessage] = FlyMessenger.getMediaMessagesOf(jid: userJid)
        
        print("mediaMessages---> \(mediaMessages)")
        
        let mediaMsgJson = JSONSerializer.toJson(mediaMessages)
        
        print(mediaMsgJson)
        
       result(mediaMsgJson)
               
    }
    
    static func setMyProfileStatus(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let status = args["status"] as? String ?? ""
       
    
//        var getAllStatus: [ProfileStatus] = []
//            getAllStatus = getStatus()
//            for status in getAllStatus {
//            var chatUpdateStatus = ChatManager.updateStatus(statusId: status.id, statusText: status.status, currentStatus: false)
//            print("Update Status---> \(chatUpdateStatus)")
//        }
      
        ChatManager.saveProfileStatus(statusText: status, currentStatus: true)
        
        let statusUpdateJSON = "{\"message\": \"Status Update Success\",\"status\": true}"
        
       result(statusUpdateJSON)
               
    }
    
    static func getStatus() -> [ProfileStatus] {
        let profileStatus = ChatManager.getAllStatus()
        print("Get Status Started profileList Count \(profileStatus.count)")
        return profileStatus
    }
    
    static func updateArchiveUnArchiveChat(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let userJid = args["jid"] as? String ?? ""
        let archive = args["isArchived"] as? Bool ?? false
        
        var userJidList = [] as [String]
        userJidList.append(userJid)
       
    
        if(archive){
            ChatManager.archiveChatConversation(jidsToArchive: userJidList)
        }else{
            ChatManager.unarchiveChatConversation(jidsToUnarchive: userJidList)
        }
    
       result(true)
               
    }
    static func getArchivedChatList(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        ChatManager.getArchivedChatList { (isSuccess, flyError, resultDict) in
           if isSuccess {
               var flydata = resultDict
               print(flydata.getData())
               
               let archiveChatJson = JSONSerializer.toJson(flydata.getData())
               
               print("Archive Chat---> \(archiveChatJson)")
               
               
               let archiveChatListJson = "{\"data\":" + archiveChatJson + "}"
              
               print("Archive Chat list json---> \(archiveChatListJson)")
               result(archiveChatListJson)
           }else{
               print(flyError!.localizedDescription)
               result(FlutterError(code: "500", message: "Unable to Get Archived List", details: flyError?.localizedDescription))
           }
        }
    
       result(true)
               
    }
    
    
    
    static func getProfileDetails(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let userJid = args["jid"] as? String ?? ""
        print(userJid)
        let userProfile = ChatManager.profileDetaisFor(jid: userJid)
        print("User Profile --->")
        var userProfileJson = JSONSerializer.toJson(userProfile as Any)
        userProfileJson = userProfileJson.replacingOccurrences(of: "{\"some\":", with: "")
        userProfileJson = userProfileJson.replacingOccurrences(of: "}}", with: "}")
        result(userProfileJson)
//        do {
//            try ContactManager.shared.getUserProfile(for: userJid, fetchFromServer: false, saveAsFriend: true){ isSuccess, flyError, flyData in
//                var data  = flyData
//                if isSuccess {
//
//                    let profileJSON = "{\"data\" : " + JSONSerializer.toJson(data.getData() as Any) + ",\"status\": \"true\"}"
//                    print(profileJSON)
//                    result(profileJSON)
//                } else{
//                    print(flyError!.localizedDescription)
//                    result(FlutterError(code: "500", message: flyError!.localizedDescription, details: nil))
//                }
//            }
//        }catch{
//            print("Error while calling User Profile Details")
//        }
    }
    
    
    
}
