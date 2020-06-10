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
    @IBOutlet weak var nextDayButton: UIButton!
    @IBOutlet weak var previousDayButton: UIButton!
    @IBOutlet weak var weatherImageView: UIImageView!
    
    var day = 0
    var weatherData: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadData()
    }

    func downloadData() {
        let url = URL(string: "https://www.metaweather.com/api/location/44418")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
        
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let weather = json["consolidated_weather"] as? [[String: Any]] {
                        self.weatherData = weather
                        DispatchQueue.main.async {
                            self.displayData()
                        }                    }
                }
            } catch let error as NSError {
                print(error)
            }
        }
        
        task.resume()
    }
    
    func displayData() {
        let dayData = weatherData[self.day]
        if let minTemp = dayData["min_temp"] as? Double {
            self.minTempView.text = String(minTemp)
        }
        if let date = dayData["applicable_date"] as? String {
            self.dateView.text = date
        }
        if let state = dayData["weather_state_abbr"] as? String {
            self.displayImage(urlString: "https://www.metaweather.com/static/img/weather/png/64/\(state).png")
        }
    }
    
    func displayImage(urlString: String) {
        let url = URL(string: urlString)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.weatherImageView.image = UIImage(data: data)
            }
        }
        
        task.resume()
    }
    
    func adjustButtons() {
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

