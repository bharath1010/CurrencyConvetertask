//
//  ViewController.swift
//  CurrencyConverterTask
//
//  Created by macbook on 30/10/17.
//  Copyright © 2017 Falconnect Technologies Private Limited. All rights reserved.
//

import UIKit

enum buttonClicked {

case convert
case Evaulate
}


class ViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate  {

    
    static let CellIdentifier   = "TableViewCell"
    let DefaultAmount = 1000.0
    static let DefaultCurrency     = "EUR"

    
    var userCurrencyInfo    : [CurrencyDetailValue]?
    var convertCurrencyType : String?
    var selectedTextField   : UITextField?
    
    var selectedCurrencyInfo:CurrencyDetailValue  = CurrencyDetailValue()
    var actionType: buttonClicked         = buttonClicked.convert
    var currencyList                           = [String]()
    var pickerView                             = UIPickerView()
    
    @IBOutlet weak var amountText   : UITextField!
    @IBOutlet weak var fromCurrencyText    : UITextField!
    @IBOutlet weak var toCurrencyText       : UITextField!
    @IBOutlet weak var updateLabel   : UILabel!
    @IBOutlet weak var balanceTableView   : UITableView!
    @IBOutlet weak var activityIndicator : UIActivityIndicatorView!
    @IBOutlet weak var activityView       : UIView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //Intitalize the setup
        initalSetup()
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Setup Inital UI
    func initalSetup() {
        
        currencyList = CurrencySerivceHandler.fetchCurrencyArray()
        
        //Setting up the textField,picker and ActivityIndicator
        
        

        fromCurrencyText.inputView  = pickerView
        toCurrencyText.inputView    = pickerView
        
        fromCurrencyText.tintColor = UIColor.clear
        toCurrencyText.tintColor   = UIColor.clear
        
        pickerView.delegate      = self
        balanceTableView.tableFooterView = UIView()
        
        setUpToolBar()
        stopActivityIndicator()
        
        InitialAmount()
    }
    
    // Start the activity Indicator
    func startActivityIndicator() {
        
        activityView.isHidden = false
        activityIndicator.isHidden = false
        self.view.bringSubview(toFront: activityView)
        activityIndicator.startAnimating()
        
    }
    
    // Stop the activity Indicator
    func stopActivityIndicator() {
        
        activityView.isHidden = true
        activityIndicator.isHidden = true
        self.view.sendSubview(toBack: activityView)
        activityIndicator.stopAnimating()
        
    }
    
    //Setup the Initial amount and default value
    func InitialAmount() {
        
        userCurrencyInfo = [CurrencyDetailValue]()
        
        for currencyVal in currencyList {
            
            let currencyDetailInfo = CurrencyDetailValue()
            currencyDetailInfo.currencyName = currencyVal
            currencyDetailInfo.currencyBalance = 0.0
            
            if currencyVal == ViewController.DefaultCurrency {
                currencyDetailInfo.currencyBalance = DefaultAmount
            }
            userCurrencyInfo?.append(currencyDetailInfo)
        }
        
        selectedCurrencyInfo.currencyName = ViewController.DefaultCurrency
        convertCurrencyType = ViewController.DefaultCurrency
        
        fromCurrencyText.text = selectedCurrencyInfo.currencyName
        toCurrencyText.text   = convertCurrencyType
    }
    
    //Alert Methods
    func showErrorMessage(eTitle:String, eDescription:String) {
        
        let alert = UIAlertController(title: eTitle, message: eDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //TableView Delegates

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let currencyCount = userCurrencyInfo?.count {
            return currencyCount
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let TableViewCell = tableView.dequeueReusableCell(withIdentifier: ViewController.CellIdentifier, for: indexPath) as? TableViewCell
        
        let TableViewCellInfo = CurrencySerivceHandler.fetchCurrencyDetailInfo(selectedIndex: indexPath.row, userCurrencyInfo: self.userCurrencyInfo)
        TableViewCell?.currencyNameLabel.text  = TableViewCellInfo.currencyName
        TableViewCell?.AmountLabel.text = TableViewCellInfo.currencyValue
        
        return TableViewCell!
    }
    
    //PickerView Delegates

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return currencyList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return currencyList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        updateText(textToUpdate: currencyList[row])
    }
    
    //ToolBar For TextField

    func setUpToolBar() {
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        
        toolBar.tintColor = UIColor.black
        
        toolBar.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        

        /*
        let previousButton = UIBarButtonItem(title: "Previous", style: UIBarButtonItemStyle.plain, target: self, action: #selector(previousButotnPressed))

        let nextButton = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.plain, target: self, action: #selector(nextButotnPressed))
        
        let fixedSpaceButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
         */

        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(donePressed))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        toolBar.setItems([flexSpace,doneButton], animated: true)
        
        fromCurrencyText.inputAccessoryView = toolBar
        toCurrencyText.inputAccessoryView   = toolBar
        amountText.inputAccessoryView = toolBar
        
    }
    
    // Done button action
    @objc func donePressed(_ sender: UIBarButtonItem) {
        
        selectedTextField?.resignFirstResponder()
        
    }
    /*
    // Previous button action

    @objc func previousButotnPressed(_ sender: UIBarButtonItem) {
        selectedTextField?.becomeFirstResponder()
//        selectedTextField?.resignFirstResponder()
    }
    
//     Next button action

    @objc func nextButotnPressed(_ sender: UIBarButtonItem) {

        selectedTextField?.next?.becomeFirstResponder()
//        selectedTextField?.resignFirstResponder()
    }
    */
    
    
    //Custom IBAction Methods
    @IBAction func convertPressed(_ sender: Any) {
        
        actionType = .convert
        makeConvertionCall()
    }
    
