//
//  RequestOperation.swift
//  Restofire
//
//  Created by Rahul Katariya on 28/01/18.
//  Copyright © 2018 AarKay. All rights reserved.
//

import Foundation

/// An NSOperation that executes the `Requestable` asynchronously
/// or when added to a NSOperationQueue
public class RequestOperation<R: Requestable>: BaseOperation {
    
    let requestable: R
    var retryAttempts = 0
    
    /// The underlying Alamofire.DataRequest.
    public let request: DataRequest
    let completionHandler: ((DataResponse<R.Response>) -> Void)?
    
    #if !os(watchOS)
    lazy var reachability: NetworkReachability = {
        return NetworkReachability(configurable: requestable)
    }()
    #endif
    
    /// A boolean value `true` indicating the operation executes its task asynchronously.
    override public var isAsynchronous: Bool {
        return true
    }
    
    init(requestable: R, request: DataRequest, completionHandler: ((DataResponse<R.Response>) -> Void)?) {
        self.requestable = requestable
        self.retryAttempts = requestable.maxRetryAttempts
        self.request = request
        self.completionHandler = completionHandler
        super.init()
        self.isReady = true
    }
    
    /// Starts the request.
    override public func main() {
        if isCancelled { return }
        executeRequest()
    }
    
    /// Cancels the request.
    override public func cancel() {
        super.cancel()
        request.cancel()
    }
    
    @objc func executeRequest() {
        request.downloadProgress {
            self.requestable.request(self.request, didDownloadProgress: $0)
        }
        request.response(
            queue: requestable.queue,
            responseSerializer: requestable.responseSerializer
        ) { (response: DataResponse<R.Response>) in
            if response.error == nil {
                if let completionHandler = self.completionHandler {
                    completionHandler(response)
                }
                self.requestable.request(self.request, didCompleteWithValue: response.value!)
                self.isFinished = true
            } else {
                self.handleErrorDataResponse(response)
            }
        }
    }
    
    func handleErrorDataResponse(_ response: DataResponse<R.Response>) {
        if let error = response.error as? URLError {
            if requestable.waitsForConnectivity && error.code == .notConnectedToInternet {
                #if !os(watchOS)
                    requestable.eventuallyOperationQueue.isSuspended = true
                    let eventuallyOperation = RequestOperation(
                        requestable: requestable,
                        request: request,
                        completionHandler: completionHandler
                    )
                    reachability.addOperation(operation: eventuallyOperation)
                    isFinished = true
                #else
                    requestable.request(request, didFailWithError: response.error!)
                    completionHandler?(response)
                    isFinished = true
                #endif
            } else if retryAttempts > 0 && requestable.retryErrorCodes.contains(error.code) {
                retryAttempts -= 1
                perform(
                    #selector(RequestOperation<R>.executeRequest),
                    with: nil,
                    afterDelay: requestable.retryInterval
                )
            } else {
                requestable.request(request, didFailWithError: response.error!)
                completionHandler?(response)
                isFinished = true
            }
        } else {
            requestable.request(request, didFailWithError: response.error!)
            completionHandler?(response)
            isFinished = true
        }
    }
    
}
