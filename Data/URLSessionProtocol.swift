//
//  URLSessionProtocol.swift
//  RideFlagChallenge
//
//  Created by Nikita on 2021-01-06.
//

import Foundation

protocol URLSessionProtocol {
    associatedtype dta: URLSessionDataTaskProtocol
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> dta
}
