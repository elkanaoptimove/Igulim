//
//  AppDelegate.swift
//  Igulim
//
//  Created by Elkana Orbach on 12/11/2017.
//  Copyright © 2017 Optimove. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        let info = OptimoveTenantInfo(token: "c0458fb79ea03ef7be4589549a969ede",
                                      version: "1.0.1",
                                      hasFirebase: false)
        Optimove.sharedInstance.configure(info: info)
        return true
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        Optimove.sharedInstance.application(didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        Optimove.sharedInstance.handleRemoteNotificationArrived(userInfo: userInfo, fetchCompletionHandler: completionHandler)
    }
}

