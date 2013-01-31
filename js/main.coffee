# IceMaze (c) 2012-2013 by Matt Cudmore

# globals
game = null
theme = null
themes = {}

loadMaze = (maze) ->
	theme?.stop()
	game.set maze: maze
	theme?.set maze: maze
	refitUI()

registerTheme = (name, theme) ->
	themes[name] = theme

loadTheme = (name) ->
	unless themes[name]?
		alert "Theme #{name} is undefined"
		return
	# unload previous theme
	theme?.stop()
	# load new theme
	theme = themes[name]
	# configure theme
	$canvas = $("#maze")[0]
	theme.prep
		c2d: $canvas.getContext("2d")
		raf: (fn)-> window.requestAnimationFrame(fn, $canvas)
		caf: (id)-> window.cancelAnimationFrame(id)
		maze: game.maze, mode: game.mode
	refitUI()

setMode = (mode) ->
	return if game.mode is mode #already
	alert "Begin #{mode} mode"
	setUIMode mode
	game.set mode: mode
	theme?.set mode: mode

getURLParams = ->
	# thanks http://stackoverflow.com/a/2880929/1597274
	pl     = /\+/g # for replacing addition symbol with a space
	search = /([^&=]+)=?([^&]*)/g
	decode = (s)-> decodeURIComponent(s.replace(pl, " "))
	query  = window.location.search.substring(1)
	params = {}
	while match = search.exec query
		params[decode match[1]] = decode match[2]
	return params

$ ->
	# JavaScript enabled; show the menu
	$("#menu").show()

	game = new Game
	registerTheme "Basic",     new ThemeBasic
	registerTheme "PokémonGS", new ThemePkmnGS

	args = getURLParams()

	if args.maze? then loadDecode args.maze
	else if args.eg? then loadExample args.eg
	else loadMaze new Maze(10, 10)

	args.theme ?= "Basic"
	loadTheme args.theme

	args.mode ?= "edit"
	setMode args.mode

	# load dynamic menus
	loadThemesMenu args.theme
	loadExamplesMenu()
	#loadStorage()
	#loadStorageMenus()

	# add static menu handlers
	$("#editMode").on "click", ()-> setMode "edit"
	$("#playMode").on "click", ()-> setMode "play"
	$("#playRestart").on "click", ()-> game.reset()

	# add maze handlers
	$("#maze").on "click", (ev)-> game.click ev, $("#maze")
	$(document).on "keydown", (ev)-> game.keydown ev

	# refit() handles layout
	$(window).on "resize", refitUI
	$(window).trigger "resize"
