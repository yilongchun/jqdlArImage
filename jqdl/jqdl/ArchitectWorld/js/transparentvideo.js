var World2 = {
    loaded: false,
        
    init: function initFn() {
        this.createOverlays();
    },
        
    createOverlays: function createOverlaysFn() {
        // Initialize ClientTracker
        this.tracker = new AR.ClientTracker("assets2/tracker.wtc", {
                                            
        });
        
        var video = new AR.VideoDrawable("assets2/transparentVideo.mp4", 0.7, {
                                         offsetX: -0.2,
                                         offsetY: -0.12,
                                         isTransparent: true
        });
        
        // Create a button which opens a website in a browser window after a click
        this.imgButton = new AR.ImageResource("assets2/wwwButton.jpg");
        var pageOneButton = this.createWwwButton("https://www.blue-tomato.com/en-US/products/?q=sup", 0.1, {
                                                 offsetX: -0.05,
                                                 offsetY: 0.2,
                                                 zOrder: 1
        });
        video.play(-1);
        video.pause();
        
        var pageOne = new AR.Trackable2DObject(this.tracker, "*", {
                                           drawables: {
                                           cam: [video, pageOneButton]
                                           },
                                           onEnterFieldOfVision: function onEnterFieldOfVisionFn() {
                                               AR.logger.debug("识别到物品,播放视频");
                                               video.resume();
                                           },
                                           onExitFieldOfVision: function onExitFieldOfVisionFn() {
                                               AR.logger.debug("识别结束,视频暂停");
                                               video.pause();
                                           }
       });
    },
        
    createWwwButton: function createWwwButtonFn(url, size, options) {
        options.onClick = function() {
            // this call opens a url in a browser window
            AR.context.openInBrowser(url);
        };
        return new AR.ImageDrawable(this.imgButton, size, options);
    }
};

World2.init();
