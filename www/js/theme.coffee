# IceMaze (c) 2012-2013 by Matt Cudmore

# globals
themes = {}
theme = null
activeThemeName = null

regTheme = (name, t) ->
	themes[name] = t
	return

loadTheme = (name) ->
	unless themes[name]?
		alert "Theme #{name} is undefined"
		return
	# unload previous theme
	theme.fini() if theme?
	# load new theme
	activeThemeName = name
	theme = themes[name]
	reset()
	refit()
	alert "Theme: #{name}"
	return

class Theme

	# each theme may define these maps:
	# (images will be pre-loaded by the constructor)
	images:  {} # imgID: "filename"
	sprites: {} # spriteID: [imgID, x, y, wid, hei]
	tiles:   {} # tileID: [animation mode, array of spriteID values]

	anim: {}
	dims: {}

	constructor: () ->
		# preload images
		for imgID, imgFile of @images
			@images[imgID] = img = new Image()
			img.src = imgFile
		return

	prep: ({c2d, maze, mode, raf, caf}) =>
		# update theme configuration
		@stop()
		# TODO consider using $.extend(this, atts)
		@c2d = c2d if c2d? # context2D for drawing
		@raf = raf if raf? # requestAnimationFrame
		@caf = caf if caf? # cancelAnimationFrame
		@maze = maze if maze?
		@mode = mode if mode?
		running = true
		return

	fini: () =>
		# finished with theme
		@running = false
		@stop()
		delete @c2d
		delete @maze
		return

	busy: () =>
		return @running and @anim.length > 0

	stop: () =>
		# stop any animations
		for animID, t of @anim
			clearTimeout t
			delete @anim[animID]
		return

	resize: (min) =>
		[w1, h1] = min
		[w2, h2] = @size()
		max = (a, b) -> if a > b then a else b
		@dims.canvas = [max(w1, w2), max(h1, h2)]

	# each theme must implement these methods:

	#offsets: =>
		# return the [left,top] padding of the maze on the canvas

	#size: () =>
		# return the minimum size [w,h] needed to draw the maze

	#drawMaze: (@maze) =>
		# redraw matte, border, and maze

	#drawPlayerAt: ([x,y], direction) =>
		# draw an avatar at the position [x,y] facing the direction

	#drawPlayerMove: (direction, path, callback) =>
		# draw an avatar moving in the direction along the path
		# use @raf(animFunction) to request an animation frame
		# call callback when animation completes
