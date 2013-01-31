# IceMaze (c) 2012-2013 by Matt Cudmore

class Maze

	constructor: (@width, @height) ->
		@cells = [[]]
		# default entry in top-left corner
		@entry = [0, 0]
		# default exit in bottom-right corner
		@exit  = [@width - 1, @height - 1]

	get: (at) =>
		[x, y] = at
		tile = (@cells[x] or [])[y] or {}
		# check for edges
		[L, R, T, B] = [x is 0, x is @width - 1, y is 0, y is @height - 1]
		# define positional attributes on tile
		return $.extend tile,
			inside: 0 <= x < @width and 0 <= y < @height
			border: L or R or T or B
			corner: (L or R) and (T or B)
			edges:  {left: L, right: R, top: T, bottom: B}
			entry:  x is @entry[0] and y is @entry[1]
			exit:   x is @exit[0] and y is @exit[1]

	is: (at, attrs) =>
		tile = @get at
		for a of attrs when tile[a] or attrs[a]
			return false if tile[a] isnt attrs[a]
		return true

	set: (at, attrs) =>
		return unless @is at, inside: true
		[x, y] = at
		# create the column in @cells if not yet defined
		tile = (@cells[x] ?= [])[y] or {}
		tile[a] = attrs[a] for a of attrs
		@cells[x][y] = tile

	toggle: (at, attr) =>
		return unless @is at, inside: true
		tog = {}
		ret = tog[attr] = not @get(at)[attr]
		@set at, tog
		return ret

	setEntry: (at) =>
		@entry = at if @is at, inside: true, exit: false

	setExit: (at) =>
		@exit = at if @is at, inside: true, entry: false

	click: (at, metac) =>
		return unless @is at, inside: true
		switch metac
			when 1
				@toggle at, "ground"
				alert "Toggle ground at #{at}"
			when 2
				locked = @toggle at, "locked"
				unl = if locked then "L" else "Unl"
				alert "#{unl}ock tile at #{at}"
			when 3
				special = (@get(at).special || 0) + 1
				@set at, special: special
				alert "Change special sprite index to #{special} at #{at}"
			else
				@toggle at, "blocked"
				alert "Toggle block at #{at}"
		return true

	isPassable: (at) =>
		tile = @get at
		return false if not tile.inside
		# entry and exit are always passable
		return true if tile.entry or tile.exit
		# non-blocked tiles are passable
		return not tile.blocked

	movePlayer: (from, dir) =>
		path = [from]
		while true
			next = @getNextPosition from, dir
			break if not @isPassable next
			path.push next
			# take only one step onto ground
			break if @is next, ground: true
			from = next
		return path

	getNextPosition: (from, dir) ->
		switch dir
			when "left"  then [from[0] - 1, from[1]]
			when "up"    then [from[0], from[1] - 1]
			when "right" then [from[0] + 1, from[1]]
			when "down"  then [from[0], from[1] + 1]
			else throw "Unrecognized direction #{dir}"

	getRelativeDirection: (a, b) ->
		# a relative to b
		left:  a[0] < b[0]
		right: a[0] > b[0]
		up:    a[1] < b[1]
		down:  a[1] > b[1]
