//
//  Place.swift
//  Places
//
//  Created by Crislei Terassi Sorrilha on 4/15/18.
//  Copyright © 2018 Crislei Terassi Sorrilha. All rights reserved.
//

import UIKit
import os.log

class Place: NSObject, NSCoding{
    
    //MARK: Properties
    var title: String
    var latitude: Double
    var longitude: Double
    
    //MARK: Achiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("places")
    
    //MARK: types
    struct PropertyKey {
        
        static let title = "title"
        static let latitude = "latitude"
        static let longitude = "longitude"
        
    }
    
    //MARK: Initialization
    init?(title: String, latitude: Double, longitude: Double) {
        
        //No one can be empty
        guard !title.isEmpty else {
            return nil
        }
        
        //Initialize stored properties
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(title, forKey: PropertyKey.title)
        aCoder.encode(latitude, forKey: PropertyKey.latitude)
        aCoder.encode(longitude, forKey: PropertyKey.longitude)
        
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        //The name is required. if not decode a name string, the initializer should fail
        guard let title = aDecoder.decodeObject(forKey: PropertyKey.title) as? String else {
            os_log("Unable to decode the name for a Place object.", log: OSLog.default, type: .default)
            return nil
        }
        
        let latitude = aDecoder.decodeDouble(forKey: PropertyKey.latitude)
        let longitude = aDecoder.decodeDouble(forKey: PropertyKey.longitude)
        
        //Must call designated initializer
        self.init(title: title, latitude: latitude, longitude: longitude)
    }
    
    
}
