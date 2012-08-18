/* theme to simply draw the maze with squares and circles */

var themeBasic = {

	tileW: 50,
	tileH: 50,
	margin: 10,

	init: function() {
		// nothing to do to initialize basic theme
	},

	minSize: function(maze) {
		var w = (maze.width * this.tileW) + (2 * this.margin);
		var h = (maze.height * this.tileH) + (2 * this.margin);
		return [w, h];
	},

	whichTile: function(x, y) {
		x = Math.floor((x - this.margin) / this.tileW);
		y = Math.floor((y - this.margin) / this.tileH);
		return [x, y];
	},

	drawMatte: function(c2d, cSize) {
		// simply clear the entire canvas
		c2d.clearRect(0, 0, cSize[0], cSize[1]);
	},

	drawMaze: function(c2d, cSize, maze) {
		c2d.save();

		// get offsets for drawing the maze in centre of canvas
		var mazeSize = this.minSize(maze);
		var xoff = Math.floor((cSize[0] - mazeSize[0]) / 2);
		var yoff = Math.floor((cSize[1] - mazeSize[1]) / 2);
		c2d.translate(xoff + this.margin, yoff + this.margin);

		// draw grid
		c2d.fillStyle = 'black';
		c2d.strokeStyle = 'black';
		c2d.lineCap = 'round';
		c2d.beginPath();
		for (var x = 0; x <= maze.width; x++) {
			var level = x * this.tileW;
			c2d.moveTo(level, 0);
			c2d.lineTo(level, maze.height * this.tileH);
		}
		for (var y = 0; y <= maze.height; y++) {
			var level = y * this.tileH;
			c2d.moveTo(0, level);
			c2d.lineTo(maze.width * this.tileW, level);
		}
		c2d.closePath();
		c2d.stroke();
		c2d.fill();

		c2d.restore();
	},

	drawTile: function(c2d, x, y, tile) {
	},

	drawSolns: function(c2d, solns) {
	},

	flipTile: function(c2d, x, y, fromTile, toTile) {
		this.drawTile(c2d, x, y, toTile);
	},

};
