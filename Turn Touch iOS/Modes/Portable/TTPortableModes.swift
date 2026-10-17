import Foundation

@objcMembers
class TTModeVideo: TTMode {
    override class func title() -> String { return TTText("Video") }
    override class func subtitle() -> String { return TTText("Control video playback") }
    override class func imageName() -> String { return "mode_video.png" }
    override class func actions() -> [String] { return ["TTModeVideoVolumeUp", "TTModeVideoVolumeDown", "TTModeVideoFF", "TTModeVideoRewind", "TTModeVideoPause", "TTModeVideoFullScreen"] }
    override func shouldUseModeOptionsFor(_ action: String) -> Bool { return true }
    override func defaultNorth() -> String { return "TTModeVideoVolumeUp" }
    override func defaultEast() -> String { return "TTModeVideoPause" }
    override func defaultWest() -> String { return "TTModeVideoFullScreen" }
    override func defaultSouth() -> String { return "TTModeVideoVolumeDown" }
    func titleTTModeVideoVolumeUp() -> String { return TTText("Volume up") }
    func imageTTModeVideoVolumeUp() -> String { return "music_volume_up.png" }
    func runTTModeVideoVolumeUp() { TTMobileBrowser.run(mode: TTText("Video"), action: "VolumeUp") }
    func titleTTModeVideoVolumeDown() -> String { return TTText("Volume down") }
    func imageTTModeVideoVolumeDown() -> String { return "music_volume_down.png" }
    func runTTModeVideoVolumeDown() { TTMobileBrowser.run(mode: "Video", action: "VolumeDown") }
    func titleTTModeVideoFF() -> String { return TTText("Fast forward") }
    func imageTTModeVideoFF() -> String { return "music_ff.png" }
    func runTTModeVideoFF() { TTMobileBrowser.run(mode: "Video", action: "FF") }
    func titleTTModeVideoRewind() -> String { return TTText("Rewind") }
    func imageTTModeVideoRewind() -> String { return "music_rewind.png" }
    func runTTModeVideoRewind() { TTMobileBrowser.run(mode: "Video", action: "Rewind") }
    func titleTTModeVideoPause() -> String { return TTText("Play/pause") }
    func imageTTModeVideoPause() -> String { return "music_play_pause.png" }
    func runTTModeVideoPause() { TTMobileBrowser.run(mode: "Video", action: "Pause") }
    func titleTTModeVideoFullScreen() -> String { return TTText("Full screen") }
    func imageTTModeVideoFullScreen() -> String { return "fullscreen.png" }
    func runTTModeVideoFullScreen() { TTMobileBrowser.run(mode: "Video", action: "FullScreen") }
}

@objcMembers
class TTModeNews: TTMode {
    override class func title() -> String { return TTText("NewsBlur") }
    override class func subtitle() -> String { return TTText("Read your NewsBlur stories") }
    override class func imageName() -> String { return "mode_news.png" }
    override class func actions() -> [String] { return ["TTModeNewsNextStory", "TTModeNewsNextSite", "TTModeNewsPreviousStory", "TTModeNewsPreviousSite", "TTModeNewsScrollUp", "TTModeNewsScrollDown", "TTModeNewsMenu"] }
    override func shouldUseModeOptionsFor(_ action: String) -> Bool { return true }
    override func defaultNorth() -> String { return "TTModeNewsScrollUp" }
    override func defaultEast() -> String { return "TTModeNewsNextStory" }
    override func defaultWest() -> String { return "TTModeNewsMenu" }
    override func defaultSouth() -> String { return "TTModeNewsScrollDown" }
    func titleTTModeNewsNextStory() -> String { return TTText("Next story") }
    func imageTTModeNewsNextStory() -> String { return "next.png" }
    func runTTModeNewsNextStory() { TTMobileBrowser.run(mode: TTText("News"), action: "NextStory") }
    func titleTTModeNewsNextSite() -> String { return TTText("Next site") }
    func imageTTModeNewsNextSite() -> String { return "next_site.png" }
    func runTTModeNewsNextSite() { TTMobileBrowser.run(mode: "News", action: "NextSite") }
    func titleTTModeNewsPreviousStory() -> String { return TTText("Previous story") }
    func imageTTModeNewsPreviousStory() -> String { return "previous.png" }
    func runTTModeNewsPreviousStory() { TTMobileBrowser.run(mode: "News", action: "PreviousStory") }
    func titleTTModeNewsPreviousSite() -> String { return TTText("Previous site") }
    func imageTTModeNewsPreviousSite() -> String { return "previous_site.png" }
    func runTTModeNewsPreviousSite() { TTMobileBrowser.run(mode: "News", action: "PreviousSite") }
    func titleTTModeNewsScrollUp() -> String { return TTText("Scroll up") }
    func imageTTModeNewsScrollUp() -> String { return "scroll_up.png" }
    func runTTModeNewsScrollUp() { TTMobileBrowser.run(mode: "News", action: TTText("ScrollUp")) }
    func titleTTModeNewsScrollDown() -> String { return TTText("Scroll down") }
    func imageTTModeNewsScrollDown() -> String { return "scroll_down.png" }
    func runTTModeNewsScrollDown() { TTMobileBrowser.run(mode: "News", action: "ScrollDown") }
    func titleTTModeNewsMenu() -> String { return TTText("Menu") }
    func imageTTModeNewsMenu() -> String { return "menu.png" }
    func runTTModeNewsMenu() { TTMobileBrowser.run(mode: "News", action: "Menu") }
}

