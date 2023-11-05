//
//  Array+.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import Foundation

extension Array {
    func randomElements(count: Int) -> [Element] {
        if count >= self.count {
            return self
        }
        let shuffledArray = self.shuffled()
        return Array(shuffledArray.prefix(count))
    }
    
    func shuffleArray<T>(_ array: [T]) -> [T] {
        var shuffledArray = array
        for _ in 0..<(shuffledArray.count - 1) {
            let randomIndex = Int(arc4random_uniform(UInt32(shuffledArray.count)))
            if randomIndex != shuffledArray.count - 1 {
                shuffledArray.swapAt(randomIndex, shuffledArray.count - 1)
            }
        }
        return shuffledArray
    }
}
