import Foundation


struct AlertModel {
    let title: String
    let message: String
    let buttonTitle: String
    let completion: () -> Void
}
