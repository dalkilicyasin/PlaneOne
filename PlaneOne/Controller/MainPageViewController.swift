//
//  ViewController.swift
//  PlaneOne
//
//  Created by Yasin Dalkilic on 30.09.2023.
//

import UIKit
import MapKit
import SnapKit

class MainPageViewController: UIViewController {

    var mainPAgeViewModel: MainPageViewModel?

    private lazy var mapView: MKMapView = {
        let map = MKMapView()
        return map
    }()

    private lazy var customLocationView: UIImageView = {
        let locationView = UIImageView()
        locationView.image = UIImage(named: "location")
        return locationView
    }()

    private lazy var customLocationLabel: UILabel = {
        let locationLabel = UILabel()
        locationLabel.backgroundColor = .red.withAlphaComponent(0.5)
        locationLabel.textColor = .black
        return locationLabel
    }()

    private lazy var selectedCountryLabel: UILabel = {
        let locationLabel = UILabel()
        locationLabel.text = "\(mainPAgeViewModel?.selectedCountry ?? "")"
        locationLabel.backgroundColor = .white
        locationLabel.textColor = .blue
        return locationLabel
    }()

    private lazy var customTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.textColor = .blue
        textField.keyboardType = .numberPad
        textField.placeholder = "Enter Search Area in Km"
        return textField
    }()

    init(mainPAgeViewModel: MainPageViewModel) {
        self.mainPAgeViewModel = mainPAgeViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.mainPAgeViewModel = MainPageViewModel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mainPAgeViewModel?.mainPageVieModelDelegate = self
        mapView.delegate = self
        LocationManager.shared.locationManagerDelegate = self
        self.setupView()
        self.setupUserLocation()
        self.hideKeyboardWhenTappedAround()
        self.textFieldChange()
    }
}

extension MainPageViewController {
    func textFieldChange(){
        self.customTextField.addTarget(self, action: #selector(textFieldDidChange(_:)),
                                       for: UIControl.Event.editingChanged)
    }

    @objc func textFieldDidChange(_ textField: UITextField) {

        if let doubleValue = Double(textField.text ?? ""){
            self.mainPAgeViewModel?.searchDistance = doubleValue
        }
    }
}

extension MainPageViewController {
    func setupView(){
        view.addSubview(self.mapView)
        self.mapView.addSubview(self.customLocationView)
        self.mapView.addSubview(self.customLocationLabel)
        self.mapView.addSubview(self.customTextField)
        self.mapView.addSubview(self.selectedCountryLabel)

        self.mapView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        self.customLocationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(30)
        }

        self.customLocationLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(300)
            make.bottom.equalTo(customLocationView.snp.top)
        }

        self.customTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(300)
            make.top.equalToSuperview().inset(50)
        }

        self.selectedCountryLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(300)
            make.top.equalTo(customTextField.snp.bottom).offset(5)
        }

        self.selectedCountryLabel.layer.masksToBounds = true
        self.selectedCountryLabel.layer.cornerRadius = 20
        self.customTextField.layer.cornerRadius = 20
    }
}

//MARK: Get User Current Location
extension MainPageViewController {
    func setupUserLocation() {
        LocationManager.shared.getUserLocation { [weak self] location in
            DispatchQueue.main.async {
                guard let strongSelf = self else {
                    return
                }

                strongSelf.mapView.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)

                //Get max 50 km distance around user
                strongSelf.searchDistance(searchAre: 100, latitude: location.coordinate.latitude, longitute: location.coordinate.longitude)

                //Get address user address
                self?.getAdress(latitute: location.coordinate.latitude, longitute: location.coordinate.longitude)
            }
        }
    }
}

