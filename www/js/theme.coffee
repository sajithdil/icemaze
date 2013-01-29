# IceMaze (c) 2012-2013 by Matt Cudmore

# globals
themes = {}
theme = null
activeThemeName = null

regTheme = (name, t, useAsDefault) ->
	themes[name] = t
	loadTheme name if useAsDefault
	return

loadTheme = (name) ->
	if not themes[name]
		alert "Theme #{name} is undefined"
		return

	# unload previous theme
	theme.fini() if theme?
	# load new theme
	activeThemeName = name
	alert "Theme: #{name}"
	theme = themes[name]
	reprep()
	refit()
	return

class Theme

	# each theme may define these maps;
	# images will be pre-loaded by the constructor
	images:  {} # imgID: "filename"
	sprites: {} # spriteID: [imgID, x, y, wid, hei]
	tiles:   {} # tileID: [animation mode, array of spriteID values]

	anim: {}
	dims: {}

	constructor: (@name, useAsDefault) ->
		# preload images
		for imgID, imgFile of @images
			@images[imgID] = img = new Image()
			img.src = imgFile
		return

	prep: ({c2d, maze, mode}) =>
		# update theme configuration
		@stop()
		@c2d = c2d if c2d?
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
		# return actual
		@dims.canvas = [max(w1, w2), max(h1, h2)]
