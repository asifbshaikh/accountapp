jQuery(document).ready(function($) {
	//Mainmenu
	$('ul#menu').superfish();
	
	//Fade portfolio
	$(".fade").fadeTo(1, 1);
	$(".fade").hover(
	function () {$(this).fadeTo("fast", 0.45);},
	function () { $(this).fadeTo("slow", 1);}
	);		
	
	//Tab Jquery
	$(".tab_content, .tab_content_blog").hide(); 
	$("ul.tabs li:first, ul.tabs_blog li:first").addClass("active").show(); 
	$(".tab_content:first, .tab_content_blog:first").show(); 
	$("ul.tabs li, ul.tabs_blog li").click(function() {
		$("ul.tabs li, ul.tabs_blog li").removeClass("active");
		$(this).addClass("active"); 
		$(".tab_content, .tab_content_blog").hide(); 
		var activeTab = $(this).find("a").attr("href"); 
		$(activeTab).fadeIn(); 
		return false;
	});	
	
	//Twitter Jquery
	$("#twitter").getTwitter({
		userName: "Indoneztheme",
		numTweets: 1,
		loaderText: "Loading tweets...",
		slideIn: true,
		slideDuration: 750
	});
	
	//Fancybox Jquery
	$(".fancybox").fancybox({
		padding: 0,
		openEffect : 'elastic',
		openSpeed  : 250,
		closeEffect : 'elastic',
		closeSpeed  : 250,
		closeClick : true,
		helpers : {
			overlay : {opacity : 0.65},
			media : {}
		}
	});	
	
	//TinyNav Jquery
	$('#menu').tinyNav({
	  active: 'selected'
	});	
	
	//Flickr Feed
	$('#flck-thumb').jflickrfeed({
		limit: 8,
		qstrings: {
			id: '52617155@N08'
		},
		itemTemplate: '<div>'+
						'<a class="fancybox" href="{{image}}" data-fancybox-group="gallery" title="{{title}}">' +
							'<img src="{{image_s}}" alt="{{title}}" />' +
						'</a>' +
					  '</div>'
	}, function(data) {
		$('#flck-thumb a').colorbox();
	});		
	
	//To top Jquery
	$().UItoTop({ easingType: 'easeOutQuart' });	
		
	//Shaped Mask							
	var $item_mask = $("<div />", {"class": "item-mask"});
	$(".shaped").append($item_mask)
	
});	