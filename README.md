# SFQRScaner
我自己写的二维码扫描器
## 示例
![示例](https://github.com/AbnormalProgrammer/SFQRScaner/raw/main/resources/example.gif)
## 它是什么？
它是个很简单，功能很单一的二维码扫描器。
## 它有什么用？
1. 通过摄像头扫描二维码，解析出字符串。
2. 通过iOS手机相册解读二维码，解析出字符串。
## 它的需求背景是什么？
这东西太常用了，几乎每个APP都有扫码功能。
## 行为表现
它是通过扫描或者处理图片，解析出其中包含的信息字符串，供程序处理。
## 原理
就是系统API的调用。
## 如何使用？
1. 遵循`SFQRScanerProtocol`。
2. 确保已经获取到相机权限。
3. 在合适的时机调用`internal func run(_ containerView:UIView,_ ior:CGRect?) -> Void`。
4. 使用完毕调用`internal func stop() -> Void`。

下面是使用示例代码：<br>
```
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
```
源代码在source文件夹里面，请自行取用。
## 适用环境
iOS 14.5及以上
<br>swift 5.0
<br>XCode 12
## 联系方式
我的profile里面有联系方式
## 许可证
本控件遵循MIT许可，详情请见[LICENSE](https://github.com/AbnormalProgrammer/SFQRScaner/blob/main/LICENSE)。
