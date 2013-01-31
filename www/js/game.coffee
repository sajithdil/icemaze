# IceMaze (c) 2012-2013 by Matt Cudmore

class Game

	maze: null
	mode: null # "edit" or "play"
	playerPosition: null # [x, y]

	set: (attrs) =>
		@maze = attrs.maze if attrs.maze?
		@mode = attrs.mode if attrs.mode?
		@replay() if attrs.mode is "play"

	replay: =>
		@playerPosition = @maze.entry
		alert "Begin game at #{@playerPosition}"
		theme.movePlayer @playerPosition, "down"

	click: (ev, $canvas) =>
		ev.preventDefault()
		# only respond to click events during edit mode
		return if @mode isnt "edit"
		# get click coordinates relative to the canvas
		offs = $canvas.offset()
		relX = ev.pageX - offs.left
		relY = ev.pageY - offs.top
		edat = theme.at relX, relY
		# count active meta keys
		metaCount = ev.altKey + ev.ctrlKey + ev.shiftKey
		# pass only what is needed
		@maze.click edat, metaCount
		theme.redraw edat

	keydown: (ev) =>
		ev.preventDefault()
		# only respond to keydown events during play mode
		return if @mode isnt "play"
		# block further moves during animation
		return if theme.busy()
		# get the direction of which arrow key was pressed
		dirkeys = {37: "left", 38: "up", 39: "right", 40: "down"}
		direction = dirkeys[ev.which]
		# ignore unrecognized keys
		return if not direction
		# get the movement path
		path = @maze.movePlayer @playerPosition, direction
		endpoint = path[path.length - 1]
		# is the endpoint a win?
		winner = @maze.is endpoint, exit: true
		# log the move
		alert "Move #{direction} to #{endpoint}"
		# tell the theme to draw the movement
		theme.movePlayer @playerPosition, direction, path, =>
			@playerPosition = endpoint
			alert "WIN!" if winner
