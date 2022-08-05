//
//  SetGame.swift
//  Set
//
//  Created by 1C on 30/04/2022.
//

import Foundation

struct Game {
    
    var deck = Deck()
    private (set) var score = 0
    private var lastDateCheckIn: Date!
    
    private (set) var matchedCards = [Card]()
    private (set) var cardsOnTheTable = [Card]()
    private (set) var setCards = [Card]()
    var selectedCards = [Card]()
        
    func isSelected(this card: Card) -> Bool {
        selectedCards.contains(card) && (selectedCards.count < 3)
    }
    
    func isMatched(this card: Card) -> Bool {
        matchedCards.contains(card) && selectedCards.contains(card)
    }
    
    func isDismatched(this card: Card) -> Bool {
        !matchedCards.contains(card) && selectedCards.contains(card) && (selectedCards.count == 3)
    }
    
    mutating func isGameOver() -> Bool {
        if deck.cards.count == 0 && findAllSetsOnTheTable().count == 0 {
            takeOff3cardsFromTheTable()
            setCards.removeAll()
            selectedCards.removeAll()
            return true
        }
        return false
    }
    
    mutating func rotateCardsOnTheTable() {
        cardsOnTheTable.shuffle()
    }
    
    mutating func deal3Cards() {
                
        if setCards.isEmpty && !findAllSetsOnTheTable().isEmpty {
            score -= Constants.penaltyForDisMatchOrWrongDeal
        }
        
        if setCards.isEmpty {
            for _ in 0..<3 {
                if let card = getCard() {
                    cardsOnTheTable += [card]
                }
            }
        } else {
            replace3cardsOnTheTable()
        }
        
        if selectedCards.count == 3 { selectedCards.removeAll() }
    }
    
    mutating func selectCard(_ card: Card) {
            
        if !matchedCards.contains(card) {
            if selectedCards.count == 3 {
                selectedCards.removeAll()
            }
            
            if setCards.count == 3 {
                if cardsOnTheTable.count <= Constants.minAmountCardsOnTheTable, deck.cards.count > 0 {
                    replace3cardsOnTheTable()
                } else {
                    takeOff3cardsFromTheTable()
                }
            }
            
            if selectedCards.count < 3 {
                if let index = selectedCards.firstIndex(of: card) {
                    selectedCards.remove(at: index)
                } else {
                    selectedCards.append(card)
                }
            }
            
            if selectedCards.count == 3 {
                if isSet(in: selectedCards) {
                    matchedCards += selectedCards
                    setCards += selectedCards
                    
                    let dateDistance = Int(lastDateCheckIn.timeIntervalSinceNow.distance(to: 0.0))
                    let result = Constants.scoreForMatch - (dateDistance > Constants.secondToDecrease ? (dateDistance/Constants.secondToDecrease) : 0)
                    score += max(result, Constants.minScoreForMatch)
                    lastDateCheckIn = Date()
                    
                } else {
                    score -= Constants.penaltyForDisMatchOrWrongDeal
                }
            }
        }
        
    }
    
    private mutating func takeOff3cardsFromTheTable() {
            
        cardsOnTheTable = cardsOnTheTable.filter { return !setCards.contains($0) }
        
        setCards.removeAll()
        
    }
    private mutating func replace3cardsOnTheTable() {
        
        var take3cards: [Card] = []
        for _ in 0...2 {
            if let card = getCard() {
                take3cards += [card]
            }
        }
        
        cardsOnTheTable.replace(remove: setCards, in: take3cards)
                
        setCards.removeAll()
    }
    
    private func isSet(in cards: [Card]) -> Bool {
        
        let amountComparison = cards.reduce(0, {$0 + $1.amount.rawValue}) % 3 == 0
        let typeComparison = cards.reduce(0, {$0 + $1.type.rawValue}) % 3 == 0
        let colorComparison = cards.reduce(0, {$0 + $1.color.rawValue}) % 3 == 0
        let fillComparison = cards.reduce(0, {$0 + $1.fill.rawValue}) % 3 == 0
                
        return amountComparison && typeComparison && colorComparison && fillComparison
    }
    
    func findAllSetsOnTheTable() -> [[Card]] {
        
        var allSets = [[Card]]()
        
        for first in 0..<(cardsOnTheTable.count) {
            for second in (first + 1)..<(cardsOnTheTable.count) {
                for third in (second + 1)..<(cardsOnTheTable.count) {
                    let setToCheck = [cardsOnTheTable[first], cardsOnTheTable[second], cardsOnTheTable[third]]
                    if isSet(in: setToCheck) {
                        allSets.append(setToCheck)
                    }
                }
            }
        }

        if !setCards.isEmpty {
            allSets = allSets.map{Set($0)}.filter{$0.intersection(setCards).count==0}.map{Array($0)}
        }
        
        return allSets
    }
    
    private mutating func getCard() -> Card? {
        return deck.cards.count > 0 ? deck.cards.remove(at: deck.cards.count.random) : nil
    }
    
    init() {
        setCards.removeAll()
        matchedCards.removeAll()
        cardsOnTheTable.removeAll()
        selectedCards.removeAll()
        score = 0
        for _ in 0..<Constants.minAmountCardsOnTheTable {
            if let card = getCard() {
                cardsOnTheTable += [card]
            }
        }
        lastDateCheckIn = Date()
    }
  
    private struct Constants {
        static let penaltyForDisMatchOrWrongDeal = 20
        static let secondToDecrease = 5
        static let scoreForMatch = 10
        static let minScoreForMatch = 3
        static let minAmountCardsOnTheTable = 12
    }
}

extension Array where Element: Equatable {
        
    mutating func replace(remove: [Element], in new: [Element]) {
        guard new.count == remove.count else {return}
        
        for index in new.indices {
            let matchIndex = self.firstIndex(of: remove[index])
            if matchIndex != nil {
                self[matchIndex!] = new[index]
            }
        }
    }
 
}

extension Int {
    var random: Int {
        
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
        
    }
}
