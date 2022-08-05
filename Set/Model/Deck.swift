//
//  Deck.swift
//  Set
//
//  Created by 1C on 30/04/2022.
//

import Foundation

struct Deck {
        
   var cards = [Card]()
        
   init() {
    for amount in Card.Variants.allCases {
            for type in Card.Variants.allCases {
                for color in Card.Variants.allCases {
                    for fill in Card.Variants.allCases {
                        cards.append(Card(type: type, amount: amount, fill: fill, color: color))
                    }
                }
            }
        }
        
    }
    
}


