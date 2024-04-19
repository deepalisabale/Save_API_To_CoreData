//
//  Album.swift
//  Save_API_To_CoreData
//
//  Created by Deepali on 19/04/24.
//

import Foundation

struct Album:Decodable{
    var albumId : Int
    var id : Int
    var title : String
    var url : String
    var thumbnailUrl : String
}
