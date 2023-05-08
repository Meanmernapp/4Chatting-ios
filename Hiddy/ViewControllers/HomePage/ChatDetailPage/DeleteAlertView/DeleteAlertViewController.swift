//
//  DeleteAlertViewController.swift
//  Hiddy
//
//  Created by Hitasoft on 27/07/19.
//  Copyright © 2019 HITASOFT. All rights reserved.
//

import UIKit

protocol deleteAlertDelegate {
    func deleteActionDone(type:String, viewType: String)
}
class DeleteAlertViewController: UIViewController {

    @IBOutlet weak var deleteForEveryoneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var deleteForMeButton: UIButton!
    @IBOutlet weak var messageTitleLabel: UILabel!
    @IBOutlet weak var popupView: UIView!
    
    var alertType = String()
    var msg = String()
    var typeTag = 0
    var delegate:deleteAlertDelegate?
    var viewType = "0"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        // Do any additional setup after loading the view.
    }

    func initialSetup()  {
        self.popupView.backgroundColor = BOTTOM_BAR_COLOR
        self.popupView.viewRadius(radius: 15)
        self.messageTitleLabel.config(color: TEXT_PRIMARY_COLOR, size: 19, align: .left, text: msg)
//        self.messageTitleLabel.attributed(text:msg)
        if self.viewType == "0" {
            self.deleteForMeButton.config(color: RECIVER_BG_COLOR, size: 17, align: .right, title: "delete_me")
            self.deleteForEveryoneButton.config(color: RECIVER_BG_COLOR, size: 17, align: .right, title: "delete_everyone")
            self.cancelButton.config(color: RECIVER_BG_COLOR, size: 17, align: .right, title: "Ucancel")

        }
        else {
            self.deleteForMeButton.config(color: RECIVER_BG_COLOR, size: 17, align: .right, title: "report_abuse")
            self.deleteForEveryoneButton.config(color: RECIVER_BG_COLOR, size: 17, align: .right, title: "report_adult")
            self.cancelButton.config(color: RECIVER_BG_COLOR, size: 17, align: .right, title: "report_Inappropriate")
            
        }
        if typeTag == 0 {
            self.deleteForEveryoneButton.isHidden = true
        }
        else {
            self.deleteForEveryoneButton.isHidden = false
        }
        //tap to dismiss
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismiss (_:)))
        self.view.addGestureRecognizer(tap)
    }
    @objc func dismiss(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2.0, options: .curveLinear, animations: {
            self.dismiss(animated: true, completion: nil)
        }, completion: nil)
    }
    @IBAction func deleteForEveryoneButtonAct(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        self.delegate?.deleteActionDone(type: "1", viewType: self.viewType)

    }
    
    @IBAction func cancelButtonAct(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        if self.viewType == "1" {
            self.delegate?.deleteActionDone(type: "2", viewType: self.viewType)
        }
    }
    @IBAction func deleteForMeButtonAct(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        self.delegate?.deleteActionDone(type: "0", viewType: self.viewType)

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
