import UIKit
public class SwiftCodeKit {
    public static func start() {
        DispatchQueue.main.async {
            if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                let viewController = SwiftCodeKitViewController()
                rootViewController.present(viewController, animated: true)
            }
        }
    }
}
