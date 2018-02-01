# youtube-video-launcher

# Usage
This project is intended as an add-on to your existing project. It contains mostly UIView Swift files that are built entirely through code (not storyboard). The view will animate from a touchpoint (typically an image thumbnail) to fullscreen where the user is presented a custom view with video playback to control the YouTube iOS Player Helper. 

You can find the helper here -> https://developers.google.com/youtube/v3/guides/ios_youtube_helper

You can interact with the launcher by downloading the Sports for YouTube app here -> http://appstore.com/sportsforyoutube

# Implementation
Pass along a touchpoint (where the user taps) from your object/view to the VideoLauncher.Swift file. The following explains how to do so...

Add a touchGesture to your object/view, create the touchpoint, and pass along the through a closure:
```
var videoPressed : ((_ touchPoint: CGPoint) -> Void)?

let tapGesture = UITapGestureRecognizer(target: self, action: #selector(YouTubeVideoLargeCell.handleTopicTapGesture(_:)))
videoImageView.addGestureRecognizer(tapGesture)

@objc func handleTopicTapGesture(_ sender: UITapGestureRecognizer) {
    //get touchPoint so we can animate view from here
    var touchPoint = sender.location(in: self)
    if var topController = UIApplication.shared.keyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        //more accurate touchPoint
        touchPoint = sender.location(in: topController.view)
    }

    if self.videoPressed != nil {
        self.videoPressed!(touchPoint)
    }
}
```
Retreive the tap by completing the closure function in another view/controller:
```
youtubeVideoLargeView.videoPressed = {[weak self] selectedVideos, touchPoint, thumbnailImage in
    if self != nil {
        let rect = CGRect(x: (touchPoint.x), y: (touchPoint.y), width: 120, height: 120)
        let videoLauncher = VideoLauncher()
        videoLauncher.originPoint = rect
        videoLauncher.thumbnailImage = thumbnailImage
        videoLauncher.posts = selectedVideos!
        videoLauncher.showVideoPlayer()
    }
}
```
# Info
This project references an object called BBPost. The BBPost object is a custom class that is not included with this project. It contains several properties used by the Video Launcher including the youtube link, title, and creatorName. You are encouraged to replace this object with your own custom class.

