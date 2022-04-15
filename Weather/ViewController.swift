//
//  ViewController.swift
//  Weather
//
//  Created by Whyeon on 2022/04/15.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var cityNameTextField: UITextField!
    
    @IBOutlet weak var cityNameLabel: UILabel!
    
    @IBOutlet weak var weatherDiscriptionLabel: UILabel!
    
    @IBOutlet weak var tempLabel: UILabel!
    
    @IBOutlet weak var maxTempLabel: UILabel!
    
    @IBOutlet weak var minTempLabel: UILabel!
    
    @IBOutlet weak var watherStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func configureView(weatherInformation: WeatherInformation) {
        self.cityNameLabel.text = weatherInformation.name
        if let weather = weatherInformation.weather.first {
            self.weatherDiscriptionLabel.text = weather.description
        }
        self.tempLabel.text = "\(Int(weatherInformation.temp.temp - 273.15))℃"
        self.minTempLabel.text = "최저 : \(Int(weatherInformation.temp.minTemp - 273.15))℃"
        self.maxTempLabel.text = "최고 : \(Int(weatherInformation.temp.maxTemp - 273.15))℃"

    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func tapFetchWeatherButton(_ sender: UIButton) {
        if let cityName = self.cityNameTextField.text {
            self.getCurrentWeather(cityName: cityName)
            self.view.endEditing(true) // 버튼이 눌리면 키보드 사라짐
        }
    }
    func getCurrentWeather(cityName: String) {
        guard let url = URL(string:
                                "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=0d907f132847b30949b9c871df50dcbc") else {
            return }
        let session = URLSession(configuration: .default)
        session.dataTask(with: url) {
            //컴플리션 헨들러; 네트워크작업은 별도의 스레드에서 작업됨. 응답이오더라도 자동으로 메인스레드로 돌아오지않음. 따라서 메인스레드에서 작업하도록 해주어야함.
            [weak self] data, responds, error in // status code를 읽어서 에러인지 판단
            let successRange = (200..<300) // 200~299까지의 수를 가지게함.
            guard let data = data, error == nil else { return }
            let decoder = JSONDecoder()
            if let response = responds as? HTTPURLResponse, successRange.contains(response.statusCode) { //status가 200번대인지 확인
                guard let weatherInformation = try? decoder.decode(WeatherInformation.self, from: data)// Json Codable 프로토콜을 채택하는 타입을 넣어줌; from에는 서버에서 응답받은 데이터
                else { return }
                
                //메인스레드안에서 UI 작업을 할수 있게해주는 코드
                DispatchQueue.main.async {
                    self?.watherStackView.isHidden = false
                    self?.configureView(weatherInformation: weatherInformation)
                }
            } else { //status가 200번대가 아니라면
                guard let errorMessage = try? decoder.decode(ErrorMessage.self, from: data) else { return }
                debugPrint(errorMessage)
                
                //메인스레드에서 알림이 표시되도록 하기위해
                DispatchQueue.main.async {
                    self?.showAlert(message: errorMessage.message)
                }
            }
            
            
        }.resume() // 이 데이터태스크를 실행
    }
}

