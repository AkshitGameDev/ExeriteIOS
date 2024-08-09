//
//  ExerciseSubcategoryDatabase.swift
//  Exerite
//
//  Created by Om on 28/03/24.
//

import Foundation
import SQLite3

class ExerciseSubcategoryDatabase {
    static let shared = ExerciseSubcategoryDatabase()
    private var db: OpaquePointer?

    private init() {
        openDatabase()
        createExerciseSubcategoryTable()
    }

    private func openDatabase() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("ExerciseSubcategoryDatabase.sqlite3")
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
    }

    private func createExerciseSubcategoryTable() {
        let createTableString = """
        CREATE TABLE IF NOT EXISTS ExerciseSubcategory(
            id INTEGER PRIMARY KEY,
            name TEXT,
            categoryID INTEGER,
            duration INTEGER,
            isSelected INTEGER DEFAULT 0
        );
        """

        var createTableStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("ExerciseSubcategory table created successfully.")
            } else {
                print("ExerciseSubcategory table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    
       func insert(exerciseSubcategory: ExerciseSubcategory) {
           let insertStatementString = "INSERT INTO ExerciseSubcategory (name, categoryID, duration, isSelected) VALUES (?, ?, ?, ?);"
           var insertStatement: OpaquePointer?
           if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
               let name = exerciseSubcategory.name as NSString
               let categoryID = Int32(exerciseSubcategory.categoryID)
               let duration = Int32(exerciseSubcategory.duration)
               let isSelectedInt: Int32 = exerciseSubcategory.isSelected ? 1 : 0

               sqlite3_bind_text(insertStatement, 1, name.utf8String, -1, nil)
               sqlite3_bind_int(insertStatement, 2, categoryID)
               sqlite3_bind_int(insertStatement, 3, duration)
               sqlite3_bind_int(insertStatement, 5, isSelectedInt)

               if sqlite3_step(insertStatement) == SQLITE_DONE {
                   print("Successfully inserted new exercise subcategory.")
               } else {
                   print("Could not insert new exercise subcategory.")
               }
           } else {
               print("INSERT statement could not be prepared.")
           }
           sqlite3_finalize(insertStatement)
       }

    func updateSelectedExercise(exerciseID: Int, isSelected: Bool) {
        let updateStatementString = "UPDATE ExerciseSubcategory SET isSelected = ? WHERE id = ?;"
        var updateStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            let isSelectedInt = isSelected ? 1 : 0
            sqlite3_bind_int(updateStatement, 1, Int32(isSelectedInt))
            sqlite3_bind_int(updateStatement, 2, Int32(exerciseID))
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated selected exercise.")
            } else {
                print("Could not update selected exercise.")
            }
        } else {
            print("UPDATE statement could not be prepared.")
        }
        sqlite3_finalize(updateStatement)
    }
    
    func getAllSelectedExercises() -> [ExerciseSubcategory] {
        var selectedExercises = [ExerciseSubcategory]()
        let queryStatementString = "SELECT * FROM ExerciseSubcategory WHERE isSelected = 1;"
        var queryStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let name = String(cString: sqlite3_column_text(queryStatement, 1))
                let categoryID = Int(sqlite3_column_int(queryStatement, 2))
                let duration = Int(sqlite3_column_int(queryStatement, 3))
                let isSelected = sqlite3_column_int(queryStatement, 4) != 0
                let exerciseSubcategory = ExerciseSubcategory(id: id, name: name, categoryID: categoryID, duration: duration, isSelected: isSelected)
                selectedExercises.append(exerciseSubcategory)
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return selectedExercises
    }
    
    func getCategoryWiseExercises(categoryID: Int) -> [ExerciseSubcategory] {
        var selectedExercises = [ExerciseSubcategory]()
        let queryStatementString = "SELECT * FROM ExerciseSubcategory WHERE categoryID = ?;"
        var queryStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(queryStatement, 1, Int32(categoryID))
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let name = String(cString: sqlite3_column_text(queryStatement, 1))
                let categoryID = Int(sqlite3_column_int(queryStatement, 2))
                let duration = Int(sqlite3_column_int(queryStatement, 3))
                let isSelected = sqlite3_column_int(queryStatement, 4) != 0
                let exerciseSubcategory = ExerciseSubcategory(id: id, name: name, categoryID: categoryID, duration: duration, isSelected: isSelected)
                selectedExercises.append(exerciseSubcategory)
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return selectedExercises
    }

    func getAllExercises() -> [ExerciseSubcategory] {
        var selectedExercises = [ExerciseSubcategory]()
        let queryStatementString = "SELECT * FROM ExerciseSubcategory;"
        var queryStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let name = String(cString: sqlite3_column_text(queryStatement, 1))
                let categoryID = Int(sqlite3_column_int(queryStatement, 2))
                let duration = Int(sqlite3_column_int(queryStatement, 3))
                let isSelected = sqlite3_column_int(queryStatement, 4) != 0
                let exerciseSubcategory = ExerciseSubcategory(id: id, name: name, categoryID: categoryID, duration: duration, isSelected: isSelected)
                selectedExercises.append(exerciseSubcategory)
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return selectedExercises
    }

}
