//
//  DNSBaseStageCollectionViewCell.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import Combine
import DNSProtocols
import UIKit

public protocol DNSBaseStageCellLogic: AnyObject {
    // MARK: - Outgoing Pipelines -
}
open class DNSBaseStageCollectionViewCell: UICollectionViewCell, DNSBaseStageCellLogic {
    static public var uiNib: UINib {
        UINib(nibName: String(describing: self),
              bundle: nil)
    }
    static public func register(to collectionView: UICollectionView) {
        collectionView.register(self.uiNib,
                                forCellWithReuseIdentifier: String(describing: self))
    }

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
