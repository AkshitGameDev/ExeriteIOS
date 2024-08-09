//
//  HomeModel.swift
//  Exerite
//
//  Created by Manan on 20/03/24.
//

import Foundation

struct MenuItem {
    let title: String
}

class HomeModel {
    let menuItems: [MenuItem] = [
        MenuItem(title: "Exercise"),
        MenuItem(title: "Diet"),
        MenuItem(title: "Journal"),
    ]
}
