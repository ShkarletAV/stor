//
//  CameraPhotoViewController.swift
//  PoliDash
//
//  Created by David Minasyan on 03.08.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import UIKit
import RxSwift

class CameraPhotoViewController: UIViewController {

    @IBOutlet weak var photoImage: UIImageView!
    open var photoDidLoad: ((Any) -> UIImage)?
    open var photoStartLoad: ((Any) -> UIImage)?

    // MARK: - Request Download Video
    var msgDownloadVideo = Variable<MessageVideoModel>(MessageVideoModel())

    let disposeBag = DisposeBag()
    let delegate = UIApplication.shared.delegate as! AppDelegate

    var img = UIImage()
    var swipeRecognizer: UISwipeGestureRecognizer?

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()
        photoImage.image = img //отображение полученной ранее фотографии

//        возвращаемся назад при свайпе вправо
        swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipe(rec:)))
        swipeRecognizer?.direction = .right
        self.view.addGestureRecognizer(swipeRecognizer!)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - Actions
    @IBAction func back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func share_Action(_ sender: IBDesignableButton) {
        //self.showWaitView(isWait: true)
//        загружаем фото на сервер (сжатой)
        if let data = UIImageJPEGRepresentation(img, 0.7) {
            self.returnToMainScreen(image: img)
        } else {
            self.showAlertView(text: "Попробуйте еще раз") {
                return
            }
        }
    }

    // MARK: - back if swipe right
    @objc func swipe (rec: UISwipeGestureRecognizer) {
        if rec.direction == .right {
            UIView.transition(with: (self.navigationController?.view)!, duration: 0.75, options: .curveEaseInOut, animations: {
                self.navigationController?.popViewController(animated: true)
            })
        }
    }

    deinit {
        print("CameraPhoto is deinit")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func returnToMainScreen(image: UIImage) {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        if viewControllers[viewControllers.count - 3] is MainViewController {
            let controller = viewControllers[viewControllers.count - 3] as! MainViewController
            controller.downloadVideo(image: image, video: nil)
            self.navigationController!.popToViewController(controller, animated: false)
        }
    }

}
extension CameraPhotoViewController {
    private func subscribe() {
//        Наблюдатель изменения состоянии загрузки фото на сервер
        msgDownloadVideo.asObservable().skip(1).subscribe(onNext: { [weak self] (element) in
//            обработка ошибок
            if let code = element.code, code < 200 || code >= 300, let msg = element.msg {
                if let ss = self {

                    if let alert = AuxiliaryPoliDash.showMessage(vc: ss, msg: msg, tittle: "Ошибка", actionBtn: "ОК", callback: {
                        return
                    }) {
                        ss.present(alert, animated: true, completion: nil)
                    }
                }
            } else {
//                успешная загрузка
                if let code = element.code, code >= 200 && code < 300, let msg = element.msg {
                    if let ss = self {
                        if let alert = AuxiliaryPoliDash.showMessage(vc: ss, msg: msg, tittle: "", actionBtn: "ОК", callback: {
//                            возвращаемся на главный экран
                            if let sss = self {
                                let viewControllers: [UIViewController] = sss.navigationController!.viewControllers as [UIViewController]
                                sss.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: false)
                            }
                        }) {
                            ss.present(alert, animated: true, completion: nil)
                        }

                    }
                }
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
}
