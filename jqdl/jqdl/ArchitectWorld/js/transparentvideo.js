var World2 = {
    
        
    
        
    createOverlays: function createOverlaysFn() {
        
//        this.tracker = new AR.ClientTracker("assets2/tracker.wtc", {
//                                            
//        });
        this.tracker = new AR.ClientTracker("assets2/magazine.wtc", {
                                            
                                            });
        
        var video = new AR.VideoDrawable("assets2/transparentVideo.mp4", 0.7, {
                                         offsetX: -0.2,
                                         offsetY: -0.12,
                                         isTransparent: true
        });
        
        video.play(-1);
        video.pause();
        
        var pageOne = new AR.Trackable2DObject(this.tracker, "*", {
                                           drawables: {
                                               cam: [video]
                                           },
                                           onEnterFieldOfVision: function onEnterFieldOfVisionFn() {
                                               AR.logger.debug("识别到物品");
//                                               video.resume();
                                               
                                               var architectSdkUrl = "architectsdk://tracker?id=123";
                                               document.location = architectSdkUrl;
                                               
                                           },
                                           onExitFieldOfVision: function onExitFieldOfVisionFn() {
                                               AR.logger.debug("识别结束,视频暂停");
//                                               video.pause();
                                           }
       });
    }
        
    
};

World2.createOverlays();
