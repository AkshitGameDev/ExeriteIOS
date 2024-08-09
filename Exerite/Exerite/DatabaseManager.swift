//
//  DatabaseManager.swift
//  Exerite
//
//  Created by Akshit on 28/03/24.
//

import Foundation
import SQLite3

class DatabaseManager {
    static let shared = DatabaseManager()
    
    private var db: OpaquePointer?
    
     init() {
        if sqlite3_open(self.getDatabasePath(), &db) != SQLITE_OK {
            print("Error opening database: \(errorMessage())")
        } else {
            print("Successfully opened connection to database")
            createTables()
        }
    }
    
    deinit {
        if sqlite3_close(db) != SQLITE_OK {
            print("Error closing database: \(errorMessage())")
        } else {
            print("Successfully closed connection to database")
        }
    }
    
    private func createTables() {
        createUsersTable()
        createJournalsTable()
        createDietCategoriesTable()
        createDietItemsTable()
    }
    
    private func createUsersTable() {
        let createTableQuery = """
                                CREATE TABLE IF NOT EXISTS UserLogin (
                                    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
                                    username TEXT NOT NULL,
                                    email TEXT UNIQUE NOT NULL,
                                    password TEXT NOT NULL,
                                    profile_image BLOB
                                );
                                """
        executeQuery(createTableQuery, successMessage: "UserLogin table created successfully", errorMessage: "Error creating UserLogin table")
    }
    
    private func createJournalsTable() {
        let createTableQuery = """
                                CREATE TABLE IF NOT EXISTS Journals (
                                    journal_id INTEGER PRIMARY KEY AUTOINCREMENT,
                                    title TEXT NOT NULL,
                                    description TEXT NOT NULL
                                );
                                """
        executeQuery(createTableQuery, successMessage: "Journals table created successfully", errorMessage: "Error creating Journals table")
    }
    
    private func createDietCategoriesTable() {
           let createTableQuery = """
                                   CREATE TABLE IF NOT EXISTS DietCategories (
                                       category_id INTEGER PRIMARY KEY AUTOINCREMENT,
                                       name TEXT NOT NULL
                                   );
                                   """
           executeQuery(createTableQuery, successMessage: "DietCategories table created successfully", errorMessage: "Error creating DietCategories table")
       }
       
       private func createDietItemsTable() {
           let createTableQuery = """
                                   CREATE TABLE IF NOT EXISTS DietItems (
                                       item_id INTEGER PRIMARY KEY AUTOINCREMENT,
                                       name TEXT NOT NULL,
                                       category_id INTEGER NOT NULL,
                                       calories INTEGER NOT NULL,
                                       is_deleted INTEGER NOT NULL DEFAULT 0,
                                       FOREIGN KEY(category_id) REFERENCES DietCategories(category_id)
                                   );
                                   """
           executeQuery(createTableQuery, successMessage: "DietItems table created successfully", errorMessage: "Error creating DietItems table")
       }
    
