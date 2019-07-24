//
//  EnumsExtensions.swift
//  PoliDash
//
//  Created by David Minasyan on 23.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import Foundation
import AVKit

enum VcStoryboarID: String {
    case mainViewController = "MainVC_ID"
    case camera = "CameraVC_ID"
    case userSetings = "ProfileSetings_ID"
    case playerViewController = "PlayerViewController_ID"
    case playerStorys = "PlayerStorys_ID"
    case playerLikes = "PlayerLikes_ID"
    case searchViewController = "Search_ID"
    case cameraPhotoController = "CameraPhotoController_ID"
}

enum SegueID: String {
    case fPlayerViewController = "segueFPlayerViewController"
    case avPlayerStrory = "segueAVPlayerStroryiewController"
    case imagePlayer = "segueImagePlayerViewController"
}

enum StoryboardName: String {
    case mainStoryboard = "Main"
    case videoPlayerStoryboard = "VideoPlayer"
}

enum UserDefaultKeys: String {
    case login = "KEY_Login"
    case password = "KEY_Pass"
    case opened = "KEY_Opened"
    case showMainTutorial = "showMainTutorial"
    case userBalance = "userBalance"
}

enum CellID: String {
    case userCellID = "UsersTableViewCell_ID"
    case storysCellID = "StoryCellID"
    case currentAStorysCellID = "CurrentAStorysCellID"
}

enum PlayerControl {
    case next
    case previous
    case play
    case pause
}

enum Sympathy {
    case like
    case unlike
}

extension Sympathy {
    var value: String {
        switch self {
        case .like:
            return "like"
        case .unlike:
            return "unlike"
        }
    }
}

enum QualityAction {
    case cancel
    case low
    case average
}

extension QualityAction {
    var value: String {
        switch self {
        case .average:
            return "Сжатое"
        case .low:
            return "Хорошее"
        default:
            return "Отмена"
        }
    }
    var aVAssetExport: String {
        switch self {
        case .average:
            return "AVAssetExportPresetLowQuality"
        case .low:
            return "AVAssetExportPreset640x480"
        default:
            return "AVAssetExportPreset640x480"
        }
    }
}

enum DurationFlipping {
    case next
    case previews
}

extension DurationFlipping {
    var animate: UIViewAnimationOptions {
        switch self {
        case .next:
            return .transitionFlipFromRight
        case .previews:
            return .transitionFlipFromLeft
        }
    }
}

enum TagView {
    case waitView
    case showAlert
}

extension TagView {
    var tag: Int {
        switch self {
        case .waitView:
            return 345678
        case .showAlert:
            return 345679
        }
    }
}

enum MoreAlert {
    case all
    case save

    var actions: [MoreAction] {
        switch self {
        case .all:
            return [.saveHistory, .delete, . download, .cancel]
        default:
            return [.download, .cancel]
        }
    }

}

enum MoreAction {
    case saveHistory
    case delete
    case download
    case allLikes
    case cancel

    var title: String {
        switch self {
        case .delete:
            return "Удалить"
        case .download:
            return "Загрузить"
        case .saveHistory:
            return "Сохранить в актуальные"
        case .allLikes:
            return "Все сердечки"
        case .cancel:
            return "Отмена"
        }
    }

    var style: UIAlertActionStyle {
        switch self {
        case .delete:
            return .destructive
        case .download:
            return .default
        case .saveHistory:
            return .default
        default:
            return .cancel
        }
    }
}

enum Owner {
    case isOwner
    case isFollower
}

enum See {
    case see
    case noSee
    case none

    var title: String {
        switch self {
        case .see:
            return "ОТПИСАТЬСЯ"
        case .noSee:
            return "+"
        case .none:
            return "+"
        }
    }
}
