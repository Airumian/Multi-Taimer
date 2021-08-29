//
//  TimerTableViewCell.swift
//  SferaTest
//
//  Created by Alexander Airumyan on 28.08.2021.
//

import UIKit

class TimerTableViewCell: UITableViewCell {
	
	// MARK: - Callbacks
	
	var onTimerChanged: ((_ counter: Int) -> Void)?
	
	// MARK: - Private Properties
	
	private var titleLabel = UILabel()
	private var timerLabel = UILabel()
	
	// MARK: - Initialization
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		setupConstraints()
		
		backgroundColor = .white
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Internal Methods
	
	func configure(title: String, seconds: Int) {
		let (_,m,s) = secondsToHoursMinutesSeconds(seconds: Double(seconds))
		let timerMinutes = Int(m)
		let timerSeconds = Int(s)
		titleLabel.text = title
		timerLabel.text = "\(timerMinutes) : \(timerSeconds)"
	}
}

// MARK: - Private Methods
private extension TimerTableViewCell {
	func setupConstraints() {
		[titleLabel,
		 timerLabel
		].forEach {
			contentView.addSubview($0)
			$0.translatesAutoresizingMaskIntoConstraints = false
		}
		
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor,
											constant: 8),
			titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
												constant: 16),
			titleLabel.trailingAnchor.constraint(equalTo: timerLabel.leadingAnchor,
												 constant: -16),
			titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
											   constant: -8),
			timerLabel.topAnchor.constraint(equalTo: contentView.topAnchor,
											constant: 8),
			timerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
												 constant: -16),
			timerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
											   constant: -8),
			timerLabel.widthAnchor.constraint(equalToConstant: 100)
		])
	}
	
	func secondsToHoursMinutesSeconds (seconds : Double) -> (Double, Double, Double) {
	  let (hr,  minf) = modf (seconds / 3600)
	  let (min, secf) = modf (60 * minf)
	  return (hr, min, 60 * secf)
	}
}
