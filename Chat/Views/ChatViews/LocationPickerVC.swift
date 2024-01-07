//
//  LocationPickerVC.swift
//  Chat
//
//  Created by MAHESHWARAN on 07/01/24.
//

import UIKit
import MapKit

class LocationPickerVC: UIViewController {
  
  private var result: ((CLLocationCoordinate2D) -> Void)?
  private var coordinates: CLLocationCoordinate2D?
  
  private var isPickable = true
  
  private let map: MKMapView = {
    return $0
  }(MKMapView())
  
  init(_ coordinates: CLLocationCoordinate2D? = nil,
       result: ((CLLocationCoordinate2D) -> Void)? = nil) {
    self.coordinates = coordinates
    self.result = result
    self.isPickable = coordinates == nil
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }
  
  private func setupView() {
    view.backgroundColor = .systemBackground
    
    if isPickable {
      navigationItem.rightBarButtonItem = .init(
        title: "Send", style: .done, target: self, action: #selector(sendButtonClicked))
      
      map.isUserInteractionEnabled = true
      let gesture = UITapGestureRecognizer(target: self,
                                           action: #selector(didTapMap))
      gesture.numberOfTouchesRequired = 1
      gesture.numberOfTapsRequired = 1
      map.addGestureRecognizer(gesture)
      
    } else {
      guard let coordinates else { return }
      let pin = MKPointAnnotation()
      pin.coordinate = coordinates
      map.addAnnotation(pin)
    }
    view.addSubview(map)
    setupConstrainsts()
  }
  
  @objc private func sendButtonClicked() {
    guard let coordinates else { return }
    navigationController?.popViewController(animated: true)
    result?(coordinates)
  }
  
  @objc func didTapMap(_ gesture: UITapGestureRecognizer) {
    let locationInView = gesture.location(in: map)
    let coordinates = map.convert(locationInView, toCoordinateFrom: map)
    self.coordinates = coordinates
    
    for annotation in map.annotations {
      map.removeAnnotation(annotation)
    }
    let pin = MKPointAnnotation()
    pin.coordinate = coordinates
    map.addAnnotation(pin)
  }
  
  private func setupConstrainsts() {
    map.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      map.topAnchor.constraint(equalTo: view.topAnchor),
      map.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      map.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      map.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }
}
