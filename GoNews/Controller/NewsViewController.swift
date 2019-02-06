//
//  NewsViewController.swift
//  GoNews
//
//  Created by Guest1 on 2/2/19.
//  Copyright © 2019 Nidhi. All rights reserved.
//

import UIKit
import Kingfisher
import SVProgressHUD
import Reachability
import Alamofire
import SwiftyJSON
import SafariServices

struct NewsModel {
    var title: String = ""
    var url : String = ""
    var urlToImage: String = ""
    
    init() {
    }
    init(json:JSON) {
        self.title = json["title"].stringValue
        self.url = json["url"].stringValue
        self.urlToImage = json["urlToImage"].stringValue
    }
}

class NewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,SFSafariViewControllerDelegate {
    
    @IBOutlet weak var tblViewNews: UITableView!
    var arNews = [NewsModel]()
    
    //MARK:- View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "News"
        self.tblViewNews.tableFooterView = UIView(frame: .zero)
        callTopNewsAPI()
    }
    
    
    // MARK:- UITableView Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arNews.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell") as! NewsTableViewCell
        
        let modal = arNews[indexPath.row]
        
        //        modal.urlToImage = "https://www.freeiconspng.com/uploads/news-icon-38.png"
        
        let imgUrl = URL(string:modal.urlToImage)
        cell.imgNews.kf.setImage(with: imgUrl, options: [.transition(.fade(0.5))])
        
        cell.lblTitle.text = modal.title
        if cell.lblTitle.calculateMaxLines() <= 1 {
            cell.lblTitle.text?.append("\n")
        }
        let urlText = URL(string:modal.url)
        let defaultURL = URL(string:"http://www.google.com")!
        
        let font = UIFont.systemFont(ofSize: 14, weight: .light)
        let linkName = "Open in Browser"
        let attributedString = NSMutableAttributedString(string:linkName)
        attributedString.setAttributes([.link: urlText ?? defaultURL,.font:font], range: NSMakeRange(0, linkName.count))
        
        cell.txtUrl.attributedText = attributedString
        cell.txtUrl.linkTextAttributes = [
            .foregroundColor: UIColor.blue,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
        ]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let urlString =  arNews[indexPath.row].url
        if let url = URL(string: urlString) {
            let vc = SFSafariViewController(url: url)
            vc.delegate = self
            present(vc, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK:- SFSafariViewController Delegate
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
    }

    
    // MARK:- API Call
    
    func callTopNewsAPI() {
        
        let reachability = Reachability()!
        guard reachability.connection != .none else {
            self.tblViewNews.tableFooterView = UIView(frame: .zero)
            showAlertWithMessage(alertMessage: Constant.AlertMessage.networkErrorMessage)
            return
        }
        
        SVProgressHUD.show()
        let url = "https://newsapi.org/v2/top-headlines?country=us&apiKey=\(Constant.ApiKey)"
        
        Alamofire.request(url, method:.get, parameters:nil ).responseJSON { (response) in
            if response.result.isSuccess {
                let  newsJSON : JSON = JSON(response.result.value!)
                for arr in newsJSON["articles"].arrayValue {
                    self.arNews.append(NewsModel(json:arr))
                }
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.tblViewNews.reloadData()
                }
            }
            else {
                SVProgressHUD.dismiss()
            }
        }
    }
    
    
    // MARK: - Custom Method
    func showAlertWithMessage(alertMessage:String)  {
        let alert = UIAlertController(title:Constant.AppName, message:alertMessage,preferredStyle:.alert)
        let ok = UIAlertAction(title: "OK", style:.default) { (action) in
        }
        alert.addAction(ok)
        present(alert, animated: true,completion:nil)
    }
    
    
}






