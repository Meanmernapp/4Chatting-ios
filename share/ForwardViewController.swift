//
//  ForwardViewController.swift
//  Share
//
//  Created by Hitasoft on 15/07/19.
//  Copyright © 2019 HITASOFT. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ForwardViewController: UIViewController {
    @IBOutlet var searchTableView: UITableView!
    @IBOutlet var noLbl: UILabel!
    @IBOutlet var navigationView: UIView!
    @IBOutlet var searchTF: UITextField!
    @IBOutlet var noView: UIView!
    
    let sharedKey = "ImageSharePhotoKey"
    var selectedImages: [UIImage] = []
    var selectedData: [Data] = []
    var selectedUrl: [String] = []
    var selectedType: [String] = []
    var sharedData = [CellModel]()
    let userDefaults = UserDefaults(suiteName: "group.\(Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? "")")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("forward********** view did load")
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        print("forward********** view will appear")
        self.manageImages()
    }
    func manageImages() {
        //
        
        let content = extensionContext!.inputItems[0] as! NSExtensionItem
        let contentType = kUTTypeImage as String
        var rediractName = ""
        let selectedCount = (content.attachments)?.count
        print("selectedddd count \(content.attachments?.count)")
        for (index, attachment) in (content.attachments)!.enumerated() {
            if attachment.hasItemConformingToTypeIdentifier(contentType) {
                print(attachment)
                attachment.loadItem(forTypeIdentifier: contentType, options: nil) { [weak self] data, error in
                    
                    if error == nil, let url = data as? URL, let _ = self {
                        do {
                            // print(attachment.registeredTypeIdentifiers[0])
                            // GETTING RAW DATA
                            let rawData = try Data(contentsOf: url)
                            let rawImage = UIImage(data: rawData)
                            
                            // CONVERTED INTO FORMATTED FILE : OVER COME MEMORY WARNING
                            // YOU USE SCALE PROPERTY ALSO TO REDUCE IMAGE SIZE
                            //                            let image = UIImage.resizeImage(image: rawImage!, width: 100, height: 100)
                            let imgData = rawImage?.jpegData(compressionQuality: 0.5)!
                            self?.selectedData.append(imgData!)
                            self?.selectedUrl.append("\(url)")
                            self?.selectedType.append("image")
                            
                            
                            self?.userDefaults?.removeObject(forKey: "ImageSharePhotoKey")
                            self?.userDefaults?.removeObject(forKey: "local_path")
                            self?.userDefaults?.removeObject(forKey: "imageType")
                            self?.userDefaults?.set(self?.selectedData, forKey: "ImageSharePhotoKey")
                            self?.userDefaults?.set(self?.selectedUrl, forKey: "local_path")
                            self?.userDefaults?.set(self?.selectedType, forKey: "imageType")
                            self?.userDefaults?.synchronize()
                            if selectedCount == self?.selectedData.count {
                                print("moved with count of \(self?.selectedData.count)")
                                self?.redirectToHostApp(type: "imageVideo")
                            }
                        }
                        catch _ {
                            print("GETTING EXCEPTION \(String(describing: error?.localizedDescription))")
                            
                        }
                        
                    } else {
                        if let rawImage = data as? UIImage {
                            //                            let rawData = try Data(contentsOf: url)
                            //                            let image = UIImage.resizeImage(image: rawImage, width: 100, height: 100)
                            let imgData = rawImage.jpegData(compressionQuality: 0.5)!
                            self?.selectedData.append(imgData)
                            self?.selectedUrl.append("")
                            self?.selectedType.append("image")
                            
                            self?.userDefaults?.removeObject(forKey: "ImageSharePhotoKey")
                            self?.userDefaults?.removeObject(forKey: "local_path")
                            self?.userDefaults?.removeObject(forKey: "imageType")
                            
                            self?.userDefaults?.set(self?.selectedData, forKey: "ImageSharePhotoKey")
                            self?.userDefaults?.set(self?.selectedUrl, forKey: "local_path")
                            self?.userDefaults?.set(self?.selectedType, forKey: "imageType")
                            self?.userDefaults?.synchronize()
                            if selectedCount == self?.selectedData.count {
                                print("moved with count of \(self?.selectedData.count)")

                                self?.redirectToHostApp(type: "imageVideo")
                            }
                        }
       
                    }
                }
            }
            else if attachment.hasItemConformingToTypeIdentifier(String(kUTTypeMovie)) {
                print(attachment)

                attachment.loadItem(forTypeIdentifier: String(kUTTypeMovie), options: nil) { [weak self] data, error in
                    var type = ""
                    type = ""
                    if error == nil, let url = data as? URL, let _ = self {
                        // print(attachment.registeredTypeIdentifiers[0])
                        // GETTING RAW DATA
                        if (url.absoluteString.hasSuffix("MOV")) {
                            type = ".mov"
                        } else {
                            type = ".mp4"
                        }
                        // CONVERTED INTO FORMATTED FILE : OVER COME MEMORY WARNING
                        // YOU USE SCALE PROPERTY ALSO TO REDUCE IMAGE SIZE
                        
                        self?.selectedType.append("video")
                        let videoData = NSData.init(contentsOf: url)
                        self?.selectedData.append(videoData! as Data)
                        self?.selectedUrl.append("\(url)")
                        self?.userDefaults?.removeObject(forKey: "ImageSharePhotoKey")
                        self?.userDefaults?.removeObject(forKey: "local_path")
                        self?.userDefaults?.removeObject(forKey: "imageType")
                        
                        self?.userDefaults?.set(self?.selectedData, forKey: "ImageSharePhotoKey")
                        self?.userDefaults?.set(self?.selectedUrl, forKey: "local_path")
                        self?.userDefaults?.set(self?.selectedType, forKey: "imageType")
                        self?.userDefaults?.synchronize()
                        if selectedCount == self?.selectedData.count {
                            print("moved with count of \(self?.selectedData.count)")
                            self?.redirectToHostApp(type: "imageVideo")
                        }
                    } else {
                        // print("GETTING ERROR")
                        let alert = UIAlertController(title: "Error", message: "Error loading image", preferredStyle: .alert)
                        
                        let action = UIAlertAction(title: "Error", style: .cancel) { _ in
                            self?.dismiss(animated: true, completion: nil)
                        }
                        
                        alert.addAction(action)
                        self?.present(alert, animated: true, completion: nil)
                    }
                }
            }
            else if attachment.hasItemConformingToTypeIdentifier(String(kUTTypeFileURL)) {
                
                attachment.loadItem(forTypeIdentifier: String(kUTTypeFileURL), options: nil) { [weak self] data, error in
                    
                    if error == nil, let url = data as? URL, let _ = self {
                        do {
                            // GETTING RAW DATA
                            print("fileURLLLL: \(url)")
                            let rawData = try Data(contentsOf: url)
                            self?.userDefaults?.set("\(url)", forKey: "text")
                            self?.selectedData.append(rawData)
                            self?.selectedUrl.append("\(url)")
                            self?.userDefaults?.set(rawData, forKey: "documentData")
                            self?.redirectToHostApp(type: "document")
                        }
                        catch _ {
                            print("GETTING EXCEPTION \(error!.localizedDescription)")
                        }
                        
                    } else {
                        // print("GETTING ERROR")
                        let alert = UIAlertController(title: "Error", message: "Error loading image", preferredStyle: .alert)
                        
                        let action = UIAlertAction(title: "Error", style: .cancel) { _ in
                            self?.dismiss(animated: true, completion: nil)
                        }
                        
                        alert.addAction(action)
                        self?.present(alert, animated: true, completion: nil)
                    }
                }
            }
            else  {
                if attachment.hasItemConformingToTypeIdentifier(String(kUTTypeURL)){
                    attachment.loadItem(forTypeIdentifier: String(kUTTypeURL), options: nil, completionHandler: { (item, error) -> Void in
                        let url = item as! URL
                        self.userDefaults?.synchronize()
                        if attachment.hasItemConformingToTypeIdentifier(String(kUTTypeFileURL)) {
                            self.userDefaults?.set("\(url)", forKey: "text")
                            self.redirectToHostApp(type: "document")
                        }
                        else if "\(url)".contains("maps") {
                            rediractName = "location"
                            self.redirectToHostApp(type: "location")
                        }
                        else {
                            self.userDefaults?.set("\(url)", forKey: "text")
                            self.redirectToHostApp(type: "text")
                        }
                    })
                }
                else if attachment.hasItemConformingToTypeIdentifier(String(kUTTypeContact)) {
                    attachment.loadItem(forTypeIdentifier: String(kUTTypeContact), options: nil, completionHandler: { (item, error) -> Void in
                        let text = item as! Data
                        self.userDefaults?.set(text, forKey: "contactData")
                        self.userDefaults?.synchronize()
                        self.redirectToHostApp(type: "contact")
                    })
                    
                }
                else if attachment.hasItemConformingToTypeIdentifier(String(kUTTypePlainText)) {
                    attachment.loadItem(forTypeIdentifier: String(kUTTypeText), options: nil, completionHandler: { (item, error) -> Void in
                        let text = item as? String ?? ""
                        self.userDefaults?.set("\(text)", forKey: "text")
                        self.userDefaults?.synchronize()
                        if content.attachments?.count == 1 {
                            self.redirectToHostApp(type: "text")
                        }
                        
                    })
                }
                else if attachment.hasItemConformingToTypeIdentifier(String(kUTTypeText)) {
                    attachment.loadItem(forTypeIdentifier: String(kUTTypeText), options: nil, completionHandler: { (item, error) -> Void in
                        let text = item as? String ?? ""
                        if rediractName != "location" && attachment.registeredTypeIdentifiers[0]
                            != "public.plain-text"  && attachment.registeredTypeIdentifiers[0] != "public.vcard" && attachment.registeredTypeIdentifiers[0] != "com.apple.mapkit.map-item" {
                            self.userDefaults?.set("\(text)", forKey: "text")
                            self.userDefaults?.synchronize()
                            self.redirectToHostApp(type: "text")
                        }
                    })
                }
            }
        }
    }
    func redirectToHostApp(type: String) {
        let url = URL(string: "\(Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? "")://dataUrl=\(type)")
        var responder = self as UIResponder?
        let selectorOpenURL = sel_registerName("openURL:")
        
        while (responder != nil) {
            if (responder?.responds(to: selectorOpenURL))! {
                let _ = responder?.perform(selectorOpenURL, with: url)
            }
            responder = responder!.next
        }
        if self.extensionContext != nil {
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }
    }
    @IBAction func backArrowAct(_ sender: UIButton) {
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
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

