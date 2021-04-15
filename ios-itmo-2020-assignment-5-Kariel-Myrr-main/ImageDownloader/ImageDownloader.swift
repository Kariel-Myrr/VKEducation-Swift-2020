import UIKit
import Combine




final class ImageDownloader {
    typealias ImageCompletion = (UIImage) -> Void
    
    static let sharedInstance = ImageDownloader()
    
    private let asyncQueue : OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 6
        return queue
    }()
    
    private let syncQueue : OperationQueue =  {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private var cache : NSCache<NSString, UIImage> = NSCache()
    private var operations : [String : Operation] = [:]//TODO delete operations
    
    
    private init(){
    }
    
    // MARK: - Public
    
    func image(by url: String, completion: @escaping ImageCompletion) -> Cancellable {
        let operation = ImageDownloadOperation(url: url, cache: cache)
        
        
        syncQueue.addOperation {
            if let oldOperation = self.operations[url] {
                operation.addDependency(oldOperation)
            }
            self.operations[url] = operation
        }
        
        operation.completionBlock = { [weak operation] in
            guard
                let operation = operation,
                !operation.isCancelled,
                let image = operation.image
            else { return }
            
            OperationQueue.main.addOperation {
                completion(image)
            }
        }
        
        
        asyncQueue.addOperation(operation)
        
        return operation
    }
    
    // MARK: - Private
    
    
    /*
     Реализация логики
     */
}
