//
//  PlayingCard.swift
//  Set
//
//  Created by 1C on 30/04/2022.
//

import Foundation

struct Card: Equatable, CustomStringConvertible, Hashable {
    
    static func ==(lhs: Card, rhs: Card) -> Bool {
        return lhs.amount == rhs.amount && lhs.color == rhs.color && lhs.fill == rhs.fill && lhs.type == rhs.type
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(amount)
        hasher.combine(color)
        hasher.combine(fill)
        hasher.combine(type)
    }
    
    var description: String {
        return "\(amount) | \(type) | \(fill) | \(color)"
    }
    
    var type: Variants //1.circle 2.square 3.triangle
    var amount: Variants
    var fill: Variants //1.fill 2.striped 3.outline
    var color: Variants //1.red 2.green 3.purple
    
    enum Variants: Int, CaseIterable {
        case v1 = 1
        case v2
        case v3
    }
        
}
