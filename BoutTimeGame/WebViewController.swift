//
//  WebViewController.swift
//  BoutTimeGame
//
//  Created by redBred LLC on 11/6/16.
//  Copyright © 2016 redBred. All rights reserved.
//

protocol WebViewDelegate {
    func getContentURL() -> URL?
    func onWebViewDismiss()
}

import UIKit

class WebViewController: UIViewController {
    
    @IBOutlet var webView: UIWebView!
    @IBOutlet var failureLabel: UILabel!
    
    @IBAction func onDismiss() {
        delegate?.onWebViewDismiss()
    }
    
    var delegate: WebViewDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if let url = delegate?.getContentURL() {
            
            failureLabel.isHidden = true
            
            let urlRequest = URLRequest(url: url)
            webView.loadRequest(urlRequest)
            
        } else {
            
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
