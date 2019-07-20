//
//  ExtensionComponents.swift
//  PoliDash
//
//  Created by David Minasyan on 24.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    func changeColorTFiledOnWhite() {
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "",
                                                        attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])

    }
}

extension UIView {
    func rotate180Degrees(duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.y")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(.pi * 1.0)
        rotateAnimation.duration = duration

        self.layer.add(rotateAnimation, forKey: nil)
    }
}

extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ..< end]
    }
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ... end]
    }
    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        return self[start ... end]
    }
    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ... end]
    }
    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ..< end]
    }
}
extension Substring {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ..< end]
    }
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ... end]
    }
    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        return self[start ... end]
    }
    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ... end]
    }
    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ..< end]
    }
}

extension UIView {
    func removeAllSubviews() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
}

extension UIViewController {

    //блокируем пользовательский интерфейс, затемняем и устанавливаем индикатор ожидания
    func showWaitView(isWait: Bool) {
        print("is Wait", isWait)
        DispatchQueue.main.async {
            self.view.window?.isUserInteractionEnabled = !isWait
            if isWait {
                if !(self.checkView(tag: TagView.waitView)) {
                    let waitView = self.addViewWait()
                    waitView.isHidden = false
                    waitView.tag = TagView.waitView.tag
                    self.view.addSubview(waitView)
                }
            } else {
                if let v = self.view.subviews.first(where: {$0.tag == TagView.waitView.tag}) {
                    v.isHidden = true
                    v.removeFromSuperview()
                }
            }
        }
    }

    private func checkView(tag: TagView) -> Bool {
        for item in view.subviews {
            print(item.tag)
            if item.tag == tag.tag {
                 return true
            }
        }
        return false
    }

    private func addViewWait() -> UIView {
        let view = UIView()
        view.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        view.backgroundColor = .black
        view.alpha = 0.6

        let indicator = UIActivityIndicatorView()
        indicator.activityIndicatorViewStyle = .whiteLarge
        indicator.startAnimating()

        indicator.frame = CGRect(x: view.center.x - 32.0, y: view.center.y-32.0, width: 64.0, height: 64.0)
        view.addSubview(indicator)
        return view
    }
}

extension UIViewController {
    func showAlertView(text: String?, callback: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            var alertView: UIView?
            if !(self.checkView(tag: .showAlert)) {
                alertView = self.addViewAlert(window: self.view)
                self.view.addSubview(alertView!)
            } else {
                if let v = self.view.subviews.first(where: {$0.tag == TagView.showAlert.tag}) {
                    alertView = v
                }
            }
            if let alert = alertView {
                if let viewLabel = alert.subviews.first, let label = viewLabel as? UILabel {
                    alert.alpha = 0.9
                    label.text = text
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        UIView.animate(withDuration: 0.7) {
                            alert.alpha = 0.0
                            callback?()
                        }
                    }
                }
            }
        }

    }

    private func addViewAlert(window: UIView) -> UIView {
        let view = UIView()
        view.frame = CGRect(x: 0.0, y: window.frame.height - 100.0, width: window.frame.size.width, height: 100.0)
        view.backgroundColor = .black

        let label = UILabel()
        label.text = "Текст"
        label.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: 100.0)
        label.textAlignment = .center
        label.font = label.font.withSize(14.0)
        label.textColor = .white
        label.backgroundColor = .black
        label.numberOfLines = 3

        view.addSubview(label)
        view.alpha = 0.0
        view.tag = TagView.showAlert.tag
        return view
    }
}

extension Date {
    var yearsFromNow: Int { return Calendar.current.dateComponents([.year], from: self, to: Date()).year        ?? 0 }
    var monthsFromNow: Int { return Calendar.current.dateComponents([.month], from: self, to: Date()).month       ?? 0 }
    var weeksFromNow: Int { return Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear  ?? 0 }
    var daysFromNow: Int { return Calendar.current.dateComponents([.day], from: self, to: Date()).day         ?? 0 }
    var hoursFromNow: Int { return Calendar.current.dateComponents([.hour], from: self, to: Date()).hour        ?? 0 }
    var minutesFromNow: Int { return Calendar.current.dateComponents([.minute], from: self, to: Date()).minute      ?? 0 }
    var secondsFromNow: Int { return Calendar.current.dateComponents([.second], from: self, to: Date()).second      ?? 0 }
    var relativeTime: String {
        if yearsFromNow   > 0 { return "\(yearsFromNow)г"}
//        if monthsFromNow  > 0 { return " м"  + (monthsFromNow   > 1 ? "s" : "") + "" }
        if weeksFromNow   > 0 { return "\(weeksFromNow)н"}
//        if daysFromNow    > 0 { return daysFromNow == 1 ? "Yesterday" : "\(daysFromNow) days ago" }
        if hoursFromNow   > 0 { return "\(hoursFromNow)ч"}
        if minutesFromNow > 0 { return "\(minutesFromNow)м"}
        if secondsFromNow > 0 { return "\(secondsFromNow)с"}
        return ""
    }
}
