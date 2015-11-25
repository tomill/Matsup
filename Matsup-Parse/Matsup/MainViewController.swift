//
//  MainViewController.swift
//  Matsup
//
//  Created by Naoki Tomita on 11/22/15.
//  Copyright © 2015 Tomill. All rights reserved.
//

import UIKit

class MainViewController: PFQueryTableViewController {

    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: "Timeline")
        
        
        // where={
        //     "user":{"$notInQuery":{"where":{"disabled":true},"className":"_User"}}
        //     ,
        //     "createdAt":{"$lt":"...."}
        let userDisabled = PFQuery(className:"_User")
        userDisabled.whereKey("disabled", equalTo:true)
        query.whereKey("user", doesNotMatchQuery:userDisabled)
        query.whereKey("createdAt", greaterThan:"2015-11-22T09:00:00.000Z")
        
        // include=user&limit=50&order=-createdAt
        query.includeKey("user")
        query.limit = 50
        query.orderByDescending("createdAt")
        
        return query
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        
        // fake PFTableViewCell
        object!["picture"] = object?["user"]["picture"]
        
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath, object: object)
        return cell
    }
}
