//
//  FontExtension.swift
//  MirrorFly
//
//  Created by User on 18/05/21.
//

import Foundation
import UIKit

extension UIFont {
    
    //MARK:- Font 23px
    class func font23px_appHeavy( ) -> UIFont {
        return  UIFont(name: fontHeavy, size: 23)!
    }
    
    class func font23px_appBold( ) -> UIFont {
        return  UIFont(name: fontBold, size: 23)!
    }
    
    class func font32px_appBold( ) -> UIFont {
        return  UIFont(name: fontBold, size: 38)!
    }
    
    class func font84px_appBold( ) -> UIFont {
        return  UIFont(name: fontBold, size: 84)!
    }
    
    //MARK:- Font 22px
    class func font22px_appSemibold( ) -> UIFont {
        return  UIFont(name: fontSemibold, size: 22)!
    }
    
    //MARK:- Font 20px
    class func font20px_appBold( ) -> UIFont {
        return  UIFont(name: fontBold, size: 20)!
    }
    
    //MARK:- Font 18px
    class func font18px_appMedium( ) -> UIFont {
        return  UIFont(name: fontMedium, size: 18)!
    }
    
    //MARK:- Font 16px
    class func font16px_appSemibold( ) -> UIFont {
        return  UIFont(name: fontSemibold, size: 16)!
    }
    
    class func font18px_appSemibold( ) -> UIFont {
        return  UIFont(name: fontSemibold, size: 18)!
    }
    
    
    
    //MARK:- Font 15px
    class func font15px_appMedium( ) -> UIFont {
        return  UIFont(name: fontMedium, size: 15)!
    }
    
    //MARK:- Font 14px
    class func font14px_appMedium( ) -> UIFont {
        return  UIFont(name: fontMedium, size: 14)!
    }
    
    class func font14px_appSemibold( ) -> UIFont {
        return  UIFont(name: fontSemibold, size: 14)!
    }
    
    class func font14px_appLight( ) -> UIFont {
        return  UIFont(name: fontLight, size: 14)!
    }
    
    class func font14px_appRegular( ) -> UIFont {
        return  UIFont(name: fontRegular, size: 14)!
    }
    
    //MARK:-Font 12px
    class func font12px_appMedium( ) -> UIFont {
        return  UIFont(name: fontMedium, size: 12)!
    }
    
    class func font12px_appRegular( ) -> UIFont {
        return  UIFont(name: fontRegular, size: 12)!
    }
    
    class func font9px_appRegular( ) -> UIFont {
        return  UIFont(name: fontRegular, size: 9)!
    }
    
    
    class func font15px_appRegular( ) -> UIFont {
        return  UIFont(name: fontRegular, size: 15)!
    }
    
    class func font12px_appLight( ) -> UIFont {
        return  UIFont(name: fontLight, size: 12)!
    }
    
    class func font12px_appSemibold( ) -> UIFont {
        return  UIFont(name: fontSemibold, size: 12)!
    }
    
    //MARK:- Font 10px
    class func font10px_appLight( ) -> UIFont {
        return  UIFont(name: fontLight, size: 10)!
    }
    
    class func font10px_appSemibold( ) -> UIFont {
        return  UIFont(name: fontSemibold, size: 10)!
    }
    
    //MARK:- Font 9px
    class func font9px_appLight( ) -> UIFont {
        return  UIFont(name: fontLight, size: 9)!
    }
    
    //MARK:- Font 8px
    class func font8px_appLight( ) -> UIFont {
        return  UIFont(name: fontLight, size: 8)!
    }
    
    //MARK:- Font 200px
    class func font200px_appBold( ) -> UIFont {
        return  UIFont(name: fontBold, size: 200)!
    }
    
}

private let familyName = "SFUIDisplay"
enum AppFont: String {
    case Regular = "Regular"
    case Medium = "Medium"
    case Light = "Light"
    case Bold = "Bold"
    func size(_ size: CGFloat) -> UIFont {
        if let font = UIFont(name: fullFontName, size: size + 1.0) {
            return font
        }
        fatalError("Font '\(fullFontName)' does not exist.")
    }
    fileprivate var fullFontName: String {
        return rawValue.isEmpty ? familyName : familyName + "-" + rawValue
    }
}
