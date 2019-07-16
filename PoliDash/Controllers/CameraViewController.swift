//
//  CameraViewController.swift
//  PoliDash
//
//  Created by David Minasyan on 20.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import UIKit
import SwiftyCam
import Photos
import MobileCoreServices

class CameraViewController: SwiftyCamViewController, SwiftyCamViewControllerDelegate{

    @IBOutlet weak var circle_Button: SwiftyRecordButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var flipCamera_Button: UIButton!
    @IBOutlet weak var back_Button: UIButton!
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var whiteCircle: UIView!
    @IBOutlet weak var tutorialView: UIImageView!
    @IBOutlet weak var buttonsView : UIStackView!
    var circleView = LayerCircle()
    var focusPoint : CGPoint?
    var imagePicker = UIImagePickerController()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        circle_Button.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        showTutorialIfNeed()
        self.loadCircles()
    }
    
    func loadCircles(){
        Profile_API.requestCircles(delegate: ((UIApplication.shared.delegate as? AppDelegate)!), email: AllUserDefaults.getLoginUD()!) { (_, _, circles) in
            for btn in self.buttonsView.arrangedSubviews {
                btn.isHidden = true
            }
            var i = 0
            for owner in circles {
                (self.buttonsView.arrangedSubviews[i] as! RoundButton).owner = owner
                (self.buttonsView.arrangedSubviews[i] as! RoundButton).isHidden = false
                i = i + 1
            }
        }
    }
    
    @IBAction func selectRound(sender:RoundButton){
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "MainVC_ID") as! MainViewController
        if let email = sender.owner?.email{
            vc.emailProfile = email
            vc.isSaveVideo = false
            vc.hashVideo = ""
            let nav = self.navigationController
            nav?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewDidLoad() {
        self.whiteCircle.alpha = 0.0
        circle_Button.addTarget(self, action: #selector(multipleTap(_:event:)), for: UIControlEvents.touchDownRepeat)
        circle_Button.addTarget(self, action: #selector(oneTap(_:event:)), for: UIControlEvents.touchDown)
        circle_Button.buttonEnabled = false
        videoGravity = .resizeAspectFill
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        cameraDelegate = self
        self.shouldUseDeviceOrientation = true
        maximumVideoDuration = 10.0
        tapToFocus = true
        flashEnabled = false
        self.pinchToZoom = false
        longPressDidReachMaximumDuration()
        fetchPhotos()
        self.doubleTapCameraSwitch = true
        self.addLongPressGesture()
    }
    
    func showTutorialIfNeed(){
        let videoTutorial = UserDefaults.standard.bool(forKey: "videoTutorialShow")
        let photoTutorial = UserDefaults.standard.bool(forKey: "photoTutorialShow")
        if videoTutorial != true {
            tutorialView.image = #imageLiteral(resourceName: "video_tutorial.png")
            tutorialView.isHidden = false
        } else if photoTutorial != true {
            tutorialView.image = #imageLiteral(resourceName: "photo_tutorial.png")
            tutorialView.isHidden = false
        } else {
            tutorialView.isHidden = true
        }
    }
    
    func addLongPressGesture(){
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:)))
        longPress.minimumPressDuration = 0.3
        circle_Button.addGestureRecognizer(longPress)
    }
    
    @objc func longPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.began {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(focusAction), object: nil)
            self.startVideoRecording()
            UserDefaults.standard.set(true, forKey: "videoTutorialShow")
            UserDefaults.standard.synchronize()
            self.tutorialView.isHidden = true
        } else if gesture.state == .ended {
            self.stopVideoRecording()
        }
    }

    
    @objc func multipleTap(_ sender: UIButton, event: UIEvent) {
        let touch: UITouch = event.allTouches!.first!
        if (touch.tapCount == 2) {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(focusAction), object: nil)
           self.takePhoto()
            UserDefaults.standard.set(true, forKey: "photoTutorialShow")
            UserDefaults.standard.synchronize()
        }
    }
    
    @objc func oneTap(_ sender: UIButton, event: UIEvent) {
        let touch: UITouch = event.allTouches!.first!
        if (touch.tapCount == 1) {
            self.focusPoint = touch.location(in: circle_Button)
            perform(#selector(focusAction), with: nil, afterDelay: 0.33)
        }
    }
    
    @objc func focusAction() {
        self.swiftyCam(self, didFocusAtPoint: focusPoint!)
        focusPoint = nil
    }
    
    func fetchPhotos () {
        // Sort the images by descending creation date and fetch the first 3
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        
        // Fetch the image assets
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        
        // If the fetch result isn't empty,
        // proceed with the image request
        if fetchResult.count > 0 {
            let totalImageCountNeeded = 1 // <-- The number of images to fetch
            fetchPhotoAtIndex(0, totalImageCountNeeded, fetchResult)
        }
    }
    
    // Repeatedly call the following method while incrementing
    // the index until all the photos are fetched
    func fetchPhotoAtIndex(_ index:Int, _ totalImageCountNeeded: Int, _ fetchResult: PHFetchResult<PHAsset>) {
        
        // Note that if the request is not set to synchronous
        // the requestImageForAsset will return both the image
        // and thumbnail; by setting synchronous to true it
        // will return just the thumbnail
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        // Perform the image request
        PHImageManager.default().requestImage(for: fetchResult.object(at: index) as PHAsset, targetSize: view.frame.size, contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, _) in
            if let image = image {
                // Add the returned image to your array
                self.libraryButton.setImage(image, for: .normal)
                self.libraryButton.layer.cornerRadius = 13.0
                self.libraryButton.layer.borderWidth = 2.0
                self.libraryButton.layer.borderColor = UIColor.white.cgColor
                self.libraryButton.imageView?.contentMode = .scaleAspectFill
                self.libraryButton.clipsToBounds = true
            }
        })
    }

    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
