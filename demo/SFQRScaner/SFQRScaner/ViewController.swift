//
//  ViewController.swift
//  SFQRScaner
//
//  Created by Stroman on 2021/7/11.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,SFQRScanerProtocol,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.beginScaning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.scanner.stop()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.albumButton)
        NSLayoutConstraint.init(item: self.albumButton, attribute: .width, relatedBy: .equal, toItem: self.albumButton, attribute: .height, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint.init(item: self.albumButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 100).isActive = true
        NSLayoutConstraint.init(item: self.albumButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint.init(item: self.albumButton, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -100).isActive = true
        // Do any additional setup after loading the view.
    }
    
    private func beginScaning() -> Void {
        if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success == true {
                    DispatchQueue.main.async {
                        self.scanner.run(self.view, nil)
                    }
                } else {
                    self.gotoSettingApp()
                }
            }
        } else {
            self.scanner.run(self.view, nil)
        }
    }
    
    private func gotoSettingApp() -> Void {
        guard UIApplication.shared.canOpenURL(URL.init(string: UIApplication.openSettingsURLString)!) else {
            return
        }
        UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
    
    @objc private func albumButtonAction(_ sender:UIButton) -> Void {
        let controller:UIImagePickerController = UIImagePickerController.init()
        controller.sourceType = .savedPhotosAlbum
        controller.delegate = self
        self.present(controller, animated: true) {
        }
    }
    
    lazy private var albumButton:UIButton = {
        let result:UIButton = UIButton.init(type: .custom)
        result.setTitle("相册", for: .normal)
        result.addTarget(self, action: #selector(albumButtonAction(_:)), for: .touchUpInside)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()

    lazy private var scanner:SFQRScaner = {
        let result:SFQRScaner = SFQRScaner.init()
        result.delegate = self
        return result
    }()
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image:UIImage = info[.originalImage] as! UIImage
        picker.dismiss(animated: true) {
            self.scanner.readFromImage(image)
        }
    }

    func SFQRScanerProcessFailed(_ scanner: SFQRScaner) {
        print("失败了")
    }

    func SFQRScanerInitilizationFailed(_ scanner: SFQRScaner) {
        print("初始化失败")
    }
    
    func SFQRScanerGainResult(_ scanner: SFQRScaner, _ result: String?) {
        guard result != nil else {
            return
        }
        let controller:ResultViewController = ResultViewController.init()
        controller.dismissClosure = {
            self.beginScaning()
        }
        controller.resultString = result
        scanner.stop()
        self.present(controller, animated: true) {
        }
    }
}

