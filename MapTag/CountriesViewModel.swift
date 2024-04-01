//
//  CountriesViewModel.swift
//  MapTag
//
//  Created by Cam Graham on 01/04/2024.
//

import Foundation

@MainActor
class CountriesViewModel: ObservableObject {
    init() {
        self.countriesList = CountriesViewModel.testingCountryData
//        Task.init {
//            self.countriesList = await fetchCountries()
//        }
    }
    
    @Published var countriesList: [Country] = []
    
    func fetchCountries() async -> [Country] {
        let apiCallURLString = "https://restcountries.com/v3.1/all?fields=name,latlng,flags"
        
        do {
            guard let url = URL(string: apiCallURLString) else {
                return []
            }
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode([Country].self, from: data) {
                return decodedResponse
            } else {
                return []
            }
        } catch {
            return []
        }
    }
    
    static let testingCountryData: [Country] = [Country(name: "New Zealand", lattitude: -40.900557, longitude: 174.885971, flagURL: "urlhere")]
}

struct Country: Codable, Hashable {
    init(name: String,
         lattitude: Double,
         longitude: Double,
         flagURL: String) {
        self.name = name
        self.lattitude = lattitude
        self.longitude = longitude
        self.flagURL = flagURL
        self.isFavourite = false
    }
    
    let name: String
    let lattitude: Double
    let longitude: Double
    let flagURL: String
    var isFavourite: Bool
}

extension Country {
    enum RootKeys: String, CodingKey {
        case flags, name, latlng
    }
    
    enum FlagKeys: String, CodingKey {
        case png, svg, alt
    }
        
    enum NameKeys: String, CodingKey {
        case common, official, nativeName
    }
    
    enum NativeNameKeys: String, CodingKey {
        case ell, tur
    }
    
    enum EllTurrKeys: String, CodingKey {
        case official, common
    }

    init(from decoder: any Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootKeys.self)
        
        let nameContainer = try rootContainer.nestedContainer(keyedBy: NameKeys.self, forKey: .name)
        self.name = try nameContainer.decode(String.self, forKey: .common)
        
        let latlong = try rootContainer.decode([Double].self, forKey: .latlng)
        self.lattitude = latlong[0]
        self.longitude = latlong[1]
        
        let flagContainer = try rootContainer.nestedContainer(keyedBy: FlagKeys.self, forKey: .flags)
        
        self.flagURL = try flagContainer.decode(String.self, forKey: .png)
        
        self.isFavourite = false
    }
}
