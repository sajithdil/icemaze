# IceMaze (c) 2012-2013 by Matt Cudmore
# ThemePkmnGS to draw the maze using the original Pokémon Gold/Silver tileset

class ThemePkmnGS extends ThemeTopdown

	constructor: ->
		super tileSize: 16, marginSize: 32, onReady: resumeGame, onError: alert

#registerTheme "gs", "Pokémon Gold/Silver theme", new ThemePkmnGS
