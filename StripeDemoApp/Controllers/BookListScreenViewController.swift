//
//  BookListScreenViewController.swift
//  simpleStripeDemo
//
//  Created by aidan egan on 07/07/2020.
//  Copyright © 2020 aidan egan. All rights reserved.
//

import UIKit

class BookListScreenViewController: UIViewController {
    
    var books : [Book] = []
    

    @IBOutlet weak var bookTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        books = Book.demoBooks
        bookTableView.delegate = self
        bookTableView.dataSource = self
    }
}

extension BookListScreenViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let book = books[indexPath.row]
        var cellToReturn = BookCell()
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell") as? BookCell {
            
            
            cell.bookImage.image = book.image
            cell.bookTitleLbl.text = book.title
            cell.bookPricelbl.text = "€\(book.price)"
            cellToReturn = cell
        }
        return cellToReturn
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let checkoutViewController = self.storyboard?.instantiateViewController(identifier: "CheckoutViewsControllerStoryboardID") as CheckoutViewController? {

            checkoutViewController.bookPurchase = books[indexPath.row]
            

            navigationController?.pushViewController(checkoutViewController, animated: true)
        }
    }
    
    
}
