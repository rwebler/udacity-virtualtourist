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
        self.init(latitude: decoder.decodeDoubleForKey(Keys.Latitude), longitude: decoder.decodeDoubleForKey(Keys.Longitude), latitudeDelta: decoder.decodeDoubleForKey(Keys.LatitudeDelta), longitudeDelta: decoder.decodeDoubleForKey(Keys.LongitudeDelta))
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