//
//  Restofire.swift
//  Restofire
//
//  Created by Rahul Katariya on 19/04/16.
//  Copyright © 2016 AarKay. All rights reserved.
//

import Alamofire

class RestofireRequest {
    
    static func dataRequest<R: ARequestable>(fromRequestable requestable: R, withUrlRequest urlRequest: URLRequest) -> Alamofire.DataRequest {
        let request = requestable.sessionManager.request(urlRequest)
        authenticateRequest(request, usingCredential: requestable.credential)
        RestofireRequestValidation.validateDataRequest(request: request, requestable: requestable)
        return request
    }
    
    static func downloadRequest<R: ADownloadable>(fromRequestable requestable: R, withUrlRequest urlRequest: URLRequest) -> Alamofire.DownloadRequest {
        let request = requestable.sessionManager.download(urlRequest, to: requestable.destination)
        authenticateRequest(request, usingCredential: requestable.credential)
        RestofireDownloadValidation.validateDownloadRequest(request: request, requestable: requestable)
        return request
    }
    
    static func fileUploadRequest<R: AFileUploadable>(fromRequestable requestable: R, withUrlRequest urlRequest: URLRequest) -> Alamofire.UploadRequest {
        let request = requestable.sessionManager.upload(requestable.url, with: urlRequest)
        authenticateRequest(request, usingCredential: requestable.credential)
        RestofireRequestValidation.validateDataRequest(request: request, requestable: requestable)
        return request
    }
    
    static func dataUploadRequest<R: ADataUploadable>(fromRequestable requestable: R, withUrlRequest urlRequest: URLRequest) -> Alamofire.UploadRequest {
        let request = requestable.sessionManager.upload(requestable.data, with: urlRequest)
        authenticateRequest(request, usingCredential: requestable.credential)
        RestofireRequestValidation.validateDataRequest(request: request, requestable: requestable)
        return request
    }
    
    static func streamUploadRequest<R: AStreamUploadable>(fromRequestable requestable: R, withUrlRequest urlRequest: URLRequest) -> Alamofire.UploadRequest {
        let request = requestable.sessionManager.upload(requestable.stream, with: urlRequest)
        authenticateRequest(request, usingCredential: requestable.credential)
        RestofireRequestValidation.validateDataRequest(request: request, requestable: requestable)
        return request
    }
    
    static func multipartUploadRequest<R: AMultipartUploadable>(fromRequestable requestable: R, withUrlRequest urlRequest: URLRequest, encodingCompletion: ((MultipartFormDataEncodingResult) -> Void)? = nil) {
        let localEncodingCompletion = encodingCompletion
        requestable.sessionManager.upload(
            multipartFormData: requestable.multipartFormData,
            usingThreshold: requestable.threshold,
            with: urlRequest) { encodingCompletion in
                switch encodingCompletion {
                case .success(let request, let streamingFromDisk, let streamFileURL):
                    authenticateRequest(request, usingCredential: requestable.credential)
                    RestofireRequestValidation.validateDataRequest(request: request, requestable: requestable)
                    let result = MultipartFormDataEncodingResult.success(request: request, streamingFromDisk: streamingFromDisk, streamFileURL: streamFileURL)
                    localEncodingCompletion?(result)
                case .failure(_):
                    localEncodingCompletion?(encodingCompletion)
                }
        }
    }

    fileprivate static func authenticateRequest(_ request: Request, usingCredential credential: URLCredential?) {
        guard let credential = credential else { return }
        request.authenticate(usingCredential: credential)
    }

}
