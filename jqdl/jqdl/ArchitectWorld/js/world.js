// information about server communication. This sample webservice is provided by Wikitude and returns random dummy places near given location
var ServerInformation = {
	POIDATA_SERVER: "https://example.wikitude.com/GetSamplePois/",
	POIDATA_SERVER_ARG_LAT: "lat",
	POIDATA_SERVER_ARG_LON: "lon",
	POIDATA_SERVER_ARG_NR_POIS: "nrPois"
};

// implementation of AR-Experience (aka "World")
var World = {
	// you may request new data from server periodically, however: in this sample data is only requested once
	isRequestingData: false,

	// true once data was fetched
	initiallyLoadedData: false,
    
    //是否点击detailImage
    isClickDetailImage: false,
    
    initialized: false,

	// different POI-Marker assets
	markerDrawable_idle: null,
	markerDrawable_selected: null,
	markerDrawable_directionIndicator: null,

	// list of AR.GeoObjects that are currently shown in the scene / World
	markerList: [],
    //jingquListLocation
    jingquList: [],
    
    jingquType:0,//2 街景默认 1 景区
    
//    jingquLat:0,
//    jingquLng:0,

	// The last selected marker
	currentMarker: null,
    

	locationUpdateCounter: 0,
	updatePlacemarkDistancesEveryXLocationUpdates: 5,
    
    
    // called to inject new POI data
    loadJingquPoisFromJsonData: function loadJingquPoisFromJsonDataFn(poiData) {
        
        if (World.currentMarker) {
            World.currentMarker.setDeselected(World.currentMarker);
            World.isClickDetailImage = false;
            World.currentMarker = null;
        }
        
        //        for(var i = 0;i < World.markerList.length;i++){
        //            World.markerList[i].markerObject.destroy();
        //
        //        }
        AR.context.destroyAll();
        // show radar & set click-listener
        PoiRadar.show();
        //        PoiRadar.setMaxDistance(1000);
        //        AR.context.scene.cullingDistance = 10000;
        
        
        AR.logger.debug("wikitude sdk versionNumber:" + AR.context.versionNumber);
        
        
        AR.context.scene.minScalingDistance = 22;
        AR.context.scene.maxScalingDistance = 300;
        AR.context.scene.scalingFactor = 0.4;
        
        
        $('#radarContainer').unbind('click');
        $("#radarContainer").click(PoiRadar.clickedRadar);
        
        // empty list of visible markers
        World.markerList = [];
        World.jingquList = [];
        
        // start loading marker assets
        World.markerDrawable_idle = new AR.ImageResource("assets/marker_idle3.png");
        World.markerDrawable_selected = new AR.ImageResource("assets/marker_selected3.png");
        World.markerDrawable_directionIndicator = new AR.ImageResource("assets/indi.png");
        
        AR.logger.debug("poiData.length:" + poiData.length);
        
        // loop through POI-information and create an AR.GeoObject (=Marker) per POI
        for (var currentPlaceNr = 0; currentPlaceNr < poiData.length; currentPlaceNr++) {
            var singlePoi = {
                "id": poiData[currentPlaceNr].id,
                "latitude": parseFloat(poiData[currentPlaceNr].latitude),
                "longitude": parseFloat(poiData[currentPlaceNr].longitude),
                "altitude": parseFloat(poiData[currentPlaceNr].altitude),
                "title": poiData[currentPlaceNr].name,
                "description": poiData[currentPlaceNr].description,
                "image":poiData[currentPlaceNr].image,
                "images":poiData[currentPlaceNr].images,
                "voice":poiData[currentPlaceNr].voice,
                "address":poiData[currentPlaceNr].address,
                "type":poiData[currentPlaceNr].type
            };
            AR.logger.debug("currentPlaceNr:" + currentPlaceNr + "," + poiData[currentPlaceNr].name);
            World.jingquList.push(new Marker(singlePoi));
        }
        
        World.updateDistanceToUserValues();
        World.initialized = true;
    },
    
	// called to inject new POI data
	loadPoisFromJsonData: function loadPoisFromJsonDataFn(poiData) {
        
        
        
        if (World.currentMarker) {
            World.currentMarker.setDeselected(World.currentMarker);
            World.isClickDetailImage = false;
            World.currentMarker = null;
        }
        
//        for(var i = 0;i < World.markerList.length;i++){
//            World.markerList[i].markerObject.destroy();
//            
//        }
        AR.context.destroyAll();
		// show radar & set click-listener
		PoiRadar.show();
//        PoiRadar.setMaxDistance(1000);
//        AR.context.scene.cullingDistance = 10000;
        
        
        AR.logger.debug("versionNumber:" + AR.context.versionNumber);
        
        
        AR.context.scene.minScalingDistance = 22;
        AR.context.scene.maxScalingDistance = 300;
        AR.context.scene.scalingFactor = 0.4;
        
        
		$('#radarContainer').unbind('click');
		$("#radarContainer").click(PoiRadar.clickedRadar);

		// empty list of visible markers
		World.markerList = [];
        World.jingquList = [];

		// start loading marker assets
		World.markerDrawable_idle = new AR.ImageResource("assets/marker_idle3.png");
		World.markerDrawable_selected = new AR.ImageResource("assets/marker_selected3.png");
		World.markerDrawable_directionIndicator = new AR.ImageResource("assets/indi.png");

		// loop through POI-information and create an AR.GeoObject (=Marker) per POI
		for (var currentPlaceNr = 0; currentPlaceNr < poiData.length; currentPlaceNr++) {
			var singlePoi = {
				"id": poiData[currentPlaceNr].id,
				"latitude": parseFloat(poiData[currentPlaceNr].latitude),
				"longitude": parseFloat(poiData[currentPlaceNr].longitude),
				"altitude": parseFloat(poiData[currentPlaceNr].altitude),
				"title": poiData[currentPlaceNr].name,
				"description": poiData[currentPlaceNr].description,
                "image":poiData[currentPlaceNr].image,
                "images":poiData[currentPlaceNr].images,
                "voice":poiData[currentPlaceNr].voice,
                "address":poiData[currentPlaceNr].address,
                "type":poiData[currentPlaceNr].type
			};
            AR.logger.debug("currentPlaceNr:" + currentPlaceNr + "," + poiData[currentPlaceNr].name);
			World.markerList.push(new Marker(singlePoi));
		}
		World.updateDistanceToUserValues();
        World.initialized = true;
	},
    updateJingquType: function updateJingquTypeFn(data) {
        AR.logger.debug("updateJingquTypeFn:" + data);
        World.jingquType = data;
    },
    
//    loadPoisFromJsonDataTest: function loadPoisFromJsonDataTestFn(poiData) {
//        
//        AR.context.destroyAll();
//        // show radar & set click-listener
//        PoiRadar.show();
//        //        PoiRadar.setMaxDistance(10000);
//        //        AR.context.scene.cullingDistance = 10000;
//        $('#radarContainer').unbind('click');
//        $("#radarContainer").click(PoiRadar.clickedRadar);
//        
//        // empty list of visible markers
//        World.markerList = [];
//        
//        // start loading marker assets
//        World.markerDrawable_idle = new AR.ImageResource("assets/marker_idle2.png");
//        World.markerDrawable_selected = new AR.ImageResource("assets/marker_selected2.png");
//        World.markerDrawable_directionIndicator = new AR.ImageResource("assets/indi.png");
//        
//        // loop through POI-information and create an AR.GeoObject (=Marker) per POI
//        for (var currentPlaceNr = 0; currentPlaceNr < poiData.length; currentPlaceNr++) {
//            var singlePoi = {
//                "id": poiData[currentPlaceNr].id,
//                "latitude": parseFloat(poiData[currentPlaceNr].latitude),
//                "longitude": parseFloat(poiData[currentPlaceNr].longitude),
//                "altitude": parseFloat(currentPlaceNr*150),
//                "title": poiData[currentPlaceNr].name,
//                "description": poiData[currentPlaceNr].description,
//                "image":"",
//                "voice":""
//            };
//            AR.logger.debug("currentPlaceNr:" + currentPlaceNr + "," + poiData[currentPlaceNr].name);
//            World.markerList.push(new Marker(singlePoi));
//        }
//        
//        // updates distance information of all placemarks
//        World.updateDistanceToUserValues();
//        
//        World.initialized = true;
//        
//        //		World.updateStatusMessage(currentPlaceNr + ' places loaded');
//    },

	// sets/updates distances of all makers so they are available way faster than calling (time-consuming) distanceToUser() method all the time
	updateDistanceToUserValues: function updateDistanceToUserValuesFn() {//更新距离
		
        if(World.jingquType == 2){//街景模式
            for (var i = 0; i < World.jingquList.length; i++) {
                var distanceToUser = World.jingquList[i].markerObject.locations[0].distanceToUser();
                if(distanceToUser != undefined){
                    //                AR.logger.debug("distanceToUser:"+distanceToUser);
                    World.jingquList[i].distanceToUser = distanceToUser;
                    var distanceToUserValue = (distanceToUser > 999) ? ((distanceToUser / 1000).toFixed(2) + " km") : (Math.round(distanceToUser) + " m");
                    World.jingquList[i].descriptionLabel.text = distanceToUserValue;
                }
            }
        }else if(World.jingquType == 1){//景区模式
            for (var i = 0; i < World.markerList.length; i++) {
                var distanceToUser = World.markerList[i].markerObject.locations[0].distanceToUser();
                if(distanceToUser != undefined){
                    //                AR.logger.debug("distanceToUser:"+distanceToUser);
                    World.markerList[i].distanceToUser = distanceToUser;
                    var distanceToUserValue = (distanceToUser > 999) ? ((distanceToUser / 1000).toFixed(2) + " km") : (Math.round(distanceToUser) + " m");
                    World.markerList[i].descriptionLabel.text = distanceToUserValue;
                }
            }
        }
        
	},

	// updates status message shon in small "i"-button aligned bottom center
//	updateStatusMessage: function updateStatusMessageFn(message, isWarning) {
//
//		var themeToUse = isWarning ? "e" : "c";
//		var iconToUse = isWarning ? "alert" : "info";
//
//		$("#status-message").html(message);
//		$("#popupInfoButton").buttonMarkup({
//			theme: themeToUse
//		});
//		$("#popupInfoButton").buttonMarkup({
//			icon: iconToUse
//		});
//	},

	// location updates, fired every time you call architectView.setLocation() in native environment
	locationChanged: function locationChangedFn(lat, lon, alt, acc) {//位置更改回调
        
        
        
//        document.location = "architectsdk://button?action=locationChangedFn2&lat="+lat+"&lon="+lon+"&alt="+alt+"&acc="+acc;
        
        AR.logger.debug("locationChanged " + World.locationUpdateCounter + " lat:"+lat+",log:"+lon+",alt:"+alt+",acc:"+acc);
//        World.currentLat = lat;
//        World.currentLng = lon;
//        AR.logger.debug("locationChanged currentLat:"+World.currentLat + ",currentLng:"+World.currentLng);
		// request data if not already present
		if (!World.initiallyLoadedData) {
			//World.requestDataFromServer(lat, lon);
			World.initiallyLoadedData = true;
		} else if (World.locationUpdateCounter === 0) {
			// update placemark distance information frequently, you max also update distances only every 10m with some more effort
//            document.location = "architectsdk://button?action=locationChangedFn";
			World.updateDistanceToUserValues();
            
            
            
            
            
            if(World.jingquType == 2){//街景模式
                for (var i = 0; i < World.jingquList.length; i++) {
                    
                    var jingqu = World.jingquList[i];
                    
                    AR.logger.debug("i:" + i + ",jingqu:" + jingqu.poiData.latitude);
                    
                    
                    
                    var location3 = new AR.GeoLocation(jingqu.poiData.latitude, jingqu.poiData.longitude);//景区位置
                    var location4 = new AR.GeoLocation(lat, lon, alt);//当前位置
                    var dist = location4.distanceTo(location3);
                    AR.logger.debug("dist:" + dist + ",World.jingquType:" + World.jingquType);
                    if(dist != undefined){
                        if(dist < 1000){
                            if(World.jingquType != "1"){
                                AR.logger.debug("已进入景区");
                                document.location = "architectsdk://button?action=reloadArData&jingquType=1&storeId="+jingqu.poiData.id+"&name="+escape(encodeURIComponent(jingqu.poiData.title));
                            }
                        }else{
                            if(parseInt(World.jingquType) != 2){
                                AR.logger.debug("已离开景区");
                                document.location = "architectsdk://button?action=reloadArData&jingquType=2";
                            }
                        }
                    }
                }
            }
            
            
            
//            if(World.jingquType != 0){
//                for(var i = 0;i < World.jingquList.length;i++){
//                    var jingqu = World.jingquList[i];
//                    
//                    
//                    AR.logger.debug("i:" + i + ",jingqu:" + jingqu.markerObject.poiData.latitude + "," + jingqu.markerObject.poiData.longitude);
//                }
            
//                var location3 = new AR.GeoLocation(World.jingquLat, World.jingquLng);
//                var location4 = new AR.GeoLocation(lat, lon, alt);
//                var dist = location4.distanceTo(location3);
//                AR.logger.debug("dist:" + dist + ",World.jingquType:" + World.jingquType);
//                if(dist != undefined){
//                    if(dist < 500){
//                        if(World.jingquType != "1"){
//                            AR.logger.debug("已进入景区");
//                            document.location = "architectsdk://button?action=reloadArData&jingquType=1";
//                        }
//                    }else{
//                        if(parseInt(World.jingquType) != 2){
//                            AR.logger.debug("已离开景区");
//                            document.location = "architectsdk://button?action=reloadArData&jingquType=2";
//                        }
//                    }
//                }
//            }
//            else{
//                document.location = "architectsdk://button?action=reloadArData&jingquType=2";
//            }
            
		}
		// helper used to update placemark information every now and then (e.g. every 10 location upadtes fired)
		World.locationUpdateCounter = (++World.locationUpdateCounter % World.updatePlacemarkDistancesEveryXLocationUpdates);
        
//        if(World.jingquType == 1){//如果是街景模式 切换为景区模式
//            World.jingquType = 2;
//            setTimeout(function(){
//               if (World.initialized) {
//                    document.location = "architectsdk://button?action=reloadArData&jingquType="+World.jingquType;//重新获取数据
//               }
//            }, 10 * 1000 );
//        }
        
        
        
        
	},

	// fired when user pressed maker in cam
	onMarkerSelected: function onMarkerSelectedFn(marker) {//点击marker
        
        
        
        
        
        
        
        
        
//		World.currentMarker = marker;
//
//		// update panel values
//		$("#poi-detail-title").html(marker.poiData.title);
//		$("#poi-detail-description").html(marker.poiData.description);
//
		var distanceToUserValue = (marker.distanceToUser > 999) ? ((marker.distanceToUser / 1000).toFixed(2) + " km") : (Math.round(marker.distanceToUser) + " m");
//
//		$("#poi-detail-distance").html(distanceToUserValue);
//
//		// show panel
//		$("#panel-poidetail").panel("open", 123);
//		
//		$( ".ui-panel-dismiss" ).unbind("mousedown");
//
//		$("#panel-poidetail").on("panelbeforeclose", function(event, ui) {
//			World.currentMarker.setDeselected(World.currentMarker);
//		});
        
        AR.logger.debug("distanceToUserValue:"+distanceToUserValue);
        
        // deselect previous marker
        if (World.currentMarker) {
            if (World.currentMarker.poiData.id == marker.poiData.id) {
                return;
            }
            World.currentMarker.setDeselected(World.currentMarker);
        }
        
        // highlight current one
        marker.setSelected(marker);
        World.currentMarker = marker;
        
        AR.logger.debug("onMarkerSelected:" + marker.poiData.image)
        AR.logger.debug("目的地位置 latitude:" + marker.poiData.latitude + " , longitude:" + marker.poiData.longitude)

        //设置其他marker禁用
//        for(var i = 0;i < World.markerList.length;i++){
//            var tempMarker = World.markerList[i];
//            if(tempMarker.id != marker.id){
//                tempMarker.markerObject.enabled = false;
//            }
//        }
        
        
        
	},
    
//    onDetailImageSelected: function DetailImageSelectedFn(marker){
//        
//        
//        
//        
////        var currentMarker = marker;
////        var architectSdkUrl = "architectsdk://markerselected?id=" + encodeURIComponent(currentMarker.poiData.id) + "&title=" + encodeURIComponent(currentMarker.poiData.title) + "&description=" + encodeURIComponent(currentMarker.poiData.description);
////        /*
////         The urlListener of the native project intercepts this call and parses the arguments.
////         This is the only way to pass information from JavaSCript to your native code.
////         Ensure to properly encode and decode arguments.
////         Note: you must use 'document.location = "architectsdk://...' to pass information from JavaScript to native.
////         ! This will cause an HTTP error if you didn't register a urlListener in native architectView !
////         */
////        document.location = architectSdkUrl;
//        
////        if (World.currentMarker) {
////            if (World.currentMarker.poiData.id == marker.poiData.id) {
////                return;
////            }
////            World.currentMarker.setDeselected(World.currentMarker);
////        }
////        
////        // highlight current one
////        marker.setSelected(marker);
////        World.currentMarker = marker;
//        
//       
//    },
//
	// screen was clicked but no geo-object was hit
	onScreenClick: function onScreenClickFn() {//点击屏幕
        if(World.isClickDetailImage){
            World.isClickDetailImage = false;
        }else{
            // you may handle clicks on empty AR space too
            if (World.currentMarker) {
                World.currentMarker.setDeselected(World.currentMarker);
//                AR.logger.debug("开始删除路线 World.lineList.length:"+World.lineList.length);
//                for(var i = 0 ;i<World.lineList.length;i++){
//                    World.lineList[i].lineObject.destroy();
//                }
//                World.lineList = [];
//                AR.logger.debug("删除路线结束 World.lineList.length:"+World.lineList.length);
//                
//                $(".paizhao").css('display','none');
                
                
                //设置其他marker禁用
//                for(var i = 0;i < World.markerList.length;i++){
//                    var tempMarker = World.markerList[i];
//                    tempMarker.markerObject.enabled = true;
//                }
            }
        }
        
	},

	// returns distance in meters of placemark with maxdistance * 1.1
	getMaxDistance: function getMaxDistanceFn() {

		// sort palces by distance so the first entry is the one with the maximum distance
		World.markerList.sort(World.sortByDistanceSortingDescending);

		// use distanceToUser to get max-distance
		var maxDistanceMeters = World.markerList[0].distanceToUser;

		// return maximum distance times some factor >1.0 so ther is some room left and small movements of user don't cause places far away to disappear
		return maxDistanceMeters * 1.1;
	},

    captureScreen: function captureScreenFn() {
        if (World.initialized) {
//            document.location = "architectsdk://button?action=captureScreen";
        }
    },

	// request POI data
	requestDataFromServerTest: function requestDataFromServerTestFn(lat, lon) {
        
		// set helper var to avoid requesting places while loading
		World.isRequestingData = true;
//		World.updateStatusMessage('Requesting places from web-service');

		// server-url to JSON content provider
		var serverUrl = ServerInformation.POIDATA_SERVER + "?" + ServerInformation.POIDATA_SERVER_ARG_LAT + "=" + lat + "&" + ServerInformation.POIDATA_SERVER_ARG_LON + "=" + lon + "&" + ServerInformation.POIDATA_SERVER_ARG_NR_POIS + "=10";
 
		var jqxhr = $.getJSON(serverUrl, function(data) {
         
			World.loadPoisFromJsonDataTest(data);
		})
			.error(function(err) {
				World.updateStatusMessage("Invalid web-service response.", true);
				World.isRequestingData = false;
			})
			.complete(function() {
				World.isRequestingData = false;
			});
	},

	// helper to sort places by distance
	sortByDistanceSorting: function(a, b) {
		return a.distanceToUser - b.distanceToUser;
	},

	// helper to sort places by distance, descending
	sortByDistanceSortingDescending: function(a, b) {
		return b.distanceToUser - a.distanceToUser;
	}
    
};

/* forward locationChanges to custom function */
AR.context.onLocationChanged = World.locationChanged;

/* forward clicks in empty area to World */
AR.context.onScreenClick = World.onScreenClick;
