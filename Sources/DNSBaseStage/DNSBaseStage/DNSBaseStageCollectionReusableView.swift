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
    static public var reuseIdentifier: String {
        String(describing: self)
    }
    static public var uiNib: UINib {
        UINib(nibName: self.reuseIdentifier,
              bundle: nil)
    }
    static public func register(to collectionView: UICollectionView,
                                for elementKind: String) {
        collectionView.register(self.uiNib,
                                forSupplementaryViewOfKind: elementKind,
                                withReuseIdentifier: self.reuseIdentifier)
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
