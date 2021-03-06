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
		# check for horizontal and vertical coincidence
		[H, V] = [0 <= x < @width, 0 <= y < @height]
		# check for outer edges
		[L, R, T, B] = [x is -1, x is @width, y is -1, y is @height]
		# define positional attributes on tile
		return $.extend tile,
			inside: H and V
			border: ((L or R) and V) or ((T or B) and H)
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
				walkable = @toggle at, "walkable"
				ac = if walkable then "Set" else "Unset"
				alert "#{ac} walkable at #{at}"
			when 2
				special = ((@get(at).special || 0) + 1) % 32
				@set at, special: special
				alert "Set sprite index to #{special} at #{at}"
			when 3
				locked = @toggle at, "locked"
				ac = if locked then "Lock" else "Unlock"
				alert "#{ac} tile at #{at}"
			else
				obstacle = @toggle at, "obstacle"
				ac = if obstacle then "Put" else "Clear"
				alert "#{ac} obstacle at #{at}"
		return true

	scroll: (at, delta) =>
		dir = if delta > 0 then 1 else -1
		special = ((@get(at).special || 0) + dir) % 32
		if special < 0 then special += 32
		@set at, special: special

	isPassable: (at) =>
		tile = @get at
		return false if not tile.inside
		# entry and exit are always passable
		return true if tile.entry or tile.exit
		# non-obstacle tiles are passable
		return not tile.obstacle

	getPath: (from, dir) =>
		path = [from]
		while true
			next = @getNext from, dir
			break if not @isPassable next
			path.push next
			# take only one step onto walkable
			break if @is next, walkable: true
			from = next
		return path

	getNext: (from, dir, dist = 1) ->
		# get next position
		switch dir
			when "left"  then [from[0] - dist, from[1]]
			when "up"    then [from[0], from[1] - dist]
			when "right" then [from[0] + dist, from[1]]
			when "down"  then [from[0], from[1] + dist]
			else throw "Unrecognized direction #{dir}"

	getRelativeDirection: (a, b) ->
		# a relative to b
		left:  a[0] < b[0]
		right: a[0] > b[0]
		up:    a[1] < b[1]
		down:  a[1] > b[1]
