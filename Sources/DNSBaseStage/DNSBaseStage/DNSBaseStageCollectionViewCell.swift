//
//  DNSBaseStageCollectionViewCell.swift
//  DoubleNode Core - DNSBaseScene
//
//  Created by Darren Ehlers on 2019/08/12.
//  Copyright © 2019 - 2016 Darren Ehlers and DoubleNode, LLC. All rights reserved.
//

import Combine
import DNSProtocols
import UIKit

public protocol DNSBaseStageCellLogic: class {
    // MARK: - Outgoing Pipelines -
}

open class DNSBaseStageCollectionViewCell: UICollectionViewCell, DNSBaseStageCellLogic {
    // MARK: - Outgoing Pipelines -

    open func subscribe(to baseViewController: DNSBaseStageDisplayLogic) {
    }

    // MARK: - Workers -
    public var analyticsWorker: PTCLAnalytics_Protocol?

    override open func awakeFromNib() {
        super.awakeFromNib()
    }
}
