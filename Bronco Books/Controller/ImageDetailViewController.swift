//
//  ImageDetailViewController.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 3/2/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    var photos: [UIImage] = []
    var selectedIndex: Int!
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        updateImage()
    }
    
    // MARK: - Helper Functions
    
    func updateImage() {
        imageView.image = photos[selectedIndex]
    }
    
    // MARK: - Selector Functions
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case .left:
                selectedIndex += 1
                if selectedIndex >= photos.count {
                    selectedIndex = 0
                }
                updateImage()
            case .right:
                selectedIndex -= 1
                if selectedIndex < 0 {
                    selectedIndex = photos.count - 1
                }
                updateImage()
            default:
                print("Neither left swipe nor right swipe was performed.")
            }
        }
    }
    
}
