//
//  SearchViewController.swift
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

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tblViewSearch: UITableView!
    var arNews = [NewsModel]()
    
    //MARK:- View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Search"
        self.tblViewSearch.tableFooterView = UIView(frame: .zero)
        self.tblViewSearch.setupAutoAdjust()
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        arNews.removeAll()
//        tblViewSearch.reloadData()
//        super.viewWillDisappear(animated)
//    }
    
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
        
        cell.lblTitle.text = modal.title
        if cell.lblTitle.calculateMaxLines() <= 1 {
            cell.lblTitle.text?.append("\n")
        }
        let imgUrl = URL(string:modal.urlToImage)
        cell.imgNews.kf.setImage(with: imgUrl, options: [.transition(.fade(0.5))])
        
        let urlText = URL(string:modal.url)
        let defaultURL = URL(string:"http://www.google.com")!

        let linkName = "Open in Browser"
        let font = UIFont.systemFont(ofSize: 14, weight: .light)
        let attributedString = NSMutableAttributedString(string: linkName)
        attributedString.setAttributes([.link: urlText ?? defaultURL,.font:font], range: NSMakeRange(0,linkName.count))
        
        cell.txtUrl.attributedText = attributedString
        cell.txtUrl.linkTextAttributes = [
            .foregroundColor: UIColor.blue,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
        ]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK:- UISearchBar Delegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)  {
        // print(searchBar.text)
      //  callTopSeachAPI(withText:searchBar.text ?? "")
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)  {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        arNews.removeAll()
        tblViewSearch.reloadData()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count>=3 {
           callTopSeachAPI(withText: searchBar.text ?? "" )
        }else {
            arNews.removeAll()
            tblViewSearch.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        guard range.location == 0 else {
            return true
        }
        let newString = (searchBar.text! as NSString).replacingCharacters(in: range, with: text) as NSString
        return newString.rangeOfCharacter(from:CharacterSet.whitespacesAndNewlines).location != 0
    }
    
    
    // MARK:- API Call
    func callTopSeachAPI(withText:String){
        
        let reachability = Reachability()!
        guard reachability.connection != .none else {
            self.tblViewSearch.tableFooterView = UIView(frame: .zero)
            showAlertWithMessage(alertMessage:Constant.AlertMessage.networkErrorMessage)
            return
        }
        self.arNews.removeAll()
        tblViewSearch.reloadData()
        
        SVProgressHUD.show()
        let urlString = withText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        guard let url = URL(string:"https://newsapi.org/v2/everything?q=\(urlString ?? "")&apiKey=\(Constant.ApiKey)") else {return}
        print(url)
        
        Alamofire.request(url, method:.get, parameters:nil ).responseJSON { (response) in
            if response.result.isSuccess {
                let  newsJSON : JSON = JSON(response.result.value!)
               
                for arr in newsJSON["articles"].arrayValue {
                    self.arNews.append(NewsModel(json:arr))
                }
              //  self.arNews = self.arNews.filter { $0.title.localizedCaseInsensitiveContains(withText)}

                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.tblViewSearch.reloadData()
                }
            }
            else {
                SVProgressHUD.dismiss()
            }
        }
    }
    
    // MARK: - Custom Method
    func isValidURL(strURL:String) -> Bool {
        let urlRegEx = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        return urlTest.evaluate(with: strURL)
    }
    
    func showAlertWithMessage(alertMessage:String)  {
        let alert = UIAlertController(title:Constant.AppName, message:alertMessage,preferredStyle:.alert)
        let ok = UIAlertAction(title: "OK", style:.default) { (action) in
        }
        alert.addAction(ok)
        present(alert, animated: true,completion:nil)
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Search" {
            if let indexPath = tblViewSearch.indexPathForSelectedRow{
                let selectedRow = indexPath.row
                let newsDetail = segue.destination as! NewsDetailViewController
                newsDetail.newsDetailModel =  arNews[selectedRow]
            }
        }
    }
    
}
