//
//  ViewController.swift
//  SQLLite
//
//  Created by Aleksandr Pronin on 4/9/16.
//  Copyright © 2016 RIT. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileManager = NSFileManager.defaultManager()
        var sqliteDB: COpaquePointer = nil
        var dbURL: NSURL? = nil
        
        do {
            let baseURL = try fileManager.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
            dbURL = baseURL.URLByAppendingPathComponent("swift.sqlite")
            
        } catch {
            print("error: \(error)")
        }
        if let dbURL = dbURL {
            let flags = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE
            let status = sqlite3_open_v2(dbURL.absoluteString.cStringUsingEncoding(NSUTF8StringEncoding)!, &sqliteDB, flags, nil)
            if status == SQLITE_OK {
                let errMsg: UnsafeMutablePointer<UnsafeMutablePointer<Int8>> = nil
                let sqlStatement = "create table if not exists Tutorials (ID Integer Primary key AutoIncrement, Title Text, Author Text, PublicationDate Date);"
                if sqlite3_exec(sqliteDB, sqlStatement, nil, nil, errMsg) == SQLITE_OK {
                    print("created table")
                } else {
                    print("failed to create table")
                }
                var statement: COpaquePointer = nil
                let insertStatement = "insert into Tutorials (Title, Author, PublicationDate) values ('Intro to SQLite', 'Ray Wenderlich', '2015-11-11 11:00:00');"
                sqlite3_prepare_v2(sqliteDB, insertStatement, -1, &statement, nil)
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("inserted")
                } else {
                    print("not inserted")
                }
                sqlite3_finalize(statement)
                
                var selectStatement: COpaquePointer = nil
                let selectSql = "select * from Tutorials"
                if sqlite3_prepare_v2(sqliteDB, selectSql, -1, &selectStatement, nil) == SQLITE_OK {
                    while sqlite3_step(selectStatement) == SQLITE_ROW {
                        let rowID = sqlite3_column_int(selectStatement, 0)
                        let title = UnsafePointer<CChar>(sqlite3_column_text(selectStatement, 1))
                        let author = UnsafePointer<CChar>(sqlite3_column_text(selectStatement, 2))
                        let date = UnsafePointer<CChar>(sqlite3_column_text(selectStatement, 3))
                        let titleString = String.fromCString(title)!
                        let authortring = String.fromCString(author)!
                        let datetring = String.fromCString(date)!
                        print("rowID: \(rowID) title: \(titleString) authortring: \(authortring) datetring: \(datetring)")
                    }
                }
                sqlite3_finalize(selectStatement)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

