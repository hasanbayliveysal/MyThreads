//
//  CenterInputButtonView.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 19.07.24.
//

import UIKit

class CenterInputButtonView: UIView {
    var postButtunTapped: ((String?) -> Void)?
    private let stackView: HStack = {
        let stackView = HStack()
        stackView.distribution = .fill
        return stackView
    }()
    
    private let inputTextField: UITextField = {
        let tf = UITextField()
        tf.autocorrectionType = .no
        tf.textColor = .black
        tf.backgroundColor = .white
        tf.placeholder = "writereplieshere".localized()
        return tf
    }()
    
    private let postButton: UIButton = {
        let button = UIButton()
        button.setTitle("post".localized(), for: .normal)
        button.setTitleColor( UIColor.systemBlue, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        clipsToBounds = true
        layer.cornerRadius = 8
        layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
        layer.borderWidth = 1
        addSubview(stackView)
        [inputTextField, postButton].forEach({stackView.addArrangedSubview($0)})

        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(safeAreaLayoutGuide).inset(16)
            make.top.bottom.equalTo(safeAreaLayoutGuide)
        }
        
        postButton.addTarget(self, action: #selector(didTapPostButton), for: .touchUpInside)
    }
    
    @objc
    private func didTapPostButton() {
        guard let text = inputTextField.text,
              !text.isEmpty else {
            postButtunTapped?(nil)
            return
        }
        postButtunTapped?(text)
    }
    
}
