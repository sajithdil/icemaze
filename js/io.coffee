# IceMaze (c) 2012-2013 by Matt Cudmore

encodeMaze = (maze) ->
	# 1 byte per value
	data = [
		maze.width, maze.height
		maze.entry[0], maze.entry[1]
		maze.exit[0], maze.exit[1]
	]
	# 1 byte per tile
	for x in [0 .. maze.width - 1]
		for y in [0 .. maze.height - 1]
			tile = maze.get [x, y]
			# 5 bits for special
			props = (tile.special or 0) & 0x31
			# 3 bits for properties
			props |= 1 << 7 if tile.locked
			props |= 1 << 6 if tile.blocked
			props |= 1 << 5 if tile.ground
			data.push props
	# encode in base64
	return window.btoa String.fromCharCode data...

decodeMaze = (data) ->
	data = window.atob data
	i = 0
	# 1 byte per value
	maze = new Maze(data.charCodeAt(i++), data.charCodeAt(i++))
	maze.entry = [data.charCodeAt(i++), data.charCodeAt(i++)]
	maze.exit = [data.charCodeAt(i++), data.charCodeAt(i++)]
	# 1 byte per tile
	for x in [0 .. maze.width - 1]
		for y in [0 .. maze.height - 1]
			props = data.charCodeAt(i++)
			maze.set [x, y],
				# 5 bits for special
				special: props & 0x31
				# 3 bits for properties
				locked: (props & (1 << 7)) > 0
				blocked: (props & (1 << 6)) > 0
				ground: (props & (1 << 5)) > 0
	return maze
