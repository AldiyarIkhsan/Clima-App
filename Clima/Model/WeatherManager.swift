import Foundation

protocol WeatherManagerDelegate{
    func userDidUpdate(_ weatherManager:WeatherManager, weather:WeatherModel)
    func errorDefined(error:Error)
}

struct WeatherManager{
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=3b5fa12a0b69733cd6ed8618275560f9&units=metric"
    
    func urlFetch(_ cityName:String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        requestURL(with: urlString)
    }
    
    var delegate: WeatherManagerDelegate?
    
    func requestURL(with urlString:String){
       if let url = URL(string: urlString){
        let session  = URLSession(configuration: .default)
        let task = session.dataTask(with:url) { data, response, error in
            if error != nil{
                self.delegate?.errorDefined(error: error!)
            }
            
            if let safedata = data{
                if let weaherNew = parseJson(weatherData: safedata){
                    self.delegate?.userDidUpdate(self, weather: weaherNew)
                }
                }
            }
           task.resume()
        }
    }
    
    func parseJson(weatherData:Data)->WeatherModel?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let name = decodedData.name
            let temp = decodedData.main.temp
            
            let weather = WeatherModel(modelId: id, modelCityName: name, modelTemperature: temp)
            return weather
            
        }catch{
            delegate?.errorDefined(error: error)
            return nil
        }
    }
}
