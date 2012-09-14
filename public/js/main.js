/* main.js with very minimal error-checking */

var arrow = {
	left: 37, up: 38, right: 39, down: 40
};

var themes = {
	"Basic theme": themeBasic,
	"Pokémon Gold/Silver theme": themePkmnGS,
};

var config = {
	theme: themeBasic,
	statusTimeout: 2000,
};

// begin with a blank maze
// TODO instead use a random maze on startup
var maze = new Maze([10, 10]);

/* ********************************** */

function setMode(mode) {
	if (config.mode == mode) return;

	if (mode == "play") {
		config.mode = "play";

		$("#play-mode").addClass("active");
		$("#play-menu").show();

		$("#edit-mode").removeClass("active");
		$("#edit-menu").hide();

		showStatus("mode: play");
	} else {
		// edit is default mode
		config.mode = "edit";

		$("#edit-mode").addClass("active");
		$("#edit-menu").show();

		$("#play-mode").removeClass("active");
		$("#play-menu").hide();

		showStatus("mode: edit");
	}

	// TODO prep theme for new mode
	// TODO begin play if now in play mode
}

function setTheme(theme) {
}

function loadDecode(code) {}

function loadExample(index) {}

function edit(ev) {
	ev.preventDefault();
	if (config.mode != "edit") return;
	// get the click coordinates relative to the canvas
	var off = $("#maze").offset();
	var relX = ev.pageX - off.left, relY = ev.pageY - off.top;
	// doesn't matter which keys; just count how many at once
	var metaCount = ev.altKey + ev.ctrlKey + ev.shiftKey;
	// pass only what's needed
	maze.click(config.theme.at(relX, relY), metaCount);
	// show any changes
	redraw();
}

function play(ev) {
	ev.preventDefault();
	if (config.mode != "play") return;
	if (config.anim) return; // anim blocks further moves
	// TODO check whether move is valid
	// TODO tell theme where to move the player
	// TODO wait until theme is finished animating
}

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
	setTimeout(fadeRemove, timeout || config.statusTimeout);
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

	// JavaScript enabled; show the menu
	$("#menu").show();

	// check connection with server
	$.get("ack")
	.error(function() {
		showStatus("server: no connection");
	})
	.success(function() {
		showStatus("server: ready");
	});

	// TODO check whether canvas and 2d drawing context is supported

	// TODO initialize themes

	// TODO load themes list into menu

	// TODO load saved mazes into menu

	// TODO check URI query for initial config
	setMode(urlParams.mode || config.mode || "edit");
	//setTheme(urlParams.theme);

	if (urlParams.maze) {
		// TODO decode given maze
	} else if (urlParams.eg) {
		// TODO load example
	}

	// add menu handlers
	$("#edit-mode").on("click", function(ev){ setMode("edit"); });
	$("#play-mode").on("click", function(ev){ setMode("play"); });

	// add maze handlers
	$("#maze").on("click", edit);
	$(document).on("keydown", play);

	$(window).on("resize", refit);
	refit();

});
