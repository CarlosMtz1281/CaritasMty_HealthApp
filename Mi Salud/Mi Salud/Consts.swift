//
//  Consts.swift
//  Mi Salud
//
//  Created by Germán Salas on 22/08/24.
//

import UIKit
import SwiftUI

struct Constants {
    // MARK: - Colors
    struct Colors {
        static let PANTONE_320_C = UIColor(named: "PANTONE_320_C") ?? UIColor.gray
        static let primary = UIColor(named: "PANTONE_302_C") ?? UIColor.gray
        static let background = UIColor(named: "PANTONE_601_C") ?? UIColor.gray
        static let PANTONE_COOL_GRAY_8_C = UIColor(named: "PANTONE_COOL_GRAY_8_C") ?? UIColor.gray
        static let PANTONE_621_C = UIColor(named: "PANTONE_621_C") ?? UIColor.gray
        static let accent = UIColor(named: "PANTONE_1575_C") ?? UIColor.gray
        static let fontColor = Color(.black)
        static let fontColor2 = Color(.white)
        
    }

  
    static let path = "https://sabritones.tc2007b.tec.mx:10206/"
    //static let path = "http://192.168.1.65:8000/"
    //static let path = "http://localhost:8000"

    // MARK: - Endpoints
    struct Endpoints {
        static let BASE_API_URL = ""
    }
    
    // MARK: - Keys
    struct Keys {
        static let USER_TOKEN_KEY = ""
    }
}
