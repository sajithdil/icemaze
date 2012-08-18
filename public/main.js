
var themes = {
	"Basic theme": themeBasic,
	"Pokémon Gold/Silver theme": themePkmnGS,
};

var config = {
	theme: themeBasic,
};

// begin with a blank maze
// TODO instead use a random maze on startup
var maze = newMaze(10,10);

// returns a blank maze of width w and height h
function newMaze(w, h) {
	return {
		width: w,
		height: h,
		cells: [[]],
		entry:[-1,0], // left of top-left corner
		exit:[w,h-1]  // right of bottom-right corner 
	};
}

function showMaze(m) {
	var canvas = $("#maze"), wrapper = $("#wrap");
	var min = config.theme.minSize(m), wid, hei;

	// at least fill the wrapper width
	if (min[0] <= wrapper.width()) {
		wid = wrapper.width();
		wrapper.css("overflow-x", "hidden");
	} else {
		wid = min[0];
		wrapper.css("overflow-x", "scroll");
	}

	// at least fill the wrapper height
	if (min[1] <= wrapper.height()) {
		hei = wrapper.height();
		wrapper.css("overflow-y", "hidden");
	} else {
		hei = min[1];
		wrapper.css("overflow-y", "scroll");
	}

	// resize the canvas
	canvas.attr("width", wid).attr("height", hei);

	// draw matte and maze using the theme
	var c2d = canvas.get(0).getContext("2d");
	config.theme.drawMatte(c2d, [wid, hei]);
	config.theme.drawMaze(c2d, [wid, hei], m);
}

function resizeWindow() {
	// position and size #wrap to fill screen under #menu
	var menuHeight = $("#menu").outerHeight(true);
	$("#wrap").css("margin-top", menuHeight);
	$("#wrap").height($(window).height() - menuHeight);
	// redraw the maze
	showMaze(maze);
}

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

	$(window).bind("resize", resizeWindow);
	resizeWindow();

});
