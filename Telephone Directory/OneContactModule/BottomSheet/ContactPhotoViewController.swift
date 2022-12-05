//
//  ContactPhotoViewController.swift
//  Telephone Directory
//
//  Created by Diana Princess on 04.12.2022.
//

import Foundation
import UIKit
import SnapKit
final class ContactPhotoViewController: BottomSheetController{
    let photoImageView: UIImageView = {
        let imgV = UIImageView()
        imgV.contentMode = .scaleAspectFit
        return imgV
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configure(photo: UIImage){
        photoImageView.image = photo
        view.addSubview(photoImageView)
        setUpConstraints()
    }
    func setUpConstraints(){
        photoImageView.snp.makeConstraints{ (maker) in
            maker.edges.equalToSuperview()
        }
    }
}
