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

public protocol DNSBaseStageReusableViewLogic: class {
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
    }
}
