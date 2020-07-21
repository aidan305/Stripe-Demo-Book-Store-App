//
//  MyAPIClient.swift
//  StripeDemoApp
//
//  Created by aidan egan on 07/07/2020.
//  Copyright © 2020 aidan egan. All rights reserved.
//

import Foundation
import Stripe
import Alamofire

class MyAPIClient: NSObject, STPCustomerEphemeralKeyProvider {
    
    var customerName = ""
    
    
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        let url = URL(string: backendURL)!.appendingPathComponent("ephemeral_keys")
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [URLQueryItem(name: "api_version", value: apiVersion), URLQueryItem(name: "name", value: customerName), URLQueryItem(name: "email", value: "eganjessie123@hotmail.com")]
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    if let data = data {
                        if let json = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]) as [String : Any]??) {
                            completion(json, nil)
                        }
                    }
                }
            }
            else {
                completion(nil, error)
                return
            }
        })
        task.resume()
    }
    
    
    let backendURL = "https://stripedemobackend.herokuapp.com"
     static let sharedClient = MyAPIClient()
    
   
    
    //MARK: Create payment Intent
    func createPaymentIntent(custId: String, price: Int, completion: @escaping STPJSONResponseCompletionBlock) {
           var url = URL(string: backendURL)!
           url.appendPathComponent("create_payment_intent")
           
           AF.request(url, method: .post, parameters: [ "amount" : "\(price * 100)" , "country" : "it", "description" : "eganjessie@hotmail.com", "customer" : custId])
               .validate(statusCode: 200..<300)
               .responseJSON { (response) in
                   switch (response.result){
                   case .failure(let error):
                       completion(nil, error)
                   case .success(let jsonResponse):
                       completion(jsonResponse as? [String : Any], nil)
                   }
           }
       }
}
    
