import UIKit

class RootViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let label = UILabel(frame: CGRect(x:0, y:0, width:100, height:100))
        label.text = "Hello world"
        label.center = self.view.center
        self.view.addSubview(label)
    }
}
