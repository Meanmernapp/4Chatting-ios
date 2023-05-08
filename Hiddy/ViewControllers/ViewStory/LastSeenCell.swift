//
//import UIKit
//
//class LastSeenCell: UITableViewCell {
//    @IBOutlet weak var imgView: UIImageView!
//    @IBOutlet weak var lblUserName: UILabel!
//    @IBOutlet weak var userImageBGView: UIView!
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//        userImageBGView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
//        imgView.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
//        self.specificCornerRadius(radius: 15)
//        userImageBGView.backgroundColor = LineColor
//
//    }
//
//    func specificCornerRadius(radius:Int)
//    {
//        let rectShape = CAShapeLayer()
//        rectShape.bounds = userImageBGView.frame
//        rectShape.position = userImageBGView.center
//        rectShape.path = UIBezierPath(roundedRect: userImageBGView.bounds, byRoundingCorners: [.topRight , .bottomLeft], cornerRadii: CGSize(width: radius, height: radius)).cgPath
//        userImageBGView.layer.mask = rectShape
//
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//
//}
