
String.prototype.trim = function() { return this.replace(/^\s+|\s+$/g, '') ; }

$.fn.wait = function(time, type) {
	time = time || 1000;
	type = type || "fx";
	return this.queue(type, function() {
		var self = this;
		setTimeout(function() { $(self).dequeue(); }, time);
	});
};

/* ================================================== */

var maze = null;

$(function() {

	$("#status").position({of: "#maze", my: "left top", at: "left top"});

	$("#NewMazeDialog").dialog({
		autoOpen: false, modal: true, title: "New Maze...", width: "auto",
		buttons: {
			"Create": function() { $(this).dialog("close"); requestNewMaze(); },
			"Cancel": function() { $(this).dialog("close"); }
		}
	});
	$("#newMaze").click( function(e) {
		$("#NewMazeDialog").dialog("open");
	} );


	$("#RandomMazeDialog").dialog({
		autoOpen: false, modal: true, title: "Randomize Maze...", width: "auto",
		buttons: {
			"Randomize": function() { $(this).dialog("close"); requestRandomize(); },
			"Cancel": function() { $(this).dialog("close"); }
		}
	});
	$("#randomMaze").click( function(e) {
		$("#RandomMazeDialog").dialog("open");
	} );

	$("#SaveLoadDialog").dialog({
		autoOpen: false, modal: true, title: "Maze code...", width: "auto",
		buttons: {
			"Output": function() {
				$("#mazeCode").val(JSON.stringify(maze));
			},
			"Input": function() {
				$(this).dialog("close");
				var v = $("#mazeCode").val();
				requestEcho(v);
			},
			"Close": function() { $(this).dialog("close"); }
		}
	});
	$("#ioJSON").click( function(e) {
		$("#SaveLoadDialog").dialog("open");
	} );

	$("#showShortest").click( function (e) {
	 status("Please Wait", "Requesting shortest path...", false);
	 $.getJSON("/Shortest.json",
	  { m: JSON.stringify(maze) },
	  showSolns );
	} );

	$("#showColours").click( function (e) {
	 status("Please Wait", "Requesting colours...", false);
	 $.getJSON("/Colours.json",
	  { m: JSON.stringify(maze) },
	  showColours );
	} );

	$("#exportPNG").click( function (e) {
	 status("Please Wait", "Requesting PNG...", false);
	 $.getJSON("/PNG.json",
	  { m: JSON.stringify(maze) },
	  loadPNG );
	} );

	$("#randEE").click( function (e) {
	 status("Please Wait", "Requesting random entry/exit points...", false);
	 $.getJSON("/RandEE.json",
	  { m: JSON.stringify(maze) },
	  callback );
	} );

	$("#randB").click( function (e) {
	 status("Please Wait", "Requesting random blocks...", false);
	 $.getJSON("/RandB.json",
	  { m: JSON.stringify(maze) },
	  callback );
	} );

	$("#clearB").click( function (e) {
	 status("Please Wait", "Requesting clear blocks...", false);
	 requestClear("TileBlocked");
	} );

	$("#clearUB").click( function (e) {
	 status("Please Wait", "Requesting clear \"unblockable\" flags...", false);
	 requestClear("TileUnblockable");
	} );

	$("#clearC").click( function (e) {
	 status("Please Wait", "Requesting clear \"colour\" flags...", false);
	 requestClear("TileColoured");
	} );

	$("#clearA").click( function (e) {
	 status("Please Wait", "Requesting clear all blocks and flags...", false);
	 requestClear("TileAll");
	} );

	// Initialize interface with a new maze
	requestNewMaze();

});

function addGridHandlers() {

	$("#maze > button").click( function(e) {

		var b = e.button;
		// Rearrange inputs for my scheme
		// So that all three buttons can be emulated through any one
		b = b == 1 ? 2 : (b == 2 ? 1 : 0); // Left by default
		if (e.shiftKey) b++; if (e.ctrlKey) b++;
		b %= 3; // Loop

		b = b == 0 ? "left" : (b == 1 ? "right" : "middle");

		$.getJSON("/Click.json",
			{ x: $(this).attr("x"), y: $(this).attr("y"),
			button: b,
			m: JSON.stringify(maze) },
			callback );

	} );

}

/* ================================================== */

function requestNewMaze() {
	var w = parseInt($("#newMazeWidth").val());
	var h = parseInt($("#newMazeHeight").val());
	var b = parseInt($("#newMazeBlocks").val());
	if (w == NaN || h == NaN || w < 0 || h < 0) { alert("Create new maze...", "Invalid dimensions."); return; }
	if (b == NaN) b = 0;
	status("Please Wait", "Requesting new maze from server...", false);
	$.getJSON("/NewMaze.json", { "w": w, "h": h, "b" : b }, updateMaze );
}

function requestRandomize() {
	var slen = parseInt($("#shortestSolutionLength").val());
	var slenOpt = $("input[@name='slenOpt']:checked").val();
	var nnrs = parseInt($("#numNRSolutions").val());
	var nnrsOpt = 0;
	var poolSize = parseInt($("#sizePool").val());
	if (slen == NaN || nnrs == NaN || poolSize == NaN) { alert("Randomize maze...", "Invalid arguments."); return; }
	status("Please Wait", "Requesting randomization from server...", false);
	// TODO
}

