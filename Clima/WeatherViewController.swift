//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, ChangeCityDelegate {
    
    @IBOutlet weak var faren: UISwitch!
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "4be65b5ec35063b7f69280da72b9e9dd"
    
    @IBAction func `switch`(_ sender: UISwitch) {
        
        if sender.isOn {
            
        }
    }
    
    
    
    func textFieldShouldReturn(userText: UITextField!) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }



    @IBAction func butprim(_ sender: UIButton) {
        
        let defaults = UserDefaults.standard
        let mytext = txtRan.text
        
        defaults.set(mytext!, forKey: "ran")
        print("here")
    }
    
    @IBOutlet weak var txtchangeme: UIButton!
    
    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBAction func txtend(_ sender: UITextField) {
    }
    @IBOutlet weak var txtRan: UITextField!
    @IBOutlet weak var runnable: UILabel!
    
    @IBOutlet weak var button: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
    
       
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        self.txtRan.delegate = self
        //var time = 0.0
        var timer = Timer()
        timer = Timer.scheduledTimer(timeInterval: 600, target: self, selector: #selector(WeatherViewController.updateWithWeatherData), userInfo: nil, repeats: true)
        
    }
       

    
    @objc func adjustmentBestSongBpmHeartRate(_ timer: Timer) {
        print("frr")
    }
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData(url: String, parameters: [String: String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                
                print("Success! Got the weather data")
                let weatherJSON : JSON = JSON(response.result.value!)
                
                
                print(weatherJSON)
                
                
                self.updateWeatherData(json: weatherJSON)
                
            }
            else {
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    
    
    
    //Write the updateWeatherData method here:
    
    
    func updateWeatherData(json : JSON) {
    
        let tempResult = json["main"]["temp"].doubleValue
    
            //weatherDataModel.temperature = Int(tempResult - 273.15)
            let F = (1.8*(Double(tempResult) - 273.15)) + 32
            weatherDataModel.temperature = Int(F)
        
            weatherDataModel.city = json["name"].stringValue
    
            weatherDataModel.condition = json["weather"][0]["id"].intValue
    
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
    
    
            updateUIWithWeatherData()
        }
    
        
//        else {
//            cityLabel.text = "Weather Unavailable"
//        }
//    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    @objc func updateWithWeatherData() {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        
        let timeString = "Updated: \(dateFormatter.string(from: Date() as Date))"
        
        runnable.text = String(timeString)

        userEnteredANewCityName(city:cityLabel.text!)
    }
    
    
    @objc func updateUIWithWeatherData() {
        
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let defaults = UserDefaults.standard
        
        
        if let stringOne = defaults.string(forKey: "ran") {
            txtRan.text=stringOne
            print(stringOne) // Some String Value
        }
        
        // No need for semicolon
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/

    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            
            locationManager.stopUpdatingLocation()
            
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    
    func userEnteredANewCityName(city: String) {
        
        let params : [String : String] = ["q" : city, "appid" : APP_ID,"Unit" : "Standard"]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
        
    }

    
    //Write the PrepareForSegue Method here
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeCityName" {
            
            let destinationVC = segue.destination as! ChangeCityViewController
            
            
            destinationVC.delegate = self
            
        }
        
    }
    
    
}











