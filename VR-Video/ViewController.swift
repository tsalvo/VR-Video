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

    private weak var movieTheaterView: MovieTheaterView?
    
    override var prefersHomeIndicatorAutoHidden: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let movieURL = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8"),
              let movieTheaterView = MovieTheaterView(withPlayer: AVPlayer(url: movieURL))
        else { return }
        
        movieTheaterView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(movieTheaterView)
        
        self.view.leadingAnchor.constraint(equalTo: movieTheaterView.leadingAnchor).isActive = true
        self.view.trailingAnchor.constraint(equalTo: movieTheaterView.trailingAnchor).isActive = true
        self.view.topAnchor.constraint(equalTo: movieTheaterView.topAnchor).isActive = true
        self.view.bottomAnchor.constraint(equalTo: movieTheaterView.bottomAnchor).isActive = true
        
        self.movieTheaterView = movieTheaterView
    }
    
    @IBAction private func screenTapped(_ sender: AnyObject?) {
        self.movieTheaterView?.screenTapped()
    }
    
    @IBAction private func screenDoubleTapped(_ sender: AnyObject?) {
        self.movieTheaterView?.screenDoubleTapped()
    }
}

