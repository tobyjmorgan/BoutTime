//
//  HistoricalEvent.swift
//  BoutTimeGame
//
//  Created by redBred LLC on 11/6/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

struct HistoricalEvent {
    
    let eventDescription: String
    let year: Int
    let detailsURL: URL?
}

extension HistoricalEvent: Equatable {}

func ==(lhs: HistoricalEvent, rhs: HistoricalEvent) -> Bool {
    return lhs.eventDescription == rhs.eventDescription && lhs.year == rhs.year
}
