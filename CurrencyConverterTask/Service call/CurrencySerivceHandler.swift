//
//  CurrencySerivceHandler.swift
//  CurrencyConverterTask
//
//  Created by macbook on 31/10/17.
//  Copyright © 2017 Falconnect Technologies Private Limited Falconnect Technologies Private Limited Falconnect Technologies Private Limited. All rights reserved.
//

import Foundation
import UIKit

typealias mappedCurrencyBlock    = (_ error: String?, _ response: CurrencyDetailValue?) -> Void
typealias convertedCurrencyBlock = (_ response: CurrencyDetailValue?) -> Void

let AmountKey   = "amount"
let CurrencyKey = "currency"
let CommissonFee             = 0.7
let CommissonFeeText            = "Commission Fee"
let CurrencyArrayList     = ["EUR", "USD", "JPY"]



class CurrencySerivceHandler: NSObject {
    
    //Service call
    public class func makeServiceCall(requestUrl:String, completionHandler:@escaping mappedCurrencyBlock) {
        
        // requesturl - API URL
        CurrencyManager.makeServiceCall(requestUrl: requestUrl, requestParams: nil) { (error, response) in
            
            let mappedResponse = convertFCCurrencyDetailFrom(response: response)
            completionHandler(mappedResponse.errorMessage, mappedResponse.currencyDetail)
        }
    }
    
    // Convert json repsone from Dict to Model
    
    public class func convertFCCurrencyDetailFrom(response:Any?) -> (currencyDetail:CurrencyDetailValue?, errorMessage: String?) {
        
        if let wrappedResponse = response as? [String:Any] {
            
            let currencyDetail = CurrencyDetailValue()
            
            if let currencyValue = wrappedResponse[AmountKey] as? String,
                let converteDouble = Double(currencyValue) {
                
                currencyDetail.currencyBalance = converteDouble
            }
            
            if let currencyType = wrappedResponse[CurrencyKey] as? String {
                
                currencyDetail.currencyName = currencyType
            }
            return (currencyDetail, nil)
        }
        
        return (nil, "Server is Down.Please try after some time")
        
    }
    
    // Get the combined url
    public class func fetchCombinedURL(fromCurrencyInfo:CurrencyDetailValue, convertedCurrencyType:String?) -> String {
        
        var combinedURL = CurrencyConstant.APIURL
        
        if let selectCurrencyType = fromCurrencyInfo.currencyName, let selectCurrencyAmount = fromCurrencyInfo.currencyBalance {
            
            combinedURL = combinedURL + String(selectCurrencyAmount) + "-" + selectCurrencyType
        }
        
        if let convertCurrencyType = convertedCurrencyType {
            
            combinedURL = combinedURL + "/" + convertCurrencyType + CurrencyConstant.URLKey
        }
        
        return combinedURL
        
    }
}
extension CurrencySerivceHandler {
    
    // Update the user amount based on service response
   
    public class func updateUserAmount(userCurrencyInfo:inout [CurrencyDetailValue]?, fromCurrencyInfo:CurrencyDetailValue, convertedCurrencyInfo:CurrencyDetailValue) -> String {
        
        var message = "Server is Down.Please try after some time"
        
        if let wrappedCurrencyInfo = userCurrencyInfo,
            let convertAmount = fromCurrencyInfo.currencyBalance,
            let serviceConvertAmount = convertedCurrencyInfo.currencyBalance {
            
            message = "Converted Amount is \(convertAmount) \(fromCurrencyInfo.currencyName!) to \(serviceConvertAmount) \(convertedCurrencyInfo.currencyName!).\n \(CommissonFeeText) - \(fetchCommissionAmount(convertAmount: convertAmount)) \(fromCurrencyInfo.currencyName!)"
            
            for userCurrencyInfoDetail in wrappedCurrencyInfo {
                
                if userCurrencyInfoDetail.currencyName == fromCurrencyInfo.currencyName,
                    let userSelectedCurrencyValue = userCurrencyInfoDetail.currencyBalance {
                    
                    userCurrencyInfoDetail.currencyBalance = userSelectedCurrencyValue - convertAmount
                }
                
                if userCurrencyInfoDetail.currencyName == convertedCurrencyInfo.currencyName,
                    let userSelectedCurrencyValue = userCurrencyInfoDetail.currencyBalance {
                    
                    userCurrencyInfoDetail.currencyBalance = userSelectedCurrencyValue + serviceConvertAmount
                }
            }
        }
        
