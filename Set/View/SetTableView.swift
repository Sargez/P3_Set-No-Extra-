//
//  SetTable.swift
//  Set
//
//  Created by 1C on 21/05/2022.
//

import UIKit

//@IBDesignable
class SetTableView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    private var grid: Grid!
    
    private var cardsOnTheTable: Int {cardsView.count}

    var cardsView: [SetCardView] = [] {
        willSet{
            removeSubviews()
        }
        didSet {
            addSubviews()
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
      
        grid = makeGridByAspectRatioStrategy(amountOfCards: cardsOnTheTable)
        
        for row in 0..<grid.dimensions.rowCount {
            for column in 0..<grid.dimensions.columnCount {
                if let frameForCard = grid[row, column] {
  
                    cardsView[row*grid.dimensions.columnCount+column].frame = frameForCard.insetBy(
                        dx: Constants.spacingBetweenCards,
                        dy: Constants.spacingBetweenCards)
                    
                }
            }
        }
        
    }
    
    private func removeSubviews() {
        for card in cardsView {
            card.removeFromSuperview()
        }
    }
    
    private func addSubviews() {
        for card in cardsView {
            addSubview(card)
        }
    }
    
    private func makeGridByAspectRatioStrategy(amountOfCards cellCount: Int) -> Grid {
        var grid = Grid(
            layout: Grid.Layout.aspectRatio(Constants.aspectRatioWithToHeightCard),
            frame: bounds
        )
        grid.cellCount = cellCount
        return grid
    }

    private struct Constants {
        static let aspectRatioWithToHeightCard = CGFloat(0.625)
        static let spacingBetweenCards = CGFloat(5.0)
    }
    
}
