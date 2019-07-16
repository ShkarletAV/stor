//
//  CircleLayer.swift
//  PoliDash
//
//  Created by David Minasyan on 23.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import Foundation
import UIKit

class CircleLayer: UIView {

    var circleLayer: CAShapeLayer!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear

        // Use UIBezierPath as an easy way to create the CGPath for the layer.
        // The path should be the entire circle.
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: frame.size.width / 2.0,
                               y: frame.size.height / 2.0),
            radius: frame.size.width/2,
            startAngle: (.pi) * 3 / 2.0,
            endAngle: (.pi) * 3 / 2.0 + .pi*2.0,
            clockwise: true)

        // Setup the CAShapeLayer with the path, colors, and line width
        circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = #colorLiteral(red: 0, green: 0.4941381812, blue: 0.9527845979, alpha: 1)
        circleLayer.lineWidth = 2.0

        // Don't draw the circle initially
        circleLayer.strokeEnd = 0.0

        // Add the circleLayer to the view's layer's sublayers
        layer.addSublayer(circleLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func animateCircle(duration: TimeInterval) {
        // We want to animate the strokeEnd property of the circleLayer
        let animation = CABasicAnimation(keyPath: "strokeEnd")

        // Set the animation duration appropriately
        animation.duration = duration

        // Animate from 0 (no circle) to 1 (full circle)
        animation.fromValue = 0
        animation.toValue = 1

        // Do a linear animation (i.e. the speed of the animation stays the same)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)

        // Set the circleLayer's strokeEnd property to 1.0 now so that it's the
        // right value when the animation ends.
        circleLayer.strokeEnd = 1.0

        // Do the actual animation
        circleLayer.add(animation, forKey: "animateCircle")
    }

    func changeProgress(progress: Double) {
        circleLayer.strokeEnd = CGFloat(progress)
    }
}
