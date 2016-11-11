//
//  BoutTimeModel.swift
//  BoutTimeGame
//
//  Created by redBred LLC on 11/6/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation
import GameKit

class BoutTimeModel {
    
    // create constants for notifications
    static let notificationEventsReady = "notificationEventsReady"
    static let notificationEventsChanged = "notificationEventsChanged"
    
    // enumeration for managing game state
    enum GameState {
        case betweenRounds
        case playingRound
        case showingScore
    }
    
    // set initial game state
    var gameState: GameState = .betweenRounds
    
    // these could be made constants, but in future may want to change
    // these between rounds e.g. gradually make the levels harder
    var maxNumberOfRounds: Int = 6
    var maxNumberOfSeconds: Int = 60
    var maxNumebrOfEventsInEachSet: Int = 4
    
    // variables to keep track of game progress
    var roundsPlayed: Int = 0
    var score: Int = 0
    var timerSecondsRemaining: Int = 0
    var currentRoundsEvents: [HistoricalEvent] = []
    var lastSelectedEvent: HistoricalEvent? = nil
    
    // array to hold all available historical events
    let allEvents: [HistoricalEvent]
    
    // initializer will attempt to load list of historical events from a plist
    init() {
        
        do {
            self.allEvents = try HistoricalEventPlistConverter.arrayFromFile(resource: "HistoricalEvents", ofType: "plist")
            
        } catch HistoricalEventPlistConverter.ConverterError.resourceNotFound {
            fatalError("Unable to find source data file.")
        } catch HistoricalEventPlistConverter.ConverterError.conversionError {
            fatalError("Unexpected structure found in source file.")
        } catch HistoricalEventPlistConverter.ConverterError.unarchivingError(let message) {
            fatalError(message)
        } catch {
            fatalError("Unknown error loading source data.")
        }
    }
    
    // reset the game model ready for the next go-around
    func resetGame() {
        roundsPlayed = 0
        score = 0
        resetTimer()
        currentRoundsEvents = []
        lastSelectedEvent = nil
    }
    
    // reset the timer
    func resetTimer() {
        timerSecondsRemaining = maxNumberOfSeconds
    }
    
    // set up the historical events ready for play
    func setUpEventSet() {
        
        if let events = getEventSet() {
            
            currentRoundsEvents = events
            
            // post a notification to anyone who is interested
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: BoutTimeModel.notificationEventsChanged), object: nil)
            
            // post a notification to anyone who is interested
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: BoutTimeModel.notificationEventsReady), object: nil)
        }
    }
    
    // if possible return an unused historical event from the available events
    func getUnusedRandomHistoricalEvent(usedEvents: [HistoricalEvent]) -> HistoricalEvent? {
        
        // only proceed if the allEvents array is populated
        // (its a constant so it bloody well should be)
        // and there are more events than have already been used
        // (again this should only be an issue if maxNumebrOfEventsInEachSet
        // exceeds the number of events in allEvents, which should never happen)
        guard allEvents.count > 0 && usedEvents.count < allEvents.count else {
            return nil
        }
        
        var newEvent: HistoricalEvent
        
        // keep picking a random event, until we find one that hasn't already been used
        repeat {
            
            // get a random index
            let newEventIndex = GKRandomSource.sharedRandom().nextInt(upperBound: allEvents.count)
            
            // ensure it is inside the bounds of the array
            guard allEvents.indices.contains(newEventIndex) else {
                // this should neven happen
                // but if it ever did - return nil
                return nil
            }
            
            // fetch the event using the event index
            newEvent = allEvents[newEventIndex]
            
        } while usedEvents.contains(newEvent) // if it has already been used, try again
        
        return newEvent
    }
    
    // get a fresh event set
    func getEventSet() -> [HistoricalEvent]? {
        
        // start off with an empty event set
        var historicalEvents: [HistoricalEvent] = []
        
        // we need 'maxNumebrOfEventsInEachSet' events in each set
        for _ in 1...maxNumebrOfEventsInEachSet {
            
            // fetch a random historical event that has not already been used
            if let newEvent = getUnusedRandomHistoricalEvent(usedEvents: historicalEvents) {
                
                // append it to our event set
                historicalEvents.append(newEvent)
                
            } else {
                // there was a problem fetching a random event
                // we can't proceed so return nil
                return nil
            }
        }
        
        // give 'em a shuffle using a home grown extension to Array
        historicalEvents.swapShuffle(nTimes: 20)
        
        return historicalEvents
    }
    
    // quick enum to indicate desired direction of movement
    enum DesiredDirection {
        case up
        case down
    }
    
    // attempt to apply up or down movement to specfied element
    func moveElement(elementIndex: Int, direction: DesiredDirection) {
        
        var desiredIndex: Int
        
        // determine the desired index
        switch direction {
        case .up:
            desiredIndex = elementIndex - 1
        case .down:
            desiredIndex = elementIndex + 1
        }
        
        guard currentRoundsEvents.indices.contains(desiredIndex) else {
            // this move would be out of bounds, so do nothing
            return
        }
        
        // perform the move
        currentRoundsEvents.swap(firstElementIndex: elementIndex, secondElementIndex: desiredIndex)
        
        // post a notification to anyone who is interested
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: BoutTimeModel.notificationEventsChanged), object: nil)
    }
    
    // check to see if all events are ordered correctly
    func isCurrentRoundOrderedCorrectly() -> Bool {
        
        // N.B. this approach allows the check to work with any number of events
        
        // N.B. assumes we want them ordered from oldest to most recent
        
        // set a variable to lowest possible value of Int
        // we will track the last date viewed as we progress through the events
        // and use it for comparison each time
        var lastEventsYear: Int = Int.min
        
        // iterate through the events in the current round
        for event in currentRoundsEvents {
            
            if event.year >= lastEventsYear {
                lastEventsYear = event.year
            } else {
                // so the previous date was more recent than this one
                return false
            }
        }
        
        // if we got here then every time we compared the event year to tge last
        // event year it was greater than or higher, meaning they are in order
        return true
    }
}
