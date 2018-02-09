//
//  FoodEditorVC.swift
//  OxalateMate
//
//  Created by Justin Erickson on 2/8/18.
//  Copyright © 2018 Justin Erickson. All rights reserved.
//

import UIKit
import CoreData

class FoodEditorVC: UIViewController {
    
    // MARK: Types
    
    private enum FoodEditorState {
        case editing
        case adding
    }
    
    // MARK: Constants
    
    private enum Constants {
        static let AlternativesText = "Optionally list some foods that you might enjoy eating in place of the above food."
    }
    
    // MARK: Properties
    
    @IBOutlet weak var alternativesTextView: UITextView!
    
    @IBOutlet weak var foodNameTextField: UITextField! {
        didSet {
            let textFieldPadding = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: foodNameTextField.frame.height))
            foodNameTextField.leftView = textFieldPadding
            foodNameTextField.leftViewMode = .always
        }
    }
    
    @IBOutlet var oxalateButtons: [OxalateRadioButton]! {
        didSet {
            self.oxalateRadioButtons = RadioButtons(buttons: oxalateButtons)
        }
    }
    
    var foodDataManager: FoodDataManager?
    var oxalateRadioButtons: RadioButtons<OxalateRadioButton>?
    
    var foodItem: FoodItem? {
        didSet {
            if let foodItem = foodItem {
                self.configureView(forEditing: foodItem)
            }
        }
    }
    
    private var editorState: FoodEditorState {
        if let _ = self.foodItem {
            return .editing
        }
        return .adding
    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    // MARK: Setup
    
    private func setupView() {
        foodNameTextField.becomeFirstResponder()
        alternativesTextView.delegate = self
        
        if editorState == .adding {
            alternativesTextView.text = Constants.AlternativesText
        }
    }
    
    // MARK: Configuration
    
    private func configureView(forEditing foodItem: FoodItem) {
        self.foodNameTextField.text = foodItem.nameString
        self.oxalateRadioButtons!.selectButton(at: Int(foodItem.content))
        self.alternativesTextView.text = foodItem.alternatives
        self.foodNameTextField.becomeFirstResponder()
        self.title = "Edit Food"
    }
    
    // MARK: Actions

    @IBAction func submit(_ sender: Any) {
        switch editorState {
        case .adding:
            saveNewFoodItem()
        case .editing:
            updateFoodItem()
        }
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func radioButtonTapped(_ sender: OxalateRadioButton) {
        let content = sender.tag
        oxalateRadioButtons?.selectButton(at: content)
    }
    
    // MARK: Convenience
    
    private func saveNewFoodItem() {
        guard let name = foodNameTextField.text, !name.isEmpty else { return }
        guard let content = oxalateRadioButtons?.selectedIndex else { return }
        guard var alternatives = alternativesTextView.text else { return }
        if alternatives == Constants.AlternativesText { alternatives = "" }
        
        foodDataManager?.addFoodItem(name: name, content: content, alternatives: alternatives)
    }
    
    private func updateFoodItem() {
        guard let foodItem = self.foodItem else { return }
        
        if let name = foodNameTextField.text, !name.isEmpty && foodItem.name != name {
            foodItem.name = name
        }
        
        if let content = oxalateRadioButtons?.selectedIndex {
            foodItem.content = Int16(content)
        }
        
        if let alternatives = alternativesTextView.text, foodItem.alternatives != alternatives {
            foodItem.alternatives = alternatives
        }
    }
}

// MARK:- UITextViewDelegate

extension FoodEditorVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
}
