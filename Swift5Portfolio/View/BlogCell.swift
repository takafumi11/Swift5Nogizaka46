//
//  BlogCell.swift
//  Swift5Portfolio
//
//  Created by 野入隆史 on 2020/12/11.
//  Copyright © 2020 野入隆史. All rights reserved.
//

import UIKit

class BlogCell: UITableViewCell {

    @IBOutlet weak var face: UIImageView!
    @IBOutlet weak var blogTitle: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var upDate: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var blogImageView: UIImageView!
    
    @IBOutlet weak var bgView: UIView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
