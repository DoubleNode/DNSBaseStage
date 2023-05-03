//
//  CommonAlertVC.swift
//  WeMinder
//
//  Created by Krishna on 21/05/19.
//  Copyright © 2019 Krishna All rights reserved.
//

import AlamofireImage
import DNSBaseTheme
import DNSCore
import DNSCoreThreading
import UIKit

class CommonAlertVC: UIViewController {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var messageLabel: UILabel?
    @IBOutlet weak var disclaimerLabel: UILabel?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?
    @IBOutlet weak var cancelButton: UIButton?
    @IBOutlet weak var cancelButtonSpacerViewConstraint: NSLayoutConstraint?
    @IBOutlet weak var cancelButtonView: UIView?
    @IBOutlet weak var cancelButtonViewWidthConstraint: NSLayoutConstraint?
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var actionButtonView: UIView?
    @IBOutlet weak var actionButtonViewWidthConstraint: NSLayoutConstraint?
    @IBOutlet weak var action2Button: UIButton?
    @IBOutlet weak var action2ButtonView: UIView?
    @IBOutlet weak var action2ButtonViewWidthConstraint: NSLayoutConstraint?
    @IBOutlet weak var action3Button: UIButton?
    @IBOutlet weak var action3ButtonView: UIView?
    @IBOutlet weak var action3ButtonViewWidthConstraint: NSLayoutConstraint?
    @IBOutlet weak var action4Button: UIButton?
    @IBOutlet weak var action4ButtonView: UIView?
    @IBOutlet weak var action4ButtonViewWidthConstraint: NSLayoutConstraint?
    @IBOutlet weak var tag1Label: UILabel?
    @IBOutlet weak var tag1View: UIView?
    @IBOutlet weak var tag2Label: UILabel?
    @IBOutlet weak var tag2View: UIView?

    @IBOutlet weak var mainImageView: UIImageView?
    @IBOutlet weak var progressView: UIProgressView?

    @IBOutlet weak var heightViewContainer: NSLayoutConstraint!

    var cancelButtonSpacerViewConstraintConstant: CGFloat = 0
    var disclaimer: String = ""
    var message: String = ""
    var subtitle: String = ""
    var imageItem: UIImage?
    var imageUrl: URL?
    var tags: [String] = []

    var arrayAction: [[String: DNSStringBlock]]?
    var arrayActionStyles: [[String: DNSThemeButtonStyle]]?
    var okButtonAct: (DNSStringBlock)?

    var isContactNumberHidden: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //viewContainer.layer.cornerRadius = 20.0
        //viewContainer.layer.masksToBounds = true
        //actionButton.addCornerRadiusWithShadow(color: .lightGray, borderColor: .clear, cornerRadius: 25)
        //cancelButton.setCornerRadiusWith(radius: 25, borderWidth: 1.0, borderColor: #colorLiteral(red: 0.03529411765, green: 0.2274509804, blue: 0.9333333333, alpha: 1))

        self.disclaimerLabel?.text = disclaimer
        self.messageLabel?.text = message
        self.titleLabel?.text = title
        self.subtitleLabel?.text = subtitle

        if tags.count > 0 {
            self.tag1Label?.text = tags[0]
            self.tag1View?.isHidden = self.tag1Label?.text?.isEmpty ?? true
        } else {
            self.tag1View?.isHidden = true
        }
        if tags.count > 1 {
            self.tag2Label?.text = tags[1]
            self.tag2View?.isHidden = self.tag1Label?.text?.isEmpty ?? true
        } else {
            self.tag2View?.isHidden = true
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

        if let arrayAction = self.arrayAction {
            if cancelButtonSpacerViewConstraintConstant == 0.0 {
                cancelButtonSpacerViewConstraintConstant = cancelButtonSpacerViewConstraint?.constant ?? 0.0
            }
            cancelButtonSpacerViewConstraint?.constant = cancelButtonSpacerViewConstraintConstant
            var buttonCount = 0
            for dic in arrayAction {
                if buttonCount > 1 {
                    return
                }
                let styleDic = arrayActionStyles?[buttonCount] ?? [:]
                let allKeys = Array(dic.keys)
                if allKeys.isEmpty {
                    cancelButtonSpacerViewConstraint?.constant = 0.0
                    if buttonCount == 0 {
                        actionButtonView?.isHidden = true
                        actionButtonViewWidthConstraint?.priority = UILayoutPriority.required
                        action2ButtonView?.isHidden = true
                        action2ButtonViewWidthConstraint?.priority = UILayoutPriority.required
                    } else {
                        cancelButtonView?.isHidden = true
                        cancelButtonViewWidthConstraint?.priority = UILayoutPriority.required
                    }
                } else {
                    let buttonTitle: String = allKeys[0]
                    if buttonCount == 0 {
                        actionButton.setTitle(buttonTitle, for: .normal)
                        if let actionDNSButton = actionButton as? DNSUIButton {
                            actionDNSButton.style = styleDic[buttonTitle] ?? .default
                        }
                        actionButtonView?.isHidden = false
                        actionButtonViewWidthConstraint?.priority = UILayoutPriority.defaultLow
                        if allKeys.count > 1 {
                            let button2Title: String = allKeys[1]
                            action2Button?.setTitle(button2Title, for: .normal)
                            if let action2DNSButton = action2Button as? DNSUIButton {
                                action2DNSButton.style = styleDic[button2Title] ?? .default
                            }
                            action2ButtonView?.isHidden = false
                            action2ButtonViewWidthConstraint?.priority = UILayoutPriority.defaultLow
                            if allKeys.count > 2 {
                                let button3Title: String = allKeys[2]
                                action3Button?.setTitle(button3Title, for: .normal)
                                if let action3DNSButton = action3Button as? DNSUIButton {
                                    action3DNSButton.style = styleDic[button3Title] ?? .default
                                }
                                action3ButtonView?.isHidden = false
                                action3ButtonViewWidthConstraint?.priority = UILayoutPriority.defaultLow
                                if allKeys.count > 3 {
                                    let button4Title: String = allKeys[3]
                                    action4Button?.setTitle(button4Title, for: .normal)
                                    if let action4DNSButton = action4Button as? DNSUIButton {
                                        action4DNSButton.style = styleDic[button4Title] ?? .default
                                    }
                                    action4ButtonView?.isHidden = false
                                    action4ButtonViewWidthConstraint?.priority = UILayoutPriority.defaultLow
                                }
                            }
                        }
                    } else {
                        cancelButton?.setTitle(buttonTitle, for: .normal)
                        if let cancelDNSButton = cancelButton as? DNSUIButton {
                            cancelDNSButton.style = styleDic[buttonTitle] ?? .default
                        }
                        cancelButtonView?.isHidden = false
                        cancelButtonViewWidthConstraint?.priority = UILayoutPriority.defaultLow
                    }
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
        let buttonLabel = sender.title(for: .normal) ?? ""
        guard let arrayAction = self.arrayAction,
            arrayAction.count > 1 else {
            okButtonAct?(buttonLabel)
            return
        }
        let dic = arrayAction[1]
        for (key, value) in dic {
            value(key)
        }
    }
    @IBAction func actionButtonAction(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        let buttonLabel = sender.title(for: .normal) ?? ""
        guard let arrayAction = self.arrayAction,
            arrayAction.count > 0 else {
            okButtonAct?(buttonLabel)
            return
        }
        let dic = arrayAction[0]
        for (key, value) in dic {
            if key == buttonLabel {
                value(key)
            }
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
