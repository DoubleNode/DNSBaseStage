//
//  DNSBaseStageCollectionViewSwipeCell.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import Combine
import DNSCrashWorkers
import DNSProtocols
import DNSThemeObjects
import UIKit

open class DNSBaseStageCollectionViewSwipeCell: DNSUICollectionViewSwipeCell, DNSBaseStageCellLogic {
    static public var reuseIdentifier: String {
        String(describing: self)
    }
    open lazy var analyticsClassTitle: String = {
        String(describing: self.classForCoder)
    }()
    static public var bundle: Bundle? = nil
    static public var uiNib: UINib {
        UINib(nibName: self.reuseIdentifier,
              bundle: self.bundle)
    }
    static public func register(to collectionView: UICollectionView,
                                from bundle: Bundle? = nil) {
        self.bundle = bundle
        collectionView.register(self.uiNib,
                                forCellWithReuseIdentifier: self.reuseIdentifier)
    }
    static public func dequeue(from collectionView: UICollectionView,
                               for indexPath: IndexPath) -> DNSBaseStageCollectionViewSwipeCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier,
                                                  // swiftlint:disable:next force_cast
                                                  for: indexPath) as! DNSBaseStageCollectionViewSwipeCell
    }

    // MARK: - Workers -
    public var wkrAnalytics: WKRPTCLAnalytics = WKRCrashAnalytics()

    // MARK: - Outgoing Pipelines -
    open func subscribe(to baseViewController: DNSBaseStageDisplayLogic) { }

    // MARK: - Lifecycle methods -
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
    open func contentInit() { }
    
    // MARK: - Utility methods
    open func utilityAutoTrack(_ method: String) {
        self.wkrAnalytics.doAutoTrack(class: self.analyticsClassTitle, method: method)
    }
}
