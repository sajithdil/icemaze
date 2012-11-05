# theme to simply draw the maze with no external image dependencies

class ThemeBasic
	constructor: (config) ->
		@prep(config)

	anim: {}
	dims:
		tile:   40 # px for tile width and height
		pad:     2 # px internal tile padding
		margin: 10 # px margin around maze

	init: () =>
		# nothing to initialize

	prep: ({c2d, cSize, maze}) =>
		# update theme configuration
		@c2d = c2d if c2d?
		@dims.canvas = cSize if cSize?
		# update source content
		@maze = maze if maze?

	fini: () =>
		# finished with theme
		@stop()
		delete @c2d
		delete @maze

	start: (mode) =>
		# reset mode
		@stop()
		@mode = mode if mode?
		# begin any ambient animations
		# (none for basic theme)

	stop: () =>
		# stop any animations
		if @anim.move?
			clearTimeout(@anim.move)
			delete @anim.move
		if @anim.matte?
			clearTimeout(@anim.matte)
			delete @anim.matte

	size: (borders, margins) =>
		# returns the minimum canvas size required for drawing.
		# include borders and margins in calculation by default,
		# for both borders and margins are included in drawing.
		b = if borders is false then 0 else 2
		m = if margins is false then 0 else @dims.margin * 2
		mazeW = @maze?.width or 0
		mazeH = @maze?.height or 0
		drawW = (mazeW + b) * @dims.tile
		drawH = (mazeH + b) * @dims.tile
		return [drawW + m, drawH + m]

	offsets: () =>
		# returns drawing offsets to the top-left (0,0) tile
		# of the maze, to centre the maze on the full canvas.
		# top-left corner border of maze is drawn at (-1,-1),
		# so ignore borders but include margins in mazePlaneSize.
		mazePlaneSize = @size(false, true)
		xoff = Math.floor((@dims.canvas[0] - mazePlaneSize[0]) / 2)
		yoff = Math.floor((@dims.canvas[1] - mazePlaneSize[1]) / 2)
		return [xoff + @dims.margin, yoff + @dims.margin]
		
	at: (drawX, drawY) =>
		# calculate which tile was clicked given click coordinates
		# relative to the full canvas.
		offs = @offsets() # tile (0,0) offsets on full canvas
		tileX = Math.floor((drawX - offs[0]) / @dims.tile)
		tileY = Math.floor((drawY - offs[1]) / @dims.tile)
		return [tileX, tileY]
