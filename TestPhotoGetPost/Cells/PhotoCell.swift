//
//  PhotoCell.swift
//  TestPhotoGetPost
//
//  Created by Александр Молчан on 18.04.23.
//

import UIKit
import SnapKit
import SDWebImage

final class PhotoCell: UITableViewCell {
    static let id = String(describing: PhotoCell.self)
    private var currentPhoto: PhotoObject
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 17)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var photoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 5
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    init(currentPhoto: PhotoObject) {
        self.currentPhoto = currentPhoto
        super.init(style: .default, reuseIdentifier: PhotoCell.id)
        cellConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func cellConfiguration() {
        layoutElements()
        makeConstraints()
        setupData()
    }
    
    private func layoutElements() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(photoImage)
    }
    
    private func makeConstraints() {
        let imageInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        photoImage.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(imageInsets)
            make.width.equalTo(80)
            make.height.equalTo(80)
        }
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(photoImage.snp.trailing).inset(-16)
        }
    }
    
    private func setupData() {
        self.photoImage.image = UIImage(named: "NotFound")
        self.titleLabel.text = currentPhoto.name
        
        guard let imageUrl = currentPhoto.image else { return }
        photoImage.sd_setImage(with: URL(string: imageUrl))
    }
    
}
