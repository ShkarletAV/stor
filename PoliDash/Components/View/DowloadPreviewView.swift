//
//  DowloadPreviewView.swift
//  PoliDash
//
//  Created by olya on 17/07/2019.
//  Copyright © 2019 Sergey Nazarov. All rights reserved.
//

import UIKit

//
//
// Превью для загрузаемых на главной странице видео, содержит индикатор загрузки и кнопку "отмена"
class DowloadPreviewView: UIView {

    let circleSize = CGSize(width: 50.0, height: 50.0)
    let buttonSize = CGSize(width: 20.0, height: 20.0)

    var circleView: CircleLayer?
    var cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "BackIcon"), for: .normal)
        button.addTarget(self, action: #selector(cancelDowloadStories), for: .touchUpInside)
        return button
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        let imgLayer = CALayer()
        imgLayer.frame = frame
        imgLayer.backgroundColor = #colorLiteral(red: 0.7881655693, green: 0.7882800698, blue: 0.7881404757, alpha: 0.78)
        self.layer.addSublayer(imgLayer)

        let circleBorder = CALayer()
        circleBorder.backgroundColor = UIColor.clear.cgColor
        circleBorder.borderWidth = 2.0
        circleBorder.borderColor = UIColor.white.cgColor
        circleBorder.bounds = CGRect(
            x: 0.0,
            y: 0.0,
            width: circleSize.width + 1.0,
            height: circleSize.width + 1.0)
        circleBorder.position = CGPoint(
            x: self.bounds.midX,
            y: self.bounds.midY)
        circleBorder.cornerRadius = circleSize.width/2
        self.layer.insertSublayer(circleBorder, at: 0)

        // Create a new CircleView
        circleView = CircleLayer(frame: CGRect(
            x: 1.0,
            y: 1.0,
            width: circleSize.width,
            height: circleSize.height))
        circleView?.center = circleBorder.position

        self.addSubview(cancelButton)
        cancelButton.frame.size = CGSize(
            width: buttonSize.width,
            height: buttonSize.height)
        cancelButton.center = circleView?.center ?? self.center
    }

    func changeProgress(progress: Double) {
        guard let circleView = circleView else { return }
        circleView.changeProgress(progress: progress)
    }

    @objc func cancelDowloadStories() {

    }
}
