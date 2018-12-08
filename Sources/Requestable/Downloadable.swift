//
//  Downloadable.swift
//  Restofire
//
//  Created by Rahul Katariya on 30/01/18.
//  Copyright © 2018 AarKay. All rights reserved.
//

import Foundation
import Alamofire

/// Represents a `Downloadable` for Restofire.
///
/// ```swift
/// protocol HTTPBinDownloadService: Downloadable {
///
///     var path: String? = "bytes/\(4 * 1024 * 1024)"
///     var destination: DownloadFileDestination?
///
///     init(destination: @escaping DownloadFileDestination) {
///         self.destination = destination
///     }
///
/// }
/// ```
public protocol Downloadable: ADownloadable, Configurable, ResponseSerializable {

    /// Called when the Request succeeds.
    ///
    /// - parameter request: The Alamofire.DownloadRequest
    /// - parameter value: The Response
    func request(_ request: DownloadOperation<Self>, didCompleteWithValue value: Response)
    
    /// Called when the Request fails
    ///
    /// - parameter request: The Alamofire.DownloadRequest
    /// - parameter error: The Error
    func request(_ request: DownloadOperation<Self>, didFailWithError error: Error)
    
}

public extension Downloadable {
    
    /// `Does Nothing`
    func request(_ request: DownloadOperation<Self>, didCompleteWithValue value: Response) {}
    
    /// `Does Nothing`
    func request(_ request: DownloadOperation<Self>, didFailWithError error: Error) {}
    
    /// Creates a `DownloadOperation` for the specified `Requestable` object.
    ///
    /// - parameter completionHandler: A closure to be executed once the request
    ///                                has finished. `nil` by default.
    ///
    /// - returns: The created `RequestOperation`.
    @discardableResult
    public func operation(completionHandler: ((DownloadResponse<Response>) -> Void)? = nil) throws -> DownloadOperation<Self> {
        let request = try self.request()
        return operation(request: request, completionHandler: completionHandler)
    }
    
    /// Creates a `DownloadOperation` for the specified `Requestable` object.
    ///
    /// - parameter request: A data request instance
    /// - parameter completionHandler: A closure to be executed once the request
    ///                                has finished. `nil` by default.
    ///
    /// - returns: The created `RequestOperation`.
    public func operation(request: @autoclosure @escaping () -> DownloadRequest, completionHandler: ((DownloadResponse<Response>) -> Void)? = nil) -> DownloadOperation<Self> {
        let downloadOperation = DownloadOperation(downloadable: self, request: request, completionHandler: completionHandler)
        downloadOperation.queuePriority = priority
        return downloadOperation
    }
    
    /// Creates a `DownloadOperation` for the specified `Requestable` object and
    /// asynchronously executes it.
    ///
    /// - parameter completionHandler: A closure to be executed once the download
    ///                                has finished. `nil` by default.
    ///
    /// - returns: The created `DownloadOperation`.
    @discardableResult
    public func execute(completionHandler: ((DownloadResponse<Response>) -> Void)? = nil) throws -> DownloadOperation<Self> {
        let request = try self.request()
        return execute(request: request, completionHandler: completionHandler)
    }
    
    /// Creates a `DownloadOperation` for the specified `Requestable` object and
    /// asynchronously executes it.
    ///
    /// - parameter request: A download request instance
    /// - parameter completionHandler: A closure to be executed once the download
    ///                                has finished. `nil` by default.
    ///
    /// - returns: The created `DownloadOperation`.
    @discardableResult
    public func execute(request: @autoclosure @escaping () -> DownloadRequest, completionHandler: ((DownloadResponse<Response>) -> Void)? = nil) -> DownloadOperation<Self> {
        let downloadOperation = operation(request: request, completionHandler: completionHandler)
        downloadQueue.addOperation(downloadOperation)
        return downloadOperation
    }
    
}
