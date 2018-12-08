//
//  AUploadable.swift
//  Restofire
//
//  Created by Rahul Katariya on 28/01/18.
//  Copyright © 2018 AarKay. All rights reserved.
//

import Foundation
import Alamofire

/// Represents an abstract `Uploadable` for Alamofire.
///
/// Instead implement AFileUploadable, ADataUploadable, AStreamUploadable,
/// AMultipartUplodable protocols.
public protocol _AUploadable: ARequestable {
    
    /// The uplaod request for subclasses to provide the implementation.
    func asRequest() throws -> UploadRequest
    
}

public extension _AUploadable {
    
    /// `.post`
    public var method: HTTPMethod {
        return .post
    }
    
}

