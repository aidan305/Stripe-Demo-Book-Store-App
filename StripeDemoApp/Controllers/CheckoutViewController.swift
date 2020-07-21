//
//  CheckoutViewController.swift
//  simpleStripeDemo
//
//  Created by aidan egan on 07/07/2020.
//  Copyright © 2020 aidan egan. All rights reserved.
//

import UIKit
import Stripe


//Create customer
//Create payment intent post to server ruby backend (herouko)
//Confirm payment intent client side
//Create customer context and payment context for shipping address collection. inherit from STPPaymentContextDelegate

class CheckoutViewController: UIViewController, STPAuthenticationContext {
    
    var paymentContext = STPPaymentContext()
    var shippingCosts = 0
    
    func initialSetup() {
        let customerContext = STPCustomerContext(keyProvider: MyAPIClient.sharedClient)
        paymentContext = STPPaymentContext(customerContext: customerContext)
        paymentContext = STPPaymentContext(customerContext: customerContext)
        paymentContext.delegate = self
        paymentContext.hostViewController = self
    }
    
    
    
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
    
    
    

    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    var backendBaseURL: String? = "https://aidanstripe.herokuapp.com"
    var bookPurchase = Book(image: UIImage(), title: "No book selected", price: 0)
    let apiClient = MyAPIClient()
    
   
    
    @IBOutlet weak var productDetailsStack: UIStackView!
    @IBOutlet weak var paymentFieldStack: UIStackView!
    @IBOutlet weak var productImage: UIImageView!
    let stripepaymentCardTextField = STPPaymentCardTextField()
    var productTitle = UILabel()
    var productPrice = UILabel()
    
    var addShippingBtn = UIButton()
    var paymentBtn = UIButton()
    var customerNameTextField = UITextField()
    
   let config = STPPaymentConfiguration.shared()
    
    override func viewDidLoad() {
        
        initialSetup()
        activitySpinner.hidesWhenStopped = true
        super.viewDidLoad()
        setupUI()
        
        //self.config.requiredShippingAddressFields = [.postalAddress, .emailAddress]
        self.config.requiredShippingAddressFields = [.postalAddress, .emailAddress]
        self.paymentContext.pushShippingViewController()
    }
    
    
    
    
    //MARK: 1)Build checkout UI
    
