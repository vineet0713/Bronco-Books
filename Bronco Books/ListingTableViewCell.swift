//
//  ListingTableViewCell.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 1/24/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import UIKit

class ListingTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var sellerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
