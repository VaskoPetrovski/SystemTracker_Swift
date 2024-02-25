import UIKit

final class SwiftCodeKitViewController: UIViewController {
    private var trackingTimer: Timer?
    
    
    
    private lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Tracking", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(startTracking), for: .touchUpInside)
        return button
    }()
    
    private lazy var stopButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Stop Tracking", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(stopTracking), for: .touchUpInside)
        return button
    }()
    
    private lazy var goBackButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Go Back", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        return button
    }()
    
    private lazy var cpuUsageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.backgroundColor = .lightGray
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var ramUsageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.backgroundColor = .lightGray
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var activeCPICountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.backgroundColor = .lightGray
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var allCPICountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.backgroundColor = .lightGray
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var useMainThreadOnlySwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.isOn = true  // This sets the switch to be on by default
        switchControl.addTarget(self, action: #selector(toggleMainThreadUsage), for: .valueChanged)
        return switchControl
    }()
    
    private lazy var useMainThreadOnlyLabel: UILabel = {
          let label = UILabel()
          label.text = "Use main thread only"
          label.textColor = .black
          label.translatesAutoresizingMaskIntoConstraints = false
          return label
      }()
      
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .orange
        view.addSubview(startButton)
        view.addSubview(stopButton)
        view.addSubview(goBackButton)
        view.addSubview(cpuUsageLabel)
        view.addSubview(ramUsageLabel)
        view.addSubview(useMainThreadOnlySwitch)
        view.addSubview(useMainThreadOnlyLabel)
//        view.addSubview(activeCPICountLabel)

        
        NSLayoutConstraint.activate([
            
            cpuUsageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cpuUsageLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cpuUsageLabel.widthAnchor.constraint(equalToConstant: 200),
            cpuUsageLabel.heightAnchor.constraint(equalToConstant: 50),

            ramUsageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ramUsageLabel.topAnchor.constraint(equalTo: cpuUsageLabel.bottomAnchor, constant: 20),
            ramUsageLabel.widthAnchor.constraint(equalToConstant: 200),
            ramUsageLabel.heightAnchor.constraint(equalToConstant: 50),

            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.topAnchor.constraint(equalTo: ramUsageLabel.bottomAnchor, constant: 20),
            startButton.widthAnchor.constraint(equalToConstant: 150),
            startButton.heightAnchor.constraint(equalToConstant: 50),

            stopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stopButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 20),
            stopButton.widthAnchor.constraint(equalToConstant: 150),
            stopButton.heightAnchor.constraint(equalToConstant: 50),

            goBackButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            goBackButton.topAnchor.constraint(equalTo: stopButton.bottomAnchor, constant: 20),
            goBackButton.widthAnchor.constraint(equalToConstant: 150),
            goBackButton.heightAnchor.constraint(equalToConstant: 50),
            
            useMainThreadOnlySwitch.topAnchor.constraint(equalTo: goBackButton.bottomAnchor, constant: 20),
            useMainThreadOnlySwitch.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -10),
                       
            useMainThreadOnlyLabel.centerYAnchor.constraint(equalTo: useMainThreadOnlySwitch.centerYAnchor),
            useMainThreadOnlyLabel.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 10),
            
//            activeCPICountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            activeCPICountLabel.topAnchor.constraint(equalTo: goBackButton.bottomAnchor, constant: 20),
//            activeCPICountLabel.widthAnchor.constraint(equalToConstant: 150),
//            activeCPICountLabel.heightAnchor.constraint(equalToConstant: 50),

        ])
    }
    
    @objc private func startTracking() {
        trackingTimer?.invalidate() // Invalidate any existing timer
        
        trackingTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
//                let currentUsage = SystemTracker.cpuUsage()
//                self?.cpuUsageLabel.text = String(format: "CPU Usage: %.2f%%", currentUsage.cpuUsage)
                
                if self?.useMainThreadOnlySwitch.isOn == true {
                               let currentUsage = SystemTracker.cpuUsageMainThread()
                               self?.cpuUsageLabel.text = String(format: "Main CPU: %.2f%%", currentUsage.cpuUsage)
                           } else {
                               let currentUsage = SystemTracker.cpuUsage()
                               self?.cpuUsageLabel.text = String(format: "CPU: %.2f%%", currentUsage.cpuUsage)
                           }
                
                let currentMemoryUsage = SystemTracker.memoryUsage()
                let usedMemoryGB = Double(currentMemoryUsage.used) / 1_073_741_824 // Convert to GB
                let totalMemoryGB = Double(currentMemoryUsage.total) / 1_073_741_824 // Convert to GB
                self?.ramUsageLabel.text = String(format: "RAM: %.2f GB / %.2f GB", usedMemoryGB, totalMemoryGB)
                
//                self?.activeCPICountLabel.text = String(format: "Active: %d",ProcessInfo.processInfo.activeProcessorCount )
            }
        }
    }
    
    @objc private func toggleMainThreadUsage() {
      }
    
    @objc private func stopTracking() {
        trackingTimer?.invalidate()
        trackingTimer = nil
    }
    
    @objc private func goBack() {
        dismiss(animated: true)
    }
    
//    private func showAlertWith(message: String) {
//        let alertController = UIAlertController(title: "Tracking Result", message: message, preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alertController, animated: true)
//    }
}



