//
//  TweetTableViewCell.swift
//  TaskApp
//
//  Created by Олег Максименко on 23.08.2018.
//  Copyright © 2018 Олег Максименко. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {

    //@IBOutlet weak var profile_image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var tweet_text: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
