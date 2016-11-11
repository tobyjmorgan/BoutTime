//
//  HistoricalEvent.swift
//  BoutTimeGame
//
//  Created by redBred LLC on 11/6/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

// struct to capture required details of an historical event
struct HistoricalEvent {
    
    let eventDescription: String
    let year: Int
    let detailsURL: URL
}



////////////////////////////////////////////////////////////////////////
// make our struct conform to equatable
extension HistoricalEvent: Equatable {}

// and implement the == method
func ==(lhs: HistoricalEvent, rhs: HistoricalEvent) -> Bool {
    return lhs.eventDescription == rhs.eventDescription && lhs.year == rhs.year && lhs.detailsURL == rhs.detailsURL
}



////////////////////////////////////////////////////////////////////////
// make our struct conform to our homegrown protocol DictionaryEncodableDecodable
extension HistoricalEvent: DictionaryEncodableDecodable {
    
    // static constants for dictionary keys to prevent typo errors
    static let eventDescriptionKey  = "eventDescription"
    static let yearKey              = "year"
    static let detailsURLKey        = "detailsURL"
    
    // create a dictionary representation of self
    func asDictionary() -> [String : AnyObject] {
        var dictionary: [String : AnyObject] = [:]
        
        dictionary[HistoricalEvent.eventDescriptionKey] = self.eventDescription as AnyObject
        dictionary[HistoricalEvent.yearKey] = self.year as AnyObject
        dictionary[HistoricalEvent.detailsURLKey] = self.detailsURL.absoluteString as AnyObject
        
        return dictionary
    }
    
    // init from a dictionary representation
    init(fromDictionary: [String: AnyObject]) throws {
        
        guard
            let eventDescription    = fromDictionary[HistoricalEvent.eventDescriptionKey] as? String,
            let year                = fromDictionary[HistoricalEvent.yearKey] as? Int,
            let detailsURLString    = fromDictionary[HistoricalEvent.detailsURLKey] as? String,
            let detailsURL          = URL(string: detailsURLString) else {
                
            throw DictionaryDecodingError.dictionaryNotValid(fromDictionary)
        }
        
        self.eventDescription = eventDescription
        self.year = year
        self.detailsURL = detailsURL
    }
}



// Helper class to import plist file and convert into an array of HistoricalEvent objects
class HistoricalEventPlistConverter {
    
    enum ConverterError: Error {
        case resourceNotFound
        case conversionError
        case unarchivingError(String)
    }
    
    class func arrayFromFile(resource: String, ofType type: String) throws -> [HistoricalEvent] {
        
        guard let path = Bundle.main.path(forResource: resource, ofType: type) else {
            throw ConverterError.resourceNotFound
        }
        
        guard let array = NSArray(contentsOfFile: path),
              let convertedArray = array as? [ [String : AnyObject] ] else {
            throw ConverterError.conversionError
        }
        
        var historicalEvents: [HistoricalEvent] = []
        
        for itemDictionary in convertedArray {
            
            do {
                
                let historicalEvent = try HistoricalEvent(fromDictionary: itemDictionary)
                historicalEvents.append(historicalEvent)
            
            } catch DictionaryDecodingError.dictionaryNotValid(let dictionary) {
            
                throw ConverterError.unarchivingError("Unable to decode dictionary into HistoricalEvent: \(dictionary)")
            }
        }
        
        return historicalEvents
    }
}
