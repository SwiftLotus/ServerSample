//
//  fork.swift
//  use_bluesocket
//
//  Created by shanks-tmt on 2016/12/19.
//
//

import Foundation

#if os(Linux)
    import Glibc
#endif


class Daemon {
    init() {
        var pid = fork()
        
        if -1 == pid {
            exit(0)
            // 异常处理
        } else if pid > 0 { // 父进程
            exit(0)
        }
        
        if -1 == setsid() {
            exit(0)
        }
        // Fork again avoid SVR4 system regain the control of terminal.
        pid = fork();
        if -1 == pid {
            exit(0)
        } else if pid > 0 {
            exit(0);
        }
    }
    
    func create(work: ()->()) {
        let pid = fork()
        
        if -1 == pid {
            // 异常处理
        } else if pid > 0 { // 父进程
            exit(0)
        }
        work()
    }
    
    
}
