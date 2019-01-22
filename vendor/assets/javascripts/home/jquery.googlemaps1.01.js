jQuery.fn.googleMaps=function(a){if(!window.GBrowserIsCompatible||!GBrowserIsCompatible()){return this}var b=$.extend({},$.googleMaps.defaults,a);return this.each(function(){$.googleMaps.gMap=new GMap2(this,b);$.googleMaps.mapsConfiguration(b)})};$.googleMaps={mapsConfiguration:function(a){if(a.geocode){geocoder=new GClientGeocoder;geocoder.getLatLng(a.geocode,function(b){if(!b){alert(address+" not found")}else{$.googleMaps.gMap.setCenter(b,a.depth);$.googleMaps.latitude=b.x;$.googleMaps.longitude=b.y}})}else{var b=$.googleMaps.mapLatLong(a.latitude,a.longitude);$.googleMaps.gMap.setCenter(b,a.depth)}if(a.polyline)$.googleMaps.gMap.addOverlay($.googleMaps.mapPolyLine(a.polyline));if(a.geodesic){$.googleMaps.mapGeoDesic(a.geodesic)}if(a.pan){a.pan=$.googleMaps.mapPanOptions(a.pan);window.setTimeout(function(){$.googleMaps.gMap.panTo($.googleMaps.mapLatLong(a.pan.panLatitude,a.pan.panLongitude))},a.pan.timeout)}if(a.layer)$.googleMaps.gMap.addOverlay(new GLayer(a.layer));if(a.markers)$.googleMaps.mapMarkers(b,a.markers);if(a.controls.type||a.controls.zoom||a.controls.mapType){$.googleMaps.mapControls(a.controls)}else{if(!a.controls.hide)$.googleMaps.gMap.setUIToDefault()}if(a.scroll)$.googleMaps.gMap.enableScrollWheelZoom();else if(!a.scroll)$.googleMaps.gMap.disableScrollWheelZoom();if(a.controls.localSearch)$.googleMaps.gMap.enableGoogleBar();else $.googleMaps.gMap.disableGoogleBar();if(a.feed)$.googleMaps.gMap.addOverlay(new GGeoXml(a.feed));if(a.trafficInfo){var c={incidents:true};trafficInfo=new GTrafficOverlay(c);$.googleMaps.gMap.addOverlay(trafficInfo)}if(a.directions){$.googleMaps.directions=new GDirections($.googleMaps.gMap,a.directions.panel);$.googleMaps.directions.load(a.directions.route)}if(a.streetViewOverlay){svOverlay=new GStreetviewOverlay;$.googleMaps.gMap.addOverlay(svOverlay)}},mapGeoDesic:function(a){geoDesicDefaults={startLatitude:37.4419,startLongitude:-122.1419,endLatitude:37.4519,endLongitude:-122.1519,color:"#ff0000",pixels:2,opacity:10};a=$.extend({},geoDesicDefaults,a);var b={geodesic:true};var c=new GPolyline([new GLatLng(a.startLatitude,a.startLongitude),new GLatLng(a.endLatitude,a.endLongitude)],a.color,a.pixels,a.opacity,b);$.googleMaps.gMap.addOverlay(c)},localSearchControl:function(a){var b=$.googleMaps.mapControlsLocation(a.location);$.googleMaps.gMap.addControl(new $.googleMaps.gMap.LocalSearch,new GControlPosition(b,new GSize(a.x,a.y)))},getLatitude:function(){return $.googleMaps.latitude},getLongitude:function(){return $.googleMaps.longitude},directions:{},latitude:"",longitude:"",latlong:{},maps:{},marker:{},gMap:{},defaults:{latitude:37.4419,longitude:-122.1419,depth:13,scroll:true,trafficInfo:false,streetViewOverlay:false,controls:{hide:false,localSearch:false},layer:null},mapPolyLine:function(a){polylineDefaults={startLatitude:37.4419,startLongitude:-122.1419,endLatitude:37.4519,endLongitude:-122.1519,color:"#ff0000",pixels:2};a=$.extend({},polylineDefaults,a);return new GPolyline([$.googleMaps.mapLatLong(a.startLatitude,a.startLongitude),$.googleMaps.mapLatLong(a.endLatitude,a.endLongitude)],a.color,a.pixels)},mapLatLong:function(a,b){return new GLatLng(a,b)},mapPanOptions:function(a){var b={panLatitude:37.4569,panLongitude:-122.1569,timeout:0};return a=$.extend({},b,a)},mapMarkersOptions:function(a){var b=new GIcon(G_DEFAULT_ICON);if(a.image)b.image=a.image;if(a.shadow)b.shadow=a.shadow;if(a.iconSize)b.iconSize=new GSize(a.iconSize);if(a.shadowSize)b.shadowSize=new GSize(a.shadowSize);if(a.iconAnchor)b.iconAnchor=new GPoint(a.iconAnchor);if(a.infoWindowAnchor)b.infoWindowAnchor=new GPoint(a.infoWindowAnchor);if(a.dragCrossImage)b.dragCrossImage=a.dragCrossImage;if(a.dragCrossSize)b.dragCrossSize=new GSize(a.dragCrossSize);if(a.dragCrossAnchor)b.dragCrossAnchor=new GPoint(a.dragCrossAnchor);if(a.maxHeight)b.maxHeight=a.maxHeight;if(a.PrintImage)b.PrintImage=a.PrintImage;if(a.mozPrintImage)b.mozPrintImage=a.mozPrintImage;if(a.PrintShadow)b.PrintShadow=a.PrintShadow;if(a.transparent)b.transparent=a.transparent;return b},mapMarkers:function(a,b){if(typeof b.length=="undefined")b=[b];var c=0;for(i=0;i<b.length;i++){var d=null;if(b[i].icon){d=$.googleMaps.mapMarkersOptions(b[i].icon)}if(b[i].geocode){var e=new GClientGeocoder;e.getLatLng(b[i].geocode,function(a){if(!a)alert(address+" not found");else $.googleMaps.marker[i]=new GMarker(a,{draggable:b[i].draggable,icon:d})})}else if(b[i].latitude&&b[i].longitude){a=$.googleMaps.mapLatLong(b[i].latitude,b[i].longitude);$.googleMaps.marker[i]=new GMarker(a,{draggable:b[i].draggable,icon:d})}$.googleMaps.gMap.addOverlay($.googleMaps.marker[i]);if(b[i].info){$(b[i].info.layer).hide();if(b[i].info.popup)$.googleMaps.marker[i].openInfoWindowHtml($(b[i].info.layer).html());else $.googleMaps.marker[i].bindInfoWindowHtml($(b[i].info.layer).html().toString())}}},mapControlsLocation:function(a){switch(a){case"G_ANCHOR_TOP_RIGHT":return G_ANCHOR_TOP_RIGHT;break;case"G_ANCHOR_BOTTOM_RIGHT":return G_ANCHOR_BOTTOM_RIGHT;break;case"G_ANCHOR_TOP_LEFT":return G_ANCHOR_TOP_LEFT;break;case"G_ANCHOR_BOTTOM_LEFT":return G_ANCHOR_BOTTOM_LEFT;break}return},mapControl:function(a){switch(a){case"GLargeMapControl3D":return new GLargeMapControl3D;break;case"GLargeMapControl":return new GLargeMapControl;break;case"GSmallMapControl":return new GSmallMapControl;break;case"GSmallZoomControl3D":return new GSmallZoomControl3D;break;case"GSmallZoomControl":return new GSmallZoomControl;break;case"GScaleControl":return new GScaleControl;break;case"GMapTypeControl":return new GMapTypeControl;break;case"GHierarchicalMapTypeControl":return new GHierarchicalMapTypeControl;break;case"GOverviewMapControl":return new GOverviewMapControl;break;case"GNavLabelControl":return new GNavLabelControl;break}return},mapTypeControl:function(a){switch(a){case"G_NORMAL_MAP":return G_NORMAL_MAP;break;case"G_SATELLITE_MAP":return G_SATELLITE_MAP;break;case"G_HYBRID_MAP":return G_HYBRID_MAP;break}return},mapControls:function(a){controlsDefaults={type:{location:"G_ANCHOR_TOP_RIGHT",x:10,y:10,control:"GMapTypeControl"},zoom:{location:"G_ANCHOR_TOP_LEFT",x:10,y:10,control:"GLargeMapControl3D"}};a=$.extend({},controlsDefaults,a);a.type=$.extend({},controlsDefaults.type,a.type);a.zoom=$.extend({},controlsDefaults.zoom,a.zoom);if(a.type){var b=$.googleMaps.mapControlsLocation(a.type.location);var c=new GControlPosition(b,new GSize(a.type.x,a.type.y));$.googleMaps.gMap.addControl($.googleMaps.mapControl(a.type.control),c)}if(a.zoom){var b=$.googleMaps.mapControlsLocation(a.zoom.location);var c=new GControlPosition(b,new GSize(a.zoom.x,a.zoom.y));$.googleMaps.gMap.addControl($.googleMaps.mapControl(a.zoom.control),c)}if(a.mapType){if(a.mapType.length>=1){for(i=0;i<a.mapType.length;i++){if(a.mapType[i].remove)$.googleMaps.gMap.removeMapType($.googleMaps.mapTypeControl(a.mapType[i].remove));if(a.mapType[i].add)$.googleMaps.gMap.addMapType($.googleMaps.mapTypeControl(a.mapType[i].add))}}else{if(a.mapType.add)$.googleMaps.gMap.addMapType($.googleMaps.mapTypeControl(a.mapType.add));if(a.mapType.remove)$.googleMaps.gMap.removeMapType($.googleMaps.mapTypeControl(a.mapType.remove))}}},geoCode:function(a){geocoder=new GClientGeocoder;geocoder.getLatLng(a.address,function(b){if(!b)alert(address+" not found");else $.googleMaps.gMap.setCenter(b,a.depth)})}}