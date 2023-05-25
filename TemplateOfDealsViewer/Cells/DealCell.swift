import UIKit

class DealCell: UITableViewCell {

	var deal: Deal?
	static let reuseIidentifier = "DealCell"
  
	@IBOutlet weak var dealDate: UILabel!
	@IBOutlet weak var instrumentNameLabel: UILabel!
	@IBOutlet weak var priceLabel: UILabel!
	@IBOutlet weak var amountLabel: UILabel!
	@IBOutlet weak var sideLabel: UILabel!

	override func layoutSubviews() {
		super.layoutSubviews()
		
		guard let deal = deal else { return }
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "HH:mm:ss dd.MM.yyyy"
		let stringDate = dateFormatter.string(from: deal.dateModifier)
		
		dealDate.text = stringDate
		instrumentNameLabel.text = deal.instrumentName
		priceLabel.text = "\(deal.price.rounded(toPlaces: 2))"
		amountLabel.text = "\(deal.amount.rounded(.toNearestOrEven))"
		switch deal.side {
		case .buy:
			sideLabel.text = "Buy"
			sideLabel.textColor = .green
		case .sell:
			sideLabel.text = "Sell"
			sideLabel.textColor = .red
		}
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		deal = nil
		instrumentNameLabel.text = "Default"
		priceLabel.text = "0"
		amountLabel.text = "0"
		sideLabel.text = "none"
	}

}
