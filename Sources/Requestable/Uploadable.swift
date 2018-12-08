//
//  Uploadable.swift
//  Restofire
//
//  Created by Rahul Katariya on 30/01/18.
//  Copyright © 2018 AarKay. All rights reserved.
//

import Foundation
import Alamofire

/// Represents an abstract `Uploadable` for Restofire.
///
/// Instead implement FileUploadable, DataUploadable, StreamUploadable,
/// MultipartUplodable protocols.
public protocol Uploadable: _AUploadable, Configurable, ResponseSerializable {

    /// Called when the Request succeeds.
    ///
    /// - parameter request: The Alamofire.UploadRequest
    /// - parameter value: The Response
    func request(_ request: UploadOperation<Self>, didCompleteWithValue value: Response)
    
    /// Called when the Request fails
    ///
    /// - parameter request: The Alamofire.UploadRequest
    /// - parameter error: The Error
    func request(_ request: UploadOperation<Self>, didFailWithError error: Error)
    
}

public extension Uploadable {

    /// `Does Nothing`
    func request(_ request: UploadOperation<Self>, didCompleteWithValue value: Response) {}
    
    /// `Does Nothing`
    func request(_ request: UploadOperation<Self>, didFailWithError error: Error) {}
    
    /// Creates a `RequestOperation` for the specified `Requestable` object.
    ///
    /// - parameter completionHandler: A closure to be executed once the request
    ///                                has finished. `nil` by default.
    ///
    /// - returns: The created `RequestOperation`.
    @discardableResult
    public func operation(completionHandler: ((DataResponse<Response>) -> Void)? = nil) throws -> UploadOperation<Self> {
        let request = try self.request()
        return operation(request: request, completionHandler: completionHandler)
    }
    
    /// Creates a `RequestOperation` for the specified `Requestable` object.
    ///
    /// - parameter request: A data request instance
    /// - parameter completionHandler: A closure to be executed once the request
    ///                                has finished. `nil` by default.
    ///
    /// - returns: The created `RequestOperation`.
    public func operation(request: @autoclosure @escaping () -> UploadRequest, completionHandler: ((DataResponse<Response>) -> Void)? = nil) -> UploadOperation<Self> {
        let uploadOperation = UploadOperation(uploadable: self, request: request, completionHandler: completionHandler)
        uploadOperation.queuePriority = priority
        return uploadOperation
    }
    
    /// Creates a `UploadOperation` for the specified `Uploadable` object and
    /// asynchronously executes it.
    ///
    /// - parameter completionHandler: A closure to be executed once the download
    ///                                has finished. `nil` by default.
    ///
    /// - returns: The created `UploadOperation`.
    @discardableResult
    public func execute(completionHandler: ((DataResponse<Response>) -> Void)? = nil) throws -> UploadOperation<Self> {
        let request = try self.request()
        return execute(request: request, completionHandler: completionHandler)
    }
    
    /// Creates a `UploadOperation` for the specified `Uploadable` object and
    /// asynchronously executes it.
    ///
    /// - parameter request: An upload request instance
    /// - parameter completionHandler: A closure to be executed once the download
    ///                                has finished. `nil` by default.
    ///
    /// - returns: The created `UploadOperation`.
    @discardableResult
    public func execute(request: @autoclosure @escaping () -> UploadRequest, completionHandler: ((DataResponse<Response>) -> Void)? = nil) -> UploadOperation<Self> {
        let uploadOperation = operation(request: request, completionHandler: completionHandler)
        uploadQueue.addOperation(uploadOperation)
        return uploadOperation
    }
    
}
