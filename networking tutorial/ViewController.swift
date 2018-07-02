//
//  ViewController.swift
//  networking tutorial
//
//  Created by jpa87 on 6/29/18.
//  Copyright © 2018 jpa87. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController,  CLLocationManagerDelegate{
    
    var posts = [Post]()
    var locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //tap a button to send the request
    @IBAction func buttonTapped(_ sender: UIButton) {
        
        getPosts(for: 1) { (result) in
            switch result {
            case .success(let posts):
                self.posts = posts
                print(posts)
            case .failure(let error):
                fatalError("error: \(error.localizedDescription)")
            }
        }
    }
    //Tap a button to send a post request
    @IBAction func postButtonTapped(_ sender: UIButton) {
        //init location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        //how you get location from locationmanager is locationManager.location?.coordinate.latitude
        /*let myPost = Post(userId: 1, id: 1, title: "Hello world", body: "How are you feeling")
        submitPost(post: myPost){ (error) in
            if let error = error{
                fatalError(error.localizedDescription)
            }
        }*/
    }
    //this will be called when the location manager is initialized
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //get user location
        let userLocation: CLLocation = locations[0] as CLLocation
        //stop updating location after getting location
        manager.stopUpdatingLocation()
        //coordinates for easier usage
        let coordinates = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        //check if location is actually gotten
        print("Location", coordinates.latitude, coordinates.longitude)
        //create a posting with the info and the location
        let myPosting = Posting(userEmail: "me@yes.com", userName: "Justin Pan", latitude: coordinates.latitude, longitude: coordinates.longitude)
        //send as a post to the server
        submitPost(post: myPosting){(error) in
            if let error = error{
                fatalError(error.localizedDescription)
            }
        }
    }
}

