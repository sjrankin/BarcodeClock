//
//  FileUtility.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/2/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

public class FileUtility
{
    /// Return the URL for the Document directory.
    ///
    /// - Returns: The URL of the Documents directory.
    public static func GetDocumentDirectory() -> URL?
    {
        let Dir = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
        if !FileManager.default.fileExists(atPath: Dir)
        {
            let FM = FileManager.default
            do
            {
            try FM.createDirectory(atPath: Dir, withIntermediateDirectories: true, attributes: nil)
            }
            catch
            {
                return nil
            }
        }
        let TheDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return TheDirectory
    }
    
    /// Determines if a file with the specified name in the specified directory exists.
    ///
    /// - Parameters:
    ///   - Directory: The directory to search for the file.
    ///   - FileName: Name of the file to search for.
    /// - Returns: True if the file exists, false if not.
    public static func FileExists(Directory: URL, FileName: String) -> Bool
    {
        if FileName.isEmpty
        {
            return false
        }
        let FinalPath = Directory.appendingPathComponent(FileName)
        let DoesExist = FileManager.default.fileExists(atPath: FinalPath.path)
    return DoesExist
    }
    
    /// Determines if a file with the specified name exists in the Documents directory.
    ///
    /// - Parameter FileName: Name of the file to check for existence.
    /// - Returns: True if the file exists, false if not.
    public static func FileExistsInDocuments(FileName: String) -> Bool
    {
        return FileExists(Directory: GetDocumentDirectory()!, FileName: FileName)
    }
    
    /// Return the contents of the file a the specified URL.
    ///
    /// - Parameter File: The URL of the file whose contents will be returned.
    /// - Returns: The contents of the file (in string format).
    public static func FileContents(File: URL) -> String
    {
        do
        {
            let Contents = try String(contentsOf: File, encoding: .utf8)
            return Contents
        }
        catch
        {
            print("Error reading file \(File.path)")
            print("\(error.localizedDescription)")
        }
        return ""
    }
    
    /// Return the contents of the file with the specified name. The file is assumed to reside in the Documents directory.
    ///
    /// - Parameter FileName: Name of the file whose contents will be returned.
    /// - Returns: Contents of the specified file on success, empty string on error.
    public static func FileContents(FileName: String) -> String
    {
        if FileName.isEmpty
        {
            print("Invalid file name.")
            return ""
        }
        return FileContents(File: (GetDocumentDirectory()?.appendingPathComponent(FileName))!)
    }
    
    /// Write a string to the file at the specified URL. If the file already exists, it will be overwritten.
    ///
    /// - Parameters:
    ///   - Source: The string to write.
    ///   - File: The URL of the destination file.
    /// - Returns: True on success, false on failure.
    @discardableResult public static func WriteString(_ Source: String, File: URL) -> Bool
    {
        if FileManager.default.fileExists(atPath: File.path)
        {
            do
            {
                try FileManager.default.removeItem(at: File)
            }
            catch
            {
                print("Error removing \(File.path): \(error.localizedDescription)")
                return false
            }
        }
        do
        {
            try Source.write(to: File, atomically: true, encoding: .utf8)
        }
        catch
        {
            print("Error writing string to \(File.path): \(error.localizedDescription)")
            return false
        }
        return true
    }
    
    /// Write a string to the file whose name is FileName. Older contents will be overwritten. The file will be saved in
    /// the Documents directory.
    ///
    /// - Parameters:
    ///   - Source: The string to write.
    ///   - FileName: The name of the file.
    /// - Returns: True on success, false on failure.
    @discardableResult public static func WriteString(_ Source: String, FileName: String) -> Bool
    {
        if FileName.isEmpty
        {
            print("Invalid file name.")
            return false
        }
        if let FileURL = GetDocumentDirectory()?.appendingPathComponent(FileName)
        {
            return WriteString(Source, File: FileURL)
        }
        return false
    }
}
