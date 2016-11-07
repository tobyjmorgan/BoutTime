//
//  ScoreViewController.swift
//  BoutTimeGame
//
//  Created by redBred LLC on 11/6/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import UIKit

// defining delegate protocol so this view controller can
// maintain a loose relationship with whatever called it
protocol ScoreViewDelegate {
    func getCurrentScore() -> Int
    func getRoundsPlayed() -> Int
    func onPlayAgain()
}

class ScoreViewController: UIViewController {
    
    // optional delegate property which must conform to our protocol
    var delegate: ScoreViewDelegate?
    
    // outlet needed for the score label, so we can update its text
    @IBOutlet var scoreLabel: UILabel!
    
    // just call our delegate's equivalent method to handle the response
    @IBAction func onPlayAgain() {
        delegate?.onPlayAgain()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the information we need from the delegate and update the label
        if let delegate = delegate {
            
            scoreLabel.text = "\(delegate.getCurrentScore())/\(delegate.getRoundsPlayed())"
            
        } else {
            
            // if the delegate was not set, then there's not much we can do
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
