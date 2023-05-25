import UIKit

class ViewController: UIViewController {
	private let server = Server()
	private var models: [Deal] = []
	@IBOutlet weak var tableView: UITableView!
	private var sortSide: ComparisonResult = .orderedDescending
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.title = "Deals"

		tableView.register(UINib(nibName: DealCell.reuseIidentifier, bundle: nil),
						   forCellReuseIdentifier: DealCell.reuseIidentifier)
		tableView.register(UINib(nibName: HeaderCell.reuseIidentifier, bundle: nil),
						   forHeaderFooterViewReuseIdentifier: HeaderCell.reuseIidentifier)
		tableView.dataSource = self
		tableView.delegate = self
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Rotate",
															style: .done,
															target: self,
															action: #selector(sortButtonTapped))

		server.subscribeToDeals { [weak self] deals in
			guard let self = self else { return }
			DispatchQueue(label: "Aboba").async { [weak self] in
				guard let self = self else { return }
				sortDataByDate()
				models.append(contentsOf: deals)
				DispatchQueue.main.async {
					self.tableView.reloadData()
					debugPrint("NEW VALUE")
				}
			}
		}
	}
	
	@objc private func sortButtonTapped() {
		sortSide = (sortSide == .orderedDescending) ? .orderedAscending : .orderedDescending
	}
	
	private func sortDataByDate() {
		print(models.count)
		if sortSide == .orderedDescending {
			let sortedDeals = models.sorted { $0.dateModifier > $1.dateModifier }
			models = sortedDeals
			models = models.sorted(by: { $0.price > $1.price })
			models = models.sorted(by: { $0.amount > $1.amount })
		} else {
			let sortedDeals = models.sorted { $0.dateModifier < $1.dateModifier }
			models = sortedDeals
			models = models.sorted(by: { $0.price < $1.price })
			models = models.sorted(by: { $0.amount < $1.amount })
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