    func insertUser(email: String, username: String, password: String) {
        let insertQuery = "INSERT INTO UserLogin (username, email, password) VALUES (?, ?, ?);"
        var insertStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertQuery, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (username as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (email as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (password as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) != SQLITE_DONE {
                print("Error inserting user: \(errorMessage())")
            } else {
                print("User inserted successfully")
                let userId = Int(sqlite3_last_insert_rowid(db))
                UserDefaults.standard.set(userId, forKey: "LoggedInUserId")
                UserDefaults.standard.set(username, forKey: "LoggedInUsername")
                UserDefaults.standard.synchronize()
            }
        } else {
            print("Error preparing insert statement: \(errorMessage())")
        }
        
        sqlite3_finalize(insertStatement)
    }
    
    func getUserByEmailAndPassword(email: String, password: String) -> Bool {
        let selectQuery = "SELECT * FROM UserLogin WHERE email = ? AND password = ?;"
        var selectStatement: OpaquePointer?
        var result = false
        
        if sqlite3_prepare_v2(db, selectQuery, -1, &selectStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(selectStatement, 1, email, -1, nil)
            sqlite3_bind_text(selectStatement, 2, password, -1, nil)
            
            if sqlite3_step(selectStatement) == SQLITE_ROW {
                let userId = Int(sqlite3_column_int(selectStatement, 0))
                if let usernamePointer = sqlite3_column_text(selectStatement, 1) {
                    let username = String(cString: usernamePointer)
                    UserDefaults.standard.set(userId, forKey: "LoggedInUserId")
                    UserDefaults.standard.set(username, forKey: "LoggedInUsername")
                    UserDefaults.standard.synchronize()
                    result = true
                }
            }
        } else {
            print("Error preparing select statement: \(errorMessage())")
        }
        
        sqlite3_finalize(selectStatement)
        return result
    }
    
    func getUserByUserId(userId: Int) -> (userId: Int, username: String, email: String)? {
        let selectQuery = "SELECT user_id, username, email FROM UserLogin WHERE user_id = ?;"
        var selectStatement: OpaquePointer?
        var userData: (userId: Int, username: String, email: String)? = nil
        
        if sqlite3_prepare_v2(db, selectQuery, -1, &selectStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(selectStatement, 1, Int32(userId))
            
            if sqlite3_step(selectStatement) == SQLITE_ROW {
                let userId = Int(sqlite3_column_int(selectStatement, 0))
                
                if let usernamePointer = sqlite3_column_text(selectStatement, 1) {
                    let username = String(cString: usernamePointer)
                    
                    if let emailPointer = sqlite3_column_text(selectStatement, 2) {
                        let email = String(cString: emailPointer)
                        
                        userData = (userId, username, email)
                    } else {
                        print("Error: Failed to retrieve email for user with ID \(userId)")
                    }
                } else {
                    print("Error: Failed to retrieve username for user with ID \(userId)")
                }
            } else {
                print("Error: No user found with ID \(userId)")
            }
        } else {
            print("Error preparing select statement: \(errorMessage())")
        }
        
        sqlite3_finalize(selectStatement)
        return userData
    }
    
    func getAllUserData() {
        let selectQuery = "SELECT * FROM UserLogin;"
        var selectStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, selectQuery, -1, &selectStatement, nil) == SQLITE_OK {
            while sqlite3_step(selectStatement) == SQLITE_ROW {
                let userId = Int(sqlite3_column_int(selectStatement, 0))
                if let usernamePointer = sqlite3_column_text(selectStatement, 1),
                   let emailPointer = sqlite3_column_text(selectStatement, 2),
                   let passwordPointer = sqlite3_column_text(selectStatement, 3) {
                    let username = String(cString: usernamePointer)
                    let email = String(cString: emailPointer)
                    let password = String(cString: passwordPointer)
                    
                    print("User ID: \(userId), Username: \(username), Email: \(email), Password: \(password)")
                }
            }
        } else {
            print("Error preparing select statement: \(errorMessage())")
        }
        
        sqlite3_finalize(selectStatement)
    }
    
    func fetchProfileImageData(forUserID userID: Int) -> Data? {
        let query = "SELECT profile_image FROM UserLogin WHERE user_id = ?;"
        var statement: OpaquePointer?
        var imageData: Data? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(userID))
            
