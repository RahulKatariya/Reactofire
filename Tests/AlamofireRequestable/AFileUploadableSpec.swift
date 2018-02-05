//
//  AFileUploadableSpec.swift
//  Restofire
//
//  Created by Rahul Katariya on 27/01/18.
//  Copyright © 2018 AarKay. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Alamofire
@testable import Restofire

class AFileUploadableSpec: BaseSpec {
    
    static var startDelegateCalled = false
    static var completeDelegateCalled = false
    
    override func spec() {
        describe("AFileUpload") {
            
            it("request should succeed") {
                // Given
                struct Upload: AFileUploadable {
                    var path: String? = "post"
                    let url: URL = BaseSpec.url(forResource: "rainbow", withExtension: "jpg")
                    
                    func prepare(_ request: URLRequest, requestable: AConfigurable) -> URLRequest {
                        var request = request
                        let header = Request.authorizationHeader(user: "user", password: "password")!
                        request.setValue(header.value, forHTTPHeaderField: header.key)
                        return request
                    }
                    
                    func didSend(_ request: Request, requestable: AConfigurable) {
                        expect(request.request?.value(forHTTPHeaderField: "Authorization"))
                            .to(equal("Basic dXNlcjpwYXNzd29yZA=="))
                        AFileUploadableSpec.startDelegateCalled = true
                    }
                    
                    func didComplete(_ request: Request, requestable: AConfigurable) {
                        AFileUploadableSpec.completeDelegateCalled = true
                    }
                    
                }
                
                let request = Upload().request
                print(request.debugDescription)
                
                expect(AFileUploadableSpec.startDelegateCalled).to(beTrue())
                
                var uploadProgressValues: [Double] = []
                var downloadProgressValues: [Double] = []
                
                // When
                waitUntil(timeout: self.timeout) { done in
                    request
                        .uploadProgress { progress in
                            uploadProgressValues.append(progress.fractionCompleted)
                        }
                        .downloadProgress { progress in
                            downloadProgressValues.append(progress.fractionCompleted)
                        }
                        .responseJSON { response in
                            defer { done() }
                            
                            // Then
                            expect(AFileUploadableSpec.completeDelegateCalled).to(beTrue())
                            
                            if let statusCode = response.response?.statusCode,
                                statusCode != 200 {
                                fail("Response status code should be 200")
                            }
                            
                            expect(response.request).toNot(beNil())
                            expect(response.response).toNot(beNil())
                            expect(response.data).toNot(beNil())
                            expect(response.error).to(beNil())
                            
                            if let value = response.value as? [String: Any],
                                let data = value["data"] as? String {
                                expect(data).toNot(beEmpty())
                            } else {
                                fail("response value should not be nil")
                            }
                            
                            var previousUploadProgress: Double = uploadProgressValues.first ?? 0.0
                            
                            for uploadProgress in uploadProgressValues {
                                expect(uploadProgress).to(beGreaterThanOrEqualTo(previousUploadProgress))
                                previousUploadProgress = uploadProgress
                            }
                            
                            if let lastUploadProgressValue = uploadProgressValues.last {
                                expect(lastUploadProgressValue).to(equal(1.0))
                            } else {
                                fail("last item in uploadProgressValues should not be nil")
                            }
                            
                            var previousDownloadProgress: Double = downloadProgressValues.first ?? 0.0
                            
                            for downloadProgress in downloadProgressValues {
                                expect(downloadProgress).to(beGreaterThanOrEqualTo(previousDownloadProgress))
                                previousDownloadProgress = downloadProgress
                            }
                            
                            if let lastDownloadProgressValue = downloadProgressValues.last {
                                expect(lastDownloadProgressValue).to(equal(1.0))
                            } else {
                                fail("last item in downloadProgressValues should not be nil")
                            }
                    }
                }
            }
            
        }
    }
    
}

