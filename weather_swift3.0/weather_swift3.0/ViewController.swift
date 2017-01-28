//
//  ViewController.swift
//  weather_swift3.0
//
//  Created by mike on 2017/1/28.
//  Copyright © 2017年 my_application. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var cityLbl: UILabel!
    
    @IBOutlet var conditionLbl: UILabel!
    
    @IBOutlet var degreeLbl: UILabel!
    
    @IBOutlet var imgView: UIImageView!
    
    var degree: Int!
    var condition: String!
    var imgurl: String!
    var city: String!
    
    var exists: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        searchBar.delegate=self
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let urlRequest = URLRequest(url:URL(string:"http://api.apixu.com/v1/current.json?key=b0323d28eeba4602b2c134820172801&q=\(searchBar.text!.replacingOccurrences(of: " ", with: "20%"))")!)
        
        /*
        let urlRequest = URLRequest(url:URL(string:"http://api.openweathermap.org/data/2.5/weather?q=\(searchBar.text!.replacingOccurrences(of: " ", with: "20%"))&units= metric&APPID=5933986010b65a4181c8994f3d137bb2")!)
        */
        
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : AnyObject]
                    //read data from api
                    if let current = json["current"] as? [String : AnyObject]{
                        if let temp = current["temp_c"] as? Int{
                            self.degree = temp
                        }
                        if let condition = current["condition"] as? [String : AnyObject]{
                            self.condition = condition["text"] as! String
                            let icon = condition["icon"] as! String
                            self.imgurl = "http:\(icon)"
                        }
                    }
                    if let location = json["location"] as? [String: AnyObject]{
                        self.city = location["name"] as! String
                    }
                    if let _=json["error"]{
                        self.exists = false
                    }
                    DispatchQueue.main.async {
                        if self.exists{
                            self.degreeLbl.isHidden = false
                            self.conditionLbl.isHidden = false
                            self.imgView.isHidden = false
                            
                            self.degreeLbl.text = "\(self.degree.description)°"
                            self.cityLbl.text = self.city
                            self.conditionLbl.text = self.condition
                            self.imgView.downloadImage(from: self.imgurl!)
                        }else{
                            self.degreeLbl.isHidden = true
                            self.conditionLbl.isHidden = true
                            self.imgView.isHidden = true
                            self.cityLbl.text = "no maching city found"
                            self.exists = true
                        }
                    }
                    
                    
                } catch let jsonError{
                    print(jsonError.localizedDescription)
                }
            }
        }
        task.resume()
        
        
    }
    
}

extension UIImageView{
    func downloadImage(from url: String){
        let urlRequest = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: urlRequest){(data,reponse,error)in
            if error == nil{
                DispatchQueue.main.async{
                    self.image = UIImage(data:data!)
                }
            }
        }
        
        task.resume()
        
    }
}

