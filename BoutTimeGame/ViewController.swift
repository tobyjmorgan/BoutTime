//
//  ViewController.swift
//  BoutTimeGame
//
//  Created by redBred LLC on 11/6/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ScoreViewDelegate, WebViewDelegate {

    let model = BoutTimeModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    
    
    ///////////////////////////////////////////////////////////////////////////
    // MARK: ScoreViewDelegate
    func getCurrentScore() -> Int {
        return model.score
    }
    
    func getRoundsPlayed() -> Int {
        return model.roundsPlayed
    }
    
    func onPlayAgain() {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    ///////////////////////////////////////////////////////////////////////////
    // MARK: WebViewDelegate
    func getContentURL() -> URL? {
        
        return model.lastSelectedEvent?.detailsURL
    }
    
    func onWebViewDismiss() {
        dismiss(animated: true, completion: nil)
    }
}

