//
//  ContactTableViewCell.swift
//  GrainChainExam
//
//  Created by Raúl Torres on 18/10/18.
//  Copyright © 2018 Raúl Torres. All rights reserved.
//

import UIKit
import Kingfisher

class ContactTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    var contact : ContactModel!  {
        didSet {
            
            //TODO: - PROCESS IMAGE
            
            if let imageURL = contact.imageStr as? String {
                guard let url = URL(string: imageURL) else { return }
                let processor = RoundCornerImageProcessor(cornerRadius: 20)
                
                self.contactImageView.kf.indicatorType = .activity
                self.contactImageView.kf.setImage(with: url, options: [.processor(processor)])
            }
            
            if let imageFile = contact.imageStr as? UIImage {
                self.contactImageView.image = imageFile
                self.contactImageView.layer.cornerRadius = 20
            }
            
            
            self.nameLabel.text = "Name: " + contact.name
            self.lastNameLabel.text = "Last name: " + contact.lastName
            self.ageLabel.text = "Age: " + contact.age
            self.phoneLabel.text = "Phone: " + contact.phone
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
