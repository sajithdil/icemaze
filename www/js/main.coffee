# IceMaze (c) 2012-2013 by Matt Cudmore

getURLParams = () ->
	# thanks http://stackoverflow.com/a/2880929/1597274
	pl     = /\+/g # for replacing addition symbol with a space
	search = /([^&=]+)=?([^&]*)/g
	decode = (s) -> decodeURIComponent(s.replace(pl, " "))
	query  = window.location.search.substring(1)
	params = {}
	while match = search.exec query
		params[decode match[1]] = decode match[2]
	return params

$ ->
	# JavaScript enabled; show the menu
	$("#menu").show()

	regTheme "Basic",     new ThemeBasic
	regTheme "PokémonGS", new ThemePkmnGS

	args = getURLParams()

	if args.maze?    then loadDecode args.maze
	else if args.eg? then loadExample args.eg
	else                  loadMaze new Maze(10, 10)

	if args.mode?    then setMode args.mode
	else                  setMode "edit" # default

	if args.theme?   then loadTheme args.theme
	else                  loadTheme "Basic" # default

	# load dynamic menus
	loadThemesMenu()
	loadExamplesMenu()
	#loadStorage()
	#loadStorageMenus()

	# add static menu handlers
	$("#editMode").on "click", -> setMode "edit"
	$("#playMode").on "click", -> setMode "play"
	$("#restart").on "click", replay

	# add maze handlers
	$("#maze").on "click", click
	$(document).on "keydown", arrow

	# refit() handles layout
	$(window).on "resize", refit
	$(window).trigger "resize"
