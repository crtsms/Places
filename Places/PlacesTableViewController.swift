//
//  PlacesTableViewController.swift
//  Places
//
//  Created by Crislei Terassi Sorrilha on 4/15/18.
//  Copyright © 2018 Crislei Terassi Sorrilha. All rights reserved.
//

import UIKit
import os.log


class PlacesTableViewController: UITableViewController {
    
    //MARK: Properties
    var store = DataStore.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        //User the edit button provided by the table view controller
        self.navigationItem.rightBarButtonItem = editButtonItem
        
        loadData()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.store.places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Table view cells are reusable and should be dequeued using a cell udentifier.
        let cellIdentifier = "PlaceTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PlacesTableViewCell else {
            fatalError("The dequeued cell is not an istance of PlaceTableViewCell")
        }
        
        //Feches the appropriate meal for the data source layout.
        let placeItem = self.store.places[indexPath.row]
        cell.titleLabel.text = placeItem.title

        return cell
        
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            store.places.remove(at: indexPath.row)
            savePlaces()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        super.prepare(for: segue, sender: sender)
        
        switch (segue.identifier ?? "") {
            
        case "ShowMap":
            guard let placesDetailViewController = segue.destination as? PlacesViewController else{
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedPlaceCell = sender as? PlacesTableViewCell else{
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedPlaceCell) else{
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedPlace = self.store.places[indexPath.row]
            placesDetailViewController.placeSelected = selectedPlace
            
        default:
            fatalError("Unexpected Segue Identifier: \(String(describing: segue.identifier))")
        }
    }
    
    private func loadData() {
        
        if let storedData = NSKeyedUnarchiver.unarchiveObject(withFile: Place.ArchiveURL.path) as? [Place]{
            self.store.places = storedData
        }
        
    }
    
    /// Save places into user data
    private func savePlaces(){
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(self.store.places, toFile: Place.ArchiveURL.path)
        print(self.store.places)
        
        if isSuccessfulSave {
            os_log("Places successfully saved.", log: OSLog.default, type: .debug)
        }else{
            os_log("Failed to save places...", log: OSLog.default, type: .error)
        }
        
    }

}
