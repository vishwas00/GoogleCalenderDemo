//
//  WebViewController.swift
//  GoogleCalenderDemo
//
//  Created by Anil Kumar on 12/03/19.
//  Copyright © 2019 Busywizzy. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    var url = ""
    var isAudio = false
    override func viewDidLoad() {
        super.viewDidLoad()
        let url: URL! = URL(string: self.url)
        webView.load(URLRequest(url: url))
        webView.navigationDelegate = self
        if isAudio == false {
        Indicator.sharedInstance.showIndicator()
        }
    }
}
extension WebViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Indicator.sharedInstance.hideIndicator()
    }
}
