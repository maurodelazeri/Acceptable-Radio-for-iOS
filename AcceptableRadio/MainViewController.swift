//
//  MainViewController.swift
//  AcceptableRadio
//
//  Created by Jake on 1/17/15.
//  Copyright (c) 2015 Acceptable Ice Development. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class MainViewController : UIViewController {
    
    var nowPlayingController: NowPlayingViewController!
    var channelListController: ChannelListViewController!

    var currentChannel: Channel? = nil;
    var musicPlayer: AVPlayer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        println("View loaded!");
        updateSongName("Sandstorm", artist: "Darude", album: "Sandstorm");
        
        NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "refreshNowPlaying", userInfo: nil, repeats: true )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //Get the subview controller instances
        switch (segue.identifier!) {
            case "NowPlayingSegue": nowPlayingController = segue.destinationViewController as NowPlayingViewController;
            case "ChannelListSegue":
                channelListController = segue.destinationViewController as ChannelListViewController;
                channelListController.mainController = self;
        default: break;//why do I have to do something wtf swift
        }
    }
    
    func refreshNowPlaying() {
        if(currentChannel == nil) {
            return;
        }
        println("Refreshing now playing data");
        let url = NSURL(string: "http://radio.acceptableice.com/actions/recentlyPlayed.php?station=" + self.currentChannel!.identifier);
        var request = NSURLRequest(URL: url!);
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            let rawData = NSString(data: data, encoding: NSUTF8StringEncoding);
            var parts = rawData!.componentsSeparatedByString("<tr>")
            var nowPlayingHtml = parts[3] as String;
            var tds = parts[3].componentsSeparatedByString("<td>");
            
            var artist = tds[2] as String;
            artist = artist.componentsSeparatedByString(">")[1].componentsSeparatedByString("<")[0];
            
            var song = tds[3] as String;
            song = song.componentsSeparatedByString("<")[0];
            
            var album = tds[4] as String;
            album = album.componentsSeparatedByString(">")[1].componentsSeparatedByString("<")[0];
            
            if(artist != self.nowPlayingController.artistName.text || song != self.nowPlayingController.songName.text) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.updateSongName(song, artist: artist, album: album);
                }
            }
        }
        task.resume()

    }
    
    func updateSongName(name: String, artist: String, album: String) {
        //darude - sandstorm
        println("Song name updated");
        nowPlayingController.songName.text = name;
        nowPlayingController.artistName.text = artist;
        getAlbumArt(artist, album: album);
    }
    
    func setChannel(channel: Channel) {
        println("Setting channel to " + channel.name);
        currentChannel = channel;
        nowPlayingController.channelName.text = "Listening to: " + channel.name;
        let channelStream = AVPlayerItem(URL: channel.getStreamURL());
        musicPlayer = AVPlayer(playerItem: channelStream);
        
        musicPlayer.rate = 1.0;
        musicPlayer.play();
        
    }
    
    func getAlbumArt(artist: String, album: String) {
        println("Pulling album art for " + artist + " - " + album);
        //Set default icon
        self.nowPlayingController.albumImage.image = UIImage(named: "defaultAlbum")
        self.nowPlayingController.albumImage.setNeedsDisplay();
        
        let baseUrl: String = "http://radio.acceptableice.com/actions/lastfm.php?method=album.getInfo&artist=" + artist + "&album=" + album;
        let encodedURL = baseUrl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding);
        let url = NSURL(string: encodedURL!);
        println(url);
        var request = NSURLRequest(URL: url!);
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            let rawData = NSString(data: data, encoding: NSUTF8StringEncoding)!;
            var list: NSDictionary = NSJSONSerialization.JSONObjectWithData(rawData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary;
            
            if let topList: NSDictionary = list["album"] as? NSDictionary {
                if let imgList = topList["image"] as? NSArray {
                    if let imgData = imgList[2] as? NSDictionary {
                        if let imgUrl = imgData["#text"] as String? {
                            if(countElements(imgUrl) > 0) {
                            let img = UIImage(data: NSData(contentsOfURL: NSURL(string: imgUrl)!, options: nil, error: nil)!)
                                dispatch_async(dispatch_get_main_queue()) {
                                    if img != nil {
                                        self.nowPlayingController.albumImage.image = img;
                                        self.nowPlayingController.albumImage.setNeedsDisplay();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        task.resume()
        
    }

    
    
}