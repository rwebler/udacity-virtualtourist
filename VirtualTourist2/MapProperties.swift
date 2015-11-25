//
//  MapProperties.swift
//  VirtualTourist2
//
//  Created by Rodrigo Webler on 11/22/15.
//  Copyright © 2015 Rodrigo Webler. All rights reserved.
//

import Foundation
import MapKit

class MapProperties: NSObject, NSCoding {
    
    struct Keys {
        static let MapProperties = "mapProperties"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let LatitudeDelta = "latitudeDelta"
        static let LongitudeDelta = "longitudeDelta"
    }

    var latitude: Double
    var longitude: Double
    var latitudeDelta: Double
    var longitudeDelta: Double
    
    init (latitude: Double, longitude: Double, latitudeDelta: Double, longitudeDelta: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.latitudeDelta = latitudeDelta
        self.longitudeDelta = longitudeDelta
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let latitude = decoder.decodeObjectForKey(Keys.Latitude) as? Double,
        let longitude = decoder.decodeObjectForKey(Keys.Longitude) as? Double,
        let latitudeDelta = decoder.decodeObjectForKey(Keys.LatitudeDelta) as? Double,
        let longitudeDelta = decoder.decodeObjectForKey(Keys.LongitudeDelta) as? Double
            else {
                self.init(latitude: 0, longitude: 0, latitudeDelta: 50, longitudeDelta: 50)
                return
        }
        
        self.init(latitude: latitude, longitude: longitude, latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeDouble(self.latitude, forKey: Keys.Latitude)
        aCoder.encodeDouble(self.longitude, forKey: Keys.Longitude)
        aCoder.encodeDouble(self.latitudeDelta, forKey: Keys.LatitudeDelta)
        aCoder.encodeDouble(self.longitudeDelta, forKey: Keys.LongitudeDelta)
    }
    
    func change(mapView: MKMapView) {
        latitude = mapView.centerCoordinate.latitude
        longitude = mapView.centerCoordinate.longitude
        latitudeDelta = mapView.region.span.latitudeDelta
        longitudeDelta = mapView.region.span.longitudeDelta
    }
}