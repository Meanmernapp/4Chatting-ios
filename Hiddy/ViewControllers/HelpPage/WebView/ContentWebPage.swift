//
//  ContentWebPage.swift
//  HSLiveStream
//
//  Created by APPLE on 20/02/18.
//  Copyright © 2018 APPLE. All rights reserved.
//

import UIKit
import WebKit

class ContentWebPage: UIViewController,WKNavigationDelegate {

    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var contentWebView: WKWebView!
    
    @IBOutlet var indicator: UIActivityIndicatorView!
    
    var helpDict = NSDictionary()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        indicator.color = SECONDARY_COLOR

        self.contentWebView.navigationDelegate = self
            self.configureWebviewWithDetails(contentDict: helpDict)
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme()
        contentWebView.isOpaque = false
        self.contentWebView.backgroundColor = BACKGROUND_COLOR
        self.contentWebView.scrollView.backgroundColor = BACKGROUND_COLOR
        self.navigationView.backgroundColor = BOTTOM_BAR_COLOR

        self.changeRTLView()
    }
    override var prefersStatusBarHidden: Bool {
        return false
    }

    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.titleLbl.textAlignment = .right
            self.titleLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.contentWebView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.view.transform = .identity
            self.titleLbl.textAlignment = .left
            self.titleLbl.transform = .identity
            self.contentWebView.transform = .identity
        }
    }

    @IBAction func backBtnTapped(_ sender: Any) {
            self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Configure webview load content
    func configureWebviewWithDetails(contentDict:NSDictionary)  {
        self.navigationView.elevationEffect()
        self.titleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text:EMPTY_STRING)
        self.titleLbl.text = contentDict.value(forKey: "title") as? String
    
        let contentString:String = contentDict.value(forKey: "description") as! String
        var htmlString = String()
        htmlString = "<font face=\(APP_FONT_REGULAR) size='10' color='black'>\(contentString)"
        if #available(iOS 13.0, *) {
            if UserModel.shared.theme() == "Dark" || UITraitCollection.current.userInterfaceStyle == .dark{
                htmlString = "<font face=\(APP_FONT_REGULAR) size='10' color='white'>\(contentString)"
            }  //overrideUserInterfaceStyle = .dark
        }
        self.contentWebView.loadHTMLString(htmlString, baseURL: nil)
        self.indicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.indicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.indicator.stopAnimating()
    }
}
