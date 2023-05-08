
import UIKit

var ContentViewControllerVC = ContentViewController()

class ContentViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate,socketClassDelegate {

    var pageViewController : UIPageViewController?
    var pages: [RecentStoryModel] = []
    var currentIndex : Int = 0
    var currentViewIndex = 0
    var segIndex: Int = 0
    fileprivate var scrollView = UIScrollView()
    var infoUpdated: ((_ dict:NSDictionary,_ type:String) -> Void)?

    var isFromChat = false
    override func viewDidLoad() {
        super.viewDidLoad()
        socketClass.sharedInstance.delegate = self

        ContentViewControllerVC = self
        pageViewController = UIPageViewController()
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController!.dataSource = self
        pageViewController!.delegate = self
        
        self.view.backgroundColor = UIColor.black
        currentViewIndex = self.currentIndex
        let startingViewController: PreViewController = viewControllerAtIndex(index: currentIndex)!
        let viewControllers = [startingViewController]
        pageViewController!.setViewControllers(viewControllers , direction: .forward, animated: false, completion: nil)
        pageViewController!.view.frame = view.bounds
        
        startingViewController.commentPosted = { dict,type in
            self.infoUpdated!(dict,type)
        }
        addChild(pageViewController!)
        view.addSubview(pageViewController!.view)
        view.sendSubviewToBack(pageViewController!.view)
        for view in self.pageViewController!.view.subviews {
            if let subView = view as? UIScrollView {
                subView.delegate = self
                subView.isScrollEnabled = true
                subView.bouncesZoom = false
            }
        }
        pageViewController!.didMove(toParent: self)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 13.0, *) {
        }
        else {
            if let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as? UIView{
                statusBar.isHidden = true
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if #available(iOS 13.0, *) {
        }
        else {
            if let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as? UIView{
                statusBar.isHidden = false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - UIPageViewControllerDataSource
    //1
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! PreViewController).pageIndex
        if (index == 0) || (index == NSNotFound) {
            currentViewIndex = index
            return nil
        }
        currentViewIndex = index
        index -= 1
        return viewControllerAtIndex(index: index)
    }

    //2
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! PreViewController).pageIndex
        if index == NSNotFound {
            return nil
        }
        currentViewIndex = index
        index += 1
        if (index == pages.count) {
            return nil
        }
        return viewControllerAtIndex(index: index)
    }
    //3
    func viewControllerAtIndex(index: Int) -> PreViewController? {
        if pages.count == 0 || index >= pages.count {
            return nil
        }

        // Create a new view controller and pass suitable data.
        let vc = PreViewController()
        vc.pageIndex = index
        vc.items = pages
        vc.segIndex = segIndex
        currentIndex = index
        vc.isFromChat = isFromChat
        vc.commentPosted = { dict,type in
            self.infoUpdated!(dict,type)
        }
        // vc.view.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        return vc
    }

    // Navigate to next page
    func goNextPage(fowardTo position: Int) {
        let startingViewController: PreViewController = viewControllerAtIndex(index: position)!
        let viewControllers = [startingViewController]
        startingViewController.commentPosted = { dict,type in
            self.infoUpdated!(dict,type)
        }
        self.currentIndex = position
        pageViewController!.setViewControllers(viewControllers , direction: .forward, animated: false, completion: nil)
    }

    // MARK: - Button Actions
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    func gotSocketInfo(dict: NSDictionary, type: String) {
        print("*********** 1")
        self.infoUpdated!(dict,type)
    }
}

extension ContentViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if currentViewIndex == 0 && scrollView.contentOffset.x < scrollView.bounds.size.width {
            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
        } else if currentViewIndex == (pages.count - 1) && scrollView.contentOffset.x > scrollView.bounds.size.width {
            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
        }
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if currentViewIndex == 0 && scrollView.contentOffset.x - 1 < scrollView.bounds.size.width {
            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
        } else if currentViewIndex == (self.pages.count - 1) && scrollView.contentOffset.x > scrollView.bounds.size.width {
            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
        }
    }
}
