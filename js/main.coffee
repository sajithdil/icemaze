# IceMaze (c) 2012-2013 by Matt Cudmore

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
	$menu.show()

	args = getURLParams()

	# load specified maze
	if args.maze? then setMaze decodeMaze args.maze
	else if args.eg? then loadExample args.eg
	# fallback to new maze
	if not currMaze then setMaze new Maze(10, 10)

	# load specified theme
	if args.theme? then setTheme args.theme
	# fallback to basic theme
	if not currTheme then setTheme args.theme = "basic"

	# set specified mode
	if args.mode is "play" then setMode "play"
	# default to edit mode
	else setMode "edit"

	# load dynamic menus
	loadThemesMenu themes, args.theme
	loadExamplesMenu examples
	#loadStorage()
	#loadStorageMenus()

	# add static menu handlers
	$editMode.on "click", ()-> setMode "edit"
	$playMode.on "click", ()-> setMode "play"
	$playRestart.on "click", ()-> resetGame()

	$newMaze.on "click", ()->
		w = parseInt($newMazeWidth.val())
		h = parseInt($newMazeHeight.val())
		setMode "edit"
		setMaze new Maze(w, h)
		$newMazeModal.modal "hide"

	$loadDecode.on "click", ()->
		$loadDecodeInput.val ""
		$loadDecodeModal.modal "show"
		$loadDecodeInput.focus()

	$loadDecodeSubmit.on "click", ()->
		setMaze decodeMaze $loadDecodeInput.val()
		$loadDecodeModal.modal "hide"

	$saveEncode.on "click", ()->
		$saveEncodeOutput.val encodeMaze currMaze
		$saveEncodeModal.modal "show"
		$saveEncodeOutput.focus()

	# add maze handlers
	$maze.on "click", handleClick
	$maze.on "mousewheel", handleScroll
	$(document).on "keydown", handleKeydown

	# refitUI() handles layout
	$(window).on "resize", ()->
		refitUI()
		resumeGame()

	# ensure initial layout
	$(window).trigger "resize"
