//
//  ViewController.swift
//  APScrollPagingBottom
//
//  Created by admin on 1/8/18.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var aryTbl = NSMutableArray()
    var SearchCurrentPageCount = NSInteger();
    var SearchTotalPageCount = NSInteger();

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        /*
        let ary = ["a","b"] ;
        let ary1 = ["c","d"] ;
        
        self.aryTbl.addObjects(from: ary)
        self.aryTbl.addObjects(from: ary1)
        
        print(aryTbl)
       */
        
        
        SearchTotalPageCount = 1;
        SearchCurrentPageCount = 1;
        self.connection_api()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func connection_api(){
        
        let dict = NSMutableDictionary()
       // dict.setValue("", forKey: "StoreGUID")
        dict.setValue("\(SearchCurrentPageCount)", forKey: "PageNo")
        dict.setValue("10", forKey: "PageSize")
        dict.setValue("Processing", forKey: "Filter")
        dict.setValue("1fda8b2a-ed75-e4cd-26d7-8c6be04a7ad2",forKey: "SessionKey")
        
     
        
      //  http://expertteam.in/502-mandi/api/store/getOrders

 
        
        print(dict)
        
        WebService().callAPIBYPOST(parameter: dict, url:
            "http://expertteam.in/502-mandi/api/store/getOrders", int_hud: 0) { (response, status) in
                print(response)
               self.load(response: response)
        }
    }
    
    
    
    
    func load(response: NSDictionary) {
        
       // if response.value(forKey: "Data") as! String == "200" {
            
            let aryData = response.value(forKey: "Data") as! NSDictionary;
            if aryData != nil {
                let aryRecord = aryData.value(forKey: "Records") as! NSArray;
                print(aryRecord)
                SearchTotalPageCount = aryData.value(forKey: "TotalRecords") as! NSInteger;
                
                if self.SearchCurrentPageCount == 1 {
                    self.aryTbl.addObjects(from: aryRecord as! [Any])
                    print(self.aryTbl)
                    
                }else{
                    self.aryTbl.addObjects(from: aryRecord as! [Any])
                    
                }
                self.tblList.reloadData()
            }

            
            
//        }else{//500
//            print("---Record not found---")
//        }
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aryTbl.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "Cell") as! Cell
        
        
        let dict = aryTbl[indexPath.row] as! NSDictionary
        
        
        
        cell.lblTitle.text = dict["FirstName"] as? String
       
        return cell;
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
            
        if indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex {
            if SearchTotalPageCount > SearchCurrentPageCount{
                SearchCurrentPageCount += 1;
                connection_api()
            } else {
                print("Final Page Call Search Movies")
            }
        }
    }
}



