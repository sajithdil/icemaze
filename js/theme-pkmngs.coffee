# IceMaze (c) 2012-2013 by Matt Cudmore
# ThemePkmnGS to draw the maze using the original Pokémon Gold/Silver tileset

class ThemePkmnGS extends Theme

	dims:
		canvasMargin: [10, 10]
		tileSize: [16, 16]
		tileMargin: [0, 0]

	images:
		# imgID: "filename"
		1: "img/pkmngs.png"

	sprites:
		# spriteID: [imgID, x, y, wid, hei]
		1: [1, 0, 0]

	tiles:
		# tileID: [animation mode, array of spriteID values
		border:  ["click", 0]
		blocked: ["click", 0]
		ice:     ["click", 0]
		ground:  ["click", 0]

	drawMaze: (maze) ->
		@maze = maze if maze?
