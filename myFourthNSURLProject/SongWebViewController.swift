//
//  SongWebViewController.swift
//  myFourthNSURLProject
//
//  Created by rails on 24/07/19.
//  Copyright © 2019 rails. All rights reserved.
//

import UIKit
import WebKit

class SongWebViewController: UIViewController {

    @IBOutlet weak var songWebView: WKWebView!
    var urlString : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("in webView")
        if let urlString = urlString{
            print("everything is fine")
            let url = URL(string: urlString)
            if let url = url {
                let request = URLRequest(url: url)
                songWebView.load(request)
                print("everything is fine")
            }
        }
    }

}
