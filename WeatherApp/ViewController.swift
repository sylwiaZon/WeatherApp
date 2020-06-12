//
//  ViewController.swift
//  WeatherApp
//
//  Created by Student on 10/06/2020.
//  Copyright © 2020 Sylwia Zon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var dateView: UILabel!
    @IBOutlet weak var minTempView: UITextField!
    @IBOutlet weak var maxTempView: UITextField!
    @IBOutlet weak var windSpeedView: UITextField!
    @IBOutlet weak var windDirectionView: UITextField!
    @IBOutlet weak var pressureView: UITextField!
    @IBOutlet weak var humidityView: UITextField!
    @IBOutlet weak var nextDayButton: UIButton!
    @IBOutlet weak var previousDayButton: UIButton!
    @IBOutlet weak var weatherImageView: UIImageView!
    
    var day = 0
    var weatherData: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adjustButtons()
        downloadData()
    }

    private func downloadData() {
        let url = URL(string: "https://www.metaweather.com/api/location/44418")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
        
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let weather = json["consolidated_weather"] as? [[String: Any]] {
                        self.weatherData = weather
                        DispatchQueue.main.async {
                            self.displayData()
                            self.adjustButtons()
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
            }
        }
        
        task.resume()
    }
    
    private func displayData() {
        let dayData = weatherData[self.day]
        self.dateView.text = "Current date: " + getStringField(data: dayData, fieldName: "applicable_date")
        self.minTempView.text = getDoubleField(data: dayData, fieldName: "min_temp") + " C"
        self.maxTempView.text = getDoubleField(data: dayData, fieldName:"max_temp") + " C"
        self.pressureView.text = getDoubleField(data: dayData, fieldName: "air_pressure") + " mbar"
        self.windDirectionView.text = getStringField(data: dayData, fieldName: "wind_direction_compass")
        self.windSpeedView.text = getDoubleField(data: dayData, fieldName: "wind_speed") + " mph"
        self.humidityView.text = getDoubleField(data: dayData, fieldName: "humidity") + " %"
        
        if let state = dayData["weather_state_abbr"] as? String {
            self.displayImage(urlString: self.getImageLink(state: state))
        }
    }
    
    private func getStringField(data: [String: Any], fieldName: String) -> String {
        return (data[fieldName] as? String) ?? "--"
    }
    private func getDoubleField(data: [String: Any], fieldName: String) -> String {
        let value = (data[fieldName] as? Double)
        if (value == nil) {
            return "--"
        }
        return String((value!*100).rounded()/100.0)
    }
    
    private func getImageLink(state: String) -> String {
        return "https://www.metaweather.com/static/img/weather/png/64/\(state).png"
    }
    
    private func displayImage(urlString: String) {
        let url = URL(string: urlString)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.weatherImageView.image = UIImage(data: data)
            }
        }
        
        task.resume()
    }
    
    private func adjustButtons() {
        nextDayButton.isEnabled = true
        previousDayButton.isEnabled = true
        if (day <= 0) {
            previousDayButton.isEnabled = false
        }
        if (day >= weatherData.count - 1) {
            nextDayButton.isEnabled = false
        }
    }

    @IBAction func onNextClicked(_ sender: UIButton) {
        if(day < weatherData.count - 1) {
            day = day + 1
        }
        adjustButtons()
        displayData()
    }
    
    
    @IBAction func onPrevClicked(_ sender: UIButton) {
        if(day > 0) {
            day = day - 1
        }
        adjustButtons()
        displayData()
    }
}

