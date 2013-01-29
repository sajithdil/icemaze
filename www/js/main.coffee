# compile with: coffee -c [-o compiled] -j *.coffee

maze  = null
mode  = null
theme = null
midAnimation = false
playerPosition  = null

click = (ev)->
	ev.preventDefault()
	# only respond to mouse clicks during edit mode
	return if mode != "edit"

arrow = (ev)->
	ev.preventDefault()
	# only respond to arrow keys during play mode
	return if mode != "play"
	# block further moves during animation
	return if midAnimation
	# get the direction of which arrow key was pressed
	dirkeys = {37: "left", 38: "up", 39: "right", 40: "down"}
	direction = dirkeys[ev.which]
	# ignore unrecognized keys
	return if not direction
	# get the movement path (path[0] is the initial player position)
	path = maze.getPath(playerPosition, direction)
	endpoint = path[path.length - 1]
	# is the endpoint a win?
	winner = maze.is(endpoint, {exit: true})
	# tell the theme to draw the movement
	midAnimation = true
	theme.drawPlayerMove direction, path, ()->
		playerPosition = endpoint
		midAnimation = false
		win() if winner
	# log the move
	alert "moving to #{endpoint}"
	alert "WIN!" if winner

redraw = ()->

help = (topic)->
	# raise info box

window.alert = (message)->
	# raise message

$ ->
	# TODO check whether canvas and 2d drawing context is supported
	# TODO initialize themes
	# TODO load themes list into menu
	# TODO load saved mazes into menu
	# TODO add menu handlers

	# add maze handlers
	$("#maze").on "click", click
	$(document).on "keydown", arrow

	# refit() handles layout
	$(window).on "resize", refit
	$(window).trigger "resize"
