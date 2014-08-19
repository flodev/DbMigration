//
//  DbCreator.swift
//  watchapp
//
//  Created by Florian Biewald on 29/07/14.
//  Copyright (c) 2014 Florian Biewald. All rights reserved.
//

import Foundation

class DbMigration {

    var db: Db
    
    var migrationSuccessful = true
    
    var migration: Dictionary<Double, (db: FMDatabase) -> Bool> = [
        // 1.0 initial version
        1.0: {(db: FMDatabase) -> Bool in
            var success = true
            
            if !db.executeUpdate("CREATE TABLE IF NOT EXISTS settings (key TEXT,value TEXT)", withArgumentsInArray: nil) {
                success = false
                NSLog("Cannot create table settings")
            }
            
            return success
        },
        1.1: {(db: FMDatabase) -> Bool in
            var success = true
            
            if !db.executeUpdate("CREATE TABLE IF NOT EXISTS fancy_table (id INTEGER PRIMARY KEY,name TEXT)", withArgumentsInArray: nil) {
                success = false
                NSLog("Cannot create table fancy_table")
            }
            
            return success
        }
    ]

    init(db: Db) {
        self.db = db
    }
    
    func update() {
        var version = self.db.getSetting(Db.Settings.DbVersion)
        var versionFromDb: NSString = version != nil ? version! as NSString : "0.0",
            currentVersion = self.db.version,
            oldVersion = versionFromDb.doubleValue,
            success = true
            
        if oldVersion == currentVersion {
            NSLog("DB is up to date. Nothing todo")
            return
        }
            
        if oldVersion < currentVersion {
            for (version, update) in self.migration {
                if oldVersion < version {
                    NSLog("updating to version: " + NSString(format: "%f", version))
                    if !update(db: self.db.fmdb) {
                        success = false
                        NSLog("Failed updating to version: " + NSString(format: "%f", version))
                    }
                }
            }
        }
        if success {
            self.db.saveSetting(Db.Settings.DbVersion, value: NSString(format: "%f", self.db.version))
        } else {
            migrationSuccessful = false
        }
    }
}
