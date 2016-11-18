//
//  AppDelegate.swift
//  SwiftMonkeyExample
//
//  Created by Dag Agren on 07/11/2016.
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import UIKit
import SwiftMonkeyPaws

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var paws: MonkeyPaws?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        paws = MonkeyPaws(view: window!)
        return true
    }
}

