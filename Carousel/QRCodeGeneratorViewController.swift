//
//  QRCodeGeneratorViewController.swift
//  Carousel
//
//  Created by Priyanka Gopakumar on 6/5/17.
//  Copyright © 2017 200OK. All rights reserved.
//

import UIKit

class QRCodeGeneratorViewController: UIViewController {
    
    // device UUID to generate a unique QR Code
    var deviceUUID: String?
    // for the QR code image (Core Image)
    var qrcodeImage: CIImage!

    @IBOutlet var outerView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    required init?(coder aDecoder: NSCoder) {
        deviceUUID = nil
        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.layer.cornerRadius = 5
        // Allowing the patient to return to the main screen by clicking anywhere if the QR code buttom is clicked by mistake
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(QRCodeGeneratorViewController.goBackToMainScreen))
        outerView.addGestureRecognizer(tap)
        
        // Reading the UUID of the device
        self.deviceUUID = UIDevice.current.identifierForVendor!.uuidString
        print ("Device UUID is \(self.deviceUUID)")
        
        // Generating QR Code
        generateQRCode()
        displayQRCodeImage()
        
        // writing it to data.plist
        writingDataToPList()
        
    }
    
    func goBackToMainScreen() {
        //self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func generateQRCode()
    {
        let data = self.deviceUUID?.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        
        qrcodeImage = filter?.outputImage
        
    }
    
    func displayQRCodeImage() {
        let scaleX = self.qrCodeImageView.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = self.qrCodeImageView.frame.size.height / qrcodeImage.extent.size.height
        let transformedImage = qrcodeImage.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
        self.qrCodeImageView.image = UIImage(ciImage: transformedImage)
    }
    
    @IBAction func returnToMainView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func readUUIDFromDataPList()
    {
        var format = PropertyListSerialization.PropertyListFormat.xml
        //var format = PropertyListSerialization.PropertyListFormat.XMLFormat_v1_0 //format of the property list
        var plistData:[String:AnyObject] = [:]  //our data
        let plistPath:String? = Bundle.main.path(forResource: "data", ofType: "plist")! //the path of the data
        let plistXML = FileManager.default.contents(atPath: plistPath!)! //the data in XML format
        let plistDictionary = NSMutableDictionary(contentsOfFile: plistPath!)
        
        do{
            //convert the data to a dictionary and handle errors.
            plistData = try PropertyListSerialization.propertyList(from: plistXML,options: .mutableContainersAndLeaves,format: &format)as! [String:AnyObject]
            
            print("Device UUID read from data.plist is \(plistData["deviceUUID"] as! String)")
        }
        catch{ // error condition
            print("Error reading plist: \(error), format: \(format)")
        }
    }
    
    func writingDataToPList()
    {
        let plistPath:String? = Bundle.main.path(forResource: "data", ofType: "plist")! //the path of the data
        let plistDictionary = NSMutableDictionary(contentsOfFile: plistPath!)
        
        do{
                // Reading the UUID of the device
                self.deviceUUID = UIDevice.current.identifierForVendor!.uuidString
                plistDictionary?.setObject(self.deviceUUID, forKey: "deviceUUID" as NSCopying)
            var success: Bool = (plistDictionary?.write(toFile: plistPath!, atomically: true))!
            if success
            {
                print ("Successfully wrote to data.plist")
                readUUIDFromDataPList()
            }
            else
            {
                print ("Writing to data.plist unsuccessful")
            }
        }
        catch{ // error condition
            print("Error writing to plist: \(error)")
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

}
