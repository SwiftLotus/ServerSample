//
//  Server.swift
//  use_bluesocket
//
//  Created by shanks-tmt on 2016/12/26.
//
//

import Foundation

#if os(Linux)
    import Glibc
#endif

import Socket

class TCPServer {
    let family: Socket.ProtocolFamily = .inet
    let QUIT: String = "QUIT"
    let port: Int32 = 1337
    let host: String = "127.0.0.1"
    let path: String = "/tmp/server"
    
    
    
    init?()  {
        
        var keepRunning: Bool = true
        var listenSocket: Socket? = nil
        
        do {
            
            try listenSocket = Socket.create(family: family)
            
            guard let listener = listenSocket else {
                print("Unable to unwrap socket...")
                return nil
            }
            
            var socket: Socket
            
            // Are we setting uo a TCP or UNIX based server?
            if family == .inet || family == .inet6 {
                
                // Setting up TCP...
                try listener.listen(on: Int(port), maxBacklogSize: 10)
                
                print("Listening on port: \(port)")
                
                socket = try listener.acceptClientConnection()
                
              //  print("Accepted connection from: \(socket.remoteHostname) on port \(socket.remotePort), Secure? \(socket.signature!.isSecure)")
                
            } else {
                
                // Setting up UNIX...
                // try listener.listen(on: path, maxBacklogSize: 10)
                
                print("Listening on path: \(path)")
                
                socket = try listener.acceptClientConnection()
                
               // print("Accepted connection from: \(socket.remotePath!), Secure? \(socket.signature!.isSecure)")
                
            }
            
            try socket.write(from: "Hello, type 'QUIT' to end session\n")
            
            var bytesRead = 0
            repeat {
                
                var readData = Data()
                bytesRead = try socket.read(into: &readData)
                
                if bytesRead > 0 {
                    
                    guard let response = NSString(data: readData, encoding: String.Encoding.utf8.rawValue) else {
                        
                        print("Error decoding response...")
                        readData.count = 0
                        break
                    }
                    
                    if response.hasPrefix(QUIT) {
                        
                        keepRunning = false
                    }
                    
                    // TCP or UNIX?
                    if family == .inet || family == .inet6 {
                        //print("Server received from connection at \(socket.remoteHostname):\(socket.remotePort): \(response) ")
                    } else {
                        //print("Server received from connection at \(socket.remotePath!): \(response) ")
                    }
                    
                    let reply = "Server response: \n\(response)\n"
                    try socket.write(from: reply)
                    
                }
                
                if bytesRead == 0 {
                    
                    break
                }
                
            } while keepRunning
            
            socket.close()
            
        } catch let error {
            
            guard let socketError = error as? Socket.Error else {
                
                print("Unexpected error...")
                
                return nil
            }
            
            // This error is expected when we're shutting it down...
            if socketError.errorCode == Int32(Socket.SOCKET_ERR_WRITE_FAILED) {
                return nil
            }
            print("serverHelper Error reported: \(socketError.description)")
        }
        
    }
    
    func listen() {
        
    }
    
    func accpetConnection() {
        
    }
}

