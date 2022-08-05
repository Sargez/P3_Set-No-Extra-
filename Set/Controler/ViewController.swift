//
//  ViewController.swift
//  Set
//
//  Created by 1C on 30/04/2022.
//

import UIKit

class ViewController: UIViewController {

    var game = Game()
        
    private var deckCount = 0 { didSet {updateDeckCountLabel()} }
    private var messageText = "" {didSet {messageTextLabel.text = messageText}}
    private var scoreCount = 0 {didSet {updateScoreCountLabel()}}
    private var scoreHints = 0 {didSet {updateHintsTitle()}}
    
    private weak var timerForHints: Timer?
    
    @IBOutlet weak var setTableView: SetTableView! {
        didSet{
        
            let swipeUp = UISwipeGestureRecognizer.init(target: self, action: #selector(swipeUpHandlerOfViewControler(_:)))
            swipeUp.direction = .up
            
            let rotate = UIRotationGestureRecognizer.init(target: self, action: #selector(rotateCardsOnTheTable(_:)))
            
            setTableView.addGestureRecognizer(rotate)
            setTableView.addGestureRecognizer(swipeUp)
            
        }
    }
    @IBOutlet private weak var deal3CardButton: ManageButtonsView!
    @IBOutlet private weak var hints: ManageButtonsView! {didSet {updateHintsTitle()}}
    
    @IBAction func swipeDownGesture(_ sender: UISwipeGestureRecognizer) {
        switch sender.state {
        case .ended :
            deal3Cards()
        default:
            break
        }
    }
        
    @objc func touchCard(_ recognizer: UITapGestureRecognizer) {

        switch recognizer.state {
        case .ended :
            if let card = (recognizer.view as? SetCardView)?.setCard {
                timerForHints?.fire()
                game.selectCard(card)
                updateViewFromModel()
            }
        default:
            break
        }

    }
    
    @IBAction func newGame(_ sender: ManageButtonsView) {
        newGame()
    }
    
    private func newGame() {
        game = Game()
        updateViewFromModel()
    }
    
    @IBAction private func showMeSet(_ sender: ManageButtonsView) {
        
        timerForHints?.invalidate()
        
        if let setToShow = game.findAllSetsOnTheTable().randomElement() {

            setTableView.cardsView.forEach { cardView in
                
                if let card = cardView.setCard, setToShow.contains(card) {
                    cardView.isHinted = true
                } else {
                    cardView.isHinted = false
                }
            }

            timerForHints = Timer.scheduledTimer(withTimeInterval: TimeInterval(Constants.flashingTime), repeats: false) {
                [weak self] timer in
                self!.setTableView.cardsView.forEach { cardView in
                    cardView.isHinted = false
                }

            }
        }
        
    }
    
    @IBAction private func deal3Card(_ sender: ManageButtonsView) {
        deal3Cards()
    }
    
    @IBOutlet private weak var deckCountLabel: UILabel! {didSet {updateDeckCountLabel()}}
    @IBOutlet private weak var messageTextLabel: UILabel! {didSet {messageTextLabel.text = messageText}}
    @IBOutlet private weak var scoreCountLabel: UILabel! {didSet {updateScoreCountLabel()}}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewFromModel()
                
    }
    
    @objc private func rotateCardsOnTheTable(_ recognizer: UIRotationGestureRecognizer) {
        
        switch recognizer.state {
        case .ended:
            game.rotateCardsOnTheTable()
            updateViewFromModel()
        default:
            break
        }
                
    }
    
    @objc private func swipeUpHandlerOfViewControler(_ recognizer: UISwipeGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            newGame()
        default:
            break
        }
    }
    
    private func deal3Cards() {
        if deckCount > 0 {
            game.deal3Cards()
            updateViewFromModel()
        }
    }
    
    private func updateViewFromModel() {
        
        updateCardsFromModel()

        var message = ""
        messageText = ""
        
        deckCount = game.deck.cards.count
        deal3CardButton.isEnabled = deckCount != 0
        scoreCount = game.score
        scoreHints = game.findAllSetsOnTheTable().count
        hints.isEnabled = scoreHints > 0

        if game.isGameOver() {
            updateCardsFromModel()
            message = "Game over!!!"
        } else if !game.setCards.isEmpty {
            message = "😆 Set!"
        } else if (game.selectedCards.count == 3 && game.setCards.isEmpty) {
            message = "😡 Ohh No..."
        }

        messageText = message

    }
    
    private func updateCardsFromModel() {
        
        setTableView.cardsView.removeAll()
        
        var cardsViewToAppend:[SetCardView] = []
        
        for cardModel in game.cardsOnTheTable {
            
            let cardView = SetCardView()
            cardView.setCard = cardModel
            cardView.count = cardModel.amount.rawValue
            cardView.symbolInt = cardModel.type.rawValue
            cardView.colorInt = cardModel.color.rawValue
            cardView.fillInt = cardModel.fill.rawValue
            cardView.isSelected = game.isSelected(this: cardModel)
            cardView.isMatched = game.isMatched(this: cardModel)
            cardView.isDismatched = game.isDismatched(this: cardModel)
               
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(touchCard(_:)))
            tap.numberOfTapsRequired = 1
            cardView.addGestureRecognizer(tap)
            
            cardsViewToAppend.append(cardView)
                        
        }
        
        setTableView.cardsView += cardsViewToAppend
        
    }
    
    private func updateDeckCountLabel() {
        deckCountLabel.text = "Deck: \(deckCount)"
    }
  
    private func updateScoreCountLabel() {
        scoreCountLabel.text = "Your score: \(scoreCount)"
    }
    
    private func updateHintsTitle() {
        hints.setTitle("Hints:\(scoreHints)", for: UIControl.State.normal)
    }
    
    private struct Constants {
        static let flashingTime = 3.0
        
    }
    
}

