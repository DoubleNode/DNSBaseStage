//
//  DNSMonochromeImageFilter.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import AlamofireImage
import UIKit

public struct DNSMonochromeImageFilter: ImageFilter, CoreImageFilter {
    /// The filter name.
    public let filterName = "CIColorMonochrome"
    
    /// The image filter parameters passed to CoreImage.
    public let parameters: [String: Any]
    
    /// Initializes the `MonochromeFilter` instance with the given blur radius.
    ///
    /// - parameter inputColor: The monochrome color.
    ///
    /// - parameter inputIntensity: The monochrome intensity.
    ///
    /// - returns: The new `MonochromeFilter` instance.
    public init(inputIntensity: Float = 1.0) {
        parameters = [
            "inputColor": CIColor(red: 0.7, green: 0.7, blue: 0.7),
            "inputIntensity": inputIntensity,
        ]
    }
}

