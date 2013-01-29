# IceMaze (c) 2012-2013 by Matt Cudmore
# ThemeBasic to simply draw the maze with no image dependencies

class ThemeBasic extends Theme

	dims:
		tile:   40 # px for tile width and height
		pad:     2 # px internal tile padding
		margin: 10 # px margin around maze

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

	drawMaze: (maze) =>
		@maze = maze if maze?
		return unless @maze? and c2d?

	drawPlayerAt: (at) =>
		return unless @maze? and @c2d?
		# TODO

	drawPlayerMove: () =>
		return unless @maze? and @c2d?
		# TODO
