//
//  AppDelegate.swift
//  GoogleCalenderDemo
//
//  Created by Anil Kumar on 18/02/19.
//  Copyright © 2019 Busywizzy. All rights reserved.
//

import UIKit
import UserNotifications
import GoogleSignIn
import Firebase
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Initialize sign-in
        GIDSignIn.sharedInstance()?.scopes = ["https://www.googleapis.com/auth/drive.file","https://www.googleapis.com/auth/drive.readonly","https://www.googleapis.com/auth/drive.metadata.readonly","https://www.googleapis.com/auth/tasks.readonly"]
        GIDSignIn.sharedInstance().clientID = "204771041462-mfpi0n4o30so4goihmlkvvpnqj7ginlj.apps.googleusercontent.com"
        printDocumentsDirectory()
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true
//        Database.database().isPersistenceEnabled = true
        self.authLogin()
        return true
    }
    
    func authLogin(){
        let id = UserDefaults.standard.value(forKey: "id") as? String
        if id != "" && id != nil {
            
            let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
            let navigationController:UINavigationController = storyBoard.instantiateInitialViewController() as! UINavigationController
            let vc = storyBoard.instantiateViewController(withIdentifier: "CalenderViewController") as? CalenderViewController
            navigationController.viewControllers = [vc] as! [UIViewController]
            self.window?.rootViewController = navigationController
        }else  {
            let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
            let navigationController:UINavigationController = storyBoard.instantiateInitialViewController() as! UINavigationController
            let vc = storyBoard.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController
            navigationController.viewControllers = [vc] as! [UIViewController]
            self.window?.rootViewController = navigationController
        }

    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    private func printDocumentsDirectory() {
        let fileManager = FileManager.default
        if let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last {
            print("Documents directory: \(documentsDir.absoluteString)")
        } else {
            print("Error: Couldn't find documents directory")
        }
    }
    
}
