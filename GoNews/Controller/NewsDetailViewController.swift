//
//  NewsDetailViewController.swift
//  GoNews
//
//  Created by Guest1 on 2/2/19.
//  Copyright © 2019 Nidhi. All rights reserved.
//

import UIKit
import WebKit
import SVProgressHUD

class NewsDetailViewController: UIViewController, WKNavigationDelegate{
    
    @IBOutlet weak var webView: WKWebView!
    var newsDetailModel:NewsModel!
    
   //MARK:- View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let urlToOpen = URL(string:newsDetailModel.url) {
            let req = URLRequest(url: urlToOpen)
            webView.navigationDelegate = self
            webView.load(req)
            SVProgressHUD.show()
        }
    }
    
    //MARK:- WKNavigation Delegate
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            SVProgressHUD.dismiss()
        })
    }
}

