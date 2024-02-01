//
//  WeatherManager.swift
//  Clima
//
//  Created by Gerald on 25/1/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate{
    func didUpdateWeather(_ weatherMnager: WeatherManager, weather: WeatherModel)
    func didFaileWithError(error: Error)
}

struct WeatherManager{
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=1e4a89c7477a829ee12ab9437c6de27d&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName : String){
        let urlString = "\(weatherUrl)&q=" + cityName
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: Double, longitude: Double){
        let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString : String){
        //1. Create a URL
        if let url = URL(string: urlString){
            
            //2. Create a URLSession
            let session = URLSession(configuration: .default)
            
            //3. Give the session a task
            let task = session.dataTask(with: url, completionHandler: { data, response, error in
                if error != nil {
                    self.delegate?.didFaileWithError(error: error!)
                    print(error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            })

            
            //4. Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decorder = JSONDecoder()
        do{
            let decodedData = try decorder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name

            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
            
        }catch{
            delegate?.didFaileWithError(error: error)
            return nil
        }
    }
    
   
                                        
    
}
