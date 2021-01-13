//
//  CryptoViewController.swift
//  Elber
//
//  Created by Martin Nava Pe&a on 05/01/21.
//

import UIKit
import Charts

class CryptoViewController: UIViewController {

    @IBOutlet weak var spotPrice: UILabel!
    @IBOutlet weak var buyPrice: UILabel!
    @IBOutlet weak var sellPrice: UILabel!
    @IBOutlet weak var cryptoIcon: UIImageView!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var priceDateLabel: UILabel!
    
    var data:Dictionary<String, Any>?
    var history:Dictionary<String, String> = [:]
    var range = 23
    var sortedDates:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        chartView.delegate = self
        setCrypto()
        
    }
    
    private func setCrypto() {
        if let cryptoInfo = data, !cryptoInfo.isEmpty {
            let crypto = cryptoInfo["crypto"] as! String
            history = cryptoInfo["history"] as! Dictionary<String, String>
            cryptoIcon.image = UIImage(named: crypto)
            setCryptoLabels()
            self.title = crypto
            setChart()
        }
    }
    
    private func setCryptoLabels() {
        self.priceDateLabel.text = "Último precio"
        self.spotPrice.text = "\(self.data!["spot"] as! String) USD"
        self.buyPrice.text = "Buy Price: \(self.data!["buy"] as! String) USD"
        self.sellPrice.text = "Sell Price: \(self.data!["sell"] as! String) USD"
    }
    
    private func setChart() {
        chartView.highlightValue(nil)
        chartView.noDataTextColor = UIColor(named: "TextColor")!
        chartView.noDataText = "No pudimos obtener la data."
        chartView.backgroundColor = UIColor(named: "MainBackground")!
               
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.xAxis.drawLabelsEnabled = false
        
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawAxisLineEnabled = false
        chartView.leftAxis.drawLabelsEnabled = false
        
        chartView.rightAxis.drawGridLinesEnabled = false
        chartView.rightAxis.drawAxisLineEnabled = false
        chartView.rightAxis.drawLabelsEnabled = false
        
        chartView.data = getChartData()
        
        if range == 0 {
            chartView.animate(xAxisDuration: 0.5, easingOption: .linear)
        }
    }
    
    private func getChartData() -> LineChartData{
        if !self.history.isEmpty {
            
            sortedDates = history.keys.sorted()
            var dataEntries:[ChartDataEntry] = []
            var count = 1.0
            
            for i in range..<history.count {
                let currDate = sortedDates[i]
                let price = Double(history[currDate]!)!
                let dataEntry = ChartDataEntry(x: count, y: price)
                dataEntries.append(dataEntry)
                count += 1
            }
            
            let chartDataSet = LineChartDataSet(entries: dataEntries, label: "")
            chartDataSet.drawCirclesEnabled = false
            chartDataSet.drawValuesEnabled = false
            chartDataSet.mode = .cubicBezier
            chartDataSet.cubicIntensity = 0.2
            chartDataSet.lineWidth = 2
            chartDataSet.colors = [UIColor(named: "IconColor")!]
                    
            let chartData = LineChartData(dataSet: chartDataSet)
                    
            return chartData
        } else {
            return LineChartData()
        }
    }
    
    @IBAction func changeRange(_ sender: Any) {
        let segmentedControl = sender as! UISegmentedControl
        
        if segmentedControl.selectedSegmentIndex == 0 {
            range = 23
        } else {
            range = 0
        }
        
        setCrypto()
    }
}

extension CryptoViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let index = self.range + Int(entry.x) - 1
        let date = self.sortedDates[index]
        let price = self.history[date]
        
        if index == self.sortedDates.count - 1 {
            setCryptoLabels()
        } else {
            self.priceDateLabel.text = date
            self.spotPrice.text = "\(price!) USD"
            self.buyPrice.text = "--"
            self.sellPrice.text = "--"
        }
    }
}
