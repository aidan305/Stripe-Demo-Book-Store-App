//
//  Book.swift
//  simpleStripeDemo
//
//  Created by aidan egan on 07/07/2020.
//  Copyright © 2020 aidan egan. All rights reserved.
//

import Foundation
import UIKit

class Book {
    var image: UIImage
    var title: String
    var price: Int
    
    init(image: UIImage, title: String, price: Int) {
        self.image = image
        self.title = title
        self.price = price
    }
}

extension Book {
    static let demoBooks = [Book(image: UIImage(named: "Harry_Potter")!, title: "Harry Potter", price: 10), Book(image: UIImage(named: "Lord_of_the_rings")!
        , title: "Lord of the Rings", price: 20), Book(image: UIImage(named: "Da_vinci_code")!, title: "Da Vinci Code", price: 30)]
}
