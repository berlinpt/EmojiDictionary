//
//  EmojiTableViewController.swift
//  EmojiDictionary
//
//  Created by Berlin Thomas on 2024-03-18.
//

import UIKit

class EmojiTableViewController: UITableViewController {
    
    var emojis: [Emoji] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedEmojis = Emoji.loadFromFile() {
            emojis = savedEmojis
        }
        else {
            emojis = Emoji.loadSampleEmojis()
        }
        
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    
    @IBSegueAction func addEditEmoji(_ coder: NSCoder, sender: Any?) -> AddEditEmojiTableViewController? {
        
        if let cell = sender as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell) {
            // Editing Emoji
            let emojiToEdit = emojis[indexPath.row]
            
            return AddEditEmojiTableViewController(coder: coder, emoji: emojiToEdit)
        }
        else {
            // Adding Emoji
            return AddEditEmojiTableViewController(coder: coder, emoji: nil)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emojis.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 1. Dequeue Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmojiCell", for: indexPath) as! EmojiTableViewCell

        // 2. Fetch Model object to display
        let emoji = emojis[indexPath.row]

        // 3. Configure cell
        cell.update(with: emoji)
        cell.showsReorderControl = true
        
        // 4. Return cell
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            emojis.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
   
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedEmoji = emojis.remove(at: fromIndexPath.row)
        emojis.insert(movedEmoji, at: to.row)
    }
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        let tableViewEditingMode = tableView.isEditing
        
        tableView.setEditing(!tableViewEditingMode, animated: true)
    }
    
    
    @IBAction func unwindToEmojiTableView(segue: UIStoryboardSegue)  {
        guard segue.identifier == "saveUnwind",
              let sourceViewController = segue.source as? AddEditEmojiTableViewController,
              let emoji = sourceViewController.emoji else { return }
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            emojis[selectedIndexPath.row] = emoji
            tableView.reloadRows(at: [selectedIndexPath], with: .none)
        }
        else {
            let newIndexPath = IndexPath(row: emojis.count, section: 0)
            emojis.append(emoji)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
        
        Emoji.saveToFile(emojis: emojis)
    }
    

}
