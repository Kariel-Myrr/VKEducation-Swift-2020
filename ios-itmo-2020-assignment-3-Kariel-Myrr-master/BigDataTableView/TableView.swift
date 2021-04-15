import UIKit

protocol TableViewDataSource: AnyObject {
    func numberOfRowInTableView(_ tableView: TableView) -> Int
    func tableView(_ tableView: TableView, textForRow row: Int) -> String
}

class TableView: UIScrollView {
    weak var dataSource: TableViewDataSource?
    
    var cells : [TableCell] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let count = dataSource?.numberOfRowInTableView(self) ?? 50
        let cellsOnDisplay = (Int)(bounds.size.height/40) + 2
        let startHeight = (Int)(bounds.minY) - ((Int)(bounds.minY) % 40)
        
        contentSize = CGSize(width: bounds.width, height: CGFloat(count*40))//we can't set it in init because no data sourse were set at that time
        
        switch cellsOnDisplay-cells.count {
        case ...(-1):
            for _ in cellsOnDisplay...(cells.count - 1) {
                print("subview removed")
                cells.popLast()!.removeFromSuperview()
            }
        case 1...:
            for _ in cells.count...(cellsOnDisplay - 1) {
                print("subview added")
                let cell = TableCell()
                cell.update(text: "ADDED_FOR_MASS")
                cells.append(cell)
                addSubview(cell)
            }
        default:
            break
        }
        
        for i in 0...(cells.count-1) {
            let y = i*40 + startHeight
            if(y >= 0 && y <= count*40 - 40){
                cells[i].frame = CGRect(x: 0, y: y, width: (Int)(bounds.width), height: 40)
                cells[i].update(text: (dataSource?.tableView(self, textForRow: startHeight/40 + i + 1))!)
            }
        }
    }
    
    
}
