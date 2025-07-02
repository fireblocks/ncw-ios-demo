//
//  AppLogger.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 14/12/2023.
//

import Foundation

class AppLoggerManager {
    var loggers = [String: AppLogger]()
    
    static let shared = AppLoggerManager()
    
    private init() {}
    
    func logger() -> AppLogger? {
        return loggers[FireblocksManager.shared.getDeviceId()]
    }
}

private enum LogLevel: String {
   case none
   case verbose
   case debug
   case info
   case warn
   case error
   
   public var rank: Int {
       switch self {
       case .none:
           return 0
       case .verbose:
           return 1
       case .debug:
           return 2
       case .info:
           return 3
       case  .warn:
           return 4
       case .error:
           return 5
       }
   }
}

final class AppLogger {

    internal let deviceId: String
    internal let logPrefix: String
    
    private let MAX_FILE_SIZE = 950000
    private let logFile1: String
    private let logFile2: String
    private var currentLogFile: String

    init(deviceId: String) {
        self.deviceId = deviceId
        self.logPrefix = "#@! - \(deviceId)"
        self.logFile1 = "demo_log1"
        self.logFile2 = "demo_log2"
        self.currentLogFile = logFile1
    }
    
    func getLogsAsString() -> String {
        guard let logsFolder = try? getFilesFolder() else { return "" }

        let logFilePath = logsFolder.appendingPathComponent("\(self.currentLogFile).txt")
        let prevFile = currentLogFile == logFile1 ? logFile2 : logFile1
        let prevFilePath = logsFolder.appendingPathComponent("\(prevFile).txt")

        var contentPrev = try? String(contentsOf: prevFilePath, encoding: .utf8)
        if contentPrev == nil {
            contentPrev = ""
        }
        
        let contentCurrent = try? String(contentsOf: logFilePath, encoding: .utf8)

        return contentPrev!.appending(contentCurrent ?? "TEST")
    }
        
    func getURLForLogFiles() -> URL? {
        let fm = FileManager.default

        var archiveUrl: URL?
        var error: NSError?

        let coordinator = NSFileCoordinator()
        
        do {
            let logsFolder = try getFilesFolder()
            coordinator.coordinate(readingItemAt: logsFolder, options: [.forUploading], error: &error) { (zipUrl) in
                do {
                    let tmpUrl = try fm.url(
                        for: .itemReplacementDirectory,
                        in: .userDomainMask,
                        appropriateFor: zipUrl,
                        create: true
                    ).appendingPathComponent("DemoZippedLogs.zip")
                    try fm.moveItem(at: zipUrl, to: tmpUrl)
                    archiveUrl = tmpUrl
                } catch {
                }
            }
            
            return archiveUrl

        } catch {
            debugPrint(error)
            return nil
        }
        
    }

    private func getFilesFolder() throws -> URL {
        let fm = FileManager.default
        let baseDirectoryURL = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let logsFolderURL = baseDirectoryURL.appendingPathComponent("Fireblocks/DemoApp/")
        var isDirectory : ObjCBool = true
        let exists = fm.fileExists(atPath: logsFolderURL.absoluteString, isDirectory: &isDirectory)
        
        if !(exists && isDirectory.boolValue) {
            do {
                try fm.createDirectory(
                    at: logsFolderURL,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                debugPrint(error)
                throw error
            }
        }

        return logsFolderURL
        
    }
    
    func log(_ msg: String) {
        write(generateLog(level: .info, msg))
    }
    
    func debug(_ msg: String) {
        write(generateLog(level: .debug, msg))
    }
    
    func warning(_ msg: String) {
        write(generateLog(level: .warn, msg))
    }
    
    func error(_ msg: String) {
        write(generateLog(level: .error, msg))
    }
    
    private func generateLog(level: LogLevel = .info, _ msg: String) -> String {
        return "\(Date().milliseconds()) - \(logPrefix) - \(level.rawValue.uppercased()) - \(msg)\n"
    }
    
    private func write(_ string: String) {
        if let logSize = string.data(using: .utf8) {
            if getCurrentFileSize() + logSize.count > MAX_FILE_SIZE {
                toggleCurrentFile(string: string)
            }
        } else {
            return
        }

        do {
            let logsFolder = try getFilesFolder()
            let logFilePath = logsFolder.appendingPathComponent("\(self.currentLogFile).txt")
            if let handle = try? FileHandle(forWritingTo: logFilePath) {
                handle.seekToEndOfFile()
                if let data = string.data(using: .utf8) {
                    handle.write(data)
                }
                handle.closeFile()
            } else {
                try? string.data(using: .utf8)?.write(to: logFilePath)
            }
            debugPrint(string)
        } catch {
            debugPrint(error)
        }

    }
        
    private func getCurrentFileSize() -> Int {
        do {
            let file = try getFilesFolder().appendingPathComponent("\(self.currentLogFile).txt")
            return file.fileSize ?? 0
        } catch {
            debugPrint(error)
            return 0
        }
    }
    
    private func toggleCurrentFile(string: String) {
        if currentLogFile == logFile1 {
            currentLogFile = logFile2
        } else {
            currentLogFile = logFile1
            
        }
        
        do {
            let logsFolder = try getFilesFolder()
            let logFilePath = logsFolder.appendingPathComponent("\(self.currentLogFile).txt")
            if currentLogFile == logFile1 {
                let text = ""
                try text.write(to: logFilePath, atomically: false, encoding: .utf8)
            } else {
                if let handle = try? FileHandle(forWritingTo: logFilePath) {
                    handle.seekToEndOfFile()
                    if let data = string.data(using: .utf8) {
                        handle.write(data)
                    }
                    handle.closeFile()
                } else {
                    let text = ""
                    try text.write(to: logFilePath, atomically: false, encoding: .utf8)
                }
            }
        } catch {
            debugPrint(error)
        }
    }
    
    private func debugPrint(_ item: Any) {
        #if DEBUG
        print(item)
        #endif
    }
    
}

extension URL {
    var fileSize: Int? {
        let value = try? resourceValues(forKeys: [.fileSizeKey])
        return value?.fileSize
    }
}
