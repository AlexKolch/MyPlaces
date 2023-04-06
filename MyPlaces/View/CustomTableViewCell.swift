//
//  CustomTableViewCell.swift
//  MyPlaces
//
//  Created by Алексей Колыченков on 31.03.2023.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {

    @IBOutlet var imageOfPlaces: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet weak var cosmosView: CosmosView!

    func configureCell() {
        imageOfPlaces.layer.cornerRadius = imageOfPlaces.frame.size.height / 2
        imageOfPlaces.clipsToBounds = true

        cosmosView.settings.updateOnTouch = false
        cosmosView.backgroundColor = .clear
    }
}
