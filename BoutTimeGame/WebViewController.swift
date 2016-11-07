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

class WebViewController: UIViewController {
    
    // optional delegate property which must conform to our protocol
    var delegate: WebViewDelegate? = nil
    
    // our outlets
    // the failure label will only appear if the delegate was not set
    // or if the url was not provided
    @IBOutlet var webView: UIWebView!
    @IBOutlet var failureLabel: UILabel!
 
    // just call our delegate's equivalent method to handle the response
    @IBAction func onDismiss() {
        delegate?.onWebViewDismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // get the information we need from the delegate and update the web view
        if let url = delegate?.getContentURL() {
            
            failureLabel.isHidden = true
            
            let urlRequest = URLRequest(url: url)
            webView.loadRequest(urlRequest)
            
        } else {
            
            // if the delegate was not set, or if the url was not provided
            // then there's not much we can do
            failureLabel.isHidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
