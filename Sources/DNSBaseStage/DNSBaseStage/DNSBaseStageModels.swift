//
//  DNSBaseStageModels.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import DNSDataObjects
import DNSError
import Foundation
import UIKit
import DNSThemeTypes

public protocol DNSBaseStageBaseInitialization {
}

public protocol DNSBaseStageBaseResults {
}

public protocol DNSBaseStageBaseData {
}

public protocol DNSBaseStageBaseRequest {
}

public protocol DNSBaseStageBaseResponse {
}

public protocol DNSBaseStageBaseViewModel {
}

open class DNSBaseStageModels {
    typealias BaseStage = DNSBaseStage
    
    public struct ToastDefaults {
        public var dismissingDirection: Direction = .default
        public var duration: Duration = .default
        public var location: Location = .default
        public var presentingDirection: Direction = .default
        public init() { }
    }
    public struct Defaults {
        public var error: DNSBaseStageModels.ToastDefaults = DNSBaseStageModels.ToastDefaults()
        public var message: DNSBaseStageModels.ToastDefaults = DNSBaseStageModels.ToastDefaults()
        public init() { }
    }
    static public var defaults: DNSBaseStageModels.Defaults = DNSBaseStageModels.Defaults()

    public enum Direction {
        case `default`
        case left
        case right
        case vertical
    }
    public enum Duration: Equatable {
        case `default`
        case short
        case average
        case long
        case custom(TimeInterval)
    }
    public enum Location {
        case `default`
        case top
        case bottom
    }
    public enum Style {
        case none, hudShow, hudHide, popup, popupAction
        case toastSuccess, toastError, toastWarning, toastInfo
    }

    public enum Base {
        public struct Initialization: DNSBaseStageBaseInitialization {
            public init() {}
        }
        public struct Results: DNSBaseStageBaseResults {
            public init() {}
        }
        public struct Data: DNSBaseStageBaseData {
            public init() {}
        }
        public struct Request: DNSBaseStageBaseRequest {
            public init() {}
        }
        public struct Response: DNSBaseStageBaseResponse {
            public init() {}
        }
        public struct ViewModel: DNSBaseStageBaseViewModel {
            public init() {}
        }
    }

    public enum Start {
        public struct Response: DNSBaseStageBaseResponse {
            public var displayMode: DNSBaseStage.Display.Mode
            public var displayOptions: DNSBaseStage.Display.Options = []

            public init(displayMode: DNSBaseStage.Display.Mode,
                        displayOptions: DNSBaseStage.Display.Options) {
                self.displayMode = displayMode
                self.displayOptions = displayOptions
            }
        }
        public struct ViewModel: DNSBaseStageBaseViewModel {
            public var animated: Bool
            public var displayMode: DNSBaseStage.Display.Mode
            public var displayOptions: DNSBaseStage.Display.Options = []

            public init(animated: Bool,
                        displayMode: DNSBaseStage.Display.Mode,
                        displayOptions: DNSBaseStage.Display.Options) {
                self.animated = animated
                self.displayMode = displayMode
                self.displayOptions = displayOptions
            }
        }
    }
    public enum Finish {
        public struct Response: DNSBaseStageBaseResponse {
            public var displayMode: DNSBaseStage.Display.Mode

            public init(displayMode: DNSBaseStage.Display.Mode) {
                self.displayMode = displayMode
            }
        }
        public struct ViewModel: DNSBaseStageBaseViewModel {
            public var animated: Bool
            public var displayMode: DNSBaseStage.Display.Mode

            public init(animated: Bool, displayMode: DNSBaseStage.Display.Mode) {
                self.animated = animated
                self.displayMode = displayMode
            }
        }
    }

    public class Confirmation {
        public class Request: DNSBaseStageBaseRequest {
            public struct TextField {
                public var value: String?
            }

            public init() {}

            public var userData: Any?

            public var selection: String?
            public var textFields: [TextField] = []
        }
        public class Response: DNSBaseStageBaseResponse {
            public struct TextField {
                public var contentType: String?
                public var keyboardType: UIKeyboardType?
                public var placeholder: String?

                public init() {}
            }
            public struct Button {
                public var code: String?
                public var style: UIAlertAction.Style?
                public var title: String?

                public init() {}
            }

            public init() {}

            public var alertStyle: UIAlertController.Style?
            public var message: String?
            public var title: String?

            public var buttons: [Button] = []
            public var textFields: [TextField] = []
            public var userData: Any?
        }
        public class ViewModel: DNSBaseStageBaseViewModel {
            public struct TextField {
                public var contentType: String?
                public var keyboardType: UIKeyboardType?
                public var placeholder: String?
            }
            public struct Button {
                public var code: String?
                public var style: UIAlertAction.Style?
                public var title: String?
            }

            public init() {}

            public var alertStyle: UIAlertController.Style?
            public var message: String?
            public var title: String?

            public var buttons: [Button] = []
            public var textFields: [TextField] = []
            public var userData: Any?
        }
    }
    public enum Disabled {
        public struct Response: DNSBaseStageBaseResponse {
            public var forceReset = false
            public var show: Bool

            public init(show: Bool) {
                self.show = show
            }
        }
        public struct ViewModel: DNSBaseStageBaseViewModel {
            public var show: Bool

            public init(show: Bool) {
                self.show = show
            }
        }
    }
    public enum Dismiss {
        public struct Response: DNSBaseStageBaseResponse {
            public var animated: Bool

