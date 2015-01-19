//
//  NowPlayingViewController.swift
//  AcceptableRadio
//
//  Created by Jake on 1/17/15.
//  Copyright (c) 2015 Acceptable Ice Development. All rights reserved.
//

import Foundation
import UIKit

class NowPlayingViewController : UIViewController {
    
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var albumImage: UIImageView!
    
    @IBOutlet weak var channelName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
