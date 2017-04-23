//
//  AppDelegate.swift
//  Carousel
//
//  Created by Vincent Liu on 26/3/17.
//  Copyright © 2017 200OK. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import UserNotifications
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    let locationManager = CLLocationManager()
    var ref: FIRDatabaseReference?
    var currentGeofence: Geofence? = nil
    
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
        
        // Override point for customization after application launch.
        
        //        let tabController = self.window?.rootViewController as! UITabBarController
        //        let photoController = (tabController.viewControllers?[0])! as UIViewController
        //        let favNavController = tabController.viewControllers![1] as! UINavigationController
        //        //let favController = favNavController.topViewController as
        
        
        // Enable local notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
            guard error == nil else {
                //Display Error.. Handle Error.. etc..
                return
            }
            
            if granted {
                //Do stuff here..
                
                //Register for RemoteNotifications. Your Remote Notifications can display alerts now :)
                application.registerForRemoteNotifications()
            }
            else {
                //Handle user denying permissions..
            }
        }
        
        
        FIRApp.configure()
        
        ref = FIRDatabase.database().reference()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        startMonitoringGeofenceRegion()
        
        return true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        
        let content = UNMutableNotificationContent()
        content.title = "Hi!"
        content.subtitle = "You have memories to view"
        content.body = "Click here if you would like to see them or if you need any assistance"
        content.badge = 1
        content.sound = UNNotificationSound.default()
        
        guard let path = Bundle.main.path(forResource: "husbandbill", ofType: "png") else {return}
        let url = URL(fileURLWithPath: path)
        do {
            let attachment = try UNNotificationAttachment(identifier: "notificationImage", url: url, options: nil)
            content.attachments = [attachment]
        }
        catch {
            print ("error occurred")
        }
        
        
        
        let date = Date(timeIntervalSinceNow: 60)
//        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
//        
//        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,
//                                                    repeats: true)
        
        let triggerDaily = Calendar.current.dateComponents([.second,], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
        
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        let request = UNNotificationRequest(identifier: "timerDone", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        print("enter background")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        print("asdasd")
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Carousel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func handleEvent(forRegion region: CLRegion!) {
        print("Geofence triggered!")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
            print("I have entered \(region.identifier)")
            
            // Notify the user when they have entered a region
            let title = "Good Job!"
            let message = "You're back inside your safe zone: \(region.identifier). Your caregiver will be notified."
            
            self.ref?.child("geofencing/testpatient/violated").setValue("false")
            
            if UIApplication.shared.applicationState == .active {
                // App is active, show an alert
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(alertAction)
                UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
                //self.present(alertController, animated: true, completion: nil)
            } else {
                // App is inactive, show a notification
                
                
                let notification = UILocalNotification()
                notification.alertTitle = title
                notification.alertBody = message
                notification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.shared.presentLocalNotificationNow(notification)
            }
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
            print("Exited region \(region.identifier)")
            // Notify the user when they have entered a region
            let title = "Beware"
            let message = "You are leaving your safe zone: \(region.identifier). Your caregiver will be notified."
            
            self.ref?.child("geofencing/testpatient/violated").setValue("true")
            
            if UIApplication.shared.applicationState == .active {
                // App is active, show an alert
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(alertAction)
                UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
                //self.present(alertController, animated: true, completion: nil)
            } else {
                // App is inactive, show a notification
                let notification = UILocalNotification()
                notification.alertTitle = title
                notification.alertBody = message
                notification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.shared.presentLocalNotificationNow(notification)
            }
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        self.ref?.child("users/testpatient/patLat").setValue(String(locValue.latitude))
        self.ref?.child("users/testpatient/patLng").setValue(String(locValue.longitude))
        
    }
    
    
    func startMonitoringGeofenceRegion()
    {
        self.ref?.child("geofencing").observe(.value, with: { (snapshot) in
            
            
            // TODO: remove all exisiting geofencing
            if let geofenceToRemove = self.currentGeofence {
                self.removePreviousGeofence(previousGeofence: geofenceToRemove)
            }
            
            
            if let current = snapshot.childSnapshot(forPath: "testpatient") as? FIRDataSnapshot
            {
                let value = current.value as? NSDictionary
                if let location = value?["locationName"] as? String
                {
                    print ("location name is \(location)")
                    if let locationLat = value?["locLat"] as? String {
                        if let locationLng = value?["locLng"] as? String {
                            print ("lat and lng for location \(locationLat) \(locationLng)")
                            if let range = value?["range"] as? Double {
                                print("radius is \(range)")
                                if let enabled = value?["enabled"] as? String {
                                    print("enabled is \(enabled)")
                                    if (enabled == "true")
                                    {
                                        self.currentGeofence = Geofence(locationName: location, locLat: Double(locationLat)!, locLng: Double(locationLng)!, radius: range, enabled: true)
                                        
                                        let lat = Double(locationLat)
                                        let lng = Double(locationLng)
                                        let loc = CLLocationCoordinate2D(latitude: lat!, longitude: lng!)
                                        print("lat: \(lat)   lng: \(lng)")
                                        
                                        let region = (name: location, coordinate:loc)
                                        let notificationRadius = range
                                        let geofence = CLCircularRegion(center: region.coordinate, radius: CLLocationDistance(notificationRadius), identifier: location)
                                        self.locationManager.startMonitoring(for: geofence)
                                        print ("Started monitoring \(region.name)")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    func removePreviousGeofence(previousGeofence: Geofence)
    {
        
        if (previousGeofence != nil)
        {
            let lat = previousGeofence.locLat
            let lng = previousGeofence.locLng
            let loc = CLLocationCoordinate2D(latitude: lat!, longitude: lng!)
            let notificationRadius = previousGeofence.radius
            let region = (name: previousGeofence.locationName, coordinate:loc)
            
            // set geofencing only if the user has chosen to keep notifications on
            
            let geofence = CLCircularRegion(center: region.coordinate, radius:  CLLocationDistance(notificationRadius!), identifier: previousGeofence.locationName!)
            locationManager.stopMonitoring(for: geofence)
        }
    }
    
}

