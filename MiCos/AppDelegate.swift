//
//  AppDelegate.swift
//  MiCos
//
//  Created by Samuel Coby Anderson on 8/28/15.
//  Copyright (c) 2015 Samuel Coby Anderson. All rights reserved.
//



import UIKit
import Parse
import Bolts
import ParseUI


@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var parseLoginHelper: ParseLoginHelper!
    
    override init() {
        super.init()
    
        
        parseLoginHelper = ParseLoginHelper {[unowned self] user, error in
            // Initialize the ParseLoginHelper with a callback
            if let error = error {
                print (error)
               
            } else  if let user = user {
                let installation = PFInstallation.currentInstallation()
                installation["user"] = user
                installation["userId"] = user.objectId!
                if let legacy = PFUser.currentUser()?["Legacy"] {
                    installation["legacy"] = legacy
                }
                if let classOf = PFUser.currentUser()?["Class"] {
                    installation["class"] = classOf
                }
                
                installation.saveInBackground()
                
                // if login was successful, display the TabBarController
                // 2
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainViewController = storyboard.instantiateViewControllerWithIdentifier("MainViewController") 
                // 3
                self.window?.rootViewController!.presentViewController(mainViewController, animated:true, completion:nil)
            }
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        
        
        //configures parse server
        let configuration = ParseClientConfiguration {
            $0.applicationId = "legacycup"
            $0.clientKey = "minervalegacycupclientkey"
            $0.server = "https://minerva-legacy-cup.herokuapp.com/parse"
            $0.localDatastoreEnabled = true
            
        }
        Parse.initializeWithConfiguration(configuration)
        
        
        //configures Flurry
        Flurry.startSession("XNQHT96N5NNC5S22PRMN");
        
 
//        Parse.setApplicationId("ptL6M8uCH8bdfi3ahQJmtM9oMdhDTzA8khp8kzaR",
//            clientKey: "L8SbAeOmjjR6DdD4nu9Ffc08feWy3uF036taEbYI")
        
        let userNotificationTypes: UIUserNotificationType = [.Alert, .Badge, .Sound]
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
      
        
        let user = PFUser.currentUser()
        
        let startViewController: UIViewController;
        
        if (user != nil) {
            // 3
            // if we have a user, set the TabBarController to be the initial View Controller
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            startViewController = storyboard.instantiateViewControllerWithIdentifier("MainViewController")
            
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            self.window?.rootViewController = startViewController;
            self.window?.makeKeyAndVisible()
            
           // return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
            
        } else {
            // 4
            presentLogInView()
            // Otherwise set the LoginViewController to be the first
        }
        
        //sketchy
         return false
        
    
       
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // Store the deviceToken in the current Installation and save it to Parse
        let installation = PFInstallation.currentInstallation()
        
        if let user = PFUser.currentUser() {
            installation["user"] = user
            installation["userId"] = user.objectId!
            
        }
        
        installation.setDeviceTokenFromData(deviceToken)
        installation.channels = ["global"]
        installation.saveInBackground()
    }
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        let currentInstallation = PFInstallation.currentInstallation()
        if currentInstallation.badge != 0 {
            currentInstallation.badge = 0
            
            currentInstallation.saveInBackground()
        }
        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func presentLogInView() {
        
        let startViewController: UIViewController;
        
        let loginViewController = PFLogInViewController()
        loginViewController.fields = [.UsernameAndPassword, .LogInButton, .SignUpButton, .PasswordForgotten, .Facebook]
        loginViewController.delegate = parseLoginHelper
        loginViewController.signUpController?.delegate = parseLoginHelper
        
        //Customization!
        
        let logoImage = UIImageView()
        logoImage.image = UIImage(named: "logo")
        logoImage.contentMode = UIViewContentMode.ScaleAspectFit
        
        loginViewController.logInView?.logo = logoImage
        
        loginViewController.logInView?.signUpButton?.removeFromSuperview()
        loginViewController.logInView?.facebookButton?.removeFromSuperview()
        loginViewController.logInView?.passwordForgottenButton?.backgroundColor = UIColor.whiteColor()
        loginViewController.logInView?.tintColor = UIColor.orangeColor()
        
        startViewController = loginViewController
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = startViewController;
        self.window?.makeKeyAndVisible()
        
        
//        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
    }


}

