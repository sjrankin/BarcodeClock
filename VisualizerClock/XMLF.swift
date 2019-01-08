//
//  XMLF.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/2/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Class that allows manipulation of fragments of XML text.
public class XMLF
{
    /// Returns a list of attributes in name="value" form.
    ///
    /// - Parameter Fragment: The fragment that will be parsed for attributes.
    /// - Returns: List of attributes in name="value" form.
    public static func GetAttributes(_ Fragment: String) -> [String]
    {
        var Final = [String]()
        if Fragment.isEmpty
        {
            return Final
        }
        let Parts = Fragment.split(separator: ">")
        if Parts.isEmpty
        {
            return Final
        }
        let Working0 = String(Parts.first!)
        let NodeName = NodeTitle(Fragment, RemoveXMLisms: false)
        let Working1 = Working0.replacingOccurrences(of: NodeName, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        let MoreParts = Working1.split(separator: "=")
        var Index = 0
        var x = [String]()
        for SomePart in MoreParts
        {
            let ThePart = String(String(SomePart).reversed())
            let SubParts = ThePart.split(separator: " ", maxSplits: 1).reversed()
            for ASubPart in SubParts
            {
                let ASubPartString = String(String(ASubPart).reversed())
                Index = Index + 1
                x.append(ASubPartString)
            }
        }
        var I = 0
        while I < x.count
        {
            if I % 2 == 0
            {
                let term = x[I] + "=" + x[I + 1]
                Final.append(term)
            }
            I = I + 1
        }
        return Final
    }
    
    /// Make a standard search term for attribute names in the form of " " + Attribute Name + "=".
    ///
    /// - Parameter Source: Attribute name.
    /// - Returns: Standard search term.
    private static func MakeAttributeSearchTerm(_ Source: String) -> String?
    {
        if Source.isEmpty
        {
            return nil
        }
        return " " + Source + "="
    }
    
    /// Determines if the passed XML fragment contains an attribute with the specified name.
    ///
    /// - Parameters:
    ///   - Fragment: XML fragment to search.
    ///   - Name: Name of the attribute to search for.
    /// - Returns: True if the attribute was found, false if: A) no attribute with the specified name was found; B) the XML
    ///            fragment was empty; C) the attribute name was empty.
    public static func ContainsAttribute(_ Fragment: String, Name: String) -> Bool
    {
        if Fragment.isEmpty
        {
            return false
        }
        if Name.isEmpty
        {
            return false
        }
        if let SearchFor = MakeAttributeSearchTerm(Name)
        {
            if Fragment.contains(SearchFor)
            {
                return true
            }
            else
            {
                return false
            }
        }
        return false
    }
    
    public static func AttributeString(_ Fragment: String, Name: String) -> String?
    {
        if !ContainsAttribute(Fragment, Name: Name)
        {
            return nil
        }
        let AllAttributes = GetAttributes(Fragment)
        for Attribute in AllAttributes
        {
            let Parts = Attribute.split(separator: "=")
            if String(Parts.first!) == Name
            {
                var AttrVal: String = String(Parts.last!)
                AttrVal.removeLast()
                AttrVal.remove(at: AttrVal.startIndex)
                return String(AttrVal)
            }
        }
        return nil
    }
    
    public static func AttributeBool(_ Fragment: String, Name: String) -> Bool?
    {
        if let Value = AttributeString(Fragment, Name: Name)
        {
            let LValue = Value.lowercased()
            if let BValue = Bool(LValue)
            {
                return BValue
            }
            else
            {
                return nil
            }
        }
        else
        {
            return nil
        }
    }
    
    public static func AttributeDouble(_ Fragment: String, Name: String) -> Double?
    {
        if let Value = AttributeString(Fragment, Name: Name)
        {
            if let DValue = Double(Value)
            {
                return DValue
            }
            else
            {
                return nil
            }
        }
        else
        {
            return nil
        }
    }
    
    public static func AttributeCGFloat(_ Fragment: String, Name: String) -> CGFloat?
    {
        if let Value = AttributeString(Fragment, Name: Name)
        {
            if let CValue = Double(Value)
            {
                return CGFloat(CValue)
            }
            else
            {
                return nil
            }
        }
        else
        {
            return nil
        }
    }
    
    public static func AttributeInt(_ Fragment: String, Name: String) -> Int?
    {
        if let Value = AttributeString(Fragment, Name: Name)
        {
            if let IValue = Int(Value)
            {
                return IValue
            }
            else
            {
                return nil
            }
        }
        else
        {
            return nil
        }
    }
    
    public static func NodeContents(_ Fragment: String) -> String
    {
        let Node = Fragment.trimmingCharacters(in: .whitespacesAndNewlines)
        let Parts = Node.split(separator: ">")
        let Part1 = Parts[1]
        let SubParts = Part1.split(separator: "<")
        let Result = String(SubParts[0])
        return Result
    }
    
    /// Returns the title of the fragment.
    ///
    /// - Parameters:
    ///   - Fragment: The fragment to parse for the node title.
    ///   - RemoveXMLisms: If true, XMLisms (such as opening angle brackets) are removed.
    /// - Returns: Name of the XML node.
    public static func NodeTitle(_ Fragment: String, RemoveXMLisms: Bool = true) -> String
    {
        let Node = Fragment.trimmingCharacters(in: .whitespacesAndNewlines)
        let Parts = Node.split(separator: " ")
        var First: String = String(Parts.first!)
        if RemoveXMLisms
        {
            First.remove(at: First.startIndex)
        }
        return First
    }
}
