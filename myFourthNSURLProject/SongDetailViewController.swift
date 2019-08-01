//
//  SongDetailViewController.swift
//  myFourthNSURLProject
//
//  Created by rails on 23/07/19.
//  Copyright © 2019 rails. All rights reserved.
//

import UIKit
import AVFoundation

class SongDetailViewController: UIViewController {

    @IBOutlet weak var songImageView: UIImageView!
    @IBOutlet weak var songNameTextView: UITextView!
    @IBOutlet weak var songArtistNameTextView: UITextView!
    @IBOutlet weak var songPreviewButton: UIButton!
    @IBOutlet weak var playSongButton: UIButton!
    var songDataStructure = SongModelStructure()
    var audioPlayer = AVPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(songDataStructure)
        activateStrictModeUI()
        setDataToUI()
    }
    
    func activateStrictModeUI(){
        songNameTextView.isUserInteractionEnabled = false
        songArtistNameTextView.isUserInteractionEnabled = false
    }
    
    func setDataToUI(){
        getImageFromApiCall()
        songNameTextView.text = songDataStructure.trackName
        songArtistNameTextView.text = songDataStructure.artistName
    }
    
    
    @IBAction func playSongPreview(_ sender: UIButton) {
        let urlString = songDataStructure.previewUrl
        if let urlString = urlString{
            let url = URL(string: urlString)
            if let url = url {
                
                let playerItem = AVPlayerItem(url: url)
                self.audioPlayer = AVPlayer(playerItem:playerItem)
                audioPlayer.volume = 2.0
                audioPlayer.play()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextVC = segue.destination as? SongWebViewController
        if let nextVC = nextVC {
            let url = songDataStructure.songUrl
            if let url = url {
                nextVC.urlString = url
                
                print("setting data for next VC")
            }
        }
    }
    
    @IBAction func playSong(_ sender: UIButton) {
        print("perform segue")
        performSegue(withIdentifier: "segueToWebView", sender: nil)
    }
    
    func getImageFromApiCall(){
        let imageUrl = songDataStructure.image100
        if let imageUrl = imageUrl{
            let url = URL(string: imageUrl)
            URLSession.shared.dataTask(with: url!) { data, response, error in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data = data, error == nil,
                    let image = UIImage(data: data)
                    else { return }
                DispatchQueue.main.async() {
                    self.songImageView.image = image
                    print("Image data is printing")
                }
                }.resume()
        }
    }

}
