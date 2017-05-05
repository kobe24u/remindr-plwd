//
//  PanicMapViewController.swift
//  Carousel
//
//  Created by Priyanka Gopakumar on 10/4/17.
//  Copyright © 2017 200OK. All rights reserved.
//

import UIKit

class PanicMapViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    // creating a view to display a progress spinner while data is being loaded from the server
    var progressView = UIView()
    var currentPanicEvent: PanicEvent?
    
    // nearest hospital google maps URL
    var googleMapsURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //webView.loadRequest(URLRequest(url: URL(string: "https://www.google.com.au/maps")!))
        getNearestHospitalFromGoogleAPI()
        setProgressView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func phoneCallCaregiver(_ sender: Any) {
    }
    
    @IBAction func videoCallCaregiver(_ sender: Any) {
    }
    
    @IBAction func returnToAlbum(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func getNearestHospitalFromGoogleAPI()
    {
        
        var requestURL: String?
        requestURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\((currentPanicEvent?.receivedLat!)!),\((currentPanicEvent?.receivedLng!)!)&rankby=distance&type=hospital&key=AIzaSyCuzBXG3yuafhEAXg_aybtOzfU5LF0o5Lg"
        
        print ("request url is \(requestURL)")
        
        var url: NSURL = NSURL(string: requestURL!)!
        let task = URLSession.shared.dataTask(with: url as URL){
            (data, response, error) in
            if (error != nil)
            {
                print("Error \(error)")
                self.displayAlertMessage(title: "Connection Failed", message: "Failed to retrieve data from the server")
            }
            else
            {
                self.parseMapsJSON(mapsJSON: data! as NSData)
                
            }
            //self.syncCompleted = true
        }
        task.resume()
    }
    
    /*
     This function is invoked after the JSON data is downloaded from the server. The key-value method is used
     to extract all the necessary data.
     */
    func parseMapsJSON(mapsJSON:NSData){
        do{
            
            let result = try JSONSerialization.jsonObject(with: mapsJSON as Data, options: JSONSerialization.ReadingOptions.mutableContainers)
            if let query = result as? NSDictionary
            {
                if let results = query["results"] as? NSArray
                {
                    if let firstResult = results[0] as? NSDictionary
                    {
                        //                        if let geometry = firstResult["geometry"] as? NSDictionary
                        //                        {
                        //                            if let location = geometry["location"] as? NSDictionary
                        //                            {
                        //                                let lat = location.object(forKey: "lat") as! Double
                        //                                let lng = location.object(forKey: "lng") as! Double
                        //                                googleMapsURL = "https://www.google.com/maps/dir/current+location/\(lat),\(lng)"
                        //                                stopProgressView()
                        //                                webView.loadRequest(URLRequest(url: URL(string: googleMapsURL!)!))
                        //                            }
                        //                        }
                        if let name = firstResult.object(forKey: "name") as? String
                        {
                            googleMapsURL = "https://www.google.com/maps/dir/\((currentPanicEvent?.receivedLat!)!),\((currentPanicEvent?.receivedLng!)!)/\(name)"
                            
                            googleMapsURL = googleMapsURL?.replacingOccurrences(of: " ", with: "+")
                            //googleMapsURL = "https://www.google.com/maps/dir/-38.1645,145.3036/Cardinia+Casey+Community+Health+Service+Cranbourne"
                            //googleMapsURL = "https://maps.google.com/?cid=2058298626246245719"
                            stopProgressView()
                            webView.loadRequest(URLRequest(url: URL(string: googleMapsURL!)!))
                        }
                    }
                }
            }
        }
        catch{
            print("JSON Serialization error")
        }
    }
    
    
    /*
     A function to allow custom alerts to be created by passing a title and a message
     */
    func displayAlertMessage(title: String, message: String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
        self.stopProgressView()
    }
    
    
    /*
     Setting up the progress view that displays a spinner while the serer data is being downloaded.
     The view uses an activity indicator (a spinner) and a simple text to convey the information.
     Source: YouTube
     Tutorial: Swift - How to Create Loading Bar (Spinners)
     Author: Melih Şimşek
     URL: https://www.youtube.com/watch?v=iPTuhyU5HkI
     */
    func setProgressView()
    {
        // setting the UI specifications
        self.progressView = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
        self.progressView.backgroundColor = UIColor.lightGray
        self.progressView.layer.cornerRadius = 10
        let wait = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        wait.color = UIColor(red: 254/255, green: 218/255, blue: 2/255, alpha: 1)
        wait.hidesWhenStopped = false
        wait.startAnimating()
        
        let message = UILabel(frame: CGRect(x: 60, y: 0, width: 200, height: 50))
        message.text = "Retrieving data..."
        message.textColor = UIColor(red: 254/255, green: 218/255, blue: 2/255, alpha: 1)
        
        self.progressView.addSubview(wait)
        self.progressView.addSubview(message)
        self.progressView.center = self.view.center
        self.progressView.tag = 1000
        
    }
    
    /*
     This method is invoked to remove the progress spinner from the view.
     Source: YouTube
     Tutorial: Swift - How to Create Loading Bar (Spinners)
     Author: Melih Şimşek
     URL: https://www.youtube.com/watch?v=iPTuhyU5HkI
     */
    func stopProgressView()
    {
        let subviews = self.view.subviews
        for subview in subviews
        {
            if subview.tag == 1000
            {
                subview.removeFromSuperview()
            }
        }
    }
    
}



/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */


