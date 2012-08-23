/* main.js with very minimal error-checking */

var themes = {
	"Basic theme": themeBasic,
	"Pokémon Gold/Silver theme": themePkmnGS,
};

var config = {
	theme: themeBasic,
};

// begin with a blank maze
// TODO instead use a random maze on startup
var maze = new Maze([10, 10]);

/* ********************************** */

function refit() {
	var menu = $("#menu"), wrapper = $("#wrap"), canvas = $("#maze");

	// position and size #wrap to fill screen under #menu
	var menuHeight = menu.outerHeight(true);
	wrapper.css("margin-top", menuHeight);
	wrapper.height($(window).height() - menuHeight);

	// resize the canvas to at least fill the wrapper
	var wrapperWidth = wrapper.width(), wrapperHeight = wrapper.height();
	var min = config.theme.minSize([maze.width, maze.height], true), wid, hei;

	// at least fill the wrapper width
	if (min[0] <= wrapperWidth) {
		wid = wrapperWidth;
		wrapper.css("overflow-x", "hidden");
	} else {
		wid = min[0];
		wrapper.css("overflow-x", "scroll");
	}

	// at least fill the wrapper height
	if (min[1] <= wrapperHeight) {
		hei = wrapperHeight;
		wrapper.css("overflow-y", "hidden");
	} else {
		hei = min[1];
		wrapper.css("overflow-y", "scroll");
	}

	// resize the canvas
	canvas.attr("width", wid).attr("height", hei);

	redraw(canvas);
}

function redraw(canvas, theme, m) {
	canvas = canvas || $("#maze");
	theme = theme || config.theme;
	m = m || maze;
	// draw matte and maze using the theme
	var c2d = canvas.get(0).getContext("2d");
	var cSize = [canvas.attr("width"), canvas.attr("height")];
	theme.prep(cSize, [m.width, m.height]);
	theme.drawMatte(c2d, m);
	theme.drawMaze(c2d, m);
}

function showStatus(mesg, timeout) {
	var d = $("<p/>").text(mesg).appendTo("#info");
	var fadeRemove = function() {
		d.fadeOut("slow", function() { d.remove(); });
	};
	d.on("click", fadeRemove);
	if (!!timeout) setTimeout(fadeRemove, timeout);
}

/* ********************************** */

/* thanks http://stackoverflow.com/a/2880929/1597274 */
var urlParams = {};
(function () {
	var match,
	 pl     = /\+/g,  // regex for replacing addition symbol with a space
	 search = /([^&=]+)=?([^&]*)/g,
	 decode = function (s) { return decodeURIComponent(s.replace(pl, " ")); },
	 query  = window.location.search.substring(1);

	while (match = search.exec(query))
	 urlParams[decode(match[1])] = decode(match[2]);
})();

$(function(){

	// TODO check whether canvas and 2d drawing context is supported

	// TODO initialize themes

	// TODO load themes list into UI selectable

	// TODO check URI query for initial config

	// TODO check connection with server

	// TODO decode and display maze provided in URI query

	$("#maze").on("click", function(ev){
		ev.preventDefault();
		// get the click coordinates relative to the canvas
		var off = $("#maze").offset();
		var relX = ev.pageX - off.left, relY = ev.pageY - off.top;
		// doesn't matter which keys; just count how many at once
		var metaCount = ev.altKey + ev.ctrlKey + ev.shiftKey;
		// pass only what's needed
		maze.click(config.theme.at(relX, relY), metaCount);
		// show any changes
		redraw();
	});

	$(window).on("resize", refit);
	refit();

});