function requestClear(t) {
	$.getJSON("/Clear.json",
	  { clear: t, m: JSON.stringify(maze) },
	  callback );
}

function requestEcho(m) {
	$.getJSON("/Echo.json",
	  { m: JSON.stringify(m) },
	  updateMaze );
}

/* ================================================== */

function callback(result) {
	var t = typeof(result);
	if (!result || !t || t != "object") {
		status("Error", "Bad result."); return;
	}
	if (result instanceof Array) {
		updateTiles(result);
	} else updateMaze(result);
}

function updateTiles(response) {
	for (var u = 0; u < response.length; u++) {
		var r = response[u];
		if (r.Do == "Set") {
			maze.Grid[r.Coords.X][r.Coords.Y] = r.Tile;
		} else if (r.Do == "Entry") {
			maze.Entry = r.Coords;
		} else if (r.Do == "Exit") {
			maze.Exit = r.Coords;
		}
	}
	redrawMaze();
}

function updateMaze(response) {
	maze = response;
	rebuildMaze();
	redrawMaze();
}

function rebuildMaze() {

	$("#maze").html("");

	// Grid
	for (var y = maze.Height; y >= -1; y--) {
		for (var x = -1; x <= maze.Width; x++) {
			$("#maze").append("<button x=\""+x+"\" y=\""+y+"\"></button>");
		}
		$("#maze").append("<br \>");
	}

	addGridHandlers()

}

function redrawMaze() {

	$("#maze > button").removeClass().addClass("grid");

	$(".grid[x=\"-1\"], .grid[y=\"-1\"], .grid[x=\""+maze.Width+"\"], .grid[y=\""+maze.Height+"\"]").addClass("gridBorder");
	bxy(maze.Entry.X, maze.Entry.Y).addClass("gridEntry");
	bxy(maze.Exit.X, maze.Exit.Y).addClass("gridExit");

	for (var x = 0; x < maze.Width; x++) {
		for (var y = 0; y < maze.Height; y++) {
			if (isBlocked(x, y)) bxy(x, y).addClass("gridBlocked");
			if (isUnblockable(x, y)) bxy(x, y).addClass("gridUnblockable");
			if (isGrey(x, y)) bxy(x, y).addClass("gridGrey");
		}
	}

	dismissStatus();

}

function showColours(response) {

	maze = response;

	for (var x = 0; x < maze.Width; x++) {
		for (var y = 0; y < maze.Height; y++) {
			applyColours(x, y);
		}
	}

	dismissStatus();

}

function showSolns(solns) {

	if (solns.length == 0) {

		status("Analysis...", "No solutions.");
		return;

	}

	for (var p = 0; p < solns.length; p++) {
		var cdpath = solns[p], step, prev;
		for (var s = 0; s < cdpath.length; s++) {
			prev = step; step = cdpath[s];
			if (prev != null) drawLineFrom(prev.Coords, step.Coords, "gridSolnPath");
			bxy(step.Coords.X, step.Coords.Y).addClass("gridSolnStep");
		}
		if (step != null) drawLineFrom(step.Coords, maze.Exit, "gridSolnPath");
	}

	status("Analysis...", solns.length + " non-redundant solutions.")

}

/* ================================================== */

function alert(title, msg) {}

var toDismiss = null;

function status(title, msg, diss) {
	diss = typeof(diss) != 'undefined' ? diss : true;
	clearTimeout(toDismiss);
	$("#status").stop(true, true).html("<h1>" + title + "</h1><p>" + msg + "</p>");
	$("#status:hidden").show("slide", {direction: "left"}, 250);
	if (diss) toDismiss = setTimeout(function() {dismissStatus()}, 1000);
}

function dismissStatus() {
	$("#status:visible").hide("slide", {direction: "left"}, 250);
	$("#footer:visible").hide("fade", {}, 10000);
}

/* ================================================== */

function bxy(x, y) {
	return $("#maze > button[x=\""+x+"\"][y=\""+y+"\"]");
}

function drawLineFrom(a, b, c) {

	// Point A to Point B, apply class C
	var xdiff = a.X - b.X, ydiff = a.Y - b.Y;
	if (xdiff != 0 && ydiff != 0) return; // Both can't be defined
	var xn = xdiff == 0 ? 0 : (xdiff > 0 ? -1 : 1), yn = ydiff == 0 ? 0 : (ydiff > 0 ? -1 : 1);
	for (; xdiff != 0 || ydiff != 0; xdiff += xn, ydiff += yn) {
		bxy(a.X - xdiff, a.Y - ydiff).addClass(c);
	}

}

/* ================================================== */

function isBlocked(x, y) {
	return ( maze.Grid[x][y] & (1 << 1) ) > 0;
}

function isUnblockable(x, y) {
	return ( maze.Grid[x][y] & (1 << 2) ) > 0;
}

function isGrey(x, y) {
	return ( maze.Grid[x][y] & (1 << 3) ) > 0;
}

function applyColours(x, y) {
	var t = maze.Grid[x][y], e = bxy(x, y);
	if ( ( t & (1 << 4) ) > 0 ) e.addClass("gridBlue");
	if ( ( t & (1 << 5) ) > 0 ) e.addClass("gridYellow");
	if ( ( t & (1 << 6) ) > 0 ) e.addClass("gridRed");
	if ( ( t & (1 << 7) ) > 0 ) e.addClass("gridGreen");
}

