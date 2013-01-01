/* main.js with very minimal error-checking */

var dirs = {
	37: "left", 38: "up", 39: "right", 40: "down"
};

var themes = {
	"Basic theme": ThemeBasic,
	"Pokémon Gold/Silver theme": themePkmnGS,
};

var defaults = {
	mode: "edit",
	themeName: "Basic theme",
};

var config = {
	statusTimeout: 2000,
};

// begin with a blank maze
var maze = new Maze([10, 10]);

var theme;

/* ********************************** */

function newMaze(w, h) {
	maze = new Maze([w, h]);
	resetTheme();
	restartMode();
}

function loadDecode(code) {
}

function loadExample(index) {
}

/* ********************************** */

function setTheme(name) {
	if (!(name in themes)) {
		showStatus("error: no such theme: " + name);
		return;
	}

	config.themeName = name;
	showStatus("theme: " + name);

	if (theme) {
		// unload previous theme
		theme.fini();
	}

	// load new theme
	var c2d = $("#maze").get(0).getContext("2d");
	theme = themes[config.themeName](c2d, maze);

	// ensure canvas size meets needs of current theme
	refit(); // will invoke theme.prep
}

function resetTheme() {
	setTheme(config.themeName);
}

/* ********************************** */

function setMode(mode) {
	if (!(maze && theme)) {
		// both are required to continue
		return;
	}

	// stop any animations
	theme.stop();
	if (config.anim) {
		delete config.anim;
	}

	if (theme.setSecret) {
		theme.setSecret(mode);
	}

	// update UI/menus
	switch (mode) {

	case "edit":
		$("#edit-mode").addClass("active");
		$("#edit-menu").show();
		$("#play-mode").removeClass("active");
		$("#play-menu").hide();
		break;

	default:
		// secrets are for play
		mode = "play";
	case "play":
		$("#play-mode").addClass("active");
		$("#play-menu").show();
		$("#edit-mode").removeClass("active");
		$("#edit-menu").hide();
		break;

	}

	config.mode = mode;
	showStatus("mode: " + mode);

	theme.start(mode);

	switch (mode) {

	case "edit":
		// no configuration state to reset
		theme.redraw();
		break;

	case "play":
		// reposition player at beginning
		config.playerAt = maze.entry;
		theme.redraw();
		theme.drawPlayerAt(config.playerAt);
		break;

	}
}

function restartMode() {
	setMode(config.mode);
}

/* ********************************** */

function edit(ev) {
	ev.preventDefault();
	if (config.mode != "edit") {
		return;
	}

	// get the click coordinates relative to the canvas
	var off = $("#maze").offset();
	var relX = ev.pageX - off.left, relY = ev.pageY - off.top;

	// doesn't matter which keys; just count how many at once
	var metaCount = ev.altKey + ev.ctrlKey + ev.shiftKey;

	// pass only what's needed
	maze.click(theme.at(relX, relY), metaCount);

	// show any changes
	theme.redraw();
}

function play(ev) {
	ev.preventDefault();
	if (config.mode != "play") {
		return;
	}
	if (config.anim) {
		// block further moves during animation
		return;
	}

	// get the move path (even if it goes nowhere)
	var direction = dirs[ev.which];
	if (!direction) {
		// ignore unrecognized keys
		return;
	}
	var path = maze.getPath(config.playerAt, direction);
	var endpoint = path[path.length - 1];

	// check win
	var winner = maze.is(endpoint, {exit: true});

	// tell theme where to move the player
	config.anim = true;
	theme.drawPlayerMove(direction, path, function() {
		config.playerAt = endpoint;
		config.anim = false;
		if (winner) {
			// TODO report
		}
	});

	showStatus("moving to " + endpoint + (winner ? " = WIN!" : ""));
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
	var min = theme.minSize(), wid, hei;

	// at least fill the wrapper width
	if (min[0] <= wrapperWidth) {
		wid = wrapperWidth;
		wrapper.css("overflow-x", "hidden");
	} else {
		// theme requires more than wrapper's width
		wid = min[0];
		wrapper.css("overflow-x", "scroll");
	}

	// at least fill the wrapper height
	if (min[1] <= wrapperHeight) {
		hei = wrapperHeight;
		wrapper.css("overflow-y", "hidden");
	} else {
		// theme requires more than wrapper's height
		hei = min[1];
		wrapper.css("overflow-y", "scroll");
	}

	// resize the canvas
	canvas.attr("width", wid).attr("height", hei);

	// prep the theme with the new canvas size
	theme.prep([wid, hei]);

	// redraw maze in case to reposition in centre of canvas, etc.
	theme.redraw();
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

	// extract config from query
	if (urlParams.maze) {
		// TODO decode given maze
	} else if (urlParams.eg) {
		// TODO load example
	}

	setTheme(urlParams.theme || defaults.themeName);
	setMode(urlParams.mode || defaults.mode);

	// add menu handlers
	$("#edit-mode").on("click", function(ev) { setMode("edit"); });
	$("#play-mode").on("click", function(ev) { setMode("play"); });
	$("#restart").on("click", restartMode);

	// add maze handlers
	$("#maze").on("click", edit);
	$(document).on("keydown", play);

	$(window).on("resize", refit);
	refit();

});
