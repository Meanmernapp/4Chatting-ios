//
//  popOverViewController.swift
//  Hiddy
//
//  Created by Hitasoft on 08/08/19.
//  Copyright © 2019 HITASOFT. All rights reserved.
//

import UIKit
import PullUpController

class popOverViewController: PullUpController {

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var storyID = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetUp()
        // Do any additional setup after loading the view.
    }
    func initialSetUp() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "PopOverTableViewCell", bundle: nil), forCellReuseIdentifier: "PopOverTableViewCell")
    }
    @IBAction func buttonAct(_ sender: UIButton) {
        let alert = DeleteAlertViewController()
        alert.modalPresentationStyle = .overCurrentContext
        alert.modalTransitionStyle = .crossDissolve
        alert.delegate = self
        alert.viewType = "0"
        alert.typeTag = 0
        alert.msg = "delete_msg"
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension popOverViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "PopOverTableViewCell") as! PopOverTableViewCell
        return cell
    }
    
    
}
extension popOverViewController: deleteAlertDelegate {
    func deleteActionDone(type: String, viewType: String) {
//        let socket = StorySocket()
//        socket.deleteStory(story_id: self.storyID, memberID: <#String#>)
//        let storage = storyStorage()
//        storage.deleteStory(story_id: storyID)
//        self.dismiss(animated: true, completion: nil)
    }
}
