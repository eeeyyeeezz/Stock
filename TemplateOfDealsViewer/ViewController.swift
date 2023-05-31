import UIKit

enum SortSide {
	case date
	case instrument
	case price
	case amount
	case side
}


class ViewController: UIViewController {
	private let server = Server()
	private lazy var instrumentNames = server.instrumentNames
	private var models: [Deal] = []
	@IBOutlet weak var tableView: UITableView!
	private var sortSide: SortSide = .date
	private var sortOrder: ComparisonResult = .orderedAscending
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.title = "Deals"

		tableView.register(UINib(nibName: DealCell.reuseIidentifier, bundle: nil),
						   forCellReuseIdentifier: DealCell.reuseIidentifier)
		tableView.register(UINib(nibName: HeaderCell.reuseIidentifier, bundle: nil),
						   forHeaderFooterViewReuseIdentifier: HeaderCell.reuseIidentifier)
		tableView.dataSource = self
		tableView.delegate = self
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sort",
															style: .plain,
															target: self,
															action: #selector(sortButtonTapped))
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "SortSide",
															style: .plain,
															target: self,
															action: #selector(changeSortSide))

		server.subscribeToDeals { [weak self] deals in
			guard let self = self else { return }
			DispatchQueue(label: "Aboba").async { [weak self] in
				guard let self = self else { return }
				models.append(contentsOf: deals)
				sortDataByDate()
				DispatchQueue.main.async {
					self.tableView.reloadData()
					debugPrint("NEW VALUE")
				}
			}
		}
	}
	
	@objc func sortButtonTapped() {
		let alert = UIAlertController(title: "Sort by",
									  message: nil,
									  preferredStyle: UIAlertController.Style.alert)

		alert.addAction(UIAlertAction(title: "Date", style: UIAlertAction.Style.default, handler: { [weak self] _ in
			self?.sortSide = .date
		}))
		
		alert.addAction(UIAlertAction(title: "Instrument", style: UIAlertAction.Style.default, handler: { [weak self] _ in
			self?.sortSide = .instrument
		}))
		
		alert.addAction(UIAlertAction(title: "Amount", style: UIAlertAction.Style.default, handler: { [weak self] _ in
			self?.sortSide = .amount
		}))
		
		alert.addAction(UIAlertAction(title: "Price", style: UIAlertAction.Style.default, handler: { [weak self] _ in
			self?.sortSide = .price
		}))
		
		alert.addAction(UIAlertAction(title: "Side", style: UIAlertAction.Style.default, handler: { [weak self] _ in
			self?.sortSide = .side
		}))
		
		// show the alert
		self.present(alert, animated: true, completion: nil)
	}
	
	@objc private func changeSortSide() {
		sortOrder = (sortOrder == .orderedAscending) ? .orderedDescending : .orderedAscending
	}
	
	// Сортировка
	private func sortDataByDate() {
		print(models.count)
		if sortSide == .date {
			models = (sortOrder == .orderedAscending) ?
			models.sorted { $0.dateModifier > $1.dateModifier } : models.sorted { $0.dateModifier < $1.dateModifier }
		} else if sortSide == .instrument {
			models = (sortOrder == .orderedAscending) ?
			models.sorted(by: { instrumentNames.firstIndex(of: $0.instrumentName)! < instrumentNames.firstIndex(of: $1.instrumentName)! })
			: models.sorted(by: { instrumentNames.firstIndex(of: $0.instrumentName)! > instrumentNames.firstIndex(of: $1.instrumentName)! })
		} else if sortSide == .amount {
			models = (sortOrder == .orderedAscending) ?
			models.sorted { $0.amount > $1.amount } : models.sorted { $0.amount < $1.amount }
		} else if sortSide == .price {
			models = (sortOrder == .orderedAscending) ?
			models.sorted { $0.price > $1.price } : models.sorted { $0.price < $1.price }
		} else if sortSide == .side {
			models = (sortOrder == .orderedAscending) ?
			models.filter { $0.side == .buy } : models.filter { $0.side == .sell }
		}
	}
	
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
	func numberOfSections(in tableView: UITableView) -> Int { 1 }
  
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { models.count }
  
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: DealCell.reuseIidentifier, for: indexPath) as! DealCell
		if cell.deal == nil, indexPath.row < models.count {
		  cell.deal = models[indexPath.row]
		}
		return cell
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderCell.reuseIidentifier) as! HeaderCell
		return cell
	}
	
}

