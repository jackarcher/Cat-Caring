//
//  Themes.swift
//  Cat Caring
//
//  Created by Jack N. Archer on 21/10/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

/// ref:https://www.raywenderlich.com/108766/uiappearance-tutorial
import UIKit

let SelectedThemeKey = "SelectedTheme"

enum Theme:Int{
    case Default, ODPMU
    
    /// The main color theme (like the color displayed when tab bar selected)
    var mainColor: UIColor {
        switch self {
        case .Default:
            return UIColor(red: 87.0/255.0, green: 188.0/255.0, blue: 95.0/255.0, alpha: 1.0)
        case .ODPMU :
            return #colorLiteral(red: 0, green: 0.3828390241, blue: 0.5051688552, alpha: 1)
        }
    }

}

struct ThemeManager {
    static func currentTheme() -> Theme {
        if let storedTheme = (UserDefaults.standard.value(forKey: SelectedThemeKey) as AnyObject).integerValue {
            return Theme(rawValue: storedTheme)!
        } else {
            return .Default
        }
    }

    static func applyTheme(theme: Theme) {
        // 1
        UserDefaults.standard.setValue(theme.rawValue, forKey: SelectedThemeKey)
        UserDefaults.standard.synchronize()
        
        // 2
        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = theme.mainColor
        
        // set the theme to navi
        UINavigationBar.appearance().barTintColor = theme.mainColor
        UINavigationBar.appearance().barStyle = .black
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
    }
}

