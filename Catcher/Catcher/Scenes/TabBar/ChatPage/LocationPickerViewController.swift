//
//  LocationPickerViewController.swift
//  Catcher
//
//  Created by 김지은 on 2023/10/19.
//

import UIKit
import CoreLocation
import MapKit

final class LocationPickerViewController: BaseViewController {

    public var completion: ((CLLocationCoordinate2D) -> Void)?
    private var coordinates: CLLocationCoordinate2D?
    private var isSendUsable = true
    private var isPickable = true
    
    private let btnSend: UIButton = {
       let button = ButtonFactory.makeButton(
        type: .custom,
        title: "Send",
        tintColor: .black)
        return button
    }()
    
    private let btnBack: UIButton = {
       let button = ButtonFactory.makeButton(
        type: .custom,
        image: UIImage(systemName: "chevron.left"),
        tintColor: .black)
        return button
    }()
    
    private let map: MKMapView = {
        let map = MKMapView()
        return map
    }()

    init(coordinates: CLLocationCoordinate2D?, isSendUsable: Bool) {
        self.coordinates = coordinates
        self.isPickable = coordinates == nil
        self.isSendUsable = isSendUsable
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeColor.backGroundColor
        btnBack.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        btnSend.isHidden = !isSendUsable
        if isPickable {
            btnSend.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
            map.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer(target: self,
                                                 action: #selector(didTapMap(_:)))
            gesture.numberOfTouchesRequired = 1
            gesture.numberOfTapsRequired = 1
            map.addGestureRecognizer(gesture)
        }
        else {
            // just showing location
            guard let coordinates = self.coordinates else {
                return
            }
            
            // drop a pin on that location
            let pin = MKPointAnnotation()
            pin.coordinate = coordinates
            map.addAnnotation(pin)
        }
        view.addSubview(map)
        setLayout()
    }
    
    func setLayout() {
        view.addSubview(btnBack)
        view.addSubview(btnSend)
        
        btnBack.snp.makeConstraints {
            $0.top.leading.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.height.equalTo(40)
            $0.width.equalTo(50)
        }
        
        btnSend.snp.makeConstraints {
            $0.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.height.equalTo(40)
            $0.width.equalTo(50)
        }
    }

    @objc func sendButtonTapped() {
        guard let coordinates = coordinates else {
            return
        }
        self.dismiss(animated: true)
        completion?(coordinates)
    }
    
    @objc func backButtonTapped() {
        self.dismiss(animated: true)
    }

    @objc func didTapMap(_ gesture: UITapGestureRecognizer) {
        let locationInView = gesture.location(in: map)
        let coordinates = map.convert(locationInView, toCoordinateFrom: map)
        self.coordinates = coordinates

        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }

        // drop a pin on that location
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        map.addAnnotation(pin)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        map.frame = view.bounds
    }
}
