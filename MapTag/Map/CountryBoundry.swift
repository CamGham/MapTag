//
//  CountryBoundry.swift
//  MapTag
//
//  Created by Cam Graham on 07/04/2024.
//

import Foundation
import CoreLocation


struct FeatureCollection: Decodable {
    var features: [CountryBoundry]
}
extension FeatureCollection {
    enum FileBaseKeys: String, CodingKey {
        case type, features
    }
    
    init(from decoder: any Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: FileBaseKeys.self)
        self.features = try rootContainer.decode([CountryBoundry].self, forKey: .features)
    }
    
    
    
}

struct CountryBoundry: Decodable {
//    static func == (lhs: CountryBoundry, rhs: CountryBoundry) -> Bool {
//        lhs.countryName == rhs.countryName
//    }
//    var dictionary: [String: [[[[Double]]]]]
    
    var countryName: String
    var coordinates: [[[CLLocationCoordinate2D]]]
    
    
    
}

extension CountryBoundry {
    enum RootKeys: String, CodingKey {
        case type, properties, geometry
    }
    
    enum PropertiesKeys: String, CodingKey {
        case ADMIN, ISO_A3, ISO_A2
    }
        
    enum GeometryKeys: String, CodingKey {
        case type, coordinates
    }

    init(from decoder: any Decoder) throws {
        
        let rootContainer = try decoder.container(keyedBy: RootKeys.self)
        
        
        
        let propertiesContainer = try rootContainer.nestedContainer(keyedBy: PropertiesKeys.self, forKey: .properties)
        self.countryName = try propertiesContainer.decode(String.self, forKey: .ADMIN)
        
        let geometryContainer = try rootContainer.nestedContainer(keyedBy: GeometryKeys.self, forKey: .geometry)
        
        
        let nestedDoubleArray = try geometryContainer.decode([[[[Double]]]].self, forKey: .coordinates)
        
        
        var tempDict = [[[CLLocationCoordinate2D]]]()
        nestedDoubleArray.forEach { arr in
            var tempArr: [[CLLocationCoordinate2D]] = []
            arr.forEach { arr2 in
                var tempArr2: [CLLocationCoordinate2D] = []
                arr2.forEach { doubArr in
                    let coord = CLLocationCoordinate2D(latitude: doubArr[1], longitude: doubArr[0])
                    tempArr2.append(coord)
                }
                
                tempArr.append(tempArr2)
            }
            tempDict.append(tempArr)
        }
        self.coordinates = tempDict
    }
}


//{ "type": "Feature", "properties": { "ADMIN": "Aruba", "ISO_A3": "ABW", "ISO_A2": "AW" }, "geometry": { "type": "MultiPolygon", "coordinates": [ [ [ [ -69.996937628999916, 12.577582098000036 ], [ -69.936390753999945, 12.531724351000051 ], [ -69.924672003999945, 12.519232489000046 ], [ -69.915760870999918, 12.497015692000076 ], [ -69.880197719999842, 12.453558661000045 ], [ -69.876820441999939, 12.427394924000097 ], [ -69.888091600999928, 12.417669989000046 ], [ -69.908802863999938, 12.417792059000107 ], [ -69.930531378999888, 12.425970770000035 ], [ -69.945139126999919, 12.44037506700009 ], [ -69.924672003999945, 12.44037506700009 ], [ -69.924672003999945, 12.447211005000014 ], [ -69.958566860999923, 12.463202216000099 ], [ -70.027658657999922, 12.522935289000088 ], [ -70.048085089999887, 12.531154690000079 ], [ -70.058094855999883, 12.537176825000088 ], [ -70.062408006999874, 12.546820380000057 ], [ -70.060373501999948, 12.556952216000113 ], [ -70.051096157999893, 12.574042059000064 ], [ -70.048736131999931, 12.583726304000024 ], [ -70.052642381999931, 12.600002346000053 ], [ -70.059641079999921, 12.614243882000054 ], [ -70.061105923999975, 12.625392971000068 ], [ -70.048736131999931, 12.632147528000104 ], [ -70.00715084499987, 12.5855166690001 ], [ -69.996937628999916, 12.577582098000036 ] ] ] ] } }
