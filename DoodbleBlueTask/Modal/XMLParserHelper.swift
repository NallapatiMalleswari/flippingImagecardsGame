//
//  XMLParserHelper.swift
//  DoodbleBlueTask
//
//  Created by malli nallapati on 25/05/18.
//  Copyright © 2018 malliswarinallapati. All rights reserved.
//

import Foundation
import CoreData

//protocol XMLPasringResultDelegate: NSObjectProtocol {
//    func parsedXmlStrings(name: String, size: String)
//}
protocol ImagesResultDelegate:NSObjectProtocol {
    func parsedImagesUrl(image: String)
}

class XMLParserHelper: NSObject {
   // var delegate: XMLPasringResultDelegate?
    var delegate:ImagesResultDelegate?
    func parseXmlFromFile(path: URL, completionHandler: @escaping(Bool)->()) {
        if let parser = XMLParser(contentsOf: path) {
            parser.delegate = self
            parser.parse()
            completionHandler(true)
        }
    }
}

extension XMLParserHelper: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "link"{
            if let imageUrl = attributeDict["href"], let url = URL.init(string:imageUrl), url.pathExtension == "jpg"{
                delegate?.parsedImagesUrl(image: imageUrl)
            }
        }

    }
}
