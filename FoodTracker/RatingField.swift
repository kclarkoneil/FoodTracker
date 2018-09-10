//
//  RatingField.swift
//  FoodTracker
//
//  Created by Kit Clark-O'Neil on 2018-09-08.
//  Copyright © 2018 Kit Clark-O'Neil. All rights reserved.
//

import UIKit
@IBDesignable class RatingField: UIStackView {

    private var ratingButtons = [UIButton]()
    var rating = 0 {
        didSet {
            updateButtonSelectionStates()
        }
    }
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var starCount = 5 {
        didSet {
            setupButtons()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
      
        setupButtons()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        setupButtons()
        
    }
    private func setupButtons() {
        
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "FilledStar", in: bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named:"EmptyStar", in: bundle, compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named:"HighlightedStar", in: bundle, compatibleWith: self.traitCollection)
    
        for index in 0..<starCount {
            let button = UIButton()
            
            button.accessibilityLabel = "set \(index + 1) star rating"
        
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for:. selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
            button.translatesAutoresizingMaskIntoConstraints = false
            let buttonHeightAnchor = button.heightAnchor.constraint(equalToConstant: starSize.height)
            let buttonWidthAnchor = button.widthAnchor.constraint(equalToConstant: starSize.width)
            button.addTarget(self, action:
                #selector(RatingField.ratingButtonTapped(button:)), for: .touchUpInside)
        
        buttonHeightAnchor.isActive = true
        buttonWidthAnchor.isActive = true
        
        addArrangedSubview(button)
        ratingButtons.append(button)
        
            
        }
        updateButtonSelectionStates()
    }
    @objc func ratingButtonTapped(button: UIButton) {
        guard let index = ratingButtons.index(of: button) else {
            fatalError("The button,\(button) is not in the ratingsButtons array: \(ratingButtons)")
        }
        let selectedRating = index + 1
        let hintString: String?
        
        if selectedRating == rating {
            
            hintString = "Tap to reset the rating to zero."
            rating = 0
            
        } else {
            hintString = nil
            rating = selectedRating
        }
        let valueString: String
        switch (rating) {
        case 0:
            valueString = "No rating set."
            
        case 1:
            valueString = "1 star set."
        
        default:
            valueString = "\(rating) stars set."
        }
        
        button.accessibilityHint = hintString
        button.accessibilityValue = valueString
    }
    private func updateButtonSelectionStates() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
}
