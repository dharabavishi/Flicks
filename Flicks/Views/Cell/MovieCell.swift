//
//  MovieCell.swift
//  Flicks
//
//  Created by Ruchit Mehta on 10/13/16.
//  Copyright © 2016 Dhara Bavishi. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {

    @IBOutlet weak var imgPosterImage: UIImageView!
    
    @IBOutlet weak var lblOverview: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblOverview.sizeThatFits(lblOverview.frame.size)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
