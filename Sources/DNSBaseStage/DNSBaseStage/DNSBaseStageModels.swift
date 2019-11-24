//
//  DNSBaseStageModels.swift
//  DoubleNode Core - DNSBaseScene
//
//  Created by Darren Ehlers on 2019/08/12.
//  Copyright © 2019 - 2016 Darren Ehlers and DoubleNode, LLC. All rights reserved.
//

import Foundation
import UIKit

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
    public enum Style {
        case hudShow, hudHide, popup
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
            public var displayType: DNSBaseStageDisplayType
            
            public init(displayType: DNSBaseStageDisplayType) {
                self.displayType = displayType
            }
        }
        public struct ViewModel: DNSBaseStageBaseViewModel {
            public var animated: Bool
            public var displayType: DNSBaseStageDisplayType
            
            public init(animated: Bool, displayType: DNSBaseStageDisplayType) {
                self.animated = animated
                self.displayType = displayType
            }
        }
    }
    public enum Finish {
        public struct Response: DNSBaseStageBaseResponse {
            public var displayType: DNSBaseStageDisplayType
            
            public init(displayType: DNSBaseStageDisplayType) {
                self.displayType = displayType
            }
        }
        public struct ViewModel: DNSBaseStageBaseViewModel {
            public var animated: Bool
            public var displayType: DNSBaseStageDisplayType
            
            public init(animated: Bool, displayType: DNSBaseStageDisplayType) {
                self.animated = animated
                self.displayType = displayType
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
    public enum Error {
        public struct Request: DNSBaseStageBaseRequest {
            public var error: NSError
            public var style: Style
            public var title: String
            
            public init(error: NSError, style: Style, title: String) {
                self.error = error
                self.style = style
                self.title = title
            }
        }
        public struct Response: DNSBaseStageBaseResponse {
            public var error: NSError
            public var style: Style
            public var title: String
            
            public init(error: NSError, style: Style, title: String) {
                self.error = error
                self.style = style
                self.title = title
            }
        }
    }
    public enum Message {
        public struct Response: DNSBaseStageBaseResponse {
            public var message: String
            public var percentage: Float = -1
            public var style: Style
            public var title: String
            
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
                public var title: UIColor?
            }
            public struct Fonts {
                public var message: UIFont?
                public var title: UIFont?
            }

            public var message: String
            public var percentage: Float = -1
            public var style: Style
            public var title: String

            public var colors: Colors?
            public var fonts: Fonts?
            
            public init(message: String, percentage: Float = -1, style: Style, title: String) {
                self.message = message
                self.style = style
                self.title = title
            }
        }
    }
    public enum Spinner {
        public struct Response: DNSBaseStageBaseResponse {
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
            
            public init(title: String) {
                self.title = title
            }
        }
        public struct ViewModel: DNSBaseStageBaseViewModel {
            public var title: String
            
            public init(title: String) {
                self.title = title
            }
        }
    }
    public enum Webpage {
        public struct Request: DNSBaseStageBaseRequest {
            public var url: NSURL
            
            public init(url: NSURL) {
                self.url = url
            }
        }
    }
    public enum WebpageError {
        public struct Request: DNSBaseStageBaseRequest {
            public var url: NSURL
            public var error: NSError

            public init(url: NSURL, error: NSError) {
                self.url = url
                self.error = error
            }
        }
    }
}
