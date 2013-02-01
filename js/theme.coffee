# IceMaze (c) 2012-2013 by Matt Cudmore

# globals
themes = {}
registerTheme = (id, title, theme) ->
	themes[id] = [title, theme]

class Theme

	# each theme may define @images, @sprites, and @tiles
	# (images will be preloaded by the default constructor)
	images:  {} # imgID: "filename"
	sprites: {} # spriteID: [imgID, x, y, w, h]
	tiles:   {} # tileID: [animation mode, array of spriteID values]

	# each theme may access @canvasSize
	canvasSize: [0, 0]

	# each theme should record active animations in @anims
	anims: {}
	animsCount: 0

	constructor: ->
		# preload images
		for imgID, imgFile of @images
			@images[imgID] = img = new Image()
			img.src = imgFile
		return

	prep: (attrs) =>
		@stop()
		@set attrs

	set: (attrs) =>
		@c2d = attrs.c2d if attrs.c2d?
		@raf = attrs.raf if attrs.raf?
		@caf = attrs.caf if attrs.caf?
		@maze = attrs.maze if attrs.maze?
		@mode = attrs.mode if attrs.mode?

	anim: (animID, cb, fn) =>
		# fn should return true for another frame
		# cb will be called when done
		@stop animID
		cb ?= -> # empty callback
		begun = null
		next = =>
			@anims[animID] = @raf (time) =>
				begun ?= time
				# pass fn a duration since anim begin
				if fn(time - begun) then next()
				else @stop animID; cb()
		@animsCount++
		next()

	busy: =>
		@animsCount > 0

	stop: (animIDs...) =>
		if animIDs.length > 0
			for animID in animIDs
				continue if not @anims[animID]
				@caf @anims[animID]
				delete @anims[animID]
				@animsCount--
		else # stop all animations
			for animID of @anims
				continue if not @anims[animID]
				@caf @anims[animID]
				delete @anims[animID]
				@animsCount--
		return

	resize: (min) =>
		[w1, h1] = min
		[w2, h2] = @size()
		max = (a, b) -> if a > b then a else b
		@canvasSize = [max(w1, w2), max(h1, h2)]

	##################################################
	# each theme must implement these methods:

	#size: () =>
		# return the minimum canvas [width, height] needed to draw the maze.

	#at: (x, y) =>
		# return the tile position at the given [x, y] pixel coordinates.

	#redraw: (positions...) =>
		# redraw the tiles at the given positions,
		# or redraw the entire maze if no positions are given.

	#movePlayer: (position, direction, path, callback) =>
		# draw an avatar at position, facing direction;
		# or animate moving in direction along path.
		# use @anim(id,fnNextFrame) to request an animation frame.
		# call callback when animation completes.

	##################################################
	# drawing utility methods:

	drawSprite: (spriteID) =>
		# @c2d.translate to dest location before calling drawSprite
		spirte = @sprites[spriteID]
		@c2d.drawImage @images[sprite[0]],
			spirte[1], sprite[2], sprite[3], sprite[4],
			0, 0, sprite[3], sprite[4]

	fill: (sty) =>
		@c2d.fillStyle = sty
		@c2d.fill()

	stroke: (wid, sty) =>
		@c2d.strokeStyle = sty
		@c2d.lineWidth = wid
		@c2d.stroke()

	traceSquare: (x, y, w, h) =>
		@c2d.beginPath()
		@c2d.moveTo(x, y)
		@c2d.lineTo(x + w, y)
		@c2d.lineTo(x + w, y + h)
		@c2d.lineTo(x, y + h)
		@c2d.lineTo(x, y)
		@c2d.closePath()

	traceRounded: (x, y, w, h, r) =>
		# thanks http://stackoverflow.com/a/3368118
		@c2d.beginPath()
		@c2d.moveTo(x + r, y);
		@c2d.lineTo(x + w - r, y);
		@c2d.quadraticCurveTo(x + w, y, x + w, y + r);
		@c2d.lineTo(x + w, y + h - r);
		@c2d.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
		@c2d.lineTo(x + r, y + h);
		@c2d.quadraticCurveTo(x, y + h, x, y + h - r);
		@c2d.lineTo(x, y + r);
		@c2d.quadraticCurveTo(x, y, x + r, y);
		@c2d.closePath()

	traceCircle: (x, y, r) =>
		@c2d.beginPath()
		@c2d.arc x, y, r, 0, Math.PI * 2, false
		@c2d.closePath()
