import Foundation
import UIKit

class AlertPresenter {
    func show(vc: UIViewController, model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )

        let action = UIAlertAction(title: model.buttonTitle, style: .default) {
            _ in
            model.completion()
        }

        alert.addAction(action)

        vc.present(alert, animated: true, completion: nil)
    }
}
