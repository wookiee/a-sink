
import UIKit

class ViewController: UIViewController {
    
    // MARK: - UI elements and state

    @IBOutlet var downloadDataButton: UIButton!
    @IBOutlet var downloadDataLabel: UILabel!
    @IBOutlet var downloadDataSpinner: UIActivityIndicatorView!
    
    @IBOutlet var findPrimesButton: UIButton!
    @IBOutlet var findPrimesLabel: UILabel!
    @IBOutlet var findPrimesSpinner: UIActivityIndicatorView!
        
    fileprivate var downloadDataState: FeatureState! {
        didSet {
            switch downloadDataState! {
            case let .running(enable: enable, button: buttonText, label: labelText):
                downloadDataButton.setTitle(buttonText, for: (enable ? .normal : .disabled))
                downloadDataButton.isEnabled = enable
                downloadDataLabel.text = labelText
                downloadDataSpinner.alpha = 1.0
                downloadDataSpinner.startAnimating()
            case let .stopped(enable: enable, button: buttonText, label: labelText):
                downloadDataButton.setTitle(buttonText, for: (enable ? .normal : .disabled))
                downloadDataButton.isEnabled = enable
                downloadDataLabel.text = labelText
                downloadDataSpinner.alpha = 0.0
                downloadDataSpinner.stopAnimating()
            }
        }
    }
    
    fileprivate var findPrimesState: FeatureState! {
        didSet {
            switch findPrimesState! {
            case let .running(enable: enable, button: buttonText, label: labelText):
                findPrimesButton.setTitle(buttonText, for: (enable ? .normal : .disabled))
                findPrimesButton.isEnabled = enable
                findPrimesLabel.text = labelText
                findPrimesSpinner.alpha = 1.0
                findPrimesSpinner.startAnimating()
            case let .stopped(enable: enable, button: buttonText, label: labelText):
                findPrimesButton.setTitle(buttonText, for: (enable ? .normal : .disabled))
                findPrimesButton.isEnabled = enable
                findPrimesLabel.text = labelText
                findPrimesSpinner.alpha = 0.0
                findPrimesSpinner.stopAnimating()
            }
        }
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Kickstart the didSet
        downloadDataState = FeatureState.stopped(enable: true, button: "Download Data", label: "")
        findPrimesState = FeatureState.stopped(enable: true, button: "Find Primes", label: "")
        
        primeLabelUpdateLink = CADisplayLink(target: self, selector: #selector(primeLabelUpdater))
        primeLabelUpdateLink.preferredFrameRateRange = CAFrameRateRange(minimum: 60, maximum: 120, preferred: 60)
        primeLabelUpdateLink.add(to: .current, forMode: .default)
    }
    
    // MARK: - Updating the Find Primes label
    
    var primeLabelUpdateLink: CADisplayLink!
    var lastShownPrime = -1
    
    @objc private func primeLabelUpdater() {
        let lastFoundPrime = primer.lastFoundPrime
        guard lastFoundPrime != lastShownPrime && primer.isRunning else { return }
        findPrimesLabel.text = lastFoundPrime.description
        lastShownPrime = lastFoundPrime
    }
    
    // MARK: - Actions
    
    let fetcher = Fetcher()
    let primer = Primer()

    @IBAction func handlePressedDownloadDataButton(_ sender: UIButton) {
        
        downloadDataState = .running(enable: false, button: "Downloading", label: "")
        
        fetcher.fetchRandomDataFile(size: .tenMegabytes) { result in
            switch result {
            case let .success(url):
                print("Successfully downloaded \(url.lastPathComponent)")
                DispatchQueue.main.async {
                    self.downloadDataState = .stopped(enable: true, button: "Again!", label: "Success!")
                }
            case let .failure(error):
                print("Failed to download the data file: \(error)")
                DispatchQueue.main.async {
                    self.downloadDataState = .stopped(enable: true, button: "Retry", label: "Failed. Check logs.")
                }
            }
        }
        
    }
    
    @IBAction func handlePressedFindPrimesButton(_ sender: UIButton) {
        
        if primer.isRunning {
            primer.stop()
            print("Stopped primer at \(primer.lastFoundPrime)")
            findPrimesState = .stopped(enable: true, button: "Resume", label: "")
        } else {
            primer.start()
            print("Starting the primer...")
            findPrimesState = .running(enable: true, button: "Pause", label: "Finding...")
        }
        
    }
    
}

// MARK: - Helper types

private extension ViewController {
    enum FeatureState {
        case running(enable: Bool, button: String, label: String)
        case stopped(enable: Bool, button: String, label: String)
    }
}
