//
//  MediaListViewController.swift
//  Lab4CameraPetrova
//
//  Created by Olesia Petrova on 08.10.2024.
//

import UIKit
import AVKit

class MediaListViewController : UITableViewController {
    private var mediaItems : [URL] = []
    private var currentPlayerVC: AVPlayerViewController?
    private var currentMediaIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "mediaCell")
        
        loadMediaItems()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    
    func loadMediaItems() {
        mediaItems = FileService.shared.retrieveAllFiles()
        
        // Reload the table view to reflect the loaded data
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mediaItems.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mediaCell", for: indexPath)
        
        // Configure the cell using the media item's name or other property
        cell.textLabel?.text = mediaItems[indexPath.row].lastPathComponent
        
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mediaVC = MediaViewController()
        mediaVC.mediaItems = self.mediaItems
        mediaVC.currentMediaIndex = indexPath.row
        navigationController?.pushViewController(mediaVC, animated: true)
    }
}
