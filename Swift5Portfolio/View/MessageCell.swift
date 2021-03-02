//
//  MessageCell.swift
//  Swift5Portfolio
//
//  Created by 野入隆史 on 2020/12/17.
//  Copyright © 2020 野入隆史. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var sender: UILabel!    
    @IBOutlet weak var backGroungView: UIView!
    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var myMessageTextLabel: UILabel!
    @IBOutlet weak var opponentTimeLabel: UILabel!
    @IBOutlet weak var myTimeLabel: UILabel!
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = .groupTableViewBackground
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
