//
//  ViewController.swift
//  MapNavigationApp
//
//  Created by MacBook AIR on 06/07/2024.
//

import UIKit
import MapKit
import CoreLocation
import AVFoundation


class ViewController: UIViewController {
    
    var steps:[MKRoute.Step] = []
    var stepCounter = 0
    var route:MKRoute?
    var showMapRoute = false
    var naigationStarted = false
    let locationDistance:Double = 500
    var speechSynthesizer = AVSpeechSynthesizer()
    
    lazy var locationManager:CLLocationManager =  {
        let locationManager = CLLocationManager()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            handleAuthorizationStatus(locationManager: locationManager, status: CLLocationManager.authorizationStatus())
        }else {
            
        }
        return locationManager
    }()
    
    private let directionalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        label.text = "Where do ypu want to go"
        return label
    }()
    private let nextButton:UIButton = {
        let button = UIButton()
        let label = UILabel()
        button.titleLabel?.font = label.font
        button.setTitle("Next", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 4
        button.backgroundColor = .systemPurple
        button.layer.masksToBounds = true
        return button
    }()
    private let entryField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.keyboardType = .emailAddress
        field.translatesAutoresizingMaskIntoConstraints = false
        field.leftViewMode = .always
        field.textColor = .white
        field.tintColor = .white
        field.layer.cornerRadius = 4
        field.placeholder = "Email address"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.layer.masksToBounds = true
        return field
    }()
    
    lazy var mapView:MKMapView =  {
        let mapView = MKMapView()
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = true
        return mapView
        
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addSubviews()
        configureConstraints()
        locationManager.startUpdatingLocation()
        view.backgroundColor = .white
    }
    
      func configureActions() {
        nextButton.addTarget(self, action: #selector(didNextButtonTapped), for: .touchUpInside)
    }
    
    @objc func didNextButtonTapped() {
        guard let text = entryField.text else {return}
        showMapRoute = true
        entryField.endEditing(true)
        
        let geoCorder = CLGeocoder()
        geoCorder.geocodeAddressString(text) { (PlaceMark, error) in
            if let error = error {
                
            }
        }
        
    }
    private func addSubviews() {
        view.addSubview(directionalLabel)
        view.addSubview(nextButton)
        view.addSubview(entryField)
        view.addSubview(mapView)
    }
    private func configureConstraints() {
        // Directional Label constraints
        NSLayoutConstraint.activate([
            directionalLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            directionalLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            directionalLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Next Button constraints
        NSLayoutConstraint.activate([
            nextButton.topAnchor.constraint(equalTo: directionalLabel.bottomAnchor, constant: 20),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 100),
            nextButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Entry Field constraints
        NSLayoutConstraint.activate([
            entryField.topAnchor.constraint(equalTo: nextButton.bottomAnchor, constant: 20),
            entryField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            entryField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            entryField.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Optionally, if mapView is added as a subview
   
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: entryField.bottomAnchor, constant: 20),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
      
    }
}

extension ViewController:CLLocationManagerDelegate {
    private func handleAuthorizationStatus(locationManager:CLLocationManager,status:CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .denied:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            locationManager.requestWhenInUseAuthorization()
        case .authorized:
            if  let center = locationManager.location?.coordinate {
                centerUserLocation(center:center )
            }
        @unknown default:
            break
        }
    }
    
    private func centerUserLocation(center:CLLocationCoordinate2D) {
       let region  = MKCoordinateRegion(center: center, latitudinalMeters: locationDistance, longitudinalMeters: locationDistance)
        mapView.setRegion(region, animated: true)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !showMapRoute {
            if let location = locations.last {
                let center = location.coordinate
                centerUserLocation(center: center)
            }
        }
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorizationStatus(locationManager: locationManager, status: manager.authorizationStatus)
    }
}

extension ViewController:MKMapViewDelegate {
    
}
