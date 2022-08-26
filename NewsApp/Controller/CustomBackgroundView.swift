//
//  CustomBAckgroundView.swift
//  NewsApp
//
//  Created by valters.steinblums on 26/08/2022.
//
// https://stackoverflow.com/questions/53420760/safe-area-layout-guide-not-working-on-uitableviews-backgroundview
import UIKit

class CustomBackgroundView: UIView {
    
    var safetyAreaTopAnchor: NSLayoutYAxisAnchor? {
            didSet {
                guard let safetyAreaTopAnchor = safetyAreaTopAnchor else { return }
                image.topAnchor.constraint(equalTo: safetyAreaTopAnchor).isActive = true
            }
        }

    var safetyAreaBottomAnchor: NSLayoutYAxisAnchor? {
            didSet {
                guard let safetyAreaBottomAnchor = safetyAreaBottomAnchor else { return }
                image.bottomAnchor.constraint(equalTo: safetyAreaBottomAnchor).isActive = true
            }
        }

    var safetyLeadingAnchor: NSLayoutXAxisAnchor? {
            didSet {
                guard let safetyLeadingAnchor = safetyLeadingAnchor else { return }
                image.leadingAnchor.constraint(equalTo: safetyLeadingAnchor).isActive = true
            }
        }

    var safetyTrailingAnchor: NSLayoutXAxisAnchor? {
            didSet {
                guard let safetyTrailingAnchor = safetyTrailingAnchor else { return }
                image.trailingAnchor.constraint(equalTo: safetyTrailingAnchor).isActive = true
            }
        }

        private let image = UIImageView()

        override init(frame: CGRect) {
            super.init(frame: frame)
            setupSubviews()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setupSubviews() {
            image.image = UIImage(named: "empty")
            image.translatesAutoresizingMaskIntoConstraints = false

            addSubview(image)
        }
}
