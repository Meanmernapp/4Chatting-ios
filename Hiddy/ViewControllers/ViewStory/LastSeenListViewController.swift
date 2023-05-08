//import UIKit
//
//class LastSeenListViewController: UIViewController {
//    
//    init(item1: [Content]) {
//        // self.backgroundImage = image
//        item = item1
//        super.init(nibName: nil, bundle: nil)
//    }
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    @IBOutlet weak var userListTable: UITableView!
//    var item: [Content] = []
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        self.userListTable.dataSource = self
//        self.userListTable.delegate = self
//        self.userListTable.register(UINib(nibName: "LastSeenCell", bundle: nil),forCellReuseIdentifier: "cell")
//        // Do any additional setup after loading the view.
//    }
//    @IBAction func btnBack_Act(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
//    }
//    
//    
//}
//extension LastSeenListViewController : UITableViewDataSource, UITableViewDelegate{
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return  item[0].lastseen.count
//    }
//    
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell : LastSeenCell = userListTable.dequeueReusableCell(withIdentifier: "cell") as! LastSeenCell
//        cell.lblUserName.text = item[0].lastseen[indexPath.row].user_name
//        cell.imgView.sd_setImage(with: URL(string: item[0].lastseen[indexPath.row].user_image), placeholderImage:#imageLiteral(resourceName: "userPlaceholder.png"))
//        return cell
//    }
//    
//}
