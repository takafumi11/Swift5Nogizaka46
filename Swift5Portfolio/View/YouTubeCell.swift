//
//  YouTubeCell.swift
//  Swift5Portfolio
//
//  Created by 野入隆史 on 2020/12/13.
//  Copyright © 2020 野入隆史. All rights reserved.
//

import UIKit

class YouTubeCell: UITableViewCell {

    
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var bgView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        contentView.backgroundColor = .groupTableViewBackground
        bgView.layer.cornerRadius = 20.0
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
