//
//  CustomModalViewController.swift
//  Telephone Directory
//
//  Created by Diana Princess on 07.12.2022.
//

import UIKit
import SnapKit
class CustomModalViewController: UIViewController {

    lazy var containerView: UIView = {
            let view = UIView()
            view.backgroundColor = .white
            view.layer.cornerRadius = 16
            view.clipsToBounds = true
            return view
        }()
        
        let maxDimmedAlpha: CGFloat = 0.6
        lazy var dimmedView: UIView = {
            let view = UIView()
            view.backgroundColor = .black
            view.alpha = maxDimmedAlpha
            return view
        }()
    lazy var photoImageView: UIImageView = {
        let imgV = UIImageView()
        imgV.contentMode = .scaleAspectFit
        return imgV
    }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupView()
            setupConstraints()
        }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePresentContainer()
        animateShowDimmedView()
    }
        
        func setupView() {
            view.backgroundColor = .clear
            view.addSubview(dimmedView)
            view.addSubview(containerView)
        }
        
    func addImage(image: UIImage){
        DispatchQueue.main.async {
            self.photoImageView.image = image
            self.photoImageView.isUserInteractionEnabled = true
            let cancelTap = UITapGestureRecognizer(target: self, action: #selector(self.cancelView(_:)))
            self.photoImageView.addGestureRecognizer(cancelTap)
            self.containerView.addSubview(self.photoImageView)
            self.photoImageView.snp.makeConstraints{ (maker) in
                maker.edges.equalToSuperview()
            }
        }
    }
    
        func setupConstraints() {
            dimmedView.snp.makeConstraints{ (maker) in
                maker.edges.equalToSuperview()
            }
            containerView.snp.makeConstraints{ (maker) in
                maker.horizontalEdges.equalToSuperview()
                maker.height.equalToSuperview().offset(64)
                maker.bottom.equalToSuperview().offset(view.frame.height-64)
            }
        }
    
    func animatePresentContainer() {
        UIView.animate(withDuration: 0.3) {
            self.containerView.snp.remakeConstraints{ (maker) in
                maker.horizontalEdges.equalToSuperview()
                maker.height.equalToSuperview().offset(64)
                maker.bottom.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }
    }
    
    func animateShowDimmedView() {
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = self.maxDimmedAlpha
        }
    }
    
    func animateDismissView() {
        UIView.animate(withDuration: 0.3) {
            self.containerView.snp.remakeConstraints{ (maker) in
                maker.horizontalEdges.equalToSuperview()
                maker.height.equalToSuperview().offset(64)
                maker.bottom.equalToSuperview().offset(self.view.frame.height-64)
            }
            self.view.layoutIfNeeded()
        }
        dimmedView.alpha = maxDimmedAlpha
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
    
    @objc func cancelView(_ sender: UITapGestureRecognizer){
        animateDismissView()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
