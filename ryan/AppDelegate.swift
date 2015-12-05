//
//  AppDelegate.swift
//  ryan
//
//  Created by monster on 05.12.15.
//  Copyright © 2015 monster. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application

        var flights = [Flight]()
        
        let fromAirport = "RIX"
        getDestinationAitports(fromAirport, completion: { toAirports in
            for toAirport in toAirports {
                print("Geting flights from \(toAirport)")
                let fromDate = NSDate()
                let toDate = fromDate.add(100)

                self.getFlights(fromAirport, to:toAirport, startDate: fromDate, endDate: toDate, completion: { flightList in
                    flights.appendContentsOf(flightList)
                    for flight in flightList {
                        print(flight)
                    }
                })
            }
        })
        
        print(flights)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func getFlights(from: String, to: String, startDate:NSDate, endDate:NSDate , completion: (response: [Flight]) -> ())
    {
        let url = "http://www.ryanair.com/en/api/2/flights/from/\(from)/to/\(to)/\(startDate.toString())/\(endDate.toString())/outbound/cheapest-per-day/"
        Alamofire.request(.GET, url)
            .responseJSON { response in
                switch response.result {
                case .Success:
                    var resultFlights = [Flight]()
                    
                    if let value = response.result.value {
                        let json = JSON(value)
                        let flights = json["flights"]
                        for (_,flight):(String, JSON) in flights {
                            let priceString = flight["price"]["value"].stringValue
                            if priceString == ""
                            {
                                continue
                            }
                            
                            let currency = flight["price"]["currencySymbol"].stringValue.characters.first
                            let dateStr = flight["dateFrom"].stringValue
                            
                            let flightDate = NSDate().dateFromString(dateStr, format:"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
                            
                            let resultFlight = Flight(
                                from: from,
                                to: to,
                                price: Double(priceString)!,
                                currency: currency!,
                                date: flightDate)
                            
                            resultFlights.append(resultFlight)
                            
                        }
                    }
                    completion(response: resultFlights)
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    func getDestinationAitports(from:String,completion: (response: [String]) -> ())
    {
        Alamofire.request(.GET, "https://www.ryanair.com/en/api/2/routes/\(from)/")
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        var dest = [String]()
                        let json = JSON(value)
                        for (_,subJson):(String, JSON) in json {
                            let toAirport = subJson["airportTo"].stringValue
                            dest.append(toAirport)
                        }
                        //dest.removeRange(1...dest.count-1)
                        completion(response: dest)
                    }
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
}

struct Flight {
    var from: String
    var to: String
    var price: Double
    var currency: Character
    var date: NSDate
}