    @IBAction func evaulatePressed(_ sender: Any) {
        
        actionType = .Evaulate
        makeConvertionCall()
    }



    //Validation Methods
    
    func isValidInformation() -> Bool {
        
        guard let amountToConvert = selectedCurrencyInfo.currencyBalance, amountToConvert > 0 else {
            showErrorMessage(eTitle: "Invaild Amount", eDescription: "Please enter valid amount.")
            return false
        }
        
        guard let selectedCurrencyType = selectedCurrencyInfo.currencyName, selectedCurrencyType != "" else {
            showErrorMessage(eTitle: "Invaild Currency", eDescription: "Please select valid currency type.")
            return false
        }
        
        guard let convertedCurrencyType = convertCurrencyType, convertedCurrencyType != "" else {
            showErrorMessage(eTitle: "Invaild Currency", eDescription: "Please select valid currency type.")
            return false
        }
        
        if selectedCurrencyType == convertedCurrencyType {
            
            showErrorMessage(eTitle: "Invaild Currencies", eDescription: "Please select different type to convert")
            return false
        }
        
        return true
    }
    
    //API Call Methods
    
    // Service call
    func makeConvertionServiceCall(completionBlock:@escaping convertedCurrencyBlock) {
        
        if CurrencySerivceHandler.isValidAmount(selectedCurrencyInfo: selectedCurrencyInfo, userCurrencyInfo: &userCurrencyInfo) || actionType == .Evaulate {
            
            self.startActivityIndicator()
            CurrencySerivceHandler.makeServiceCall(requestUrl: CurrencySerivceHandler.fetchCombinedURL(fromCurrencyInfo: selectedCurrencyInfo, convertedCurrencyType: convertCurrencyType)) { (errorMessage, currencyInfo) in
                
                DispatchQueue.main.sync {
                    
                    self.stopActivityIndicator()
                }
                
                if let wrappedCurrencyInfo = currencyInfo
                {
                    completionBlock(wrappedCurrencyInfo)
                    
                } else if let wrappedErrorMessage = errorMessage {
                    
                    completionBlock(nil)
                    self.showErrorMessage(eTitle:"Error", eDescription:wrappedErrorMessage)
                    
                } else {
                    
                    completionBlock(nil)
                    self.showErrorMessage(eTitle:"Error", eDescription:"Server is Down.Please try after some time")
                }
            }
            
        } else {
            
            showErrorMessage(eTitle:"Insufficent Fund", eDescription:"Insufficent Fund.Please check your amount and Try again.")
        }
    }


    
    //Service call with validation
    func makeConvertionCall() {
        
        guard isValidInformation() else {
            
            return
        }
        
        makeConvertionServiceCall { (convertedCurrencyDetail) in
            
            if let wrappedCurrencyInfo = convertedCurrencyDetail {
                
                if self.actionType == .convert {
                    
                    CurrencySerivceHandler.saveConvertionCount()
                    self.updateAmount(convertedCurrencyInfo: wrappedCurrencyInfo)
                    
                } else {
                    
                    let currencyMsg = CurrencySerivceHandler.fetchCurrencyMsg(selectedCurrencyInfo: self.selectedCurrencyInfo, convertedCurrencyInfo: wrappedCurrencyInfo)
                    self.showErrorMessage(eTitle: "Evaulate", eDescription: currencyMsg)
                    DispatchQueue.main.async {
                        self.updateLabel.text = currencyMsg
                        self.amountText.text = ""
                        Timer.scheduledTimer(timeInterval: 10,
                                             target: self,
                                             selector: #selector(self.updateTime),
                                             userInfo: nil,
                                             repeats: true)
                    }
                }
                
            }
            
        }
    }
    
    //Update available amount and message
    
    func updateAmount(convertedCurrencyInfo:CurrencyDetailValue) {
        
        let message = CurrencySerivceHandler.updateUserAmount(userCurrencyInfo: &userCurrencyInfo, fromCurrencyInfo: selectedCurrencyInfo, convertedCurrencyInfo: convertedCurrencyInfo)
        

        showErrorMessage(eTitle: "Transcaton Success", eDescription: message)
        
        
        
        DispatchQueue.main.async {
            self.updateLabel.text = message
            self.amountText.text = ""
            Timer.scheduledTimer(timeInterval: 10,
                                 target: self,
                                 selector: #selector(self.updateTime),
                                 userInfo: nil,
                                 repeats: true)
            
            self.balanceTableView.reloadData()
        }
    }
    
    @objc func updateTime()
    {
        DispatchQueue.main.async {
            
            self.updateLabel.text = ""
        }
    }
    
    //TextField Delegate Methods

    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        selectedTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == amountText  {
            
            updateText(textToUpdate: textField.text)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        return false
    }
    
    // Update the text for selected text field
  
    func updateText(textToUpdate : String?) {
        
        guard let textUpdate = textToUpdate, let selectTextField = selectedTextField else {
            
            return
        }
        
        selectTextField.text = textToUpdate
        if selectTextField == fromCurrencyText {
            
            selectedCurrencyInfo.currencyName = textUpdate
            
        } else if selectTextField == toCurrencyText {
            
            convertCurrencyType = textUpdate
            
        } else if let currencyDoublValue = Double(textUpdate)  {
            
            selectedCurrencyInfo.currencyBalance = currencyDoublValue
        }
    }

}






