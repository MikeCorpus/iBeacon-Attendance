//
//  HomeViewController.swift
//  Apptendance
//
//  Created by jeffery leo on 4/26/15.
//  Copyright (c) 2015 jeffery leo. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class HomeViewController: UIViewController, ESTBeaconManagerDelegate, CLLocationManagerDelegate, CBPeripheralManagerDelegate
{
    let locationManager = CLLocationManager()
    let beaconManager = ESTBeaconManager()
    let major:CLBeaconMajorValue = UInt16(2)
    let minor:CLBeaconMinorValue = UInt16(59287)
    //set this beacon is belong to which class
    let beaconRegion = CLBeaconRegion (proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D"), major: CLBeaconMajorValue(), minor: CLBeaconMinorValue(), identifier: "LAB-2")
    let beacon = CLBeacon()
    
    @IBOutlet weak var lblClassStatus: UILabel!
    @IBOutlet weak var lblAttendance: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var bluetoothMessage: UILabel!

    var message:String = ""
    var playSound = false
    var bluetooth: CBPeripheralManager!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        beaconManager.delegate = self
        locationManager.delegate = self
        self.navigationController?.navigationBar.topItem?.title = "Attendance"
        if(locationManager.respondsToSelector("requestAlwaysAuthorization"))
        {
            locationManager.requestAlwaysAuthorization()
        }
        bluetooth = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        locationManager.startMonitoringForRegion(beaconRegion)
        locationManager.startRangingBeaconsInRegion(beaconRegion)
        locationManager.startUpdatingLocation()
        lblClassStatus.text = "Finding Classroom..."
        lblAttendance.text = "Waiting to take Attendance"
        activityIndicator.startAnimating()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func locationManager(manager: CLLocationManager!,
        didEnterRegion region: CLRegion!)
    {
        
        let major:CLBeaconMajorValue = UInt16(2)
        let minor:CLBeaconMinorValue = UInt16(59287)
        //set this beacon is belong to which class
        let beaconRegion = CLBeaconRegion (proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D"), major: CLBeaconMajorValue(), minor: CLBeaconMinorValue(), identifier: "G-1:ROOM-3")
        manager.startRangingBeaconsInRegion(beaconRegion)
        manager.startUpdatingLocation()
        lblClassStatus.text = "You are in the class"
        lblClassStatus.textColor = UIColor.greenColor()
        activityIndicator.stopAnimating()
        sendLocationNotificationMessage("You are in the class", playSound: true)
        
        if bluetooth.state == CBPeripheralManagerState.PoweredOn
        {
            var subjectCodeArray:NSMutableArray = []
            var timeArray:NSMutableArray = []
            var subjectCode = ""
            var time = ""
            var query = PFQuery(className: "Timetable")
            
            //TESTING
            query.whereKey("Intake", equalTo: CustomFunction.getCurrentIntake())
            query.whereKey("Day", equalTo: CustomFunction.getDayDate())
            query.whereKey("Time", containsString: "13:45")
            query.whereKey("Room", equalTo: beaconRegion.identifier)
//            query.whereKey("Intake", equalTo: CustomFunction.getCurrentIntake())
//            query.whereKey("Day", equalTo: CustomFunction.getDayDate())
//            query.whereKey("Time".substringWithRange(Range<String.Index>(start: advance("Time".startIndex, 8), end: advance("Time".endIndex, 0))), greaterThanOrEqualTo: "14:00")
//            query.whereKey("Time".substringWithRange(Range<String.Index>(start: advance("Time".startIndex, 0), end: advance("Time".startIndex, 4))), lessThanOrEqualTo: "14:00")
//            query.whereKey("Room", equalTo: beaconRegion.identifier)
            //TESTING
            query.findObjectsInBackgroundWithBlock //query the Timetable to get the subject that are having now
                {
                    (objects:[AnyObject]?, error:NSError?) -> Void in
                    if error == nil
                    {
                        for object in objects! as [AnyObject]
                        {
                            //get the Current subject
                            subjectCodeArray.addObject((object["SubjectCode"] as! NSString))
                            subjectCode = subjectCodeArray[0] as! String
                            
                            //get the current class time
                            timeArray.addObject(object["Time"] as! NSString)
                            time = timeArray[0] as! String
                        }
                        
                        //if no subjectcode inside, means no class currently
                        if subjectCodeArray.count == 0
                        {
                            self.lblAttendance.text = "You have no class currently"
                            self.lblAttendance.textColor = UIColor.redColor()
                            self.sendLocationNotificationMessage("You have no class currently", playSound: true)
                        }
                        else //got the class, once get into the class, take this attendance
                        {
                            //send data to the database as attendance
                            var attendance = PFObject(className: "Attendance")
                            attendance["Username"] = CustomFunction.getUsername()
                            attendance["IntakeCode"] = CustomFunction.getCurrentIntake()
                            attendance["SubjectCode"] = subjectCode
                            attendance["Date"] = CustomFunction.getDayDate()
                            attendance["Time"] = time
                            attendance.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                                if(success) //student data update successfully into attendance
                                {
                                    self.lblAttendance.text = "Your Attendance has been taken!"
                                    self.lblAttendance.textColor = UIColor.greenColor()
                                    self.sendLocationNotificationMessage("Your Attendance has been taken!", playSound: true)
                                }
                                else //fail to save the student attendance
                                {
                                    self.lblAttendance.text = "Failed to get attendance."
                                    self.lblAttendance.textColor = UIColor.redColor()
                                    self.sendLocationNotificationMessage("Failed to get attendance.", playSound: true)
                                }
                            })
                        }
                    }
                }
        }
    }
    func locationManager(manager: CLLocationManager!,
        didExitRegion region: CLRegion!)
    {
        manager.stopRangingBeaconsInRegion(region as! CLBeaconRegion)
        manager.stopUpdatingLocation()
        lblClassStatus.text = "Finding Classroom..."
        lblAttendance.text = "Waiting to take Attendance"
        lblClassStatus.textColor = UIColor.blackColor()
        lblAttendance.textColor = UIColor.blackColor()
        activityIndicator.startAnimating()
        sendLocationNotificationMessage("You exit the class", playSound: true)
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!)
    {
        var statusMessage = ""
        
        switch peripheral.state
        {
        case CBPeripheralManagerState.PoweredOn:
            statusMessage = "Bluetooth Status: Turned On"
            
        case CBPeripheralManagerState.PoweredOff:
            statusMessage = "Bluetooth Status: Turned Off"
            
        case CBPeripheralManagerState.Resetting:
            statusMessage = "Bluetooth Status: Resetting"
            
        case CBPeripheralManagerState.Unauthorized:
            statusMessage = "Bluetooth Status: Not Authorized"
            
        case CBPeripheralManagerState.Unsupported:
            statusMessage = "Bluetooth Status: Not Supported"
            
        default:
            statusMessage = "Bluetooth Status: Unknown"
        }
        
        bluetoothMessage.text = statusMessage
    }
    
}

extension HomeViewController:CLLocationManagerDelegate
{
    func sendLocationNotificationMessage(message: String!, playSound:Bool)
    {
        let notification:UILocalNotification = UILocalNotification()
        notification.alertBody = message
        if(playSound)
        {
            notification.soundName = UILocalNotificationDefaultSoundName
        }
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
}