//MARK: Custom Annotations and UserSelectedArea
extension MainPageViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }

        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)

        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
        }

        annotationView?.image = UIImage(named: "plane")
        annotationView?.canShowCallout = true

        return annotationView
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapView.centerCoordinate
        print("\(center.latitude) --\(center.longitude) ")
        self.mainPAgeViewModel?.coordinate = center
        self.mainPAgeViewModel?.searchDistance = 50.00
        self.refreshData()

        //Get max 50 km distance around user
        self.searchDistance(searchAre: 50, latitude: center.latitude, longitute: center.longitude)

        //Get address
        self.getAdress(latitute: center.latitude, longitute: center.longitude)
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let value = view.annotation?.title as? String {
            print(value)
            var selectedCountryString = ""
            let allAnnotations = self.mapView.annotations
            self.mapView.removeAnnotations(allAnnotations)
            selectedCountryString = "\(mainPAgeViewModel?.selectedCountry ?? "") \(value)"
            self.selectedCountryLabel.text = "\(selectedCountryString)"
            self.mainPAgeViewModel?.filterPlanesSelectedCountry(value: value)
        }
    }
}

//MARK: Create Annotations
extension MainPageViewController {
    func createAnnotations(locations: [Flights]) {
        if locations.count > 0 {
            for location in locations {
                let annotation = MKPointAnnotation()
                annotation.title = location.originCountry
                annotation.coordinate = CLLocationCoordinate2D(latitude: Double(location.latitude ?? 0.0), longitude: Double(location.longitude ?? 0.0))
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }
}

//MARK: Observer
extension MainPageViewController: MainPageVieModelDelegate {
    func valueHasChanged(flight: [Flights], coordinate: CLLocationCoordinate2D) {
        self.mainPAgeViewModel?.flights = flight
        self.mainPAgeViewModel?.coordinate = coordinate
        self.createAnnotations(locations: self.mainPAgeViewModel?.flights ?? [])
    }
}

// MARK: Hide keyboard
extension MainPageViewController {
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                         action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
        guard self.customTextField.text?.count != 0 else {return}
            self.refreshData()
            self.searchDistance(searchAre: self.mainPAgeViewModel?.searchDistance ?? 50.00, latitude: self.mainPAgeViewModel?.coordinate.latitude ?? 0.00, longitute: self.mainPAgeViewModel?.coordinate.longitude ?? 0.00)
    }
}

//MARK: Get point address
extension MainPageViewController: LocationManagerDelegate{
    func addressUpdate(address: String) {
        self.customLocationLabel.text = address
    }

    func getAdress(latitute: Double, longitute: Double ) {
        LocationManager.shared.convertLatLongToAddress(latitude: latitute, longitude: longitute)
    }
}

//MARK: Refresh data
extension MainPageViewController {
    func refreshData(){
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        self.selectedCountryLabel.text = mainPAgeViewModel?.selectedCountry
        self.createAnnotations(locations: self.mainPAgeViewModel?.flights ?? [])
        guard self.mainPAgeViewModel?.flights.count == 0 else {return}
        self.mainPAgeViewModel?.contDownTimer()
    }
}

//MARK: Get max 50 km distance around user
extension MainPageViewController{
    func searchDistance(searchAre: Double, latitude: CLLocationDegrees, longitute: CLLocationDegrees ){
        let minLat = latitude - ((self.mainPAgeViewModel?.searchDistance ?? 0.00) / 69)
        let maxLat = latitude + ((self.mainPAgeViewModel?.searchDistance ?? 0.00) / 69)

        let minLon = longitute - (self.mainPAgeViewModel?.searchDistance ?? 0.00) / fabs(cos(self.deg2rad(degrees: longitute) )*69)
        let maxLon = longitute + (self.mainPAgeViewModel?.searchDistance ?? 0.00) / fabs(cos(self.deg2rad(degrees: longitute) )*69)

        self.mainPAgeViewModel?.lamin = minLat
        self.mainPAgeViewModel?.lamax = maxLat
        self.mainPAgeViewModel?.lomin = minLon
        self.mainPAgeViewModel?.lomax = maxLon
        self.mainPAgeViewModel?.fetchFlightData()
    }

    func deg2rad(degrees:Double) -> Double{
        return degrees * .pi / 180
    }
}




