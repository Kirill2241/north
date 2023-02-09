//
//  ContactTableViewCell.swift
//  Telephone Directory
//
//  Created by Diana Princess on 30.11.2022.
//

import UIKit
import SnapKit

class ContactTableViewCell: UITableViewCell {
    private let contactPhotoImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        imgView.layer.cornerRadius = 15
        return imgView
    }()
    private let fullNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.font = UIFont.systemFont(ofSize: 16)
        return lbl
    }()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    static let reuseId = "reuseId"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        placeSubviews()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func placeSubviews() {
        contentView.addSubview(contactPhotoImageView)
        contentView.addSubview(fullNameLabel)
        activityIndicator.hidesWhenStopped = true
        contactPhotoImageView.addSubview(activityIndicator)
    }
    
    private func setUpConstraints() {
        contactPhotoImageView.snp.makeConstraints{ (maker) in
            maker.top.equalToSuperview().offset(10)
            maker.leading.equalToSuperview().offset(15)
            maker.width.height.equalTo(30)
        }
        fullNameLabel.snp.makeConstraints{ (maker) in
            maker.top.equalToSuperview().offset(15)
            maker.leading.equalTo(contactPhotoImageView.snp.trailing).offset(10)
            maker.height.equalTo(20)
            maker.trailing.equalToSuperview().inset(10)
        }
        activityIndicator.snp.makeConstraints{ (maker) in
            maker.centerX.equalToSuperview()
            maker.centerY.equalToSuperview()
        }
    }
    
    func configure(fullName: String, photo: UIImage, photoStatus: ContactThumbnailState) {
        contactPhotoImageView.image = photo
        fullNameLabel.text = fullName
        (photoStatus == .notDownloaded) ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
}
