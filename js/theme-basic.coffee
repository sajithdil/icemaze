# IceMaze (c) 2012-2013 by Matt Cudmore
# ThemeBasic to simply draw the maze with no image dependencies

class ThemeBasic extends ThemeTopdown

	constructor: ->
		super tileSize: 30, marginSize: 15

	bgColour:       "white"
	bgLockColour:   "yellow"

	editTileSize:   .9
	playTileSize:   1
	iceColour:      "lightblue"
	dirtColour:     "tan"
	rockTileSize:   .75
	rockRadiusSize: .1
	rockColour:     "gray"

	eeCircleSize:   .65
	entryColour:    "rgb(0,200,100)"
	exitColour:     "rgb(255,100,0)"
	eeInnerSize:    .4
	eeInnerColour:  "white"

	avCircleSize:   .5
	avCircleColour: "black"
	avInnerSize:    .4
	avInnerColour:  "red"
	animOneStepMS:  50

	drawTile: (tile) =>
		return if not tile.inside
		# clear
		@traceSquareTile 1
		@fill if tile.locked then @bgLockColour else @bgColour

		# floor -- square
		@traceSquareTile if @mode is "edit" then @editTileSize else @playTileSize
		@fill if tile.walkable then @dirtColour else @iceColour

		# objects -- rounded square
		if tile.obstacle
			@traceRoundedTile @rockTileSize, @rockRadiusSize
			@fill @rockColour

		# entry/exit -- circle
		if tile.entry or tile.exit
			@traceCircleTile @eeCircleSize
			@fill if tile.entry then @entryColour else @exitColour
			@traceCircleTile @eeInnerSize
			@fill @eeInnerColour

	drawSolns: (solutions) =>
		# TODO

	drawMove: (from, dir, path, callback) =>
		offs = @offs()
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
			posPrev = @maze.getNext from, dir, nowStep - 1
			posCurr = @maze.getNext from, dir, nowStep
			posNext = @maze.getNext from, dir, nowStep + 1
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

# include this theme in production
registerTheme "basic", "Basic theme", new ThemeBasic
