//
//  TitleConstructor.swift
//  STBonjour
//
//  Created by Eric Dolecki on 7/8/16.
//  Copyright © 2016 Eric Dolecki. All rights reserved.
//

import Foundation

class TitleConstructor: NSObject {
    
    override init(){
        //
    }
    
    func translateString(sValue:String) -> String
    {
        var returnString = "??"
        if sValue.characters.count < 1 {
            return returnString
        }
        
        // Split the string if possible.
        
        let textarray = sValue.characters.split(" ")
        
        if textarray.count == 1 {
            
            let firstTwo = String(textarray[textarray.startIndex.advancedBy(0)...textarray.startIndex.advancedBy(1)])
            let firstTwoFixed = firstTwo.capitalizedString
            returnString = firstTwoFixed
            
        } else if textarray.count > 1 {
            
            //Get the first two characters, one from each of the first two
            
            let firstChunk = textarray[0]
            var firstLetter = String(firstChunk.first!)
            firstLetter = firstLetter.capitalizedString
            
            let secondChunk = textarray[1]
            var lastLetter = String(secondChunk.first!)
            lastLetter = lastLetter.lowercaseString
            returnString = "\(firstLetter)\(lastLetter)"
        }
        return returnString
    }
}