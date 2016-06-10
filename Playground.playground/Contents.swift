//: Playground - noun: a place where people can play

import UIKit

let northByte: UInt8 = 0x0F ^ UInt8(1 << 0)
let eastByte: UInt8 = 0x0F ^ UInt8(1 << 1)
let westByte: UInt8 = 0x0F ^ UInt8(1 << 2)
let southByte: UInt8 = 0x0F ^ UInt8(1 << 3)
let clearByte: UInt8 = 0x000F

String((northByte & eastByte), radix:2)
String(~(northByte & eastByte) & 0xF, radix:2)

let deviceBytes: [UInt8] = [~(northByte & eastByte) & 0xF]
let data = NSData(bytes: deviceBytes, length: 1)
var bytes = [UInt8](count: data.length, repeatedValue: 0)
data.getBytes(&bytes, length: bytes.count)
String(bytes[0], radix:2)