            if sqlite3_step(statement) == SQLITE_ROW, let blobData = sqlite3_column_blob(statement, 0) {
                let blobLength = sqlite3_column_bytes(statement, 0)
                imageData = Data(bytes: blobData, count: Int(blobLength))
            }
        } else {
            print("Error preparing select statement: \(errorMessage())")
        }
        
        sqlite3_finalize(statement)
        return imageData
    }
    
    func insertJournal(title: String, description: String) {
        let insertQuery = "INSERT INTO Journals (title, description) VALUES (?, ?);"
        var insertStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertQuery, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (title as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (description as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) != SQLITE_DONE {
                print("Error inserting journal: \(errorMessage())")
            } else {
                print("Journal inserted successfully")
            }
        } else {
            print("Error preparing insert statement: \(errorMessage())")
        }
        
        sqlite3_finalize(insertStatement)
    }
    
    func updateJournal(id: Int, newTitle: String, newDescription: String) {
        let updateQuery = "UPDATE Journals SET title = ?, description = ? WHERE journal_id = ?;"
        var updateStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, updateQuery, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(updateStatement, 1, (newTitle as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 2, (newDescription as NSString).utf8String, -1, nil)
            sqlite3_bind_int(updateStatement, 3, Int32(id))
            
            if sqlite3_step(updateStatement) != SQLITE_DONE {
                print("Error updating journal: \(errorMessage())")
            } else {
                print("Journal updated successfully")
            }
        } else {
            print("Error preparing update statement: \(errorMessage())")
        }
        
        sqlite3_finalize(updateStatement)
    }
    
    func deleteJournal(id: Int) {
        let deleteQuery = "DELETE FROM Journals WHERE journal_id = ?;"
        var deleteStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteQuery, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(deleteStatement, 1, Int32(id))
            
            if sqlite3_step(deleteStatement) != SQLITE_DONE {
                print("Error deleting journal: \(errorMessage())")
            } else {
                print("Journal deleted successfully")
            }
        } else {
            print("Error preparing delete statement: \(errorMessage())")
        }
        
        sqlite3_finalize(deleteStatement)
    }
    
    func getAllJournals() -> [JournalModel] {
          var journals: [JournalModel] = []
          let selectQuery = "SELECT * FROM Journals;"
          var selectStatement: OpaquePointer?
          
          if sqlite3_prepare_v2(db, selectQuery, -1, &selectStatement, nil) == SQLITE_OK {
              while sqlite3_step(selectStatement) == SQLITE_ROW {
                  let journalId = Int(sqlite3_column_int(selectStatement, 0))
                  let titlePointer = sqlite3_column_text(selectStatement, 1)
                  let title = String(cString: titlePointer!)
                  let descriptionPointer = sqlite3_column_text(selectStatement, 2)
                  let description = String(cString: descriptionPointer!)
                  
                  let journal = JournalModel(id: journalId, title: title, description: description)
                  journals.append(journal)
              }
          } else {
              print("Error preparing select statement")
          }
          
          sqlite3_finalize(selectStatement)
          return journals
      }
          
    func preloadDietData() {
        let categories = [
            DietCategory(name: "NonVeg"),
            DietCategory(name: "Veg"),
            DietCategory(name: "Drinks")
        ]
        
        for category in categories {
            insertDietCategory(category)
        }
        
        let categoryIdMap = fetchDietCategoryIds()
        
        let dietItems = [
            // NonVeg Items
            DietItem(id: 1, name: "Grilled Chicken", category: categoryIdMap["NonVeg"]!, calories: 200, isDeleted: false),
            DietItem(id: 2, name: "Chicken Curry", category: categoryIdMap["NonVeg"]!, calories: 250, isDeleted: false),
            DietItem(id: 3, name: "Chicken Wings", category: categoryIdMap["NonVeg"]!, calories: 180, isDeleted: false),
            DietItem(id: 4, name: "Beef Steak", category: categoryIdMap["NonVeg"]!, calories: 300, isDeleted: false),
            DietItem(id: 5, name: "Fish Fillet", category: categoryIdMap["NonVeg"]!, calories: 220, isDeleted: false),
            DietItem(id: 6, name: "Roast Turkey", category: categoryIdMap["NonVeg"]!, calories: 280, isDeleted: false),
            DietItem(id: 7, name: "Lamb Chops", category: categoryIdMap["NonVeg"]!, calories: 320, isDeleted: false),
            DietItem(id: 8, name: "Pork Ribs", category: categoryIdMap["NonVeg"]!, calories: 270, isDeleted: false),
            DietItem(id: 9, name: "Shrimp Scampi", category: categoryIdMap["NonVeg"]!, calories: 230, isDeleted: false),
            DietItem(id: 10, name: "Beef Burger", category: categoryIdMap["NonVeg"]!, calories: 350, isDeleted: false),
            // Veg Items
            DietItem(id: 11, name: "Salad", category: categoryIdMap["Veg"]!, calories: 100, isDeleted: false),
            DietItem(id: 12, name: "Stir-fried Vegetables", category: categoryIdMap["Veg"]!, calories: 120, isDeleted: false),
            DietItem(id: 13, name: "Grilled Vegetables", category: categoryIdMap["Veg"]!, calories: 90, isDeleted: false),
            DietItem(id: 14, name: "Vegetable Curry", category: categoryIdMap["Veg"]!, calories: 150, isDeleted: false),
            DietItem(id: 15, name: "Vegetable Soup", category: categoryIdMap["Veg"]!, calories: 80, isDeleted: false),
            DietItem(id: 16, name: "Broccoli", category: categoryIdMap["Veg"]!, calories: 50, isDeleted: false),
            DietItem(id: 17, name: "Spinach Salad", category: categoryIdMap["Veg"]!, calories: 70, isDeleted: false),
            DietItem(id: 18, name: "Cucumber Salad", category: categoryIdMap["Veg"]!, calories: 60, isDeleted: false),
            DietItem(id: 19, name: "Steamed Asparagus", category: categoryIdMap["Veg"]!, calories: 70, isDeleted: false),
            DietItem(id: 20, name: "Zucchini Noodles", category: categoryIdMap["Veg"]!, calories: 80, isDeleted: false),
            // Drinks
            DietItem(id: 21, name: "Water", category: categoryIdMap["Drinks"]!, calories: 0, isDeleted: false),
            DietItem(id: 22, name: "Fresh Juice", category: categoryIdMap["Drinks"]!, calories: 120, isDeleted: false),
            DietItem(id: 23, name: "Soda", category: categoryIdMap["Drinks"]!, calories: 150, isDeleted: false),
            DietItem(id: 24, name: "Tea", category: categoryIdMap["Drinks"]!, calories: 30, isDeleted: false),
            DietItem(id: 25, name: "Coffee", category: categoryIdMap["Drinks"]!, calories: 20, isDeleted: false),
            DietItem(id: 26, name: "Milkshake", category: categoryIdMap["Drinks"]!, calories: 200, isDeleted: false),
            DietItem(id: 27, name: "Lemonade", category: categoryIdMap["Drinks"]!, calories: 100, isDeleted: false),
            DietItem(id: 28, name: "Iced Tea", category: categoryIdMap["Drinks"]!, calories: 50, isDeleted: false),
            DietItem(id: 29, name: "Hot Chocolate", category: categoryIdMap["Drinks"]!, calories: 180, isDeleted: false),
            DietItem(id: 30, name: "Smoothie", category: categoryIdMap["Drinks"]!, calories: 150, isDeleted: false)
        ]
        
        for item in dietItems {
            insertDietItem(item: item)
        }
    }
    
    func insertDietItem(item: DietItem) {
        let insertQuery = """
                          INSERT INTO DietItems (name, category_id, calories, is_deleted)
                          VALUES (?, ?, ?, ?);
                          """
        var insertStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertQuery, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (item.name as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 2, Int32(item.category.id!))
            sqlite3_bind_int(insertStatement, 3, Int32(item.calories))
            sqlite3_bind_int(insertStatement, 4, item.isDeleted ? 1 : 0)
            
            if sqlite3_step(insertStatement) != SQLITE_DONE {
                print("Error inserting diet item: \(errorMessage())")
            } else {
                print("Diet item \(item.name) inserted successfully")
            }
        } else {
            print("Error preparing insert statement: \(errorMessage())")
        }
        
        sqlite3_finalize(insertStatement)
    }

    private func fetchDietCategoryIds() -> [String: DietCategory] {
        let query = """
                    SELECT category_id, name FROM DietCategories;
                    """
        var queryStatement: OpaquePointer?
        var categoryIdMap: [String: DietCategory] = [:]
        
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(queryStatement, 0)
                let name = String(cString: sqlite3_column_text(queryStatement, 1))
                categoryIdMap[name] = DietCategory(id: Int(id), name: name)
            }
        } else {
            print("Error preparing select statement: \(errorMessage())")
        }
        
        sqlite3_finalize(queryStatement)
        return categoryIdMap
    }

    
    private func insertDietCategory(_ category: DietCategory) {
        let insertQuery = """
                          INSERT INTO DietCategories (name)
                          VALUES (?);
                          """
        var insertStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertQuery, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (category.name as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) != SQLITE_DONE {
                print("Error inserting category: \(errorMessage())")
            } else {
                print("Category \(category.name) inserted successfully")
            }
        } else {
            print("Error preparing insert statement: \(errorMessage())")
        }
        
        sqlite3_finalize(insertStatement)
    }

    func insertDiet(title: String, description: String) {
        let insertQuery = "INSERT INTO DietItems (title, description) VALUES (?, ?);"
        var insertStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertQuery, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (title as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (description as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) != SQLITE_DONE {
                print("Error inserting diet: \(errorMessage())")
            } else {
                print("Diet inserted successfully")
            }
        } else {
            print("Error preparing insert statement: \(errorMessage())")
        }
        
        sqlite3_finalize(insertStatement)
    }

    func updateDiet(id: Int, newTitle: String, newDescription: String) {
        let updateQuery = "UPDATE DietItems SET name = ?, calories = ? WHERE item_id = ?;"
        var updateStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, updateQuery, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(updateStatement, 1, (newTitle as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 2, (newDescription as NSString).utf8String, -1, nil)
            sqlite3_bind_int(updateStatement, 3, Int32(id))
            
            if sqlite3_step(updateStatement) != SQLITE_DONE {
                print("Error updating diet: \(errorMessage())")
            } else {
                print("Diet updated successfully")
            }
        } else {
            print("Error preparing update statement: \(errorMessage())")
        }
        
        sqlite3_finalize(updateStatement)
    }
    
    func deleteDiet(id: Int) {
           let deleteQuery = "DELETE FROM DietItems WHERE item_id = ?;"
           var deleteStatement: OpaquePointer?

           if sqlite3_prepare_v2(db, deleteQuery, -1, &deleteStatement, nil) == SQLITE_OK {
               sqlite3_bind_int(deleteStatement, 1, Int32(id))

               if sqlite3_step(deleteStatement) != SQLITE_DONE {
                   print("Error deleting diet: \(errorMessage())")
               } else {
                   print("Diet deleted successfully")
               }
           } else {
               print("Error preparing delete statement: \(errorMessage())")
           }

           sqlite3_finalize(deleteStatement)
       }
    
    
    func fetchDietCategories() -> [DietCategory] {
        let query = "SELECT category_id, name FROM DietCategories;"
        var queryStatement: OpaquePointer?
        var categories: [DietCategory] = []
        
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let name = String(cString: sqlite3_column_text(queryStatement, 1))
                let category = DietCategory(id: id, name: name)
                categories.append(category)
            }
        } else {
            print("Error preparing select statement: \(errorMessage())")
        }
        
        sqlite3_finalize(queryStatement)
        return categories
    }
    
    func fetchDietItems(forCategory category: DietCategory? = nil) -> [DietItem] {
        var query = "SELECT item_id, name, category_id, calories, is_deleted FROM DietItems WHERE is_deleted = 0"
        var items: [DietItem] = []

        if let category = category {
            query += " AND category_id = \(category.id ?? 0)"
        }

        var queryStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let name = String(cString: sqlite3_column_text(queryStatement, 1))
                let categoryId = Int(sqlite3_column_int(queryStatement, 2))
                let calories = Int(sqlite3_column_int(queryStatement, 3))
                let isDeleted = sqlite3_column_int(queryStatement, 4) != 0

                let category = fetchDietCategoryById(categoryId: categoryId)

                let item = DietItem(id: id, name: name, category: category, calories: calories, isDeleted: isDeleted)
                items.append(item)
            }
        } else {
            print("Error preparing select statement: \(errorMessage())")
        }

        sqlite3_finalize(queryStatement)
        return items
    }

    func getItems(forCategory category: DietCategory) -> [DietItem] {
        return fetchDietItems(forCategory: category)
    }

    private func fetchDietCategoryById(categoryId: Int) -> DietCategory {
        let query = "SELECT name FROM DietCategories WHERE category_id = ?;"
        var queryStatement: OpaquePointer?
        var category: DietCategory?
        
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(queryStatement, 1, Int32(categoryId))
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                let name = String(cString: sqlite3_column_text(queryStatement, 0))
                category = DietCategory(id: categoryId, name: name)
            }
        } else {
            print("Error preparing select statement: \(errorMessage())")
        }
        
        sqlite3_finalize(queryStatement)
        
        return category ?? DietCategory(id: categoryId, name: "Unknown")
    }

   
    
     func getDatabasePath() -> String {
        let fileManager = FileManager.default
        let documentsURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        return documentsURL.appendingPathComponent("dietBuddy.sqlite").path
    }
    
    private func errorMessage() -> String {
        return String(cString: sqlite3_errmsg(db)!)
    }
    
    private func executeQuery(_ query: String, successMessage: String, errorMessage: String) {
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print(successMessage)
            } else {
                print(errorMessage)
            }
        } else {
            print("Error preparing statement: \(self.errorMessage())")
        }
        
        sqlite3_finalize(statement)
    }
}
