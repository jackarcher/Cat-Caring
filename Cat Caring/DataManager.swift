//
//  DataManager.swift
//  Cat Caring
//
//  Created by Jack N. Archer on 5/11/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import UIKit

class DataManager: NSObject {
    
    /// The domain of our server, for easy configuration, is set here seperatly
    static let domain = "http://118.139.11.233:5959/"
    
    /// This function is used for fetching data from server by using specific api.
    /// - Parameters:
    ///     - api: The api WITHOUT domain, please refer to the api documents for more information
    ///     - type: Refers to the class that the loading will deal with.
    ///     - tableview: Refers to the UITableView that requires this connection. This parameter was required for reloading in async queue
    ///     - list: The array that will store the information about the result, either about temperature or about color
    static func loadData(api: String!, for type: String, in tableview: UITableView, into list: NSMutableArray, failHandler:(()->Void)?){
        // set the activitiy icon on
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // set url
        let prepareURL = "\(domain)\(api!)".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: prepareURL!)!
        print("GET \(url)")
        
        // set session
        let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
        
        // data task for session
        var dataTask: URLSessionDataTask?
        dataTask = defaultSession.dataTask(with: url){
            data,respons, error in
            // async queue
            DispatchQueue.main.async{
                // error handler
                if let error = error{
                    print (error.localizedDescription)
                } else if let httpResponse = respons as? HTTPURLResponse {
                    print(httpResponse.statusCode)
                    if httpResponse.statusCode == 200{
                        // successufly got data
                        
                    } else{
                        // todo alert
                        failHandler?()
                    }
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        dataTask?.resume()
    }
}
