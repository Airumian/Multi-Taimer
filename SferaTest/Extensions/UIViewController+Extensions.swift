//
//  UIViewController+Extensions.swift
//  SferaTest
//
//  Created by Alexander Airumyan on 28.08.2021.
//

import UIKit

extension UIViewController {
	/// Автоматически скрывает клавиатуру при нажатии за пределами TextField
	func hideKeyboardWhenTappedAround(selectableView: UIView? = nil,
									  dismissMode: UIScrollView.KeyboardDismissMode = .onDrag) {
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		tap.cancelsTouchesInView = false
		guard let selectableView = selectableView ?? view else { return }
		selectableView.addGestureRecognizer(tap)
		
		let views = self.view.subviews
		for filterView in views {
			if filterView is UIScrollView {
				let scrollView = filterView as? UIScrollView
				scrollView?.keyboardDismissMode = dismissMode
			}
		}
	}
	
	/// Подписка на изменения позиции Inset TableView при появлении / скрытии клавиатуры
	func setupKeyboardNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIControl.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIControl.keyboardWillHideNotification, object: nil)
	}
}

// MARK: - Fileprivate Methods
fileprivate extension UIViewController {
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
	
	@objc func keyboardWillShow(_ notification: Notification) {
		let userInfo: NSDictionary = notification.userInfo! as NSDictionary
		let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
		let bottomInset = keyboardSize.height
		
		for subview in self.view.subviews {
			guard let tableView = subview as? UITableView else { continue }
			
			DispatchQueue.main.async {
				tableView.contentInset.bottom = bottomInset
				tableView.verticalScrollIndicatorInsets.bottom = bottomInset
			}
		}
	}
	
	@objc func keyboardWillHide(_ notification: Notification) {
		for subview in self.view.subviews {
			guard let tableView = subview as? UITableView else { continue }
			tableView.contentInset.bottom = .zero
			tableView.verticalScrollIndicatorInsets.bottom = .zero
		}
	}
}
