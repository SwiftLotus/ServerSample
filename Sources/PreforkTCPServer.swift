//
//  PreforkTCPServer.swift
//  use_bluesocket
//
//  Created by shanks-tmt on 2016/12/28.
//
//

import Foundation

#if os(Linux)
    import Glibc
#endif

import Socket

class PreforkTCPServer {
    let family: Socket.ProtocolFamily = .inet
    let QUIT: String = "QUIT"
    let port: Int32 = 1337
    let host: String = "127.0.0.1"
    let childNumber = 5
    
    
    var listenSocket: Socket? = nil
    var childPids = [Int32]()
    
    init() {
        do {
            try listenSocket = Socket.create(family: family)
        } catch _ {
        }
        
    }
    
    
    func makeChilds( handleRequest: @escaping (_ data: String) throws -> String) {
        guard let listener = self.listenSocket else {
            print("Unable to unwrap socket...")
            return;
        }
        
        
        do {
            try listener.listen(on: Int(port), maxBacklogSize: 10)
        } catch _ {
        }

        
        for _ in 0..<self.childNumber {
            let pid = fork()
            if pid > 0 {
                childPids.append(pid)
                continue
            }
            
            // 子进程，循环处理请求
            self.doRequest {
                do {
                        repeat {
                            let connectSocket = try listener.acceptClientConnection()
                
                            var bytesRead = 0
                
                            var readData = Data()
                            bytesRead = try connectSocket.read(into: &readData)
                    
                            if bytesRead > 0 {
                        
                                guard let response = NSString(data: readData, encoding: String.Encoding.utf8.rawValue) else {
                            
                                    print("Error decoding response...")
                                    readData.count = 0
                                    break
                                }
                                let reply = try handleRequest(String(describing: response))

                                try connectSocket.write(from: reply)
                        
                            }
                            connectSocket.close()

                        } while 1==1
                    } catch _ {
                                
                        
                    }
            }
        }
        
        //Glibc.Singal(SIGINT, self.dealSignal())
    }
    
    func doRequest(handleRequest: () -> ()) {
        handleRequest()
    }
    
    func dealSignal(signalNo: Int32) {
        
    }
    
}

