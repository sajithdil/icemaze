# IceMaze (c) 2012-2013 by Matt Cudmore
# ThemeBasic to simply draw the maze with no image dependencies

class ThemeBasic extends Theme

	tileSize:       40 # px for tile width and height
	marginSize:     20 # px margin around maze

	bgColour:       "white"
	bgLockColour:   "yellow"
	gridLineColour: "lightgray"
	gridLineSize:   1

	floorTileSize:  .9
	iceColour:      "lightblue"
	dirtColour:     "tan"
	rockTileSize:   .75
	rockRadiusSize: .1
	rockColour:     "gray"

	eeCircleSize:   .65
	entryColour:    "green"
	exitColour:     "orange"
	eeInnerSize:    .4
	eeInnerColour:  "white"

	avCircleSize:   .5
	avCircleColour: "black"
	avInnerSize:    .4
	avInnerColour:  "red"
	animOneStepMS:  50

	size: =>
		# returns the minimum canvas size required for drawing.
		m = @marginSize * 2
		mazeW = @maze?.width or 0
		mazeH = @maze?.height or 0
		drawW = mazeW * @tileSize
		drawH = mazeH * @tileSize
		return [drawW + m, drawH + m]

	offsets: =>
		# returns drawing offsets [x, y] for centring the maze on the canvas.
		mazeSize = @size()
		xoff = Math.floor((@canvasSize[0] - mazeSize[0]) / 2)
		yoff = Math.floor((@canvasSize[1] - mazeSize[1]) / 2)
		return [xoff + @marginSize, yoff + @marginSize]

	at: (canvasX, canvasY) =>
		# returns the tile position at the canvas coordinates.
		offs = @offsets() # tile (0,0) offsets on full canvas
		tileX = Math.floor((canvasX - offs[0]) / @tileSize)
		tileY = Math.floor((canvasY - offs[1]) / @tileSize)
		return [tileX, tileY]

	redraw: (positions...) => if @maze?
		@c2d.save()
		@c2d.translate @offsets()...
		if positions.length > 0
			@drawTile at for at in positions
		else # redraw matte and maze
			@drawMatte()
			[w, h] = [@maze.width - 1, @maze.height - 1]
			@drawTile [x, y] for x in [0..w] for y in [0..h]
		@c2d.restore()

	##################################################
	# tile drawing:

	drawMatte: =>
		wh = @size()
		@traceSquare -@marginSize, -@marginSize, wh[0], wh[1]
		@fill "black"

	drawTile: (at) =>
		tile = @maze.get at
		return if not tile.inside

		@c2d.save()
		@c2d.translate at[0] * @tileSize, at[1] * @tileSize

		# clear
		@traceSquareTile 1
		@fill if tile.locked then @bgLockColour else @bgColour
		# draw grid
		@stroke @gridLineSize, @gridLineColour

		# floor -- square
		@traceSquareTile @floorTileSize
		@fill if tile.ground then @dirtColour else @iceColour

		# objects -- rounded square
		if tile.blocked
			@traceRoundedTile @rockTileSize, @rockRadiusSize
			@fill @rockColour

		# entry/exit -- circle
		if tile.entry or tile.exit
			@traceCircleTile @eeCircleSize
			@fill if tile.entry then @entryColour else @exitColour
			@traceCircleTile @eeInnerSize
			@fill @eeInnerColour

		@c2d.restore()

	traceSquareTile: (psize) =>
		wh = @tileSize * psize
		xy = (@tileSize - wh) / 2
		@traceSquare xy, xy, wh, wh

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
	# player drawing:

	movePlayer: (from, dir, path, callback) =>
		offs = @offsets()
		pixy = [from[0] * @tileSize, from[1] * @tileSize]
		path ?= [from]

		endStep = path.length - 1
		endTime = endStep * @animOneStepMS
		endDist = endStep * @tileSize

		@anim callback, (nowTime) =>
			if nowTime > endTime then nowTime = endTime
			nowFrac = (nowTime / endTime) or 0
			nowStep = Math.floor (nowFrac * endStep)
			nowDist = nowFrac * endDist

			# redraw adjacent tiles
			posPrev = @maze.getNextPosition from, dir, nowStep - 1
			posCurr = @maze.getNextPosition from, dir, nowStep
			posNext = @maze.getNextPosition from, dir, nowStep + 1
			@redraw posPrev, posCurr, posNext

			# draw avatar
			@c2d.save()
			@c2d.translate offs[0], offs[1]
			@c2d.translate pixy[0], pixy[1]
			switch dir
				when "left" then  @c2d.translate -nowDist, 0
				when "right" then @c2d.translate nowDist, 0
				when "up" then    @c2d.translate 0, -nowDist
				when "down" then  @c2d.translate 0, nowDist
			@traceCircleTile @avCircleSize
			@fill @avCircleColour
			@traceCircleTile @avInnerSize
			@fill @avInnerColour
			@c2d.restore()

			# request another frame?
			return nowTime < endTime

registerTheme "basic", "Basic theme", new ThemeBasic