            public init(animated: Bool) {
                self.animated = animated
            }
        }
        public struct ViewModel: DNSBaseStageBaseViewModel {
            public var animated: Bool

            public init(animated: Bool) {
                self.animated = animated
            }
        }
    }
    public enum ErrorMessage {
        public struct Request: DNSBaseStageBaseRequest {
            public var error: Error
            public var style: Style
            public var title: String

            public var nibName: String = ""
            public var nibBundle: Bundle?
            public var okayButton: String = ""

            public init(error: Error, style: Style, title: String) {
                self.error = error
                self.style = style
                self.title = title
            }
        }
        public struct Response: DNSBaseStageBaseResponse {
            public var dismissingDirection: Direction = DNSBaseStageModels.defaults.error.dismissingDirection
            public var duration: Duration = DNSBaseStageModels.defaults.error.duration
            public var error: Error
            public var location: Location = DNSBaseStageModels.defaults.error.location
            public var presentingDirection: Direction = DNSBaseStageModels.defaults.error.presentingDirection
            public var style: Style
            public var title: String

            public var nibName: String = ""
            public var nibBundle: Bundle?
            public var okayButton: String = ""

            public init(error: Error, style: Style, title: String) {
                self.error = error
                self.style = style
                self.title = title
            }
        }
    }
    public enum Message {
        public struct Request: DNSBaseStageBaseRequest {
            public var actionCode: String = ""
            public var cancelled: Bool = false
            public var userData: Any?
        }
        public struct Response: DNSBaseStageBaseResponse {
            public var disclaimer: String = ""
            public var dismissingDirection: Direction = DNSBaseStageModels.defaults.message.dismissingDirection
            public var duration: Duration = DNSBaseStageModels.defaults.message.duration
            public var image: UIImage?
            public var imageUrl: URL?
            public var location: Location = DNSBaseStageModels.defaults.message.location
            public var tags: [String] = []
            public var message: String
            public var percentage: Float = -1
            public var presentingDirection: Direction = DNSBaseStageModels.defaults.message.presentingDirection
            public var style: Style
            public var subtitle: String = ""
            public var title: String

            public var actions: [String: String] = [:]
            public var cancelText: String = ""
            public var nibName: String = ""
            public var nibBundle: Bundle?
            public var userData: Any?

            public var actionsStyles: [String: DNSThemeButtonStyle] = [:]
            public var cancelStyle = BaseStage.defaultCancelButton

            public init(message: String, style: Style, title: String) {
                self.message = message
                self.style = style
                self.title = title
            }
        }
        public struct ViewModel: DNSBaseStageBaseViewModel {
            public struct Colors {
                public var background: UIColor?
                public var message: UIColor?
                public var subtitle: UIColor?
                public var title: UIColor?
            }
            public struct Fonts {
                public var message: UIFont?
                public var subtitle: UIFont?
                public var title: UIFont?
            }

            public var disclaimer: String = ""
            public var dismissingDirection: Direction = DNSBaseStageModels.defaults.message.dismissingDirection
            public var duration: Duration = DNSBaseStageModels.defaults.message.duration
            public var image: UIImage?
            public var imageUrl: URL?
            public var location: Location = DNSBaseStageModels.defaults.message.location
            public var message: String
            public var percentage: Float = -1
            public var presentingDirection: Direction = DNSBaseStageModels.defaults.message.presentingDirection
            public var subtitle: String = ""
            public var style: Style
            public var tags: [String] = []
            public var title: String

            public var actions: [String: String] = [:]
            public var cancelText: String = ""
            public var colors: Colors?
            public var fonts: Fonts?
            public var nibName: String = ""
            public var nibBundle: Bundle?
            public var userData: Any?

            public var actionsStyles: [String: DNSThemeButtonStyle] = [:]
            public var cancelStyle = BaseStage.defaultCancelButton

            public init(message: String, percentage: Float = -1, style: Style, title: String) {
                self.message = message
                self.style = style
                self.title = title
            }
        }
    }
    public enum Spinner {
        public struct Response: DNSBaseStageBaseResponse {
            public var forceReset = false
            public var show: Bool

            public init(show: Bool) {
                self.show = show
            }
        }
        public struct ViewModel: DNSBaseStageBaseViewModel {
            public var show: Bool

            public init(show: Bool) {
                self.show = show
            }
        }
    }
    public enum Title {
        public struct Response: DNSBaseStageBaseResponse {
            public var title: String
            public var tabBarImageName: String = ""
            public var tabBarHide: Bool = false

            public init(title: String) {
                self.title = title
            }
        }
        public struct ViewModel: DNSBaseStageBaseViewModel {
            public var title: String
            public var tabBarHide: Bool = false
            public var tabBarSelectedImage: UIImage?
            public var tabBarUnselectedImage: UIImage?

            public init(title: String) {
                self.title = title
            }
        }
    }
    public enum Webpage {
        public struct Request: DNSBaseStageBaseRequest {
            public var url: URL

            public init(url: URL) {
                self.url = url
            }
        }
    }
    public enum WebpageProgress {
        public struct Request: DNSBaseStageBaseRequest {
            public var percentage: Double

            public init(percentage: Double) {
                self.percentage = percentage
            }
        }
    }
    public enum WebpageError {
        public struct Request: DNSBaseStageBaseRequest {
            public var url: URL
            public var error: Error

            public init(url: URL, error: Error) {
                self.url = url
                self.error = error
            }
        }
    }
}
