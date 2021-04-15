//
//  ImageDownloadOperation.swift
//  ImageDownloader
//
//  Created by Kariel Myrr on 27.12.2020.
//

import Foundation
import UIKit


class ImageDownloadOperation : AsyncOperation {
    
    private var url : String
    private var cache : NSCache<NSString, UIImage>
    var image : UIImage?
    
    init(url : String, cache : NSCache<NSString, UIImage>) {
        self.url = url
        self.cache = cache
        self.image = nil
    }
    
    
    override func main() {
        
        
        if isCancelled { return }
        
        if let image = cache.object(forKey: url as NSString) {
            self.image = image
            state = .finished
            return
        }
        
        if isCancelled { return }
        
        let imagePath = FileManager.default.pathFor(imageUrl: url)
        if let image = UIImage(contentsOfFile: imagePath) {
            self.image = image
            cache.setObject(image, forKey: url as NSString)
            state = .finished
            return
        }
        
        if isCancelled { return }
        
        guard let url = URL(string: url) else {
            state = .finished
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self else { return }
            guard let image = data.flatMap({ UIImage(data: $0) }) else {
                self.state = .finished
                return
            }
        
            self.image = image
            
            self.cache.setObject(image, forKey: self.url as NSString)
            FileManager.default.createFile(atPath: imagePath, contents: image.jpegData(compressionQuality: 1), attributes: [ : ])//TODO в ||
            
            self.state = .finished
        }.resume()
        
        
        
    }
    
}

extension FileManager {
    func pathFor(imageUrl : String) -> String {
        let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
            .map{ $0.appendingPathComponent("images").appendingPathComponent("\(imageUrl.hash)") }!.absoluteString
        
        return path
    }
}
