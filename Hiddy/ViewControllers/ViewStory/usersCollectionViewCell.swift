//import UIKit
//
//class usersCollectionViewCell: UICollectionViewCell {
//    @IBOutlet weak var imgView: UIImageView!
//    @IBOutlet weak var lblUserName: UILabel!
//    @IBOutlet weak var userImageBGView: UIView!
//    @IBOutlet weak var lblAdd: UILabel!
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//        self.lblUserName.textAlignment = .center
//
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
//       // userImageBGView.backgroundColor = AppOrange
//        userImageBGView.dropShadow()
//        userImageBGView.backgroundColor = LineColor
//
//    }
//}