    func setupUI() {
        setUpPayButton()
        setUpShippingButton()
        setUpNameTextField()
        
        productImage.image = bookPurchase.image
        productTitle.text = bookPurchase.title
        productPrice.text = "€\(bookPurchase.price)"
        
        productDetailsStack.addArrangedSubview(productTitle)
        productDetailsStack.addArrangedSubview(productPrice)
        
        paymentFieldStack.addArrangedSubview(addShippingBtn)
        paymentFieldStack.addArrangedSubview(customerNameTextField)
        paymentFieldStack.setCustomSpacing(10, after: customerNameTextField)
        
        //hack to add padding to text field
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 20))
        customerNameTextField.leftView = paddingView
        customerNameTextField.leftViewMode = .always
        
        
        paymentFieldStack.addArrangedSubview(stripepaymentCardTextField)
        paymentFieldStack.setCustomSpacing(50, after: stripepaymentCardTextField)
        paymentFieldStack.addArrangedSubview(paymentBtn)
    }
    
    
    func setUpPayButton(){
        paymentBtn.layer.borderWidth = 4
        paymentBtn.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        paymentBtn.layer.cornerRadius = 10
        paymentBtn.setTitle("Submit payment", for: .normal)
        paymentBtn.backgroundColor = .gray
        paymentBtn.setTitleColor(.white, for: .normal)
        paymentBtn.titleEdgeInsets = UIEdgeInsets(top: 10,left: 50,bottom: 10,right: 50)
        paymentBtn.addTarget(self, action: #selector(pay), for: .touchUpInside)
    }
    
    func setUpShippingButton(){
        addShippingBtn.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        addShippingBtn.setTitle("Add Shipping Address", for: .normal)
        addShippingBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        addShippingBtn.contentHorizontalAlignment = .left
        addShippingBtn.backgroundColor = .white
        addShippingBtn.setTitleColor(.black, for: .normal)
        addShippingBtn.addTarget(self, action: #selector(addShipping), for: .touchUpInside)
    }
    
    
    func setUpNameTextField(){
        customerNameTextField.placeholder = "CardHolder Name"
        customerNameTextField.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        paymentBtn.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        customerNameTextField.layer.borderWidth = 1
        customerNameTextField.height(constant: 45)
    }
    
    @objc func addShipping(){
        self.paymentContext.presentShippingViewController()
        
    }
    
    
    
    //MARK: 2) Payment process
    
    @objc func pay(){
        
        activitySpinner.startAnimating()
        
        if let customerName = customerNameTextField.text {
            
            apiClient.customerName = customerName
            
            apiClient.createCustomerKey(withAPIVersion: "2020-03-02") { (CustomerInfoJson, error)   in
                
                let customerDetails = CustomerInfoJson!["associated_objects"] as! [Any]
                let customerDictionary = customerDetails[0] as! [String: Any]
                let custId = customerDictionary["id"] as! String
                                        
                
                
                self.apiClient.createPaymentIntent(custId: custId, price: self.bookPurchase.price + self.shippingCosts) { (paymentIntentResponseJson, error) in
                    if let error = error {
                        print(error)
                        return
                    } else {
                        guard let responseDictionary = paymentIntentResponseJson as? [String :  Any] else {
                            print("incorrect response")
                            return
                        }
                      
                        
                        let clientSecret = responseDictionary["secret"] as! String
                        let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
                        let paymentMethodParams = STPPaymentMethodParams(card: self.stripepaymentCardTextField.cardParams, billingDetails: nil, metadata: nil)
                        paymentIntentParams.paymentMethodParams = paymentMethodParams
                        
                        
                        STPPaymentHandler.shared().confirmPayment(withParams: paymentIntentParams, authenticationContext: self) { (status, paymentIntent, error) in
                            
                            switch (status) {
                            case .canceled:
                                self.presentPaymentConfirmationAlert(message: "Payment cancelled")
                                
                            case .failed:
                                self.presentPaymentConfirmationAlert(message: "Payment failed")
                            case .succeeded:
                                self.presentPaymentConfirmationAlert(message: "Payment successfull")
                            @unknown default:
                                self.presentPaymentConfirmationAlert(message: "Unknown error")
                            }
                            self.activitySpinner.stopAnimating()
                            self.stripepaymentCardTextField.clear()
                            self.customerNameTextField.text = ""
                        }
                    }
                }
            }
        } else {
            print("no customer name")
        }
    }
    
    
    func presentPaymentConfirmationAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}



//https://medium.com/@alexsergeev_70876/set-width-and-height-constraints-of-arranged-subview-in-uistackview-swift-108490aa5a9d
extension UITextField {
    func height(constant: CGFloat) {
        setConstraint(value: constant, attribute: .height)
    }
    
    private func setConstraint(value: CGFloat, attribute: NSLayoutConstraint.Attribute) {
        let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: value)
        self.addConstraint(constraint)
    }
}

extension CheckoutViewController: STPPaymentContextDelegate {
        
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        print("loading with error")
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
      print("contextDidChange")
        
        if let shippingMethod = paymentContext.selectedShippingMethod {
            shippingCosts = Int(shippingMethod.amount)
        }
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        print("created payment result")
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        print("did finish with")
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didUpdateShippingAddress address: STPAddress, completion: @escaping STPShippingMethodsCompletionBlock) {
        let upsGround = PKShippingMethod()
        upsGround.amount = 0
        upsGround.label = "UPS Ground"
        upsGround.detail = "Arrives in 3-5 days"
        upsGround.identifier = "ups_ground"
        let fedEx = PKShippingMethod()
        fedEx.amount = 5.99
        fedEx.label = "FedEx"
        fedEx.detail = "Arrives tomorrow"
        fedEx.identifier = "fedex"

        if address.country == "US" {
            completion(.valid, nil, [upsGround, fedEx], upsGround)
        }
        else {
            completion(.invalid, nil, nil, nil)
        }
    }
    
    
}



