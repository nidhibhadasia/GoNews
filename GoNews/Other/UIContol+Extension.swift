//
//  UIContol+Extension.swift
//  GoNews
//
//  Created by Guest1 on 2/3/19.
//  Copyright © 2019 Nidhi. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    func calculateMaxLines() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
}


extension UITableView {
    
    func setupAutoAdjust()  {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardshown), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardhide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardshown(_ notification:Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.fitContentInset(inset: UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height-64, right: 0))
        }
    }
    @objc func keyboardhide(_ notification:Notification)  {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.fitContentInset(inset: .zero)
        }
    }
    
    func fitContentInset(inset:UIEdgeInsets!) {
        self.contentInset = inset
        self.scrollIndicatorInsets = inset
    }
}