@objcMembers
class TTModeWeb: TTMode {
    override class func title() -> String { return TTText("Web") }
    override class func subtitle() -> String { return TTText("Browse the web") }
    override class func imageName() -> String { return "mode_web.png" }
    override class func actions() -> [String] { return ["TTModeWebMenu", "TTModeWebNext", "TTModeWebScrollUp", "TTModeWebScrollDown"] }
    override func shouldUseModeOptionsFor(_ action: String) -> Bool { return true }
    override func defaultNorth() -> String { return "TTModeWebScrollUp" }
    override func defaultEast() -> String { return "TTModeWebNext" }
    override func defaultWest() -> String { return "TTModeWebMenu" }
    override func defaultSouth() -> String { return "TTModeWebScrollDown" }
    func titleTTModeWebMenu() -> String { return TTText("Menu") }
    func imageTTModeWebMenu() -> String { return "menu.png" }
    func runTTModeWebMenu() { TTMobileBrowser.run(mode: "Web", action: "Menu") }
    func titleTTModeWebNext() -> String { return TTText("OK / Next") }
    func imageTTModeWebNext() -> String { return "next_site.png" }
    func runTTModeWebNext() { TTMobileBrowser.run(mode: "Web", action: "Next") }
    func titleTTModeWebScrollUp() -> String { return TTText("Scroll up") }
    func imageTTModeWebScrollUp() -> String { return "scroll_up.png" }
    func runTTModeWebScrollUp() { TTMobileBrowser.run(mode: "Web", action: "ScrollUp") }
    func titleTTModeWebScrollDown() -> String { return TTText("Scroll down") }
    func imageTTModeWebScrollDown() -> String { return "scroll_down.png" }
    func runTTModeWebScrollDown() { TTMobileBrowser.run(mode: "Web", action: "ScrollDown") }
}

@objcMembers
class TTModePresentation: TTMode {
    override class func title() -> String { return TTText("Presentation") }
    override class func subtitle() -> String { return TTText("Control your presentation") }
    override class func imageName() -> String { return "mode_presentation.png" }
    override class func actions() -> [String] { return ["TTModePresentationNextSlide", "TTModePresentationPreviousSlide", "TTModePresentationToggleSlides", "TTModePresentationPlay", "TTModePresentationVolumeUp", "TTModePresentationVolumeDown"] }
    override func shouldUseModeOptionsFor(_ action: String) -> Bool { return true }
    override func defaultNorth() -> String { return "TTModePresentationToggleSlides" }
    override func defaultEast() -> String { return "TTModePresentationNextSlide" }
    override func defaultWest() -> String { return "TTModePresentationPreviousSlide" }
    override func defaultSouth() -> String { return "TTModePresentationPlay" }
    func titleTTModePresentationNextSlide() -> String { return TTText("Next slide") }
    func imageTTModePresentationNextSlide() -> String { return "music_ff.png" }
    func runTTModePresentationNextSlide() { TTMobileBrowser.run(mode: "Presentation", action: "NextSlide") }
    func titleTTModePresentationPreviousSlide() -> String { return TTText("Previous slide") }
    func imageTTModePresentationPreviousSlide() -> String { return "music_rewind.png" }
    func runTTModePresentationPreviousSlide() { TTMobileBrowser.run(mode: "Presentation", action: "PreviousSlide") }
    func titleTTModePresentationToggleSlides() -> String { return TTText("Toggle slides") }
    func imageTTModePresentationToggleSlides() -> String { return "presentation_slides.png" }
    func runTTModePresentationToggleSlides() { TTMobileBrowser.run(mode: "Presentation", action: "ToggleSlides") }
    func titleTTModePresentationPlay() -> String { return TTText("Play presentation") }
    func imageTTModePresentationPlay() -> String { return "music_play.png" }
    func runTTModePresentationPlay() { TTMobileBrowser.run(mode: "Presentation", action: "Play") }
    func titleTTModePresentationVolumeUp() -> String { return TTText("Volume up") }
    func imageTTModePresentationVolumeUp() -> String { return "music_volume_up.png" }
    func runTTModePresentationVolumeUp() { TTMobileBrowser.run(mode: "Presentation", action: "VolumeUp") }
    func titleTTModePresentationVolumeDown() -> String { return TTText("Volume down") }
    func imageTTModePresentationVolumeDown() -> String { return "music_volume_down.png" }
    func runTTModePresentationVolumeDown() { TTMobileBrowser.run(mode: "Presentation", action: "VolumeDown") }
}
