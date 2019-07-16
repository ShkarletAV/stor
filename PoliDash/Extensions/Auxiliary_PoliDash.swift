//
//  Auxiliary_PoliDash.swift
//  PoliDash
//
//  Created by David Minasyan on 05.08.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import Foundation
import UIKit

class Auxiliary_PoliDash{
    static func showAlertQuality(callback: @escaping (QualityAction) -> ()) -> UIAlertController{
        let alert = UIAlertController(title: "", message: "Выберите качество", preferredStyle: UIAlertControllerStyle.actionSheet)
        let lowAction = UIAlertAction(title: QualityAction.average.value, style: .default) { (_) in
            callback(.average)
        }
        let averageAction = UIAlertAction(title: QualityAction.low.value, style: .default, handler: { (_) in
            callback(.low)
        })
        let cancelAction = UIAlertAction(title: QualityAction.cancel.value, style: .cancel) { (_) in
            callback(.cancel)
        }
        alert.addAction(lowAction)
        alert.addAction(averageAction)
        alert.addAction(cancelAction)
        return alert
        
    }
    
    static func showAlertMore(moreAlert: MoreAlert, callback: @escaping (MoreAction) -> ()) -> UIAlertController{
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        for item in moreAlert.actions{
            let action = UIAlertAction(title: item.title, style: item.style) { (_) in
                callback(item)
            }
            alert.addAction(action)
        }
        return alert
    }
    
    static func showMessage(vc: UIViewController, msg: String?, tittle t: String, actionBtn: String, callback: @escaping()->()) -> UIAlertController?{
        vc.view.window?.isUserInteractionEnabled = true
        vc.showWaitView(isWait: false)
        if let m = msg {
            let alert = UIAlertController(title: t, message: m, preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: actionBtn, style: UIAlertActionStyle.default) { (_) in
                callback()
            }
            alert.addAction(action)
            return alert
        }
        return nil
    }
    
    static func lastTime(lastTime: String) -> String?{
        let calendar =  Calendar.current
        var split = lastTime.split(separator: "T")
        if split.count > 1{
            let d = split[0]
            split = split[1].split(separator: ".")
            if split.count > 0{
                let t = split[0]
                split = d.split(separator: "-")
                if split.count > 2{
                    if let year = Int(split[0]), let month = Int(split[1]), let day = Int(split[2]){
                        split = t.split(separator: ":")
                        if split.count > 1{
                            if let hour = Int(split[0]), let minutes = Int(split[1]){
                                let date = DateComponents(calendar: calendar, year: year, month:  month, day: day, hour: hour, minute: minutes).date!
                                let timeOffset = date.relativeTime
                                return timeOffset
                            }
                        }
                    }
                }
            }
        }
        return nil
    }
}
