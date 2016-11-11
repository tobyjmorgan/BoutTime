    //
//  WebViewController.swift
//  BoutTimeGame
//
//  Created by redBred LLC on 11/6/16.
//  Copyright © 2016 redBred. All rights reserved.
//

// defining delegate protocol so this view controller can
// maintain a loose relationship with whatever called it
protocol WebViewDelegate {
    func getContentURL() -> URL?
    func onWebViewDismiss()
}

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    // optional delegate property which must conform to our protocol
    var delegate: WebViewDelegate? = nil
    
    // our outlets
    @IBOutlet var webView: UIWebView!

    // the failure label will only appear if the delegate was not set, if the url was
    // not provided, or if the url fails to load
    @IBOutlet var failureLabel: UILabel!
    
    // activity indicator to let the user know we are trying to load the details
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
 
    // just call our delegate's equivalent method to handle the response
    @IBAction func onDismiss() {
        delegate?.onWebViewDismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // we are the webview's delegate, this allows us to track when
        // the url is successfully loaded, or if it fails
        webView.delegate = self
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        failureLabel.isHidden = true
        
        // get the information we need from the delegate and update the web view
        if let url = delegate?.getContentURL() {
            
            let urlRequest = URLRequest(url: url)
            webView.loadRequest(urlRequest)
            
        } else {
            
            // if the delegate was not set, or if the url was not provided
            // then there's not much we can do
            failureLabel.isHidden = false
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        // great we loaded the page, turn off the indicator
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {

        // bummer, we couldn't load the page, turn off the indicator
        // and display a message
        failureLabel.isHidden = false
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
}
