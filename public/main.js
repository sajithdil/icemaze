
var themes = {
	"Basic theme": "basic",
	"Pokémon Gold/Silver theme": "pkmngs"
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

	buildGrid(m);

	// update tiles
	// TODO

}

function buildGrid(m) {

	var maze = $("#maze");
	var grid = $("#grid", maze);

	// return if the grid already has correct dimensions
	if (grid.attr("width") == m.width && grid.attr("height") == m.height)
		return;

	// reset the grid
	grid.empty();

	// set dimensions
	grid.attr("width", m.width).attr("height", m.height);

	// add and position all cells
	for (var y = -1; y <= m.height; y++) { // row by row
		for (var x = -1; x <= m.width; x++) { // col by col
			$("<button/>", {
				"x": x,
				"y": y,
				"class": ((x < 0 || x >= m.width || y < 0 || y >= m.height)
					? "border" : "plane") + " cell"
			}).appendTo(grid);
		}
		$("<br/>").appendTo(grid);
	}

	// add grid handlers
	$(".cell.plane").click(function(e){
		clickCell($(this).attr("x"), $(this).attr("y"), e);
	});

	// add entry/exit indicators (which will be positioned later)
	$(".cell[x="+m.entry[0]+"][y="+m.entry[1]+"]").addClass("entry");
	$(".cell[x="+m.exit[0]+"][y="+m.exit[1]+"]").addClass("exit");

	// add drag/drop ability to entry/exit
	// TODO

	positionMaze();

}

function positionMaze() {

	// position and size #wrap to fill screen under #menu
	var menuHeight = $("#menu").outerHeight(true);
	$("#wrap").css("marginTop", menuHeight);
	$("#wrap").height($(window).height() - menuHeight);

	// position the maze in the centre of the screen under #menu
	// or fill the screen (and include scrollbars) if too big
	// (menu will always be position fixed at top)
	$("#maze").position({
		of: $("#wrap"),
		my: "middle center",
		at: "middle center",
	});

}

function clickCell(x, y, e) {
	alert("Clicked ("+ x +", "+ y +")");
}

$(function(){

	// load themes list into UI selectable
	// TODO

	// apply default theme
	// TODO extract from URI query
 	$("#maze").addClass("basic");

	$(window).bind("resize", positionMaze);

	showMaze(maze);

});