        return message
    }
    
    // Fetch the currency message
  
    public class func fetchCurrencyMsg(selectedCurrencyInfo:CurrencyDetailValue, convertedCurrencyInfo:CurrencyDetailValue) -> String {
        
        var currencyMessage  = "Server is Down.Please try after some time"
        if let convertAmount = selectedCurrencyInfo.currencyBalance,
            let serviceConvertAmount = convertedCurrencyInfo.currencyBalance {
            
            currencyMessage = "If you convert \(convertAmount) \(selectedCurrencyInfo.currencyName!)  you will get  \(serviceConvertAmount) \(convertedCurrencyInfo.currencyName!)"
        }
        
        return currencyMessage
    }
    
    //Select the currency detail based on index
    
    public class func fetchCurrencyDetailInfo(selectedIndex: Int, userCurrencyInfo:[CurrencyDetailValue]?) -> (currencyName:String, currencyValue:String){
        
        if let CurrencyDetailValue = userCurrencyInfo?[selectedIndex],
            let currencyType = CurrencyDetailValue.currencyName,
            let currencyVal = CurrencyDetailValue.currencyBalance {
            
            return (currencyType, String(currencyVal) + " " + currencyType)
        }
        
        return ("", "")
    }
    
    //Used to validate the selected amount

    public class func isValidAmount(selectedCurrencyInfo:CurrencyDetailValue,userCurrencyInfo:inout [CurrencyDetailValue]?) -> Bool {
        
        
        if let wrappedCurrencyInfo = userCurrencyInfo,
            let convertAmount = selectedCurrencyInfo.currencyBalance,
            convertAmount > 0 {
            
            for userCurrencyInfoDetail in wrappedCurrencyInfo {
                
                if userCurrencyInfoDetail.currencyName == selectedCurrencyInfo.currencyName,
                    let availableAmount = userCurrencyInfoDetail.currencyBalance,
                    availableAmount >= (convertAmount + fetchCommissionAmount(convertAmount:availableAmount)) {
                    
                    return true
                }
                
            }
        }
        
        return false
    }
}

//Comission Fee calulation
extension CurrencySerivceHandler {
    
    // Fetch the commisson amount
    public class func fetchCommissionAmount (convertAmount : Double) -> Double{
        
        if isCommissionFeeAvailable() {
            
            return (convertAmount * CommissonFee) / 100
        }
        
        return 0.0
    }
    
    // Check commison fee is appicable or not
    public class func isCommissionFeeAvailable() -> Bool {
        
        if let totalCount = fetchTotalConvertionCount(), totalCount > 5 {
            
            return true
        }
        
        return false
    }
}

//Total convertion Count Methods for comission calculation
extension CurrencySerivceHandler {
    
    //Fetch the total count till convert for comission calculation
    public class func fetchTotalConvertionCount() -> Int? {
        
        return UserDefaults.standard.integer(forKey: "CONVERTEDAMOUNT")
    }
    
    //Update the convert count
    public class func saveConvertionCount() {
        
        guard let totalCount = fetchTotalConvertionCount() else {
            
            UserDefaults.standard.set(1, forKey: "CONVERTEDAMOUNT")
            return
        }
        
        UserDefaults.standard.set(totalCount + 1, forKey: "CONVERTEDAMOUNT")
    }
}

//Plist
extension CurrencySerivceHandler {
    
    // Get the currency array from plist
    public class func fetchCurrencyArray() -> [String] {
        
        if let languageFileUrl = Bundle.main.url(forResource: CurrencyConstant.currencyPlistFile, withExtension: CurrencyConstant.plistKey),
            let languageData = try? Data(contentsOf: languageFileUrl)
            
        {
            if let resultArray = try? PropertyListSerialization.propertyList(from: languageData, options: [], format: nil) as? [String],
                let currencyArrayList = resultArray {
                
                return currencyArrayList
            }
        }
        
        return CurrencyArrayList
    }
    
}


