//
//  ImageCache.swift
//  Telephone Directory
//
//  Created by Diana Princess on 24.01.2023.
//

import UIKit

final class ImageDataCache {
    private lazy var dataCache: NSCache<AnyObject, AnyObject> = {
            let cache = NSCache<AnyObject, AnyObject>()
            cache.countLimit = config.countLimit
            return cache
        }()

        private let lock = NSLock()
        private let config: Config

        struct Config {
            let countLimit: Int
            let memoryLimit: Int

            static let defaultConfig = Config(countLimit: 100, memoryLimit: 1024 * 1024 * 100)
        }

        init(config: Config = Config.defaultConfig) {
            self.config = config
        }
}

extension ImageDataCache: ImageDataCacheTypeProtocol {
    func lookForImageData(for urlString: String) -> Data? {
        lock.lock(); defer { lock.unlock() }
            if let data = dataCache.object(forKey: urlString as AnyObject) as? Data {
            return data
            }
        return nil
    }
    
    func insertImageData(_ data: Data?, for urlString: String) {
        guard let data = data else { return }
        lock.lock(); defer { lock.unlock() }
        dataCache.setObject(data as AnyObject, forKey: urlString as AnyObject)
    }
}
