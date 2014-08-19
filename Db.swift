//
//  Db.swift
//  watchapp
//
//  Created by Florian Biewald on 28/07/14.
//  Copyright (c) 2014 Florian Biewald. All rights reserved.
//

import Foundation


class Db {
    enum Settings: String {
        case DbVersion = "db_version"
    }
    
    let dbName = "fancy_db.db"
    let version = 1.0
    var fmdb: FMDatabase
    var tmpDb: FMDatabase?

    init() {
        var paths:NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        var documentsDirectory: NSString = paths.objectAtIndex(0) as NSString
        var writableDBPath: NSString = documentsDirectory.stringByAppendingPathComponent(dbName);
        fmdb = FMDatabase(path: writableDBPath)
        fmdb.open()
    }

    deinit {
        close()
    }
    
    func close() {
        fmdb.close()
    }
    
    func saveSetting(name: Db.Settings, value: String) -> Bool {
        var existingValue = getSetting(name)
        if existingValue != nil {
            return fmdb.executeUpdate("UPDATE settings SET value = ? WHERE key = ?", withArgumentsInArray: [value, name.toRaw()])
        } else {
            return fmdb.executeUpdate("INSERT INTO settings (key, value) VALUES (?, ?)", withArgumentsInArray: [name.toRaw(), value])
        }
    }
    
    func getSetting(name: Db.Settings) -> String? {
        var resultset = fmdb.executeQuery(
            "SELECT value FROM settings WHERE key = ?",
            withArgumentsInArray: [name.toRaw()]
        )
        return resultset != nil && resultset.next() ? resultset.stringForColumn("value") : nil
    }
}
