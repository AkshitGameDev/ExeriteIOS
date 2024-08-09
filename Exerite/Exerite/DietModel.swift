import Foundation

class DietCategory {
    var id: Int?
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

class DietItem {
    var id: Int
    var name: String
    var category: DietCategory
    var calories: Int
    var isDeleted: Bool
    
    init(id: Int, name: String, category: DietCategory, calories: Int, isDeleted: Bool) {
        self.id = id
        self.name = name
        self.category = category
        self.calories = calories
        self.isDeleted = isDeleted
    }
}
