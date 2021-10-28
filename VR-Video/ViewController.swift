//
//  ViewController.swift
//  VR-Video
//
//  Created by Tom Salvo on 12/7/16.
//  Copyright © 2016 Tom Salvo. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let movieURL = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8") else { return }
        
        let movieTheaterView = MovieTheaterView(withPlayer: AVPlayer(url: movieURL))
        movieTheaterView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(movieTheaterView)
        
        self.view.addConstraints([
            NSLayoutConstraint(item: movieTheaterView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0.0),
            
            NSLayoutConstraint(item: movieTheaterView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0.0),
            
            NSLayoutConstraint(item: movieTheaterView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0),
            
            NSLayoutConstraint(item: movieTheaterView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0)])
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

