//
//  APIWeatherManager.swift
//  WeatherAnimation_App
//
//  Created by Felix Titov on 7/2/22.
//  Copyright © 2022 by Felix Titov. All rights reserved.
//  


import Foundation

struct Coordinates {
  let latitude: Double
  let longitude: Double
}

enum ForecastType: FinalURLPoint {
  case Current(apiKey: String, coordinates: Coordinates)
  
  var baseURL: URL {
    return URL(string: "https://api.forecast.io")!
  }
  
  var path: String {
    switch self {
    case .Current(let apiKey, let coordinates):
      return "/forecast/\(apiKey)/\(coordinates.latitude),\(coordinates.longitude)"
    }
  }
  
  var request: URLRequest {
    let url = URL(string: path, relativeTo: baseURL)
    return URLRequest(url: url!)
  }
}



final class APIWeatherManager: NetworkManager {
  
  let sessionConfiguration: URLSessionConfiguration
  lazy var session: URLSession = {
    return URLSession(configuration: self.sessionConfiguration)
  } ()
  
  let apiKey: String
  
  init(sessionConfiguration: URLSessionConfiguration, apiKey: String) {
    self.sessionConfiguration = sessionConfiguration
    self.apiKey = apiKey
  }
  
  convenience init(apiKey: String) {
    self.init(sessionConfiguration: URLSessionConfiguration.default, apiKey: apiKey)
  }
  
  func fetchCurrentWeatherWith(coordinates: Coordinates, completionHandler: @escaping (APIResult<CurrentWeather>) -> Void) {
    let request = ForecastType.Current(apiKey: self.apiKey, coordinates: coordinates).request
    
    fetch(request: request, parse: { (json) -> CurrentWeather? in
      if let dictionary = json["currently"] as? [String: AnyObject] {
          print(dictionary)
        return CurrentWeather(json: dictionary)
      } else {
        return nil
      }
      
      }, completionHandler: completionHandler)
  }
}
