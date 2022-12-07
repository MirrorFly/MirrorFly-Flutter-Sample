//
//  ImageDetail.swift
//  MirrorflyUIkit
//
//  Created by User on 01/09/21.
//

import Foundation
import UIKit
import Photos
import FlyCommon
public struct ImageData {
    var image : UIImage?
    var caption: String?
    var isVideo: Bool
    var phAsset: PHAsset?
    var isSlowMotion : Bool
    var processedVideoURL : URL?
    var isUploaded : Bool?
    var mediaData : Data? = nil
    var fileName : String = emptyString()
    var isCompressed : Bool = false
    var base64Image : String = emptyString()
    var mediaType : MediaType = .image
    var fileExtension : String = emptyString()
    var compressedDataURL : URL? = nil
    var encryptedKey : String = emptyString()
    var inProgress : Bool = false
    var fileSize : Double = 0.0
}

struct Profile {
    var profileName: String?
    var jid: String = ""
    var isSelected: Bool?
}
