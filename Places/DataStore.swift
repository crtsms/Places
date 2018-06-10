//
//  DataStore.swift
//  Places
//
//  Created by Crislei Terassi Sorrilha on 4/22/18.
//  Copyright © 2018 Crislei Terassi Sorrilha. All rights reserved.
//

import Foundation

class DataStore {
    
    static let sharedInstance = DataStore()
    private init() {}
    var places: [Place] = []
    
}
