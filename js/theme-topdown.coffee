# IceMaze (c) 2012-2013 by Matt Cudmore

class ThemeTopdown extends Theme

	##################################################
	# OVERRIDABLES

	images: {
		# imgID: "filename"
	}

	frames: {
		# frameID: [imgID, x, y, w, h]
	}

	sprites: {
		# spriteID: [frameRate, framesIDs]
		# where frameRate is:
		#   either "manual" for manual select during edit,
		#   or the number of frames (e.g. 1 or 2) per player step;
		# and frameIDs is a sequence of one or more:
		#   either a frameID for one layer,
		#   or [frameID...] for a stack of layers.
	}

	##################################################
	# PURE VIRTUAL METHODS
	# (themes must implement these methods.)

	#drawTile: (tile) =>
		# draw an interpretation of the properties of the given maze tile.
		# the base translation is set to the tile offset.
		# if tile.inside then it's a maze tile; else it's a matte tile.
	#drawSolns: (solutions) =>
		# see theme.coffee
	#drawMove: =>
		# see theme.coffee

	##################################################
	# FINAL METHODS

	constructor: ({@tileSize, @marginSize, onReady, onError}) ->
		super(onReady, onError)

	size: =>
		# returns the minimum canvas size required for drawing.
		m = @marginSize * 2
		mazeW = @maze?.width or 0
		mazeH = @maze?.height or 0
		drawW = mazeW * @tileSize
		drawH = mazeH * @tileSize
		return [drawW + m, drawH + m]

	offs: =>
		# returns drawing offsets [x, y] for centring the maze on the canvas.
		minDrawingSize = @size()
		xoff = Math.floor((@canvasSize[0] - minDrawingSize[0]) / 2)
		yoff = Math.floor((@canvasSize[1] - minDrawingSize[1]) / 2)
		return [xoff + @marginSize, yoff + @marginSize]

	at: (canvasX, canvasY) =>
		# returns the tile position at the canvas coordinates.
		offs = @offs() # tile (0,0) offsets on full canvas
		tileX = Math.floor((canvasX - offs[0]) / @tileSize)
		tileY = Math.floor((canvasY - offs[1]) / @tileSize)
		return [tileX, tileY]

	draw: (positions...) => @redraw positions...
	redraw: (positions...) => if @maze? and @themeOnAir
		offs = @offs()
		transDraw = (at) =>
			@c2d.save()
			@c2d.translate offs[0]+(at[0]*@tileSize), offs[1]+(at[1]*@tileSize)
			@clearTile()
			@drawTile @maze.get at
			@c2d.restore()
		if positions.length > 0
			# redraw at only the given positions
			transDraw at for at in positions
		else # redraw everything (matte and maze)
			@clearCanvas()
			origin = [-Math.ceil(offs[0] / @tileSize), -Math.ceil(offs[1] / @tileSize)]
			canvas = [Math.ceil(@canvasSize[0] / @tileSize), Math.ceil(@canvasSize[1] / @tileSize)]
			[w, h] = [canvas[0] + origin[0], canvas[1] + origin[1]]
			transDraw [x, y] for x in [origin[0]..w] for y in [origin[1]..h]
		return

	##################################################
	# TOPDOWN BASIC DRAWING UTILITY METHODS

	clearTile: =>
		@c2d.clearRect 0, 0, @tileSize, @tileSize

	traceSquareTile: (psize) =>
		wh = @tileSize * psize
		xy = (@tileSize - wh) / 2
		@traceRect xy, xy, wh, wh

	traceRoundedTile: (psize, prad) =>
		wh = @tileSize * psize
		xy = (@tileSize - wh) / 2
		radius = wh * prad
		@traceRounded xy, xy, wh, wh, radius

	traceCircleTile: (psize) =>
		wh = @tileSize * psize
		xy = @tileSize / 2
		@traceCircle xy, xy, wh / 2

	##################################################
	# TOPDOWN SPRITE DRAWING UTILITY METHODS

	drawSprite: (spriteID, frame = 0, time = 0) =>
		# frame: integer index into the sprite's frames
		# time:  fraction of time units to advance frame
		sprite = @sprites[spriteID]
		frames = sprite.length - 1
		# adjust the time by the sprite's frame rate
		time *= if $.isNumeric sprite[0] then sprite[0] else 1
		# advance the frame by the number of whole time units
		frame += Math.ceil time
		# the sprite entry specifies one or more frameID values
		frIDs = sprite[1 + (frame % (sprite.length - 1))]
		if $.isArray frIDs then @drawFrame frID for frID in frIDs
		else @drawFrame frIDs
		return

	drawFrame: (frameID) =>
		frame = @frames[frameID]
		@c2d.drawImage @images[frame[0]],
			frame[1], frame[2], frame[3], frame[4],
			0, 0, @tileSize, @tileSize
