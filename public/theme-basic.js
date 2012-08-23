/* theme to simply draw the maze with squares and circles */

var themeBasic = {

	tileSize: 50,
	tilePad: 2,
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

	minSize: function(mSize, b) {
		// if b, add 2 to mSize width and height to include border
		b = b ? 2 : 0;
		var w = ((mSize[0] + b) * this.tileSize) + (2 * this.margin);
		var h = ((mSize[1] + b) * this.tileSize) + (2 * this.margin);
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
		x = Math.floor((x - this.current.offsets[0]) / this.tileSize);
		y = Math.floor((y - this.current.offsets[1]) / this.tileSize);
		return [x, y];
	},

/* ********************************** */

	drawMatte: function(c2d, maze) {
		// simply clear the entire canvas
		c2d.clearRect(0, 0, this.current.cSize[0], this.current.cSize[1]);
	},

	drawMaze: function(c2d, maze) {
		c2d.save();

		// translate for drawing the maze in centre of canvas
		c2d.translate(this.current.offsets[0], this.current.offsets[1]);

		for (var x = -1; x <= maze.width; x++) {
			for (var y = -1; y <= maze.height; y++) {
				c2d.save();
				// translate for drawing tile
				c2d.translate(x * this.tileSize, y * this.tileSize);
				this.drawTile(c2d, maze.get([x, y]));
				c2d.restore();
			}
		}

		c2d.restore();
	},

	drawTile: function(c2d, tile) {

		if (tile.locked) {
			c2d.fillStyle = "yellow";
			c2d.fillRect(0, 0, this.tileSize, this.tileSize);
		}

		// draw grid
		c2d.strokeStyle = "lightgrey";
		c2d.strokeRect(0, 0, this.tileSize, this.tileSize);

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

	},

	drawBlock: function(c2d) {
		var pad = this.tilePad, ded = this.tileSize - (pad * 2);
		c2d.fillRect(pad, pad, ded, ded);
	},

	drawPatch: function(c2d, steps) {
		var step = (this.tileSize - (this.tilePad * 2)) / steps;
		c2d.save();
		c2d.translate(this.tilePad, this.tilePad);
		for (var x = 0; x < steps; x++) {
			for (var y = x % 2; y < steps; y += 2) {
				c2d.fillRect(x * step, y * step, step, step);
			}
		}
		c2d.restore();
	},

/* ********************************** */

	drawSolns: function(c2d, solns) {
	}

};
