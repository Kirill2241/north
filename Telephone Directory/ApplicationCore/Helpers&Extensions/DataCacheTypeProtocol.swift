//
//  DataCacheTypeProtocol.swift
//  Telephone Directory
//
//  Created by Diana Princess on 24.01.2023.
//

import Foundation
import UIKit
protocol DataCacheTypeProtocol: AnyObject {
    func lookForImageData(for urlString: String) -> Data?
    func insertImageData(_ data: Data?, for urlString: String)
}
