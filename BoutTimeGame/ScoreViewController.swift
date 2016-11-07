//
//  ScoreViewController.swift
//  BoutTimeGame
//
//  Created by redBred LLC on 11/6/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import UIKit

protocol ScoreViewDelegate {
    func getCurrentScore() -> Int
    func getRoundsPlayed() -> Int
    func onPlayAgain()
}

class ScoreViewController: UIViewController {
    
    var delegate: ScoreViewDelegate?
    
    @IBOutlet var scoreLabel: UILabel!
    
    @IBAction func onPlayAgain() {
        delegate?.onPlayAgain()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the information from the delegate and update the label
        if let delegate = delegate {
            
            scoreLabel.text = "\(delegate.getCurrentScore())/\(delegate.getRoundsPlayed())"
            
        } else {
            
            scoreLabel.text = "?/?"
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
