//
//  WeatherInformation.swift
//  Weather
//
//  Created by Whyeon on 2022/04/15.
//

import Foundation

// Codable 프로토콜 채택시 Jason 인코딩 디코딩이 가능한 객체
struct WeatherInformation: Codable {
    let weather: [Weather]
    let temp: Temp
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case weather
        case temp = "main" //실제 Json 파일의 필드키로 맵핑
        case name
    }
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Temp: Codable {
    let temp: Double
    let feelsLike: Double
    let minTemp: Double
    let maxTemp: Double
    
    enum CodingKeys: String, CodingKey {
        //Jason 파일의 필드키와 내가 선언한 구조체 키가 다를 경우 맵핑해주어야함.
        case temp
        case feelsLike = "feels_like"
        case minTemp = "temp_min"
        case maxTemp = "temp_max"
    }
}

