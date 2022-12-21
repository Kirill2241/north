//
//  ContactTableViewCell.swift
//  Telephone Directory
//
//  Created by Diana Princess on 30.11.2022.
//

import UIKit
import SnapKit

class ContactTableViewCell: UITableViewCell {

    
    let contactPhotoImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        imgView.layer.cornerRadius = 20
        return imgView
    }()
    
    let fullNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.font = UIFont.systemFont(ofSize: 16)
        return lbl
    }()
    static let reuseId = "reuseId"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        placeSubviews()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func placeSubviews() {
        contentView.addSubview(contactPhotoImageView)
        contentView.addSubview(fullNameLabel)
    }
    
    func setUpConstraints(){
        contactPhotoImageView.snp.makeConstraints{ (maker) in
            maker.top.equalToSuperview().offset(10)
            maker.leading.equalToSuperview().offset(15)
            maker.width.height.equalTo(40)
        }
        fullNameLabel.snp.makeConstraints{ (maker) in
            maker.top.equalToSuperview().offset(20)
            maker.leading.equalTo(contactPhotoImageView.snp.trailing).offset(10)
            maker.height.equalTo(20)
            maker.trailing.equalToSuperview().inset(10)
        }
    }
    
    func configure(fullName: String, photo: UIImage) {
        contactPhotoImageView.image = photo
        fullNameLabel.text = fullName
    }

}
