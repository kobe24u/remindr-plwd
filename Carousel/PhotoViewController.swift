//
//  PhotoViewController.swift
//  Carousel
//
//  Created by Vincent Liu on 26/3/17.
//  Copyright © 2017 200OK. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import Firebase
import FirebaseDatabase

class PhotoViewController: UIViewController
 {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var weatherImage: UIImageView!
    
    @IBOutlet weak var tempLabel: UILabel!
    
    
    @IBOutlet weak var locationLabel: UILabel!
    
    var newEvent: PanicEvent? = nil
    
    var photos = [Photo]()
    let cellScaling: CGFloat = 0.6
    let picker = UIImagePickerController()
    var chosenPhoto: UIImage?
    var weather = WeatherModel()
    
//    var photoList: NSMutableArray
    var ref: FIRDatabaseReference!
    var aDecoder: NSCoder

    
    required init?(coder aDecoder: NSCoder) {
        
        self.aDecoder = aDecoder
//        self.photoList = NSMutableArray()
        super.init(coder: aDecoder)
    }
    
    override  func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        ref = FIRDatabase.database().reference()
//        retrieveDataFromFirebase()
        
        weather.downloadData {
            self.updateWeatherUI()
        }
        let screenSize = UIScreen.main.bounds.size
        let cellWidth = floor(screenSize.width * cellScaling)
        let cellHeight = floor(screenSize.height * cellScaling)
        
        let insetX = (view.bounds.width - cellWidth) / 2.0
        let insetY = (view.bounds.height - cellHeight) / 2.0
        
        let layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        collectionView!.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
        
//        picker.delegate = self
        
        collectionView!.dataSource = self
        collectionView!.delegate = self
        

    }
    
    func updateWeatherUI() {
        tempLabel.text = "\(weather.temp)"
        locationLabel.text = "\(weather.location)"
        weatherImage.image = UIImage(named: weather.weather)
    }
    

    override func viewWillAppear(_ animated: Bool) {
            retrieveDataFromFirebase()
            getCloudNotifications()
    }
    
    func getCloudNotifications()
    {
        ref.child("reminders/testpatient").observe(.value, with: {(snapshot) in
            
            // code to execute when child is changed
            // Take the value from snapshot and add it to the favourites list
            
            // Get user value
            
            UIApplication.shared.cancelAllLocalNotifications()
            
            
            for current in snapshot.children.allObjects as! [FIRDataSnapshot]
            {
                let value = current.value as? NSDictionary
                let message = value?["message"] as? String ?? ""
                let time = value?["time"]
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date = dateFormatter.date(from: time as! String)
                
                let currentDate = NSDate()
                 if date! < currentDate as Date
                 {
                    print(date)
                }
                 else{
                    print(date)
                    let notification = UILocalNotification()
                    notification.alertTitle = "Reminder"
                    notification.alertBody = "\(message)"
                    notification.fireDate = date
                    notification.soundName = UILocalNotificationDefaultSoundName
                    notification.alertLaunchImage = "pill.png"
                    UIApplication.shared.scheduleLocalNotification(notification)
                }
               
                
            }
            
            
        })
        
    }
    
    func retrieveDataFromFirebase()
    {
//        self.photos.removeAll()
        // Retrieve the list of favourites and listen for changes
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityView.color = UIColor.black
        activityView.center = self.view.center
        self.view.addSubview(activityView)
        activityView.startAnimating()
        
        ref.child("Photos/testpatient").observe(.value, with: {(snapshot) in
            
            self.photos.removeAll()
            // code to execute when child is changed
            // Take the value from snapshot and add it to the favourites list
            
            // Get user value
            for current in snapshot.children.allObjects as! [FIRDataSnapshot]
            {
                let value = current.value as? NSDictionary
                let Description = value?["Description"] as? String ?? ""
                let photoURL = value?["photoURL"]
                let audioURL = value?["audioURL"]
                if let imageURL = photoURL {
                    let url = NSURL(string: imageURL as! String)
                    URLSession.shared.dataTask(with: url! as URL,
                    completionHandler: {(data, response, error) in
                    
                        if error != nil {
                            print(error)
                            return
                        }
                        
                        let addingPhoto = UIImage(data: data!)
                        
                        
                        let newPhoto = Photo(title: Description, featuredImage: addingPhoto!, color: UIColor(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 0.6), audioURL: audioURL as! String)
                        
                        self.photos.append(newPhoto)
                        
                        DispatchQueue.main.async( execute: {
                            
                            self.collectionView.reloadData()
                            activityView.stopAnimating()
                        })
                    print(self.photos.count)
                    }).resume()
                }
            }
            self.collectionView.reloadData()

        })
        
    }
    
    @IBAction func didClickPanicButton(_ sender: Any) {
        
        print ("User clicked panic button")
        var ref2: FIRDatabaseReference!
        ref2 = FIRDatabase.database().reference()
        ref2.child("panicked/testpatient/isPanicked").setValue("true")
        
        var values: [String: Any]? = nil
        var eventName: String?
        var receivedTime: String?
        var receivedDate: String?
        var receivedLat: String?
        var receivedLng: String?
        var handled: String = "false"
        
        let dateTime = NSDate()
        print (dateTime)
        
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        timeFormatter.dateFormat = "HH:mm:ss"
        
        let dateResult = dateFormatter.string(from: dateTime as Date)
        let timeResult = timeFormatter.string(from: dateTime as Date)
        
        receivedDate = dateResult
        receivedTime = timeResult
 
//        DispatchQueue.global(qos: .background).async {
//            // Background Thread
            self.ref.child("users").observe(.value, with: { (snapshot) in
                
                if let current = snapshot.childSnapshot(forPath: "testpatient") as? FIRDataSnapshot
                {
                    let value = current.value as? NSDictionary
                    if let patLat = value?["patLat"] as? String
                    {
                        if let patLng = value?["patLng"] as? String {
                            receivedLat = patLat
                            receivedLng = patLng
                            
                            print ("received \(receivedLat) and \(receivedLng)")
                            eventName = "event\(receivedDate!)_\(receivedTime!)"
                            self.newEvent = PanicEvent(receivedDate: receivedDate!, receivedTime: receivedTime!, receivedLat: receivedLat!, receivedLng: receivedLng!)
                            values = ["eventName": eventName!, "receivedDate": receivedDate!, "receivedTime": receivedTime!, "receivedLat": receivedLat!, "receivedLng": receivedLng!, "resolved": "false", "resolvedDate": "nil", "resolvedTime": "nil"]
                            ref2.child("panicEvents/testpatient").child(eventName!).setValue(values)
//                            self.performSegue(withIdentifier: "showPanicMapSegue", sender: self)
                        }
                    }
                }
            })

//            DispatchQueue.main.async {
//
//            }
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if (segue.identifier == "showPanicMapSegue")
//        {
//            let destinationVC: PanicMapViewController = segue.destination as! PanicMapViewController
//            destinationVC.currentPanicEvent = newEvent
//        }
        if (segue.identifier == "helpOnTheWaySegue")
        {
            let destinationVC: HelpMessageViewController = segue.destination as! HelpMessageViewController
        }
    }
    
}


