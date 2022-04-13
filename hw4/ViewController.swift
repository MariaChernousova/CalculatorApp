//
//  ViewController.swift
//  hw4
//
//  Created by Chernousova Maria on 22.09.2021.
//

import UIKit

class ViewController: UIViewController {
    private enum Constant {
        static let duration: TimeInterval = 0.3
        static let delay: TimeInterval = 0.3
        static let enabledOpacity: Float = 1
        static let disabledOpacity: Float = 0.6
        static let defaultOpacity: Float = .zero
    }

    @IBOutlet private weak var operationLabel: UILabel!
    
    @IBOutlet private var landscapeButtons: [RoundedButton]!
    @IBOutlet private weak var eraseButton: RoundedButton!
    @IBOutlet private var numberButtons: [RoundedButton]!
    @IBOutlet private var allButtons: [RoundedButton]!
    
    private let model: CalculatorModelProtocol
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let model = CalculatorModel()
        self.model = model
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        model.delegate = self
    }
    
    required init?(coder: NSCoder) {
        let model = CalculatorModel()
        self.model = model
        super.init(coder: coder)
        model.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if view.bounds.width < view.bounds.height {
            landscapeButtons.forEach { $0.layer.opacity = .zero }
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            UIView.animate(withDuration: Constant.duration, delay: Constant.delay, options: [], animations: {
                self.landscapeButtons.forEach { $0.layer.opacity = Constant.enabledOpacity }
            }, completion: nil)
        default:
            landscapeButtons.forEach { $0.layer.opacity = Constant.defaultOpacity }
        }
    }
    
    @IBAction func numberButtonTapped(_ sender: RoundedButton) {
        guard let buttonTitle = sender.titleLabel?.text else { return }
        model.add(argument: buttonTitle)
    }
    
    @IBAction func operationButtonTapped(_ sender: RoundedButton) {
        guard let buttonTitle = sender.titleLabel?.text else { return }
        model.add(operation: buttonTitle)
    }
    
    @IBAction func equalButtonTapped(_ sender: RoundedButton) {
        setAllButton(enabled: false)
        model.calculate()
    }
    
    @IBAction func eraseButtonTapped(_ sender: RoundedButton) {
        reset()
    }
    
    private func reset() {
        setAllButton(enabled: true)
        model.reset()
    }
    
    private func setAllButton(enabled: Bool) {
        allButtons.forEach { button in
            button.isEnabled = enabled
            button.layer.opacity = enabled ? Constant.enabledOpacity : Constant.disabledOpacity
        }
    }
}

// MARK: - CalculatorModelDelegate conformance
extension ViewController: CalculatorModelDelegate {
    func zero(wasSelected: Bool) {
        numberButtons.forEach { button in
            button.isEnabled = !wasSelected
            button.layer.opacity = wasSelected ? Constant.disabledOpacity : Constant.enabledOpacity
        }
    }
    
    func updateTitle(with title: String) {
        operationLabel.text = title
        eraseButton.isEnabled = true
        eraseButton.layer.opacity = Constant.enabledOpacity
    }
    
    func handleError(title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok",
                                        style: .cancel) { [weak self] _ in
            self?.reset()
        }
        
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
}

