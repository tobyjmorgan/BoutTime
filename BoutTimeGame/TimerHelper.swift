//
//  TimerHelper.swift
//  BoutTimeGame
//
//  Created by redBred LLC on 11/10/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

class TimerHelper: NSObject {
    
    var timer: Timer = Timer()
    
    let duration: TimeInterval
    let closure: (() -> ())
    let repeats: Bool
    
    init(duration: TimeInterval, repeats: Bool, closure: @escaping () -> Void) {
        self.duration = duration
        self.closure = closure
        self.repeats = repeats
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(TimerHelper.performAction), userInfo: nil, repeats: repeats)
    }
    
    func stopTimer() {
        timer.invalidate()
    }
    
    @objc func performAction() {
        closure()
    }
}
