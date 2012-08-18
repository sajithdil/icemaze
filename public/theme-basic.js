/* theme to simply draw the maze with squares and circles */

var themeBasic = {

	tileW: 50,
	tileH: 50,
	margin: 10,

	current: {},

	init: function() {
		// nothing to do to initialize basic theme
	},

	prep: function(cSize, mSize) {
		this.current.cSize = cSize;
		this.current.minSize = this.minSize(mSize);
		this.current.offsets = this.offsets(cSize, mSize);
	},

	minSize: function(mSize) {
		var w = (mSize[0] * this.tileW) + (2 * this.margin);
		var h = (mSize[1] * this.tileH) + (2 * this.margin);
		return [w, h];
	},

	offsets: function(cSize, mSize) {
		// returns the offset from the top-left of the canvas
		// for drawing the maze centred in the canvas
		mSize = this.minSize(mSize);
		var xoff = Math.floor((cSize[0] - mSize[0]) / 2) + this.margin;
		var yoff = Math.floor((cSize[1] - mSize[1]) / 2) + this.margin;
		return [xoff, yoff];
	},

	at: function(x, y) {
		// call prep(cSize, mSize) before calling at(x, y)
		// returns tile coordinates at pixel (x, y)
		x = Math.floor((x - this.current.offsets[0]) / this.tileW);
		y = Math.floor((y - this.current.offsets[1]) / this.tileH);
		return [x, y];
	},

	drawMatte: function(c2d, maze) {
		// simply clear the entire canvas
		c2d.clearRect(0, 0, this.current.cSize[0], this.current.cSize[1]);
	},

	drawMaze: function(c2d, maze) {
		c2d.save();

		// translate for drawing the maze in centre of canvas
		c2d.translate(this.current.offsets[0], this.current.offsets[1]);

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
