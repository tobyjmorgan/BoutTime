//
//  ArrayExtensions.swift
//  BoutTimeGame
//
//  Created by redBred LLC on 11/6/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation
import GameKit

extension Array {
    
    mutating func swap(firstElementIndex: Int, secondElementIndex: Int) {
        
        guard self.count > 1 && firstElementIndex != secondElementIndex &&
            self.indices.contains(firstElementIndex) &&
            self.indices.contains(secondElementIndex) else {
            return
        }
        
        let temp: Element = self[firstElementIndex]
        self[firstElementIndex] = self[secondElementIndex]
        self[secondElementIndex] = temp
        
        print("Swapped items \(firstElementIndex) and \(secondElementIndex)")
    }
    
    mutating func swapShuffle(nTimes: Int) {
        
        if self.count > 1 {
            
            for _ in 0..<nTimes {
                
                let firstElementIndex = GKRandomSource.sharedRandom().nextInt(upperBound: self.count)
                let secondElementIndex = GKRandomSource.sharedRandom().nextInt(upperBound: self.count)
                
                self.swap(firstElementIndex: firstElementIndex, secondElementIndex: secondElementIndex)
            }
        }
    }
}
