//
//  TextFieldTableViewCell.swift
//  SferaTest
//
//  Created by Alexander Airumian on 28.08.2021.
//

import UIKit

/// Ячейка с закругленным текстовым полем
class TextFieldTableViewCell: UITableViewCell {
	
	// MARK: - Callbacks
	
	var onTextEnter: ((_ text: String?) -> Void)?
	
	// MARK: - Private Properties
	
	/// Label заголовка
	private let titleLabel = UILabel()
	/// Label плейсхолдера
	private let placeholderLabel = UILabel()
	/// Основной TextField
	private let textField = UITextField()
	/// Граница TextField
	private let textFieldBorderView = UIView()
	
	// MARK: - Initialization
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		selectionStyle = .none
		setupConstraints()
		setupTextFieldBorderView()
		addDoneButtonOnKeyboard()
		
		textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
		
		backgroundColor = .white
	}
	
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Internal Methods
	
	func configure(placeholder: String,
				   keyboardType: UIKeyboardType = .default) {
		textField.placeholder = placeholder
		textField.keyboardType = keyboardType
		textField.text = nil
	}
}

// MARK: - Private Methods
private extension TextFieldTableViewCell {
	func setupConstraints() {
		[titleLabel,
		 placeholderLabel,
		 textField,
		 textFieldBorderView
		].forEach { customView in
			contentView.addSubview(customView)
			customView.translatesAutoresizingMaskIntoConstraints = false
		}
		
		NSLayoutConstraint.activate([
			textFieldBorderView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
			textFieldBorderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
														 constant: 24),
			textFieldBorderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
														  constant: -24),
			textFieldBorderView.heightAnchor.constraint(equalToConstant: 76),
			textFieldBorderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
														constant: -8),
			
			titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
			titleLabel.leadingAnchor.constraint(equalTo: textFieldBorderView.leadingAnchor,
												constant: 16),
			titleLabel.trailingAnchor.constraint(equalTo: textFieldBorderView.trailingAnchor,
												 constant: -5),
			
			placeholderLabel.topAnchor.constraint(equalTo: textFieldBorderView.topAnchor,
												  constant: 28.5),
			placeholderLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
			placeholderLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
			placeholderLabel.bottomAnchor.constraint(equalTo: textFieldBorderView.bottomAnchor,
													 constant: -24.5),
			
			textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
			textField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
			textField.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
			textField.bottomAnchor.constraint(equalTo: textFieldBorderView.bottomAnchor,
											  constant: -15)
		])
	}
	
	func setupTextFieldBorderView() {
		textFieldBorderView.layer.cornerRadius = 16
		textFieldBorderView.layer.borderWidth = 0.5
		textFieldBorderView.layer.borderColor = UIColor.gray.cgColor
		addTouchBorderViewAction()
	}
	
	func addDoneButtonOnKeyboard() {
		let doneToolbar = UIToolbar(frame: .init(x: 0, y: 0,
												 width: UIScreen.main.bounds.width,
												 height: 50))
		doneToolbar.barStyle = .default
		
		let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		let doneItem = UIBarButtonItem(title: "Готово",
									   style: .done,
									   target: self,
									   action: #selector(doneButtonAction))
		
		let items = [flexSpace, doneItem]
		doneToolbar.items = items
		doneToolbar.sizeToFit()
		
		textField.inputAccessoryView = doneToolbar
	}
	
	@objc func doneButtonAction(){
		textField.resignFirstResponder()
	}
	
	func addTouchBorderViewAction() {
		let gesture = UITapGestureRecognizer(target: self, action: #selector(borderViewTapped))
		addGestureRecognizer(gesture)
	}
	
	@objc func borderViewTapped(_ sender: UIView) {
		guard !textField.isFirstResponder else { return }
		textField.becomeFirstResponder()
	}
	
	@objc func textFieldDidChange(_ textField: UITextField) {
		onTextEnter?(textField.text)
	}
}
