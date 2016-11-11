//
//  DictionaryEncodableDecodable.swift
//  BoutTimeGame
//
//  Created by redBred LLC on 11/10/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

// protocol that ensures any adopter can init from a dictionary and can 
// provide a dictionary representation of itself
protocol DictionaryEncodableDecodable {
    func asDictionary() -> [String: AnyObject]
    init(fromDictionary: [String: AnyObject]) throws
}

// error enumeration to handle when init throws 
enum DictionaryDecodingError: Error {
    case dictionaryNotValid([String:AnyObject])
}
