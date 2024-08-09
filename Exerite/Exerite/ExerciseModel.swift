//
//  ExerciseModel.swift
//  Exerite
//
//  Created by Om on 27/03/24.
//
import Foundation

struct ExerciseCategory {
    let id: Int
    let name: String
}

struct ExerciseModel {
    let categories: [ExerciseCategory]
    let subcategoriesManager: ExerciseSubcategoryManager
    
    init() {
        self.categories = [
            ExerciseCategory(id: 1, name: "Cardio"),
            ExerciseCategory(id: 2, name: "Arms"),
        ]
        
        self.subcategoriesManager = ExerciseSubcategoryManager.shared
    }
}

struct ExerciseSubcategory {
    let id: Int
    let name: String
    let categoryID: Int
    let duration: Int 
    let isSelected: Bool
}

class ExerciseSubcategoryManager {
    static let shared = ExerciseSubcategoryManager()
    
    private init() {}
    
    func getSubcategories(forCategory category: ExerciseCategory) -> [ExerciseSubcategory] {
        switch category.name {
            case "Cardio":
                return [
                    ExerciseSubcategory(id: 1, name: "Running", categoryID: category.id, duration: 30, isSelected: false),
                    ExerciseSubcategory(id: 2, name: "Cycling", categoryID: category.id, duration: 45, isSelected: false),
                    ExerciseSubcategory(id: 3, name: "Swimming", categoryID: category.id, duration: 60, isSelected: false),
                    ExerciseSubcategory(id: 4, name: "Jump Rope", categoryID: category.id, duration: 20, isSelected: false),
                    ExerciseSubcategory(id: 5, name: "Rowing", categoryID: category.id, duration: 45, isSelected: false),
                    ExerciseSubcategory(id: 6, name: "HIIT", categoryID: category.id, duration: 20, isSelected: false),
                    ExerciseSubcategory(id: 7, name: "Stair Climbing", categoryID: category.id, duration: 15, isSelected: false),
                    ExerciseSubcategory(id: 8, name: "Kickboxing", categoryID: category.id, duration: 30, isSelected: false),
                    ExerciseSubcategory(id: 9, name: "Aerobics", categoryID: category.id, duration: 45, isSelected: false),
                    ExerciseSubcategory(id: 10, name: "Dancing", categoryID: category.id, duration: 40, isSelected: false)
                ]
            case "Arms":
                return [
                    ExerciseSubcategory(id: 11, name: "Bicep Curls", categoryID: category.id, duration: 20, isSelected: false),
                    ExerciseSubcategory(id: 12, name: "Tricep Dips", categoryID: category.id, duration: 15, isSelected: false),
                    ExerciseSubcategory(id: 13, name: "Push-ups", categoryID: category.id, duration: 25, isSelected: false),
                    ExerciseSubcategory(id: 14, name: "Chin-ups", categoryID: category.id, duration: 30, isSelected: false),
                    ExerciseSubcategory(id: 15, name: "Hammer Curls", categoryID: category.id, duration: 20, isSelected: false),
                    ExerciseSubcategory(id: 16, name: "Tricep Extensions", categoryID: category.id, duration: 15, isSelected: false),
                    ExerciseSubcategory(id: 17, name: "Shoulder Press", categoryID: category.id, duration: 25, isSelected: false),
                    ExerciseSubcategory(id: 18, name: "Bench Press", categoryID: category.id, duration: 30, isSelected: false),
                    ExerciseSubcategory(id: 19, name: "Arm Circles", categoryID: category.id, duration: 10, isSelected: false),
                    ExerciseSubcategory(id: 20, name: "Dumbbell Rows", categoryID: category.id, duration: 25, isSelected: false)
                ]
            default:
                return []
        }
    }
}
