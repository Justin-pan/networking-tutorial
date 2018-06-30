//
//  ViewController.swift
//  networking tutorial
//
//  Created by jpa87 on 6/29/18.
//  Copyright © 2018 jpa87. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var posts = [Post]()
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
        let myPost = Post(userId: 1, id: 1, title: "Hello world", body: "How are you feeling")
        submitPost(post: myPost){ (error) in
            if let error = error{
                fatalError(error.localizedDescription)
            }
        }
    }
    
}

