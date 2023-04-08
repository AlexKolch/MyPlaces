//
//  RaitingControl.swift
//  MyPlaces
//
//  Created by Алексей Колыченков on 04.04.2023.
//

import UIKit

class RaitingControl: UIStackView {
    // MARK: - Properties
    private var ratingButtonsArray = [UIButton]()

    var rating = 0 {
        didSet {
            updateSelectedButtonImage()
        }
    }

    var starSize = CGSize(width: 44, height: 44)

    var starCount = 5

  // MARK: - Initialization

   override init(frame: CGRect){
       super.init(frame: frame)
       setupButtons()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    // MARK: - Method
    @objc func ratingTapButton(button: UIButton){
        //находим индекс кнопки из массива
        guard let index = ratingButtonsArray.firstIndex(of: button) else {return}

        //Определяем рейтинг в соотв. с button
        let selectedRating = index + 1

        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }

    private func setupButtons() {
        //load image button
        let filledStar = #imageLiteral(resourceName: "filledStar")
        let emptyStar = #imageLiteral(resourceName: "emptyStar")
        let highlighterStar = #imageLiteral(resourceName: "highlightedStar")

//create buttons
        for _ in 0..<starCount {
            let button = UIButton()
//set the button image
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlighterStar, for: .highlighted)
            button.setImage(highlighterStar, for: [.highlighted, .selected])
//Constraints
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
//Button Action
            button.addTarget(self, action: #selector(ratingTapButton), for: .touchUpInside)
//Add StackView
            addArrangedSubview(button)
//Add in Array
            ratingButtonsArray.append(button)
        }
    }
//логика отображения звезд рейтинга!
    private func updateSelectedButtonImage() {
        for (index, button) in ratingButtonsArray.enumerated() {
            button.isSelected = index < rating
        }
    }
}
