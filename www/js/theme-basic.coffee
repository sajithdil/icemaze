# IceMaze (c) 2012-2013 by Matt Cudmore
# ThemeBasic to simply draw the maze with no image dependencies

class ThemeBasic extends Theme

	dims:
		tile:   40 # px for tile width and height
		padd:    5 # px internal tile padding
		margin: 20 # px margin around maze

	size: () =>
		# returns the minimum canvas size required for drawing.
		# include borders and margins in calculation by default,
		# for both borders and margins are included in drawing.
		m = @dims.margin * 2
		mazeW = @maze?.width or 0
		mazeH = @maze?.height or 0
		drawW = mazeW * @dims.tile
		drawH = mazeH * @dims.tile
		return [drawW + m, drawH + m]

	offsets: () =>
		# returns drawing offsets to the top-left (0,0) tile
		# of the maze, to centre the maze on the full canvas.
		# top-left corner border of maze is drawn at (-1,-1),
		# so ignore borders but include margins in mazePlaneSize.
		mazePlaneSize = @size()
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
		return unless @maze? and @c2d? and @dims.canvas?
		@c2d.clearRect 0, 0, @dims.canvas[0], @dims.canvas[1]
		@offs = @offsets()
		for x in [0 .. @maze.width - 1]
			for y in [0 .. @maze.height - 1]
				@drawTile([x, y])
		return

	drawTile: (at) =>
		tile = @maze.get at
		t = @dims.tile
		p0 = @dims.padd
		p1 = t - (p0 * 2)

		@c2d.save()
		@c2d.translate @offs[0] + (at[0] * t), @offs[1] + (at[1] * t)

		# background
		if tile.locked
			@c2d.fillStyle = "yellow"
			@c2d.fillRect 0, 0, t, t

		# draw grid
		@c2d.strokeStyle = "lightgray"
		@c2d.lineWidth = 1
		@c2d.strokeRect 0, 0, t, t

		# ground -- square
		@c2d.fillStyle = if tile.ground then "tan" else "lightblue"
		@c2d.fillRect p0, p0, p1, p1

		# objects -- rounded square
		if tile.blocked
			@c2d.fillStyle = "gray"
			@drawRRect @c2d, p0, p0, p1, p1, p1/3

		# entry/exit -- circle
		if tile.entry or tile.exit
			@c2d.fillStyle = if tile.entry then "green" else "orange"
			@c2d.beginPath()
			@c2d.arc t/2, t/2, p1/2, 0, Math.PI * 2, false
			@c2d.fill()
			@c2d.closePath()

		# walls
		if tile.border
			@c2d.strokeStyle = "darkgray"
			@c2d.beginPath()
			@c2d.lineWidth = 3
			@c2d.lineCap = "round"
			if tile.edges.left
				@c2d.moveTo 0, 0; @c2d.lineTo 0, t
			if tile.edges.right
				@c2d.moveTo t, 0; @c2d.lineTo t, t
			if tile.edges.top
				@c2d.moveTo 0, 0; @c2d.lineTo t, 0
			if tile.edges.bottom
				@c2d.moveTo 0, t; @c2d.lineTo t, t
			@c2d.stroke()
			@c2d.closePath()

		@c2d.restore()

	drawRRect: (ctx, x, y, w, h, radius) ->
		# thanks http://stackoverflow.com/a/3368118
		ctx.beginPath()
		ctx.moveTo(x + radius, y)
		ctx.lineTo(x + w - radius, y)
		ctx.quadraticCurveTo(x + w, y, x + w, y + radius)
		ctx.lineTo(x + w, y + h - radius)
		ctx.quadraticCurveTo(x + w, y + h, x + w - radius, y + h)
		ctx.lineTo(x + radius, y + h)
		ctx.quadraticCurveTo(x, y + h, x, y + h - radius)
		ctx.lineTo(x, y + radius)
		ctx.quadraticCurveTo(x, y, x + radius, y)
		ctx.closePath()
		ctx.fill()

	drawPlayerAt: (at) =>
		return unless @maze? and @c2d?
		# TODO

	drawPlayerMove: () =>
		return unless @maze? and @c2d?
		# TODO
