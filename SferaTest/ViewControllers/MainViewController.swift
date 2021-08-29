//
//  MainViewController.swift
//  SferaTest
//
//  Created by Alexander Airumyan on 28.08.2021.
//

import UIKit

class MainViewController: UIViewController {
	
	// MARK: - Private Properties
	
	private let tableView = UITableView(frame: .zero, style: .grouped)
	
	var isTimerEnabled = false
	
	var timer: Timer?
	var timerTitle: String?
	var timerSeconds: Int?
	
	private var timers: [CustomTimer] = [] {
		didSet {
			timer?.invalidate()
			fireTimer()
		}
	}
	
	// MARK: - Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupConstraints()
		setupTableView()
		hideKeyboardWhenTappedAround()
		
		
		title = "Мульти таймер"
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupKeyboardNotifications()
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}

// MARK: - Private Methods
private extension MainViewController {
	func setupConstraints() {
		[tableView].forEach { customView in
			view.addSubview(customView)
			customView.translatesAutoresizingMaskIntoConstraints = false
		}
		
		NSLayoutConstraint.activate([
			
			tableView.topAnchor.constraint(equalTo: view.topAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}
	
	func setupTableView() {
		tableView.dataSource = self
		tableView.delegate = self
		registerCells()
	}
	
	func registerCells() {
		tableView.register(TextFieldTableViewCell.self,
						   forCellReuseIdentifier: "TextFieldTableViewCell")
		tableView.register(MainButtonTableViewCell.self,
						   forCellReuseIdentifier: "MainButtonTableViewCell")
		tableView.register(TimerTableViewCell.self,
						   forCellReuseIdentifier: "TimerTableViewCell")
	}
	
	func getTitleTextFieldCell(placeholder: String,
							   indexPath: IndexPath) -> TextFieldTableViewCell {
		guard let cell = tableView.dequeueReusableCell(
				withIdentifier: "TextFieldTableViewCell",
				for: indexPath) as? TextFieldTableViewCell
		else { return TextFieldTableViewCell() }
		
		let keyboardType: UIKeyboardType = .default
		
		cell.configure(placeholder: placeholder,
					   keyboardType: keyboardType)
		cell.onTextEnter = { text in
			self.timerTitle = text
			self.tableView.reloadSections([1], with: .automatic)
		}
		
		return cell
	}
	
	func getSecondsTextFieldCell(placeholder: String,
								 indexPath: IndexPath) -> TextFieldTableViewCell {
		guard let cell = tableView.dequeueReusableCell(
				withIdentifier: "TextFieldTableViewCell",
				for: indexPath) as? TextFieldTableViewCell
		else { return TextFieldTableViewCell() }
		
		let keyboardType: UIKeyboardType = .numberPad
		
		cell.configure(placeholder: placeholder,
					   keyboardType: keyboardType)
		cell.onTextEnter = { text in
			self.timerSeconds = Int(text ?? "0")
			self.tableView.reloadSections([1], with: .automatic)
		}
		
		return cell
	}
	
	func getAddTimerButtonCell(indexPath: IndexPath) -> MainButtonTableViewCell {
		guard let cell = tableView.dequeueReusableCell(
				withIdentifier: "MainButtonTableViewCell",
				for: indexPath) as? MainButtonTableViewCell
		else { return MainButtonTableViewCell() }
		
		let isEnabled = timerTitle != nil && timerSeconds != nil
		
		cell.configure(title: "Добавить", isEnabled: isEnabled)
		
		cell.onButtonTouched = {
			guard let timerTitle = self.timerTitle,
				  let timerSeconds = self.timerSeconds
			else { return }
			
			let timer = CustomTimer(title: timerTitle,
									seconds: timerSeconds)
			
			self.timers.insert(timer, at: 0)
			self.timers.sort(by: { $0.seconds > $1.seconds })
			self.timerTitle = nil
			self.timerSeconds = nil
			self.tableView.reloadData()
		}
		
		return cell
	}
	
	func getTimerCell(indexPath: IndexPath) -> TimerTableViewCell {
		guard let cell = tableView.dequeueReusableCell(
				withIdentifier: "TimerTableViewCell",
				for: indexPath) as? TimerTableViewCell
		else { return TimerTableViewCell() }
		
		let timer = timers[indexPath.row]
		
		cell.configure(title: timer.title,
					   seconds: timer.seconds)
		
		cell.onTimerChanged = { [weak self] counter in
			self?.timers [indexPath.row].seconds = counter
		}
		
		return cell
	}
	
	func getStopAllTimersButtonCell(indexPath: IndexPath) -> MainButtonTableViewCell {
		guard let cell = tableView.dequeueReusableCell(
				withIdentifier: "MainButtonTableViewCell",
				for: indexPath) as? MainButtonTableViewCell
		else { return MainButtonTableViewCell() }
		
		let title = isTimerEnabled ? "Остановить" : "Возобновить"
		
		cell.configure(title: title, isEnabled: true)
		
		cell.onButtonTouched = { [weak self] in
			if self?.isTimerEnabled ?? false {
				self?.timer?.invalidate()
				self?.isTimerEnabled = false
			} else {
				self?.fireTimer()
			}
			
			self?.tableView.reloadSections([3], with: .automatic)
		}
		
		return cell
	}
	
	func fireTimer() {
		timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
			var needsRestartTimer = false
			guard let self = self else { return }
			for (index, _) in self.timers.enumerated() {
				guard self.timers[index].seconds >= 1 else {
					needsRestartTimer = true
					continue
				}
				
				self.timers[index].seconds -= 1
			}
			
			self.tableView.reloadSections([2], with: .automatic)
			
			if needsRestartTimer {
				self.restartTimer()
			}
		}
		
		isTimerEnabled = true
	}
	
	func restartTimer() {
		timer?.invalidate()
		
		for (index, customTimer) in self.timers.enumerated() {
			if customTimer.seconds <= 1 {
				self.timers.remove(at: index)
			}
		}
		
		
//		self.tableView.reloadSections([2], with: .automatic)
		self.tableView.reloadData()
		fireTimer()
	}
}

//MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 4
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 2
		case 1:
			return 1
		case 3:
			return timers.count > 0 ? 1 : 0
		default:
			return timers.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch (indexPath.section, indexPath.row) {
		case (0, 0):
			return getTitleTextFieldCell(placeholder: "Название таймера",
										 indexPath: indexPath)
		case (0, 1):
			return getSecondsTextFieldCell(placeholder: "Время в секундах",
										   indexPath: indexPath)
		case (1, 0):
			return getAddTimerButtonCell(indexPath: indexPath)
		case (3, 0):
			return getStopAllTimersButtonCell(indexPath: indexPath)
		default:
			return getTimerCell(indexPath: indexPath)
		}
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			return "Добавление таймеров"
		case 2:
			return timers.isEmpty ? nil : "Таймеры"
		default:
			return nil
		}
	}
}

// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return section == 1 ? .leastNonzeroMagnitude : UITableView.automaticDimension
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return section == 0 || section == 1 ? .leastNonzeroMagnitude : UITableView.automaticDimension
	}
}