//       установка внешнего вида фокуса
        let focusView = UIImageView(image: #imageLiteral(resourceName: "focus"))
        focusView.frame = CGRect(x: point.x, y: point.y, width: 64, height: 64)
        focusView.center = point
        focusView.alpha = 0.0
        view.addSubview(focusView)
        
//        анимация для отображения и скрытия фокуса
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            focusView.alpha = 1.0
            focusView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }, completion: { (success) in
            UIView.animate(withDuration: 0.15, delay: 0.5, options: .curveEaseInOut, animations: {
                focusView.alpha = 0.0
                focusView.transform = CGAffineTransform(translationX: 0.6, y: 0.6)
            }, completion: { (success) in
                focusView.removeFromSuperview()
            })
        })
    }
    
    @IBAction func openGallery(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .savedPhotosAlbum;
            self.imagePicker.mediaTypes = [kUTTypeMovie,kUTTypeImage] as [String]
            self.imagePicker.allowsEditing = false
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    //MARK:-    Отображаем полученый снимок в кнтроллере CameraPhotoViewController
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        let storyboard = UIStoryboard(name: Storyboard_Name.Main_Storyboard.rawValue, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: VcStoryboarID.cameraPhotoController.rawValue) as! CameraPhotoViewController
        vc.img = photo
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
//    Запись видео
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        addCircleView()
//        Анимация записи видео
        UIView.animate(withDuration: 0.25, animations: {
            self.flashButton.alpha = 0.0
            self.flipCamera_Button.alpha = 0.0
            self.back_Button.alpha = 0.0
            self.whiteCircle.alpha = 1.0
        })
        print("isVideoRecord")
    }
    
//    Окончание записи
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        print("Did finish Recording")
        circleView.circleLayer.strokeEnd = 0
        circleView.circleLayer.timeOffset = 10
//        Анимация окончания записи
        UIView.animate(withDuration: 0.25, animations: {
            self.flashButton.alpha = 1.0
            self.flipCamera_Button.alpha = 1.0
            self.back_Button.alpha = 1.0
            self.whiteCircle.alpha = 0.0
        })
    }
    
//    Окончание записи и получения url video
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: VcStoryboarID.playerViewController.rawValue) as! PlayerViewController
        vc.videoURL = url
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
//    Настройка кружка вокруг кнопки
    func addCircleView() {
        
        let circleBorder = CALayer()
        circleBorder.backgroundColor = UIColor.clear.cgColor
        circleBorder.borderWidth = 2.0
        circleBorder.borderColor = UIColor.white.cgColor
        circleBorder.bounds = whiteCircle.bounds
        circleBorder.position = CGPoint(x: whiteCircle.bounds.midX, y: whiteCircle.bounds.midY)
        circleBorder.cornerRadius = whiteCircle.frame.size.width / 2
        whiteCircle.layer.insertSublayer(circleBorder, at: 0)
        
        let circleWidth = CGFloat(64)
        let circleHeight = circleWidth
        // Create a new CircleView
        circleView = LayerCircle(frame: CGRect(x: 1, y: 1, width: circleWidth, height: circleHeight))
        whiteCircle.addSubview(circleView)
        // Animate the drawing of the circle over the course of 1 second
        circleView.animateCircle(duration: 10.0)
    }
    
    //MARK:- Actions
//    изменить текущую камеру
    @IBAction func cameraSwitchTapped(_ sender: Any) {
        switchCamera()
    }
    
//    включить вспышку камеры
    @IBAction func toggleFlashTapped(_ sender: Any) {
        flashEnabled = !flashEnabled
        if flashEnabled == true {
            flashButton.setImage(#imageLiteral(resourceName: "flash"), for: UIControlState())
        } else {
            flashButton.setImage(#imageLiteral(resourceName: "flashOutline"), for: UIControlState())
        }
    }

    @IBAction func back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        print("deinit CameraViewController")
    }
}

extension CameraViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard info[UIImagePickerControllerMediaType] != nil else { return }
        let mediaType = info[UIImagePickerControllerMediaType] as! CFString
        switch mediaType {
        case kUTTypeImage:
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.swiftyCam(self, didTake: image)
            }
        case kUTTypeMovie:
            if let videoURL = info[UIImagePickerControllerReferenceURL] as? URL {
                self.swiftyCam(self, didFinishProcessVideoAt: videoURL)
            }
        default:
            break
        }
        
        picker.dismiss(animated: true, completion: nil);
    }
}
