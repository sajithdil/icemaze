/* simply draw the maze with squares and circles */

var basicTheme = {

	tileW: 50,
	tileH: 50,
	margin: 100,

	init: function() {
		// nothing to do to initialize basic theme
	},

	size: function(maze) {
		var w = (maze.width * this.tileW) + (2 * this.margin);
		var h = (maze.height * this.tileH) + (2 * this.margin);
		return [w, h];
	},

	whichTile: function(x, y) {
		x = Math.floor((x - this.margin) / this.tileW);
		y = Math.floor((y - this.margin) / this.tileH);
		return [x, y];
	},

	drawMaze: function(c2d, maze) {
		// draw matte
		var dim = this.size(maze);
		c2d.fillStyle = 'black';
		c2d.fillRect(0, 0, dim[0], dim[1]); // simply a black square

		// draw grid
		c2d.fillStyle = 'white';
		c2d.strokeStyle = 'white';
		c2d.lineCap = 'round';
		c2d.beginPath();
		for (var x = 0; x <= maze.width; x++) {
			var level = this.margin + (x * this.tileW);
			c2d.moveTo(level, this.margin);
			c2d.lineTo(level, this.margin + (maze.height * this.tileH));
		}
		for (var y = 0; y <= maze.height; y++) {
			var level = this.margin + (y * this.tileH);
			c2d.moveTo(this.margin, level);
			c2d.lineTo(this.margin + (maze.width * this.tileW), level);
		}
		c2d.closePath();
		c2d.stroke();
		c2d.fill();
	},

	drawTile: function(c2d, x, y, tile) {
	},

	drawSolns: function(c2d, solns) {
	},

	flipTile: function(c2d, x, y, fromTile, toTile) {
		this.drawTile(c2d, x, y, toTile);
	},

};
