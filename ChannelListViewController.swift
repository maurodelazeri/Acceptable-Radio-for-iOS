//
//  ViewController.swift
//  AcceptableRadio
//
//  Created by Jake on 1/16/15.
//  Copyright (c) 2015 Acceptable Ice Development. All rights reserved.
//

import UIKit

class ChannelListViewController: UITableViewController {
    
    var ChannelListing: [Channel] = [];
    
    var mainController: MainViewController!

    func refreshChannelListing() {
        println("Refreshing channels listing...");
        ChannelListing = [];
        let url = NSURL(string: "http://radio.acceptableice.com/actions/loadChannels.php");
        var request = NSURLRequest(URL: url!);
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            let rawData = NSString(data: data, encoding: NSUTF8StringEncoding);
            let xml = SWXMLHash.parse(rawData!);
            
            for elem in xml["channels"]["channel"] {
                var title: String! = elem["title"].element?.text!;
                var imgUrl: String! = elem["image"].element?.text!;
                var desc: String! = elem["description"].element?.text!;
                var img: UIImage = UIImage(data: NSData(contentsOfURL: NSURL(string: imgUrl)!, options: nil, error: nil)!)!;
                var fastpls: String! = elem["fastpls"][0].element?.text!;
                var streamCode: String! = fastpls.componentsSeparatedByString("/")[3].componentsSeparatedByString(".")[0];
                self.ChannelListing.append(Channel(name: title, image: img, desc: desc, identifier: streamCode));
                println(title + ", " + imgUrl);
            }
            
            //UI needs to be updated by the main thread
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
        task.resume()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChannelListing.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChannelCell", forIndexPath: indexPath)  as ChannelListCell;
        let channel = ChannelListing[indexPath.row] as Channel;
        cell.nameLabel?.text = channel.name;
        cell.channelImage.image = channel.image;
        cell.descLabel?.text = channel.desc;
        return cell;
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let channel = ChannelListing[indexPath.row] as Channel;
        mainController.setChannel(channel);
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        refreshChannelListing();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

