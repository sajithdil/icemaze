# IceMaze (c) 2012-2013 by Matt Cudmore

# GLOBALS
themes = {}
registerTheme = (id, title, theme) ->
	themes[id] = [title, theme]

class Theme

	##################################################
	# OVERRIDABLES

	images: {
		# imgID: "filename"
		# (filenames will be replaced by image objects,
		#  preloaded by the default constructor.)
	}

	fanfare: =>
		# acknowledge a win with visual feedback,
		# or return false to raise a simple modal message.
		return false

	##################################################
	# PURE VIRTUAL METHODS
	# (themes must implement these methods.)

	#size: () =>
		# return the minimum canvas [width, height] needed to draw the maze.
	#at: (x, y) =>
		# return the tile position at the given [x, y] pixel coordinates.
	#redraw: (positions...) =>
		# redraw the tiles at the given positions,
		# or redraw the entire maze if no positions are given.
	#drawSolns: (solutions) =>
		# draw the solution paths
	#drawMove: (position, direction, path, callback) =>
		# draw an avatar at position, facing direction;
		# or animate moving in direction along path.
		# use @anim(id,fnNextFrame) to request an animation frame.
		# call callback when animation completes.

	##################################################
	# STATE VARIABLES
	# (themes may read these, but not write.)

	#maze: set by @prep; current maze
	#mode: set by @prep; current mode either "edit" or "play"
	#c2d:  set by @prep; current context2d for drawing

	canvasSize: [0, 0] # current size of the drawing canvas
	themeReady: false  # whether all images have been loaded
	themeOnAir: false  # whether this is currently the active theme
	currAnim:   null   # controls for the active animation

	##################################################
	# FINAL METHODS

	constructor: (cbReady, cbError) ->
		allReady = ()=> @themeReady = true; cbReady() if cbReady
		# count images
		remaining = 0
		remaining++ for i of @images
		# return if none
		return allReady() if remaining is 0
		# callback closures
		imgLoaded = (src)=> ()=> allReady() if --remaining is 0
		imgFailed = (src)=> ()=> cbError("Failed to load #{src}") if cbError
		# preload images
		for imgID, imgFile of @images
			img = new Image()
			img.onload = imgLoaded(imgFile)
			img.onerror = imgFailed(imgFile)
			img.src = imgFile
			@images[imgID] = img
		return

	prep: (attrs) =>
		@stop()
		@c2d = attrs.c2d if attrs.c2d?
		@el = attrs.el if attrs.el
		@maze = attrs.maze if attrs.maze?
		@mode = attrs.mode if attrs.mode?

	anim: (cb, fn) =>
		@stop()
		@resume()
		@currAnim = startAnim fn, cb, @el

	busy: =>
		@currAnim?.busy()

	stop: () =>
		@themeOnAir = false
		@currAnim?.cancel()

	resume: () =>
		@themeOnAir = true
		@redraw()

	resize: (min) =>
		[w1, h1] = min
		[w2, h2] = @size()
		max = (a, b) -> if a > b then a else b
		@canvasSize = [max(w1, w2), max(h1, h2)]

	##################################################
	# GENERAL DRAWING UTILITY METHODS

	clearCanvas: () =>
		@c2d.clearRect(0, 0, @canvasSize[0], @canvasSize[1])

	fillCanvas: (style) =>
		@c2d.fillStyle = style
		@c2d.fillRect(0, 0, @canvasSize[0], @canvasSize[1])

	fill: (sty) =>
		@c2d.fillStyle = sty
		@c2d.fill()

	stroke: (wid, sty) =>
		@c2d.lineWidth = wid
		@c2d.strokeStyle = sty
		@c2d.stroke()

	traceRect: (x, y, w, h) =>
		@c2d.beginPath()
		@c2d.rect(x, y, w, h)
		@c2d.closePath()

	traceRounded: (x, y, w, h, r) =>
		# thanks http://stackoverflow.com/a/3368118
		@c2d.beginPath()
		@c2d.moveTo(x + r, y)
		@c2d.lineTo(x + w - r, y)
		@c2d.quadraticCurveTo(x + w, y, x + w, y + r)
		@c2d.lineTo(x + w, y + h - r)
		@c2d.quadraticCurveTo(x + w, y + h, x + w - r, y + h)
		@c2d.lineTo(x + r, y + h)
		@c2d.quadraticCurveTo(x, y + h, x, y + h - r)
		@c2d.lineTo(x, y + r)
		@c2d.quadraticCurveTo(x, y, x + r, y)
		@c2d.closePath()

	traceCircle: (x, y, r) =>
		@c2d.beginPath()
		@c2d.arc(x, y, r, 0, Math.PI * 2, false)
		@c2d.closePath()
