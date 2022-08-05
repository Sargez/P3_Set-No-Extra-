//
//  SetCardView.swift
//  Set
//
//  Created by 1C on 21/05/2022.
//

import UIKit

@IBDesignable
class SetCardView: UIView {
    
    var setCard: Card?
    
    @IBInspectable
    var count: Int = 1 {didSet{setNeedsDisplay()}}
    
    @IBInspectable
    var symbolInt: Int = 1 {
        didSet{
            switch symbolInt {
            case 1: symbol = Symbol.oval
            case 2: symbol = Symbol.diamond
            case 3: symbol = Symbol.squiggle
            default: break
            }
        }
        
    }
    
    @IBInspectable
    var fillInt: Int  = 1 {
        didSet {
            switch fillInt {
            case 1: fill = Fill.solid
            case 2: fill = Fill.striped
            case 3: fill = Fill.unfilled
            default: break
            }
        }
    }
    
    @IBInspectable
    var colorInt: Int = 1 {
        didSet{
            switch colorInt {
            case 1: color = Constants.green
            case 2: color = Constants.red
            case 3: color = Constants.purple
            default: break
            }
        }
    }
    
    @IBInspectable
    var isSelected: Bool = false {didSet{setNeedsDisplay()}}
    
    @IBInspectable
    var isMatched: Bool = false {didSet{setNeedsDisplay()}}
    
    @IBInspectable
    var isDismatched: Bool = false {didSet{setNeedsDisplay()}}
    
    @IBInspectable
    var isHinted: Bool = false {didSet{setNeedsDisplay()}}
    
    private var symbol: Symbol = .oval {didSet{setNeedsDisplay()}}
    
    private enum Symbol: Int {
        case oval = 1
        case diamond
        case squiggle
    }
    
    private var color: UIColor = Constants.green {didSet{setNeedsDisplay()}}
        
    private var fill: Fill = .solid {didSet{setNeedsDisplay()}}
    
    private enum Fill: Int {
        case solid = 1
        case striped
        case unfilled
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ rect: CGRect) {
        
        let path = UIBezierPath.init(roundedRect: bounds, cornerRadius: cornerRadius)
        path.addClip()
        UIColor.white.setFill()
        path.fill()
        
        if !isHidden {
            drawPips()
            updateFrameView()
        }
        
    }
    
    override func layoutSubviews() {
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
    }
    
