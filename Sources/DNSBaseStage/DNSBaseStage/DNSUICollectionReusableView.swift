//
//  DNSUICollectionReusableView.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import Combine
import DNSProtocols
import UIKit

public protocol DNSBaseStageReusableViewLogic: AnyObject {
    // MARK: - Outgoing Pipelines -
}

open class DNSBaseStageCollectionReusableView: UICollectionReusableView, DNSBaseStageReusableViewLogic {
    // MARK: - Outgoing Pipelines -

    open func subscribe(to baseViewController: DNSBaseStageDisplayLogic) {
    }

    // MARK: - Workers -
    public var analyticsWorker: PTCLAnalytics_Protocol?

    override open func awakeFromNib() {
        super.awakeFromNib()
        if let identifier = "\(type(of: self))".split(separator: ".").last {
            self.accessibilityIdentifier = String(identifier)
        }

        self.contentInit()
    }

    override open func prepareForReuse() {
        super.prepareForReuse()

        self.contentInit()
    }

    open func contentInit() {
    }
}
