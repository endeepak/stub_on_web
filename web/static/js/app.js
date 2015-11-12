// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
// import "deps/phoenix_html/web/static/js/phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"


$('body').on('click', '.add-response-header', function() {
	var responseHeader = $('#response-header-template').html().replace(/\$index/g, $('.response-header').length)
	$('#response-headers').append(responseHeader);
});

$('body').on('click', '.remove-trigger', function() {
	$(this).closest('.removable').remove();
});

$(function() {
	// Remove hidden ids to ensure deletes work fine by removing DOM
	$('#response-headers input[type=hidden]').remove();

	$('span[data-time]').each(function() {
		var localDateString = moment($(this).data('time')).format('YYYY-MM-DD HH:mm:ss');
		$(this).html(localDateString);
	});

	$('button[name="stub-url-action"]').on('click', function(){
		$(this).closest('form').data('stub-url-action', $(this).val());
	});

	$('.stub-url-action-form').on('submit', function(e) {
		e.preventDefault();
		var stubUrl = $(this).find('input[type="text"]').val();
		var action = $(this).data('stub-url-action') || $('button[name="stub-url-action"]:first').val();
		var host = window.location.host;
		var rawStuburlPath = stubUrl.replace(/(http|https):\/\//g, '').replace(host, '');
		var stubUrlPath = rawStuburlPath.startsWith("/") ? rawStuburlPath.substring(1) : rawStuburlPath;
		window.location = "/" + action + "/" + stubUrlPath;
	});

	$('body').on('focus', '.response-header-name:not(.ui-autocomplete-input)', function () {
    	$(this).autocomplete({        
        	source: ["Access-Control-Allow-Origin", "Accept-Patch", "Accept-Ranges", "Age", "Allow", 
					"Cache-Control", "Connection", "Content-Disposition", "Content-Encoding", "Content-Language",
					"Content-Length", "Content-Location", "Content-MD5", "Content-Range", "Content-Type", "Date",
					"ETag", "Expires", "Last-Modified", "Link", "Location", "P3P", "Pragma", "Proxy-Authenticate",
					"Public-Key-Pins", "Refresh", "Retry-After", "Server", "Set-Cookie", "Status","Strict-Transport-Security",
					"Trailer", "Transfer-Encoding", "Upgrade", "Vary", "Via", "Warning", "WWW-Authenticate", 
					"X-Frame-Options", "X-XSS-Protection", "Content-Security-Policy", "X-Content-Security-Policy",
					"X-WebKit-CSP", "X-Content-Type-Options", "X-Powered-By", "X-UA-Compatible", "X-Content-Duration"]
		});
	});
});