    private func updateFrameView() {
        
        if isSelected {
            drawImageBySelectedCard()
            setBorderSettings(Constants.selected)
        } else if isMatched {
            drawImageBySelectedCard()
            setBorderSettings(Constants.matched)
        } else if isDismatched {
            drawImageBySelectedCard()
            setBorderSettings(Constants.dismatched)
        } else if isHinted {
            setBorderSettings(Constants.hinted)
        } else {
            setBorderSettings(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0))
            layer.borderWidth = -1
        }
        
    }
    
    private func drawImageBySelectedCard() {
        
        if let pinImage = UIImage(named: "Pin", in: Bundle(for: self.classForCoder), compatibleWith: traitCollection) {
            
            var rect = bounds.zoom(by: SizeRatio.ratioImageToHeightCard)
            rect.origin = bounds.insetBy(dx: cornerOffset, dy: cornerOffset/2).origin
            if rect.size.width > rect.size.height {
                rect.size.height = rect.size.width
            } else {
                rect.size.width = rect.size.height
            }
            
            pinImage.draw(in: rect)
        
        }
        
    }
    
    private func setBorderSettings(_ color: UIColor) {
        layer.borderWidth = Constants.strokeLineWidth
        layer.borderColor = color.cgColor
        layer.cornerRadius = cornerRadius
    }
    
    private func drawPips() {
                
        var prepareRect = bounds
        
        prepareRect.size.height = prepareRect.height/CGFloat(3)
                
        let ratioData = SizeRatio.ratioCollectionOffsetsForRectanglePosition[count-1]
        
        for index in 1...count {
                    
            let ratio = CGFloat(ratioData[index-1])
            
            var pipRect = CGRect(origin: CGPoint(x: 0,y: bounds.midY + ratio*prepareRect.height),
                             size: prepareRect.size)
            
            pipRect = pipRect.insetBy(dx: cornerOffset, dy: cornerOffset)
                                               
            let shape = UIBezierPath()
            
            switch symbol {
            case .diamond: drawDiamond(by: shape, in: pipRect)
            case .oval: drawOval(by: shape, in: pipRect)
            case .squiggle: drawSquiggle(by: shape, in: pipRect)
            }
            
            shape.lineWidth = Constants.strokeLineWidth
            color.setStroke()
            shape.stroke()
            
            switch fill {
            case .solid:
                color.setFill()
                shape.fill()
            case .striped:
                if let context = UIGraphicsGetCurrentContext() {
                    context.saveGState()
                    stripped(by: shape, in: pipRect)
                    context.restoreGState()
                }
            default:
                break
            }
            
        }
        
    }
    
    private func drawDiamond(by path: UIBezierPath, in rect: CGRect) {
            
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.midY - (rect.height/2)))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.midY + (rect.height/2)))
        path.close()
            
    }
    
    private func drawOval(by path: UIBezierPath, in rect: CGRect) {
          
        let radiusOfArc = rect.height / 2
        let distanceFromCenterToCenterOfArc = (rect.width - 2*radiusOfArc)/2

        var centerOfCurrentArc = CGPoint(x: rect.midX - distanceFromCenterToCenterOfArc,
                                         y: rect.midY)

        path.addArc(withCenter: centerOfCurrentArc,
                    radius: radiusOfArc,
                    startAngle: 3*CGFloat.pi/2,
                    endAngle: CGFloat.pi/2,
                    clockwise: false)

        path.addLine(to: CGPoint(x: rect.maxX - radiusOfArc,
                                 y: path.currentPoint.y))

        centerOfCurrentArc = CGPoint(x: rect.midX + distanceFromCenterToCenterOfArc,
                                     y: rect.midY)

        path.addArc(withCenter: centerOfCurrentArc,
                    radius: radiusOfArc,
                    startAngle: CGFloat.pi/2,
                    endAngle: 3*CGFloat.pi/2,
                    clockwise: false)

        path.close()
        
    }
    
    private func drawSquiggle(by path: UIBezierPath, in rect: CGRect) {
        
        let startPoint = CGPoint(x: rect.minX, y: rect.midY)

        let dx = rect.width*0.1
        let dy = rect.height*0.2

        let upperCurve = UIBezierPath()

        upperCurve.move(to: startPoint)

        upperCurve.addCurve(to:
                                     CGPoint(x: rect.minX + rect.width * 1/2,
                                             y: rect.minY + rect.height / 8),
                      controlPoint1: CGPoint(x: rect.minX,
                                             y: rect.minY),
                      controlPoint2: CGPoint(x: rect.minX + rect.width / 2 - dx,
                                             y: rect.minY + rect.height / 8 - dy))
        
        upperCurve.addCurve(to:
                                     CGPoint(x: rect.minX + rect.width * 4/5,
                                             y: rect.minY + rect.height / 8),
                      controlPoint1: CGPoint(x: rect.minX + rect.width / 2 + dx,
                                             y: rect.minY + rect.height / 8 + dy),
                      controlPoint2: CGPoint(x: rect.minX + rect.width * 4 / 5 - dx,
                                             y: rect.minY + rect.height / 8 + dy))
        
        upperCurve.addCurve(to:
                                     CGPoint(x: rect.minX + rect.width,
                                             y: rect.minY + rect.height / 2),
                      controlPoint1: CGPoint(x: rect.minX + rect.width * 4 / 5 + dx,
                                             y: rect.minY + rect.height / 8 - dy),
                      controlPoint2: CGPoint(x: rect.minX + rect.width,
                                             y: rect.minY))

        let lowerCurve = UIBezierPath(cgPath: upperCurve.cgPath)

        lowerCurve.apply(CGAffineTransform.identity.translatedBy(x: bounds.width, y:  bounds.height).rotated(by: CGFloat.pi))

        path.append(upperCurve)
        path.append(lowerCurve)
                
    }
    
    private func stripped(by path: UIBezierPath, in rect: CGRect) {
        
        path.addClip()
//        1)
        for x in stride(from: bounds.minX, through: bounds.maxX, by: Constants.interSpace) {
            path.move(to: CGPoint(x: x, y: bounds.minY))
            path.addLine(to: CGPoint(x: x, y: bounds.maxY))
        }
        path.lineWidth = path.lineWidth / 2
        path.stroke()
//        2)
//        let stripe = UIBezierPath()
//        let pattern:[CGFloat] = [1.0, Constants.interSpace]
//        stripe.setLineDash(pattern, count: pattern.count, phase: 0.0)
//
//        stripe.lineWidth = bounds.height
//        stripe.lineCapStyle = .butt
//        stripe.move(to: CGPoint(x: bounds.minX, y: bounds.midY))
//        stripe.addLine(to: CGPoint(x: bounds.maxX, y: bounds.midY))
//        stripe.stroke()
//        3)
//        let stripe = UIBezierPath()
//        let stripeCount = Int(bounds.maxX / Constants.interSpace)
//        stripe.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
//        stripe.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))
//        for _ in 1...stripeCount {
//            let transition = CGAffineTransform(translationX: Constants.interSpace, y: 0.0)
//            stripe.apply(transition)
//            stripe.stroke()
//        }
    
    }
    
    private struct Constants {
        static let green = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        static let red = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        static let purple = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        
        static let strokeLineWidth = CGFloat(3.0)
        static let interSpace = CGFloat(5.0)
        
        static let selected = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
        static let hinted = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        static let dismatched = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        static let matched = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    }
    
}

extension CGRect {
    func zoom(by scale: CGFloat) -> CGRect {
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth)/2, dy: (height - newHeight)/2)
    }
}

extension SetCardView {
    
    private struct SizeRatio {
        static let ratioImageToHeightCard = CGFloat(0.2)
        static let cornerRadiusToHeightCard = CGFloat(0.05)
        static let cornerOffsetToCornerRadius = CGFloat(0.9)
        static let ratioCollectionOffsetsForRectanglePosition:[[Double]] = [[-1/2], [-1,0], [-3/2,-1/2,1/2]]
    }
        
    private var cornerRadius: CGFloat {
        bounds.height * SizeRatio.cornerRadiusToHeightCard
    }
    
    private var cornerOffset: CGFloat {
        cornerRadius * SizeRatio.cornerOffsetToCornerRadius
    }
}