extension PhotoViewController : UICollectionViewDataSource
{

        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            print(photos.count)
            return photos.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
//            let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
//            
//            activityView.center = cell.contentView.center
//            
//             cell.contentView.addSubview(activityView)
//            activityView.startAnimating()
            cell.photo = photos[indexPath.item]
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
//            activityView.stopAnimating()
            return cell
        }
}

extension PhotoViewController : UIScrollViewDelegate, UICollectionViewDelegate
{
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    }
}

//extension PhotoViewController
//{
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let alert = UIAlertController(title: "Notice", message: "What do you want to?", preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "Delete this photo", style: .destructive) { action in
//
//            if (self.photos.count > 1)
//            {
//                self.photos.remove(at: indexPath.row)
//                self.collectionView.reloadData()
//                self.promptMessage(title: "So easy", message: "You've successfully deleted the photo")
//            }
//            else{
//                self.promptMessage(title: "Oops", message: "This is the last photo, you cannot delete it")
//                
//            }
//        })
//        alert.addAction(UIAlertAction(title: "Add a new photo", style: .default) { action in
//            self.picker.allowsEditing = false
//            self.picker.sourceType = .photoLibrary
//            self.picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
//            self.picker.modalPresentationStyle = .popover
//            self.present(self.picker, animated: true, completion: nil)
//            
//        })
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
//            
//        })
//        
//        collectionView.reloadData()
//        self.present(alert, animated: true)
//        print("\(indexPath)")
//    }
//    
//
//}
//
//extension PhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
//{
//    func imagePickerController(_ picker: UIImagePickerController,
//                               didFinishPickingMediaWithInfo info: [String : AnyObject])
//    {
//        var chosenImage = UIImage()
//        chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
//        
//        dismiss(animated:true, completion: nil) //5
//        showInputDialog()
//        
//        self.chosenPhoto = chosenImage
//    }
//    
//    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        dismiss(animated: true, completion: nil)
//    }
//    
//    func showInputDialog(){
//        //Creating UIAlertController and
//        //Setting title and message for the alert dialog
//        let alertController = UIAlertController(title: "Notice", message: "Enter a description for the photo, \n e.g This is my son.", preferredStyle: .alert)
//        
//        //the confirm action taking the inputs
//        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
//            
//            //getting the input values from user
//            let photoDesc = (alertController.textFields?[0].text)!
//            if photoDesc.isEmpty
//            {
//                self.promptMessage(title: "Oops", message: "The description cannot be null")
//                
//            }
//            else{
//                let newPhoto = Photo(title: photoDesc, featuredImage: self.chosenPhoto!, color: UIColor(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 0.5))
//                self.photos.append(newPhoto)
//                self.collectionView.reloadData()
//                
//                self.promptMessage(title: "Ta-da!", message: "You've successfully added a new photo")
//
//            }
//            
//        }
//        
//        //the cancel action doing nothing
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
//        
//        //adding textfields to our dialog box
//        alertController.addTextField { (textField) in
//            textField.placeholder = "Enter Name"
//        }
//        
//        
//        //adding the action to dialogbox
//        alertController.addAction(confirmAction)
//        alertController.addAction(cancelAction)
//        
//        //finally presenting the dialog box
//        self.present(alertController, animated: true, completion: nil)
//        
//    }
//    
//    func promptMessage(title: String, message: String)
//    {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        self.present(alert, animated: true, completion: nil)
//        
//        // change to desired number of seconds (in this case 5 seconds)
//        let when = DispatchTime.now() + 2
//        DispatchQueue.main.asyncAfter(deadline: when){
//            // your code with delay
//            alert.dismiss(animated: true, completion: nil)
//        }
//    }
//    
//    
//}



