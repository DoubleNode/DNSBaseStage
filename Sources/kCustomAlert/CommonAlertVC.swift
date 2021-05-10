//
//  CommonAlertVC.swift
//  WeMinder
//
//  Created by Krishna on 21/05/19.
//  Copyright © 2019 Krishna All rights reserved.
//

import AlamofireImage
import DNSCore
import UIKit

class CommonAlertVC: UIViewController {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var messageLabel: UILabel?
    @IBOutlet weak var disclaimerLabel: UILabel?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subTitleLabel: UILabel?
    @IBOutlet weak var cancelButton: UIButton?
    @IBOutlet weak var okayButton: UIButton!
    @IBOutlet weak var tag1Label: UILabel?
    @IBOutlet weak var tag1View: UIView?
    @IBOutlet weak var tag2Label: UILabel?
    @IBOutlet weak var tag2View: UIView?

    @IBOutlet weak var mainImageView: UIImageView?
    @IBOutlet weak var progressView: UIProgressView?

    @IBOutlet weak var heightViewContainer: NSLayoutConstraint!

    var disclaimer: String = ""
    var message: String = ""
    var subTitle: String = ""
    var imageItem: UIImage?
    var imageUrl: URL?
    var tags: [String] = []

    var arrayAction: [[String: () -> Void]]?
    var okButtonAct: (() -> Void)?

    var isContactNumberHidden: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //viewContainer.layer.cornerRadius = 20.0
        //viewContainer.layer.masksToBounds = true
        //okayButton.addCornerRadiusWithShadow(color: .lightGray, borderColor: .clear, cornerRadius: 25)
        //cancelButton.setCornerRadiusWith(radius: 25, borderWidth: 1.0, borderColor: #colorLiteral(red: 0.03529411765, green: 0.2274509804, blue: 0.9333333333, alpha: 1))

        self.disclaimerLabel?.text = disclaimer
        self.messageLabel?.text = message
        self.titleLabel?.text = title
        self.subTitleLabel?.text = subTitle

        if tags.count > 0 {
            self.tag1Label?.text = tags[0]
            self.tag1View?.isHidden = self.tag1Label?.text?.isEmpty ?? true
        }
        if tags.count > 1 {
            self.tag2Label?.text = tags[1]
            self.tag2View?.isHidden = self.tag1Label?.text?.isEmpty ?? true
        }

        if imageItem == nil && imageUrl == nil {
            mainImageView?.isHidden = true
        } else {
            mainImageView?.isHidden = false
            mainImageView?.image = nil
            if imageItem != nil {
                mainImageView?.image = imageItem!
            }
            self.progressView?.setProgress(0.0, animated: false)
            if imageUrl != nil {
                self.mainImageView?.af.setImage(withURL: imageUrl!,
                                           cacheKey: imageUrl!.absoluteString,
                                           progress: { (progress) in
                                            self.progressView?.setProgress(Float(progress.fractionCompleted),
                                                                          animated: true)
                                            self.progressView?.isHidden = (progress.fractionCompleted >= 1.0)
                                           },
                                           imageTransition: UIImageView.ImageTransition.crossDissolve(0.2))
            }
        }

//        if !descriptionMessage.isEmpty && (imageItem != nil) {
//            //heightViewContainer.constant = 400
//        } else if !descriptionMessage.isEmpty && (imageItem == nil) {
//            //heightViewContainer.constant = 350
//        }

        if arrayAction == nil {
            //cancelButton.isHidden = true
        } else {
            var buttonCount = 0
            for dic in arrayAction! {
                if buttonCount > 1 {
                    return
                }
                let allKeys = Array(dic.keys)
                let buttonTitle: String = allKeys[0]    //.uppercased()
                if buttonCount == 0 {
                    okayButton.setTitle(buttonTitle, for: .normal)
                } else {
                    cancelButton?.setTitle(buttonTitle, for: .normal)
                }
                buttonCount += 1
            }
        }
    }

    // MARK: - IBAction Methods

    @IBAction func contactButtonAction(sender: UIButton) {
        if let url = URL(string: "tel://\(sender.titleLabel?.text ?? "")") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @IBAction func cancelButtonAction(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        if arrayAction != nil {
            let dic = arrayAction![1]
            for (_, value) in dic {
                let action: () -> Void = value
                action()
            }
        } else {
            okButtonAct?()
        }
    }

    @IBAction func okayButtonAction(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        if arrayAction != nil {
            let dic = arrayAction![0]
            for (_, value) in dic {
                let action: () -> Void = value
                action()
            }
        } else {
            okButtonAct?()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    static func showAlertWithTitle(_ title: String?, message : String?, actionDic : [String: (UIAlertAction) -> Void]) {
        var alertTitle : String = title!
        if title == nil {
            alertTitle = ""
        }
        let alert : UIAlertController = UIAlertController.init(title: alertTitle, message: message, preferredStyle: .alert)

        for (key, value) in actionDic {
            let buttonTitle : String = key
            let action: (UIAlertAction) -> Void = value
            alert.addAction(UIAlertAction.init(title: buttonTitle, style: .default, handler: action))
        }
        DNSCore.appDelegate?.rootViewController()
//        UIApplication.shared.keyWindow?.rootViewController!
            .present(alert, animated: true, completion: nil)
    }
}
