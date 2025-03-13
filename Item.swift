//
//  Item.swift
//  Arkan
//
//  Created by mac on 2/2/25.
//
import Foundation
import CoreData

@objc(Item)
public class Item: NSManagedObject {
    @NSManaged public var name: String?
    @NSManaged public var value: String?
}
