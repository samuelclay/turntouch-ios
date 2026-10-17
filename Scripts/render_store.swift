import AppKit
import Foundation
let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let locales = try JSONSerialization.jsonObject(with: Data(contentsOf:root.appendingPathComponent("localization/store-locales.json"))) as! [String:String]
let photo=NSImage(contentsOf:root.appendingPathComponent("store/artwork/assets/remote.jpg"))!
func color(_ r:CGFloat,_ g:CGFloat,_ b:CGFloat)->NSColor {NSColor(srgbRed:r/255,green:g/255,blue:b/255,alpha:1)}
func text(_ string:String,_ rect:NSRect,_ size:CGFloat,_ weight:NSFont.Weight,_ color:NSColor,_ rtl:Bool=false) {
 let style=NSMutableParagraphStyle();style.alignment=rtl ? .right:.left;style.baseWritingDirection=rtl ? .rightToLeft:.leftToRight;style.lineSpacing=10;style.lineBreakStrategy=[.hangulWordPriority,.pushOut]
 var fontSize=size
 var attrs:[NSAttributedString.Key:Any]=[:]
 while true {attrs=[.font:NSFont.systemFont(ofSize:fontSize,weight:weight),.foregroundColor:color,.paragraphStyle:style];let bounds=(string as NSString).boundingRect(with:NSSize(width:rect.width,height:10000),options:[.usesLineFragmentOrigin,.usesFontLeading],attributes:attrs);if bounds.height+30<=rect.height || fontSize<=70 {break};fontSize-=4}
 (string as NSString).draw(with:rect,options:[.usesLineFragmentOrigin,.usesFontLeading],attributes:attrs)
}
func image(_ image:NSImage,_ rect:NSRect,_ radius:CGFloat) {
 NSGraphicsContext.saveGraphicsState();NSBezierPath(roundedRect:rect,xRadius:radius,yRadius:radius).addClip();image.draw(in:rect,from:.zero,operation:.sourceOver,fraction:1,respectFlipped:true,hints:[.interpolation:NSImageInterpolation.high]);NSGraphicsContext.restoreGraphicsState()
}
let selected = CommandLine.arguments.dropFirst()
for lang in locales.keys.sorted() where selected.isEmpty || selected.contains(lang) {
 let copy=try JSONSerialization.jsonObject(with:Data(contentsOf:root.appendingPathComponent("localization/store/\(lang).json"))) as! [String:String]
 for (placement,h) in [("header",1646),("search",2560)] {
  let w=3840; let bitmap=NSBitmapImageRep(bitmapDataPlanes:nil,pixelsWide:w,pixelsHigh:h,bitsPerSample:8,samplesPerPixel:4,hasAlpha:true,isPlanar:false,colorSpaceName:.deviceRGB,bytesPerRow:0,bitsPerPixel:0)!
  NSGraphicsContext.saveGraphicsState();NSGraphicsContext.current=NSGraphicsContext(cgContext:NSGraphicsContext(bitmapImageRep:bitmap)!.cgContext,flipped:true)
  let transform=NSAffineTransform();transform.translateX(by:0,yBy:CGFloat(h));transform.scaleX(by:1,yBy:-1);transform.concat()
  let ctx=NSGraphicsContext.current!;ctx.imageInterpolation = .high
  color(242,240,235).setFill();NSRect(x:0,y:0,width:w,height:h).fill()
  let rtl=["ar","he"].contains(lang), navy=color(38,67,79), accent=color(175,99,54)
  text("TURN TOUCH",NSRect(x:220,y:placement=="header" ? 190:200,width:1470,height:130),84,.semibold,navy,rtl)
  text(lang == "en" ? "Your favorite\nactions, one\ntouch away" : copy["screenshot-caption"]!,NSRect(x:220,y:placement=="header" ? 410:440,width:1480,height:placement=="header" ? 690:820),placement=="header" ? 190:220,.semibold,navy,rtl)
  text(copy["subtitle"]!,NSRect(x:220,y:placement=="header" ? 1230:1410,width:1430,height:180),76,.regular,accent,rtl)
  let photoRect=NSRect(x:1780,y:placement=="header" ? 210:700,width:1850,height:1233)
  image(photo,photoRect,100)
  let screenURL=root.appendingPathComponent("store/\(locales[lang]!)/images/iphone/01-remote.png")
  if let screen=NSImage(contentsOf:screenURL) {
   let sw:CGFloat=placement=="header" ? 550:600, sh=sw*screen.size.height/screen.size.width
   let frame=NSRect(x:3030,y:placement=="header" ? 200:440,width:sw,height:sh)
   navy.setFill();NSBezierPath(roundedRect:frame.insetBy(dx:-16,dy:-16),xRadius:65,yRadius:65).fill();image(screen,frame,50)
  } else {fatalError("Missing localized screenshot \(lang)")}
  NSGraphicsContext.restoreGraphicsState()
  let out=root.appendingPathComponent("store/artwork/exports/\(lang)");try FileManager.default.createDirectory(at:out,withIntermediateDirectories:true)
  let format:NSBitmapImageRep.FileType=placement=="header" ? .png:.jpeg
  let opaque=NSBitmapImageRep(bitmapDataPlanes:nil,pixelsWide:w,pixelsHigh:h,bitsPerSample:8,samplesPerPixel:3,hasAlpha:false,isPlanar:false,colorSpaceName:.deviceRGB,bytesPerRow:w*3,bitsPerPixel:24)!
  for y in 0..<h { for x in 0..<w { let src=y*bitmap.bytesPerRow+x*4,dst=y*opaque.bytesPerRow+x*3;for c in 0..<3 {opaque.bitmapData![dst+c]=bitmap.bitmapData![src+c]} } }
  try opaque.representation(using:format,properties:[.compressionFactor:0.95])!.write(to:out.appendingPathComponent("turntouch-\(lang)-\(placement).\(placement=="header" ? "png":"jpg")"))
 }
 print("Rendered \(lang)")
}
