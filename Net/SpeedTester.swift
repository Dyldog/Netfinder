//
//  SpeedTester.swift
//  Net
//
//  Created by Dylan Elliott on 19/1/2023.
//

import Foundation

class SpeedTester: NSObject {
    typealias SpeedTestCompletion = (_ megabytesPerSecond: Double? , _ error: Error?) -> Void
    private var speedTestCompletionBlock : SpeedTestCompletion?
    
    private var startTime: CFAbsoluteTime!
    private var stopTime: CFAbsoluteTime!
    private var bytesReceived: Int!
    
    private let testURL = URL(string: "https://apple.com")!
    
    func testDownloadSpeed(timeout: TimeInterval, withCompletionBlock: @escaping SpeedTestCompletion) {
        startTime = CFAbsoluteTimeGetCurrent()
        stopTime = startTime
        bytesReceived = 0
        
        speedTestCompletionBlock = withCompletionBlock
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForResource = timeout
        
        let operationQueue = OperationQueue()
        
        let session = URLSession.init(configuration: configuration, delegate: nil, delegateQueue: operationQueue)
        session.dataTask(with: .init(url: testURL)) { data, _, error in
            
            self.stopTime = CFAbsoluteTimeGetCurrent()
            
            if let data = data {
                self.bytesReceived! += data.count
            }
            
            let elapsed = self.stopTime - self.startTime
            
            if let aTempError = error as NSError?, aTempError.domain != NSURLErrorDomain && aTempError.code != NSURLErrorTimedOut && elapsed == 0  {
                self.speedTestCompletionBlock?(nil, error)
                return
            }
            
            let speed = elapsed != 0 ? Double(self.bytesReceived) / elapsed / 1024.0 / 1024.0 : -1
            self.speedTestCompletionBlock?(speed, nil)
        }.resume()
        
    }
}

//extension SpeedTester: URLSessionTaskDelegate {
//    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
//        bytesReceived! += data.count
//        stopTime = CFAbsoluteTimeGetCurrent()
//    }
//
//
//    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//        let elapsed = stopTime - startTime
//
//        if let aTempError = error as NSError?, aTempError.domain != NSURLErrorDomain && aTempError.code != NSURLErrorTimedOut && elapsed == 0  {
//            speedTestCompletionBlock?(nil, error)
//            return
//        }
//
//        let speed = elapsed != 0 ? Double(bytesReceived) / elapsed / 1024.0 / 1024.0 : -1
//        speedTestCompletionBlock?(speed, nil)
//    }
//}
