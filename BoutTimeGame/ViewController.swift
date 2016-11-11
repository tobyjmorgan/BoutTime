//
//  ViewController.swift
//  BoutTimeGame
//
//  Created by redBred LLC on 11/6/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController, ScoreViewDelegate, WebViewDelegate {

    /////////////////////////////////////////////////////////////////////////////
    // MARK: IBOutlets
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var shakeLabel: UILabel!
    @IBOutlet var startButtonView: UIView!
    @IBOutlet var nextRoundSuccess: UIButton!
    @IBOutlet var nextRoundFailure: UIButton!
    
    
    /////////////////////////////////////////////////////////////////////////////
    // MARK: IBOutlets collections to simplify accessing groups of GUI elements
    @IBOutlet var eventButtons: [UIButton]!
    @IBOutlet var eventLabels: [UILabel]!
    @IBOutlet var directionButtons: [UIButton]!
    @IBOutlet var eventContainers: [UIView]!
    @IBOutlet var eventYearLabels: [UILabel]!
    
    /////////////////////////////////////////////////////////////////////////////
    // MARK: IBActions
    
    // called when an event is touched (more detail)
    @IBAction func onTouchEvent(_ sender: UIButton) {
        
        // only perform button handling if we are between rounds
        guard model.gameState == .betweenRounds else {
            return
        }
        
        // using the button's tag to identify which historical event to show the details for
        if model.currentRoundsEvents.indices.contains(sender.tag) {
            model.lastSelectedEvent = model.currentRoundsEvents[sender.tag]
        }
        
        // perform web view segue
        performSegue(withIdentifier: "webViewSegue", sender: self)
    }
    
    // called when any directional arrow button is touched
    @IBAction func onDirectionButton(_ sender: UIButton) {
        
        // only perform button handling if we are in playing mode
        guard model.gameState == .playingRound else {
            return
        }
        
        // identify the clicked button ny its tag and send the appropriate 
        // instructions to the model
        switch sender.tag {
            case 1:
                model.moveElement(elementIndex: 0, direction: .down)
                playClickSound()
            case 2:
                model.moveElement(elementIndex: 1, direction: .up)
                playClickSound()
            case 3:
                model.moveElement(elementIndex: 1, direction: .down)
                playClickSound()
            case 4:
                model.moveElement(elementIndex: 2, direction: .up)
                playClickSound()
            case 5:
                model.moveElement(elementIndex: 2, direction: .down)
                playClickSound()
            case 6:
                model.moveElement(elementIndex: 3, direction: .up)
                playClickSound()
            default:
                break
        }
    }
    
    // called when either of the next round buttons is touched
    @IBAction func onNextRound() {
        
        // if we have played a full set of rounds then show the score
        if model.roundsPlayed == model.maxNumberOfRounds {
            
            // perform score view segue
            model.gameState = .showingScore
            performSegue(withIdentifier: "scoreViewSegue", sender: self)
            playQuizOverSound()
            
        } else {
            
            // otherwise start the next round
            startRound()
        }
    }
    
    // called when the flashing start game button is touched
    @IBAction func onStartGame() {
        // hide the start button
        startButtonView.isHidden = true
        stopFlashingButton()
        
        startRound()
    }
    
    
    
    
    // sounds
    var gameSound: SystemSoundID = 0
    var correctSound: SystemSoundID = 0
    var incorrectSound: SystemSoundID = 0
    var quizOver: SystemSoundID = 0
    var clickSound: SystemSoundID = 0

    // create an instance of the model
    let model = BoutTimeModel()
    
    // homegrown TimerHelper class to clean up timer usage
    var timer: TimerHelper?
    
    // just to keep track of whether we prompted the player yet
    var showedTheAlert: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // load sounds ready to be used later
        loadGameSounds()
        
        // homegrown TimerHelper class to clean up timer usage
        // created and ready to use
        timer = TimerHelper(duration: 1.0, repeats: true, closure: self.decrementCounter)
        
        // set up some notification observers to handle events from the model
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.onEventsChanged), name: NSNotification.Name(rawValue: BoutTimeModel.notificationEventsReady), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.onEventsChanged), name: NSNotification.Name(rawValue: BoutTimeModel.notificationEventsChanged), object: nil)
        
        getReadyToStartGame()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // round the corners of various bits and bobs
        startButtonView.layer.cornerRadius = 24.0
        
        for container in eventContainers {
            
            // lovely bit of code for rounding only specific corners of a view found at:
            // http://stackoverflow.com/questions/10167266/how-to-set-cornerradius-for-only-top-left-and-top-right-corner-of-a-uiview
            
            let path = UIBezierPath(roundedRect:container.bounds,
                                    byRoundingCorners:[.topLeft, .bottomLeft],
                                    cornerRadii: CGSize(width: 4.0, height:  4.0))
            
            let maskLayer = CAShapeLayer()
            
            maskLayer.path = path.cgPath
            container.layer.mask = maskLayer
        }
        
        if !showedTheAlert {
            
            let alert = UIAlertController(title: "Welcome!", message: "To play the game, arrange the historical events in order from oldest at the top, to most recent at the bottom. Good luck.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it!", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)

            showedTheAlert = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let scoreVC = segue.destination as? ScoreViewController {
            scoreVC.delegate = self
        } else if let webVC = segue.destination as? WebViewController {
            webVC.delegate = self
        }
    }

    func getReadyToStartGame() {
        
        model.gameState = .betweenRounds
        
        // reset the model
        model.resetGame()
        
        // get the screen set up for start of game
        clearEventDescriptions()
        refreshTimerLabel()
        disableEventButtons()
        disableDirectionButtons()
        hideYearLabels()
        
        nextRoundSuccess.isHidden = true
        nextRoundFailure.isHidden = true
        shakeLabel.isHidden = true
        startButtonView.isHidden = false
        startFlashingButton()
    }

    func startRound() {
        
        nextRoundFailure.isHidden = true
        nextRoundSuccess.isHidden = true
        
        shakeLabel.text = "Shake to complete"
        shakeLabel.isHidden = false
        
        disableEventButtons()
        enableDirectionButtons()
        hideYearLabels()
        
        // ask the model to set up an event set
        model.setUpEventSet()
        
        model.gameState = .playingRound
        model.roundsPlayed += 1
        startTimer()
        playGameStartSound()
    }
    
    
    
    
    ///////////////////////////////////////////////////////////////////////////
    // MARK: historical event handling
    
    func clearEventDescriptions() {
        
        // clear out any existing descriptions
        for label in eventLabels {
            label.text = ""
        }
    }
    
    func onEventsChanged() {
        
        clearEventDescriptions()
        
        // iterate through the buttons in the IBOutlet collection
        for label in eventLabels {
            
            // since with IBOutlet collections we cannot be sure of the order of
            // its members, each label has been tagged with an integer between 0...3
            // rather than using the label's implicit order, we will use this tag
            // as the index to use when fetching the event from the model
            if model.currentRoundsEvents.indices.contains(label.tag) {
                
                label.text = model.currentRoundsEvents[label.tag].eventDescription
            }
        }
        
        for yearLabel in eventYearLabels {
            
            // since with IBOutlet collections we cannot be sure of the order of
            // its members, each label has been tagged with an integer between 0...3
            // rather than using the label's implicit order, we will use this tag
            // as the index to use when fetching the event from the model
            if model.currentRoundsEvents.indices.contains(yearLabel.tag) {
                
                let suffix: String
                var year = model.currentRoundsEvents[yearLabel.tag].year
                
                // if negative use BCE instead
                if year < 0 {
                    
                    suffix = " BCE"
                    year = year * -1
                    
                } else {
                    
                    suffix = ""
                }
                
                yearLabel.text = "\(year)" + suffix
            }
        }
    }
    
    
    
    
    ///////////////////////////////////////////////////////////////////////////
    // MARK: flashing start button
    
    // start button flashes to indicate to player what to do next
    func startFlashingButton() {
        
        // using tag as a toggle to determine what flash state it is in
        if startButtonView.tag == 0 {
            
            startButtonView.tag = 1
            startButtonView.backgroundColor = UIColor.TMRGBA(red: 255, green: 221, blue: 0, alpha: 255)
            
        } else {
            
            startButtonView.tag = 0
            startButtonView.backgroundColor = UIColor.TMRGBA(red: 224, green: 131, blue: 10, alpha: 255)
        }
        
        // relaunch the timer for the next toggling
        perform(#selector(ViewController.startFlashingButton), with: nil, afterDelay: 0.6)
    }
    
    // turn off the flashing
    func stopFlashingButton() {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(ViewController.startFlashingButton), object: nil)
        
        // normalize the start button again
        startButtonView.tag = 0
        startButtonView.backgroundColor = UIColor.TMRGBA(red: 224, green: 131, blue: 10, alpha: 255)
    }
    
    
    
    
    
    ///////////////////////////////////////////////////////////////////////////
    // MARK: Timer handling
    func startTimer() {
        
        // reset the model, refresh the timer label and start the timer
        model.resetTimer()
        refreshTimerLabel()
        timer?.startTimer()
    }
    
    func stopTimer() {
        timer?.stopTimer()
    }
    
    // update the label with model's current value
    func refreshTimerLabel() {
        
        let minutes = Int(model.timerSecondsRemaining / 60)
        let seconds = Int(model.timerSecondsRemaining % 60)
        
        timerLabel.text = "\(minutes):\(String(format: "%02d", seconds))"
    }
    
    func decrementCounter() {
        
        // decrement the number of seconds in model
        model.timerSecondsRemaining -= 1
        
        // check to see if we have run out of time
        if model.timerSecondsRemaining <= 0 {
            
            refreshTimerLabel()
            
            // ensure seconds remaining never drops below zero
            model.timerSecondsRemaining = 0
            
            // we have run out of time
            timesUp()
            
        } else {
            
            refreshTimerLabel()
        }
    }
    
    func timesUp() {
        
        // stop the timer
        stopTimer()
        
        // do whatever needs to be done for the end of the round
        handleEndOfRound()
    }
    
    func handleEndOfRound() {
        
        model.gameState = .betweenRounds
        
        shakeLabel.text = "Tap events to learn more"
        shakeLabel.isHidden = false
        
        disableDirectionButtons()
        enableEventButtons()
        showYearLabels()
        
        if model.isCurrentRoundOrderedCorrectly() {
            
            playCorrectSound()
            nextRoundSuccess.isHidden = false
            model.score += 1
            
        } else {
            
            playIncorrectSound()
            nextRoundFailure.isHidden = false
        }
    }
    
    
    
    
    ///////////////////////////////////////////////////////////////////////////
    // MARK: shake handling
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        
        // onle perform button handling if we are in playing mode
        guard model.gameState == .playingRound else {
            return
        }
        
        if motion == UIEventSubtype.motionShake {
            
            // ensure the timer is stopped
            stopTimer()

            // do whatever needs to be done for the end of the round
            handleEndOfRound()
        }
    }

    
    
    
    ///////////////////////////////////////////////////////////////////////////
    // MARK: year label handling
    
    func showYearLabels() {
        
        for label in eventYearLabels {
            label.isHidden = false
        }
    }
    
    func hideYearLabels() {
        
        for label in eventYearLabels {
            label.isHidden = true
        }
    }

    
    
    
    ///////////////////////////////////////////////////////////////////////////
    // MARK: direction button handling
    
    func enableDirectionButtons() {
        
        for button in directionButtons {
            button.isEnabled = true
        }
    }
    
    func disableDirectionButtons() {
        
        for button in directionButtons {
            button.isEnabled = false
        }
    }
    
    
    
    
    ///////////////////////////////////////////////////////////////////////////
    // MARK: event button handling
    
    func enableEventButtons() {
        
        for button in eventButtons {
            button.isEnabled = true
        }
    }
    
    func disableEventButtons() {
        
        for button in eventButtons {
            button.isEnabled = false
        }
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
        getReadyToStartGame()
    }
    
    
    
    
    ///////////////////////////////////////////////////////////////////////////
    // MARK: WebViewDelegate
    func getContentURL() -> URL? {
        
        return model.lastSelectedEvent?.detailsURL
    }
    
    func onWebViewDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    /////////////////////////////////////////////////////////////////
    // MARK: Sound Methods
    
    func loadSound(filename: String, systemSound: inout SystemSoundID) {
        
        if let pathToSoundFile = Bundle.main.path(forResource: filename, ofType: "wav") {
            
            let soundURL = URL(fileURLWithPath: pathToSoundFile)
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &systemSound)
        }
    }
    
    func loadGameSounds() {
        
        loadSound(filename: "GameSound", systemSound: &gameSound)
        loadSound(filename: "Correct", systemSound: &correctSound)
        loadSound(filename: "Incorrect", systemSound: &incorrectSound)
        loadSound(filename: "QuizOver", systemSound: &quizOver)
        loadSound(filename: "Click", systemSound: &clickSound)
    }
    
    func playGameStartSound() {
        AudioServicesPlaySystemSound(gameSound)
    }
    
    func playCorrectSound() {
        AudioServicesPlaySystemSound(correctSound)
    }
    
    func playIncorrectSound() {
        AudioServicesPlaySystemSound(incorrectSound)
    }
    
    func playQuizOverSound() {
        AudioServicesPlaySystemSound(quizOver)
    }

    func playClickSound() {
        AudioServicesPlaySystemSound(clickSound)
    }
}

