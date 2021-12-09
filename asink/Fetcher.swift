//
//  Downloader.swift
//  asink
//
//  Created by Mikey Ward on 12/9/21.
//

import Foundation

class Fetcher {
    
    func fetchRandomDataFile(size: RandomDataSize, completion: @escaping (Result<URL,Error>) -> Void) {
        
        let downloadTask = URLSession.shared.downloadTask(with: size.url) {
            (localURL, response, error) -> Void in
            
            var result: Result<URL,Error> = .failure(.illegalExitWithoutCompletion)
            defer {
                if case let .failure(reason) = result, reason == .illegalExitWithoutCompletion {
                    fatalError("Illegal exit without completion")
                }
                completion(result)
            }
            
            guard let localURL = localURL else {
                result = .failure(.fetchFailure(error as! URLError))
                return
            }
            
            result = .success(localURL)

        }
        downloadTask.resume()
    }
    
}

// MARK: - Helper types

extension Fetcher {
    enum Error: Swift.Error, Equatable {
        case illegalExitWithoutCompletion
        case fetchFailure(URLError)
    }
    
    enum RandomDataSize {
        case tenMegabytes
        case hundredMegabytes
        case oneGigabyte
        
        fileprivate var url: URL {
            switch self {
            case .tenMegabytes: return URL(string: "https://mw-dropshare.s3.amazonaws.com/random_10MB-Qq8wFiLq.data")!
            case .hundredMegabytes: return URL(string: "https://mw-dropshare.s3.amazonaws.com/random_100MB-OYyMC5wd.data")!
            case .oneGigabyte: return URL(string: "")!
            }
        }
    }
}
