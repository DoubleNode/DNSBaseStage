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
        }
        public struct Results: DNSBaseStageBaseResults {
        }
        public struct Data: DNSBaseStageBaseData {
        }
        public struct Request: DNSBaseStageBaseRequest {
        }
        public struct Response: DNSBaseStageBaseResponse {
        }
        public struct ViewModel: DNSBaseStageBaseViewModel {
        }
    }

    public enum Start {
        public struct Response: DNSBaseStageBaseResponse {
            var displayType: DNSBaseStageDisplayType
        }
        public struct ViewModel: DNSBaseStageBaseViewModel {
            var animated: Bool
            var displayType: DNSBaseStageDisplayType
        }
    }
    public enum Finish {
        public struct Response: DNSBaseStageBaseResponse {
            var displayType: DNSBaseStageDisplayType
        }
        public struct ViewModel: DNSBaseStageBaseViewModel {
            var animated: Bool
            var displayType: DNSBaseStageDisplayType
        }
    }

    public class Confirmation {
        public class Request: DNSBaseStageBaseRequest {
            public struct TextField {
                var value: String?
            }

            public init() {}

            var userData: Any?

            var selection: String?
            var textFields: [TextField] = []
        }
        public class Response: DNSBaseStageBaseResponse {
            public struct TextField {
                var contentType: String?
                var keyboardType: UIKeyboardType?
                var placeholder: String?
            }
            public struct Button {
                var code: String?
                var style: UIAlertAction.Style?
                var title: String?
            }

            public init() {}

            var alertStyle: UIAlertController.Style?
            var message: String?
            var title: String?

            var buttons: [Button] = []
            var textFields: [TextField] = []
            var userData: Any?
        }
        public class ViewModel: DNSBaseStageBaseViewModel {
            public struct TextField {
                var contentType: String?
                var keyboardType: UIKeyboardType?
                var placeholder: String?
            }
            public struct Button {
                var code: String?
                var style: UIAlertAction.Style?
                var title: String?
            }

            public init() {}

            var alertStyle: UIAlertController.Style?
            var message: String?
            var title: String?

            var buttons: [Button] = []
            var textFields: [TextField] = []
            var userData: Any?
        }
    }
    public enum Dismiss {
        public struct Response: DNSBaseStageBaseResponse {
            var animated: Bool
        }
        public struct ViewModel: DNSBaseStageBaseViewModel {
            var animated: Bool
        }
    }
    public enum Error {
        public struct Request: DNSBaseStageBaseRequest {
            var error: NSError
            var style: Style
            var title: String
        }
        public struct Response: DNSBaseStageBaseResponse {
            var error: NSError
            var style: Style
            var title: String
        }
    }
    public enum Message {
        public struct Response: DNSBaseStageBaseResponse {
            var message: String
            var percentage: Float = -1
            var style: Style
            var title: String
        }
        public struct ViewModel: DNSBaseStageBaseViewModel {
            public struct Colors {
                var background: UIColor?
                var message: UIColor?
                var title: UIColor?
            }
            public struct Fonts {
                var message: UIFont?
                var title: UIFont?
            }

            var message: String
            var percentage: Float = -1
            var style: Style
            var title: String

            var colors: Colors?
            var fonts: Fonts?
        }
    }
    public enum Spinner {
        public struct Response: DNSBaseStageBaseResponse {
            var show: Bool
        }
        public struct ViewModel: DNSBaseStageBaseViewModel {
            var show: Bool
        }
    }
    public enum Title {
        public struct Response: DNSBaseStageBaseResponse {
            var title: String
        }
        public struct ViewModel: DNSBaseStageBaseViewModel {
            var title: String
        }
    }
    public enum Webpage {
        public struct Request: DNSBaseStageBaseRequest {
            var url: NSURL
        }
    }
    public enum WebpageError {
        public struct Request: DNSBaseStageBaseRequest {
            var url: NSURL
            var error: NSError
        }
    }
}
