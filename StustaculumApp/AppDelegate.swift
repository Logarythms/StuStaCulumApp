//
//  AppDelegate.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 21.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        
//        UITabBar.appearance().barTintColor = .black
//        UITabBar.appearance().tintColor = .white
        
//        UINavigationBar.appearance().backgroundColor = Util.backgroundColor
//        UINavigationBar.appearance().tintColor = .white
        
        self.registerForPushNotifications()
        
        guard UserDefaults.standard.bool(forKey: "initialLoadCompleted") else {
            return true
        }
        
        DataManager.shared.updatePerformances()
        
        return true
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
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            print("Permission granted: \(granted)")
            guard granted else { return }
//            self?.getNotificationSettings()
            self?.setupPfandNotifications()
        }
    }
    
    func getNotificationSettings() {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: "pushRegistered") else { return }
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification Settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func setupPfandNotifications() {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: "pfandNotifications") else { return }
        
        let content = UNMutableNotificationContent()
        
        content.title = "Pfandrückgabe!"
        content.body = "Die Pfandrückgabe endet bald!\nBis 3 Uhr kannst du dein Pfand noch beim Festzelt zurückgeben!"
        content.sound = UNNotificationSound.default
        
        let triggers = Util.getNotificationTriggers()
        for trigger in triggers {
            let uuid = UUID()
            let request = UNNotificationRequest(identifier: uuid.uuidString, content: content, trigger: trigger)

            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { error in
                if let error = error {
                    print(error)
                } else {
                    print("registered Pfand-notifications")
                }
            }
        }
        UserDefaults.standard.set(true, forKey: "pfandNotifications")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data)}
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        
//        NetworkingManager.shared.addDeviceForPushNotifications(token: token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
}

