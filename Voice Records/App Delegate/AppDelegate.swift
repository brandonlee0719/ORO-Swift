//
//  AppDelegate.swift
//  Voice Records
//
//  Created by MAC on 21/03/22.
//

import UIKit
import DropDown
import SVProgressHUD
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupApplicationUIAppearance()
//        printFontFamilyNames()
        goToHome()
        
        return true
    }
    
    // MARK: - Methods

    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    private func setupApplicationUIAppearance() {
        window = UIWindow()
        window?.backgroundColor = UIColor.white
        window?.makeKeyAndVisible()
        
        DropDown.appearance().cellHeight = 40
        DropDown.appearance().backgroundColor = UIColor.white
        DropDown.appearance().setupCornerRadius(7)
        DropDown.appearance().textFont = UIFont(name: AppFont.RoobertRegular, size: setCustomFont(15))!

        SVProgressHUD.setFont(UIFont(name: AppFont.RoobertRegular, size: setCustomFont(15))!)
        
        UITextField.appearance().tintColor = AppColor.Blue
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.toolbarTintColor = AppColor.Blue
    }
    
    func printFontFamilyNames() {
        for family: String in UIFont.familyNames {
            print("\(family)")
            for names: String in UIFont.fontNames(forFamilyName: family) {
                print("== \(names)")
            }
        }
    }
    
    func goToHome() {
        
        let homeVc = UIStoryboard.instantiateVC(HomeVC.self, .Main)
        let mainNavVC = UINavigationController(rootViewController: homeVc)
            mainNavVC.isNavigationBarHidden = true
            _ = window!.setRootVC(mainNavVC)
    }
    
    func getUUID() -> String? {

        // create a keychain helper instance
        let keychain = KeychainAccess()

        // this is the key we'll use to store the uuid in the keychain
        let uuidKey = "com.Oro.unique_uuid"

        // check if we already have a uuid stored, if so return it
        if let uuid = try? keychain.queryKeychainData(itemKey: uuidKey), uuid != "" {
            return uuid
        }

        // generate a new id
        guard let newId = UIDevice.current.identifierForVendor?.uuidString else {
            return nil
        }

        // store new identifier in keychain
        try? keychain.addKeychainData(itemKey: uuidKey, itemValue: newId)

        // return new id
        return newId
    }
}
