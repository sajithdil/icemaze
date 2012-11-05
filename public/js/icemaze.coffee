# IceMaze (c) 2012 by Matt Cudmore

class Maze
	constructor: (@width, @height) ->
		@cells = [[]]
		@entry = [-1, 0]
		@exit  = [@width, @height - 1] 

	get: (at) =>
		[x, y] = at
		tile = (@cells[x] or [])[y] or {}
		return $.extend tile,
			border: x < 0 or x >= @width or y < 0 or y >= @height
			entry:  x is @entry[0] and y is @entry[1]
			exit:   x is @exit[0] and y is @exit[1]

	is: (at, attrs) =>
		tile = @get at
		for a of attrs when tile[a] or attrs[a]
			return false if tile[a] isnt attrs[a]
		return true

	isMutable: (at, orEntryExit) =>
		# returns whether the maze is mutable at the given position.
		[x, y] = at
		# all tiles within the maze are mutable.
		within = x >= 0 and x < @width and y >= 0 and y < @height
		return within if within or not orEntryExit
		# non-corner border positions may be considered mutable,
		# for the entry or exit may be on the outer edge of the maze.
		bWE = x is -1 or x is @width # west or east border
		bNS = y is -1 or y is @height # north or south border
		return (bWE and not bNS) or (bNS and not bWE)

	set: (at, attrs) =>
		return if not @isMutable at
		[x, y] = at
		# create the column in @cells if not yet defined
		tile = (@cells[x] ?= [])[y] or {}
		tile[a] = attrs[a] for a of attrs
		@cells[x][y] = tile

	toggle: (at, attr) =>
		return if not @isMutable at
		tog = {}
		ret = tog[attr] = not @get(at)[attr]
		@set at, tog
		return ret

	setEntry: (at) =>
		return if not @isMutable at, true
		@entry = at if not @is at, exit: true

	setExit: (at) =>
		return if not @isMutable at, true
		@exit = at if not @is at, entry: true

	click: (at, metac) =>
		return if not @isMutable at
		switch metac
			when 1
				@toggle at, "ground"
				showStatus "toggle ground at #{at}"
			when 2
				locked = @toggle at, "locked"
				un = if locked then "" else "un"
				showStatus "#{un}lock tile at #{at}"
			else
				@toggle at, "blocked"
				showStatus "toggle block at #{at}"

	isPassable: (at) =>
		return false if not @isMutable at, true
		tile = @get at
		# entry and exit are always passable
		return true if tile.entry or tile.exit
		# non-blocked mutable non-border tiles are passable
		return not (tile.blocked or tile.border)

	move: (from, dir) =>
		switch dir
			when "left"  then [from[0] - 1, from[1]]
			when "up"    then [from[0], from[1] - 1]
			when "right" then [from[0] + 1, from[1]]
			when "down"  then [from[0], from[1] + 1]
			else throw "Unrecognized direction #{dir}"

	getPath: (from, dir) =>
		path = [from]
		while true
			from = move from, dir
			break if not @isPassable from
			path.push from
			# take only one step onto ground
			break if @is from, ground: true
		return path
