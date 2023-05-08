//
//  ContactPickerViewController.swift
//  Hiddy
//
//  Created by Hitasoft on 09/06/21.
//  Copyright © 2021 HITASOFT. All rights reserved.
//

import UIKit

class ContactPickerViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var refreshContact: ((_ selected: String) -> Void)?
    var contactVal = ContactModel()
    var selectedNumber = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    @IBAction func cancelButtonAct(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendButtonAct(_ sender: UIButton) {
        self.refreshContact?(self.selectedNumber)
        self.navigationController?.popViewController(animated: true)
    }
    func configUI() {
        self.cancelButton.config(color: .blue, size: 16, align: .left, title: "cancel")
        self.sendButton.config(color: SECONDARY_COLOR, size: 20, align: .left, title: "send")
        self.titleLabel.config(color: .black, size: 20, align: .center, text: "share_contact")
        self.tableView.register(UINib(nibName: "ContactPickerHeaderTableViewCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "ContactPickerHeaderTableViewCell")
        self.tableView.register(UINib(nibName: "ContactPickerTableViewCell", bundle: nil), forCellReuseIdentifier: "ContactPickerTableViewCell")
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = 40
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 40
        if contactVal.contactNumber.count > 0 {
            self.selectedNumber = contactVal.contactNumber.first ?? ""
        }
    }
}
extension ContactPickerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contactVal.contactNumber.count
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ContactPickerHeaderTableViewCell") as! ContactPickerHeaderTableViewCell
        return cell
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactPickerTableViewCell") as! ContactPickerTableViewCell
        if self.contactVal.contactNumber.count != 0{
        cell.headerLabel.text = self.contactVal.contactName
        cell.mobileNumberLabel.text = self.contactVal.contactNumber[indexPath.row]
        if self.contactVal.contactNumber[indexPath.row] == selectedNumber {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedNumber = self.contactVal.contactNumber[indexPath.row]
        self.tableView.reloadData()
    }
}
