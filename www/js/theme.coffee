# IceMaze (c) 2012-2013 by Matt Cudmore

class Theme

	constructor: (@c2d, @maze) ->

	# each theme may define these maps
	# images will be pre-loaded by init()
	images:  {} # imgID: "filename"
	sprites: {} # spriteID: [imgID, x, y, wid, hei]
	tiles:   {} # tileID: [animation mode, array of spriteID values]

	anim: {}
	dims: {}

	init: () =>
		# preload images
		for imgID, imgFile in @images
			@images[imgID] = img = new Image()
			img.src = imgFile
		return

	prep: ({c2d, maze}) =>
		# update theme configuration
		@c2d = c2d if c2d?
		@maze = maze if maze?
		return

	fini: () =>
		# finished with theme
		@stop()
		delete @c2d
		delete @maze
		return

	start: (mode) =>
		@stop()
		@mode = mode if mode?
		@running = true
		return

	stop: () =>
		@running = false
		# stop any animations
		for animID, t of @anim
			clearTimeout t
			delete @anim[animID]
		return

	resize: (min) =>
		[w1, h1] = min
		[w2, h2] = @size()
		max = (a, b) -> if a > b then a else b
		# return actual
		@dims.canvas = [max(w1, w2), max(h1, h2)]
