# IceMaze (c) 2012-2013 by Matt Cudmore

currMaze = null
currMode = null # "edit" or "play"
currTheme = null
currPPost = null # player position [x, y]

setMaze = (maze) ->
	currMaze = maze if maze
	currTheme?.prep maze: currMaze
	# reset with new maze
	refitUI()
	resetGame()

setMode = (mode) ->
	return if currMode is mode #already
	if mode in ["edit", "play"] then alert "Begin #{mode} mode"
	else return alert "Mode[#{mode}] is undefined"

	currMode = mode if mode
	currTheme?.prep mode: currMode
	setUIMode currMode
	# reset with new mode
	resetGame()

setTheme = (thID) ->
	if th = themes[thID] then alert "Theme: #{th[0]}"
	else return alert "Theme[#{thID}] is undefined"

	# unload previous
	currTheme?.stop()
	# load theme
	currTheme = th[1]
	# configure theme
	currTheme.prep
		c2d: $maze[0].getContext("2d"), el: $maze[0]
		maze: currMaze, mode: currMode
	# resume with new theme
	refitUI()
	resumeGame()

resetGame = ->
	currTheme?.stop()
	if currMode is "play"
		currPPost = currMaze.entry
		alert "Begin game at #{currPPost}"
	resumeGame()

resumeGame = ->
	currTheme?.stop()
	currTheme?.clearCanvas()
	currTheme?.redraw()
	if currMode is "play"
			currTheme?.movePlayer currPPost, "down"

winGame = ->
	alert "WIN!"
	currTheme.fanfare()

##################################################
# user interactions

handleClick = (ev) ->
	# intercept all canvas clicks
	ev.preventDefault()
	# only respond to click events during edit mode
	return if currMode isnt "edit"
	# get click coordinates relative to the canvas
	offs = $maze.offset()
	relX = ev.pageX - offs.left
	relY = ev.pageY - offs.top
	edat = currTheme.at relX, relY
	# count active meta keys
	metaCount = ev.altKey + ev.ctrlKey + ev.shiftKey
	# pass only what is needed
	currMaze.click edat, metaCount
	currTheme.redraw edat

handleKeydown = (ev) ->
	# only respond to keydown events during play mode
	return if currMode isnt "play"
	# block further moves during animation
	return if currTheme.busy()
	# get the direction of which arrow key was pressed
	dirkeys = {37: "left", 38: "up", 39: "right", 40: "down"}
	direction = dirkeys[ev.which]
	# ignore unrecognized keys
	return if not direction
	# get the movement path
	path = currMaze.movePlayer currPPost, direction
	endpoint = path[path.length - 1]
	# is the endpoint a win?
	winner = currMaze.is endpoint, exit: true
	# log the move
	alert "Move #{direction} to #{endpoint}"
	# tell the theme to draw the movement
	currTheme.movePlayer currPPost, direction, path, =>
		currPPost = endpoint
		winGame() if winner
