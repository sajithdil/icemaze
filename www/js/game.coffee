# IceMaze (c) 2012-2013 by Matt Cudmore

# globals
maze = null
mode = null

playerPosition = null

loadMaze = (m) ->
	maze = m
	reset()
	return

setMode = (toMode) ->
	return if mode is toMode #already
	mode = toMode
	setUIMode toMode
	reset()
	alert "Mode: #{toMode}"
	return

reset = () ->
	return unless maze? and theme?
	switch mode
		when "edit" then reprep()
		when "play" then replay()
	return

# thanks to polyfill https://gist.github.com/1579671
retRAF = (el) -> (fn) -> window.requestAnimationFrame(fn, el)
retCAF = () -> (id) -> window.cancelAnimationFrame(id)

reprep = () ->
	$maze0 = $("#maze").get(0)
	theme.prep
		c2d: $maze0.getContext("2d"),
		raf: retRAF($maze0), caf: retCAF(),
		maze: maze, mode: mode
	theme.drawMaze()
	return

replay = () ->
	reprep()
	playerPosition = maze.entry
	theme.drawPlayerAt playerPosition
	return

click = (ev) ->
	ev.preventDefault()
	# only respond to mouse clicks during edit mode
	return if mode isnt "edit"
	# get click coordinates relative to the canvas
	offs = $("#maze").offset()
	relX = ev.pageX - offs.left
	relY = ev.pageY - offs.top
	# count active meta keys
	metaCount = ev.altKey + ev.ctrlKey + ev.shiftKey
	# pass only what is needed
	maze.click theme.at(relX, relY), metaCount
	theme.drawMaze()
	return

arrow = (ev) ->
	ev.preventDefault()
	# only respond to arrow keys during play mode
	return if mode isnt "play"
	# block further moves during animation
	return if theme.busy()
	# get the direction of which arrow key was pressed
	dirkeys = {37: "left", 38: "up", 39: "right", 40: "down"}
	direction = dirkeys[ev.which]
	# ignore unrecognized keys
	return if not direction
	# get the movement path (path[0] is the initial player position)
	path = maze.getPath playerPosition, direction
	endpoint = path[path.length - 1]
	# is the endpoint a win?
	winner = maze.is endpoint, exit: true
	# log the move
	alert "Move #{direction} from #{playerPosition} to #{endpoint}"
	# tell the theme to draw the movement
	theme.drawPlayerMove direction, path, () ->
		playerPosition = endpoint
		alert "WIN!" if winner
	return
