//
//  ShippingViewController.swift
//  StripeDemoApp
//
//  Created by aidan egan on 14/07/2020.
//  Copyright © 2020 aidan egan. All rights reserved.
//

import UIKit
import Stripe

class ShippingViewController: UIViewController, STPPaymentContextDelegate {
    
    let paymentContext: STPPaymentContext
    let stpShippingAddressViewController = STPShippingAddressViewController()
    
    init() {
        //self.paymentContext = STPPaymentContext(customerContext: customerContext)
        
        super.init(nibName: nil, bundle: nil)
        self.paymentContext.delegate = self
        self.paymentContext.hostViewController = self
        self.paymentContext.paymentAmount = 5000 // This is in cents, i.e. $50 USD
        
    }

   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        <#code#>
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        <#code#>
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        <#code#>
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        <#code#>
    }
}
