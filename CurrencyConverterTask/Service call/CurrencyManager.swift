//
//  CurrencyManager.swift
//  CurrencyConverterTask
//
//  Created by macbook on 31/10/17.
//  Copyright © 2017 Falconnect Technologies Private Limited Falconnect Technologies Private Limited Falconnect Technologies Private Limited. All rights reserved.
//

import UIKit

typealias serviceCallBlock = (_ error: Error?, _ response: Any?) -> Void


class CurrencyManager: NSObject {
    
    // Make API call
   
    public class func makeServiceCall(requestUrl: String, requestType: String = "GET", requestParams:[String:Any]?, completionHandler:@escaping serviceCallBlock) {
        
        var urlRequest = URLRequest(url: URL(string:requestUrl)!)
        urlRequest.httpMethod = requestType
        updataDataFor(request: &urlRequest, requestParams: requestParams)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            if let httpStatus = response as? HTTPURLResponse,
                httpStatus.statusCode == 200 {
                
                do {
                    
                    let parsedJson = try JSONSerialization.jsonObject(with: data! as Data, options: []) as! [String:Any]
                    completionHandler(nil, parsedJson)
                }
                    
                catch let error as NSError {
                    print(error)
                }
                
                completionHandler(error,nil)
                
            }else {
                
                completionHandler(error,nil)
            }
            
        }
        
        task.resume()
    }
    
    //Convert data params from Dict to data
  
    public class func updataDataFor(request: inout URLRequest, requestParams : [String: Any]?) {
        
        if let wrappedRequestParams = requestParams {
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: wrappedRequestParams, options: .prettyPrinted)
                
            } catch let error {
                
                print(error.localizedDescription)
                
            }
        }
    }
    
}
    

