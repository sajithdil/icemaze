/* icemaze.js with very minimal error-checking */

function Maze(data) {
	// in case I forget to type "new"
	if (!(this instanceof Maze)) {
		return new Maze(data);
	}

	// check whether data is Array or Object
	if ($.isArray(data)) {
		// data should be [width, height]
		var w = data[0], h = data[1];
		this.width  = w;
		this.height = h;
		this.cells  = [[]];
		this.entry  = [-1, 0];  // left of top-left corner
		this.exit   = [w, h-1]; // right of bottom-right corner
	} else {
		// data should be object received from server
		// TODO
	}
}

Maze.prototype = {

	get: function(at) {
		var x = at[0], y = at[1], tile = ((this.cells[x]||[])[y])||{};
		$.extend(tile, {x: x, y: y,
			border: x < 0 || x >= this.width || y < 0 || y >= this.height,
			entry:  x == this.entry[0] && y == this.entry[1],
			exit:   x == this.exit[0] && y == this.exit[1]
		});
		return tile;
	},

	is: function(at, attrs) {
		var tile = this.get(at);
		for (var a in attrs) {
			if (tile[a] != attrs[a]) {
				return false;
			}
		}
		return true;
	},

	isMutable: function(at, orEntryExit) {
		var x = at[0], y = at[1];
		var within = x >= 0 && x < this.width && y >= 0 && y < this.height;
		if (within || !orEntryExit) {
			return within;
		}

		// entry and exit may be positioned on the border,
		// but not on the border corners
		var borderW = x == -1, borderE = x == this.width;
		var borderN = y == -1, borderS = y == this.height;
		return ((borderW || borderE) && !(borderN || borderS))
			|| ((borderN || borderS) && !(borderW || borderE));
	},

	set: function(at, attrs) {
		if (!this.isMutable(at)) {
			return;
		}
		var x = at[0], y = at[1];
		// create the column in this.cells if not yet defined
		var col = this.cells[x] || (this.cells[x] = []);
		var tile = col[y] || {};
		for (var a in attrs) {
			tile[a] = attrs[a];
		}
		this.cells[x][y] = tile;
	},

	toggle: function(at, attr) {
		var t = {};
		t[attr] = !this.get(at)[attr];
		this.set(at, t);
		return t[attr];
	},

	setEntry: function(at) {
		// entry and exit may not occupy the same position
		if (this.isMutable(at, true) && !this.get(at).exit) {
			this.entry = at;
		}
	},

	setExit: function(at) {
		// entry and exit may not occupy the same position
		if (this.isMutable(at, true) && !this.get(at).entry) {
			this.exit = at;
		}
	},

	click: function(at, metac) {
		if (!this.isMutable(at)) {
			return;
		}
		switch (metac) {
		default:
		case 0:
			this.toggle(at, "blocked");
			showStatus("toggle block at " + at);
			break;
		case 1:
			this.toggle(at, "ground");
			showStatus("toggle ground at " + at);
			break;
		case 2:
			var locked = this.toggle(at, "locked");
			showStatus((locked ? "" : "un") + "lock tile at " + at);
			break;
		}
	},

	isPassable: function(at) {
		if (!this.isMutable(at, true)) {
			return false;
		}
		var tile = this.get(at);
		return !(tile.blocked || tile.border) || tile.entry || tile.exit;
	},

	getPath: function(from, dir) {
		var path = [from];

		while (true) {
			// get the next step
			switch (dir) {
			case "left":
				from = [from[0] - 1, from[1]];
				break;
			case "up":
				from = [from[0], from[1] - 1];
				break;
			case "right":
				from = [from[0] + 1, from[1]];
				break;
			case "down":
				from = [from[0], from[1] + 1];
				break;
			default:
				// unrecognized direction; can't move
				throw new Error("unrecognized direction " + dir);
			}

			if (this.isPassable(from)) {
				path.push(from);
			} else {
				break;
			}

			// only go one step on ground
			if (this.get(from).ground) {
				break;
			}
		}

		return path;
	}

};
