/* theme to simply draw the maze with squares and circles */

function ThemeBasic(c2d, maze) {
	if (!(this instanceof ThemeBasic)) {
  		return new ThemeBasic(c2d, maze);
  	}

	this.c2d = c2d;
  	this.maze = maze;
}

ThemeBasic.prototype = {

	anim: {},

	dims: {
		tile:   40, // px for tile width and height
		pad:     2, // px internal tile padding
		margin: 10, // px margin around maze
	},

	init: function() {
		// nothing to do to initialize basic theme
	},

	prep: function(canvasSize) {
		this.dims.canvas = canvasSize;
		this.dims.offs = this.offsets();
		return this.dims.maze = this.minSize();
	},

	start: function(mode) {
		this.stop();
		this.mode = mode;
	},

	stop: function() {
		if (this.anim.move) {
			clearTimeout(this.anim.move);
			delete this.anim.move;
		}
		if (this.anim.matte) {
			clearTimeout(this.anim.matte);
			delete this.anim.matte;
		}
	},

	fini: function() {
		// stop any animation
		this.stop();
		// release c2d and maze
		delete this.c2d;
		delete this.maze;
	},

	minSize: function(noBorder) {
		var borders = 2;
		if (noBorder) {
			borders = 0;
		}

		var w = (this.maze.width + borders) * this.dims.tile;
		var h = (this.maze.height + borders) * this.dims.tile;
		var margins = this.dims.margin * 2;
		return [w + margins, h + margins];
	},

	// offsets returns the [x,y] offset from the top-left of the canvas
	// for drawing the maze centred in the canvas
	offsets: function() {
		var mSize = this.minSize(true);
		var xoff = Math.floor((this.dims.canvas[0] - mSize[0]) / 2);
		var yoff = Math.floor((this.dims.canvas[1] - mSize[1]) / 2);
		return [xoff + this.dims.margin, yoff + this.dims.margin];
	},

	// at returns tile coordinates at pixel (x, y)
	at: function(x, y) {
		x = Math.floor((x - this.dims.offs[0]) / this.dims.tile);
		y = Math.floor((y - this.dims.offs[1]) / this.dims.tile);
		return [x, y];
	},

/* ********************************** */

	redraw: function(c2d) {
		this.c2d = c2d || this.c2d;
		this.c2d.clearRect(0, 0, this.dims.canvas[0], this.dims.canvas[1]);
		this.drawMatte();
		this.drawMaze();
	},

	drawMatte: function() {
		var c2d = this.c2d;
		c2d.save();

		var g = this.anim.matte || 88;
		c2d.fillStyle = "rgb(" + g + "," + g + "," + g + ")";
		c2d.fillRect(0, 0, this.dims.canvas[0], this.dims.offs[1]); // top
		c2d.fillRect(0, 0, this.dims.offs[0], this.dims.canvas[1]); // left
		// TODO right, bottom, or decide another style

		c2d.restore();
	},

	drawMaze: function() {
		// draw tile-by-tile
		for (var x = -1; x <= this.maze.width; x++) {
			for (var y = -1; y <= this.maze.height; y++) {
				this.drawTile([x, y]);
			}
		}
	},

	drawTile: function(at) {
		var c2d = this.c2d;
		c2d.save();

		// translate to tile position
		c2d.translate(this.dims.offs[0] + (at[0] * this.dims.tile),
			this.dims.offs[1] + (at[1] * this.dims.tile));

		var tile = this.maze.get(at);

		if (tile.locked) {
			c2d.fillStyle = "yellow";
			c2d.fillRect(0, 0, this.dims.tile, this.dims.tile);
		}

		// draw grid
		c2d.strokeStyle = "lightgrey";
		c2d.strokeRect(0, 0, this.dims.tile, this.dims.tile);

		if (tile.border) {
			c2d.fillStyle = "darkgrey";
			this.drawBlock(c2d);

		} else {
			if (tile.blocked) {
				c2d.fillStyle = "grey";
				this.drawBlock(c2d);

			} else if (tile.ground) {
				c2d.fillStyle = "tan";
				this.drawPatch(c2d, 5);
		
			} else {
				c2d.fillStyle = "lightblue";
				this.drawPatch(c2d, 4);
			}
		}

		if (tile.entry) {
			c2d.fillStyle = "green";
			this.drawBlock(c2d);
		} else if (tile.exit) {
			c2d.fillStyle = "orange";
			this.drawBlock(c2d);
		}

		c2d.restore();
	},

// CONTINUE WORKING BELOW

	drawBlock: function(c2d) {
		var pad = this.dims.pad, ded = this.dims.tile - (pad * 2);
		c2d.fillRect(pad, pad, ded, ded);
	},

	drawPatch: function(c2d, steps) {
		var step = (this.dims.tile - (this.dims.pad * 2)) / steps;
		c2d.save();
		c2d.translate(this.dims.pad, this.dims.pad);
		for (var x = 0; x < steps; x++) {
			for (var y = x % 2; y < steps; y += 2) {
				c2d.fillRect(x * step, y * step, step, step);
			}
		}
		c2d.restore();
	},

/* ********************************** */

	drawSolns: function(solns) {
	},

/* ********************************** */

	drawPlayerAt: function(coords) {
	},

	drawPlayerMove: function(dir, path, callback) {
		if (callback) {
			callback();
		}
	}

};
