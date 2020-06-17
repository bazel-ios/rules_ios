import UIKit

final class CustomView: UIView {

    @IBOutlet private var label: UILabel!

    static func fromNib() -> CustomView? {
        let bundle = Bundle(for: CustomView.self)

        return bundle.loadNibNamed("CustomView", owner: nil, options: nil)?.first as? CustomView
    }
}
