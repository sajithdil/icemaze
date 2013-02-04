# IceMaze (c) 2012-2013 by Matt Cudmore

# global jQuery elements
$win              = $(window)
$menu             = $("#menu")
$wrap             = $("#wrap")
$maze             = $("#maze")
$info             = $("#info")

$newMaze          = $("#newMaze")
$newMazeWidth     = $("#newMazeWidth")
$newMazeHeight    = $("#newMazeHeight")
$newMazeModal     = $("#newMazeModal")

# LOAD MENU
$examplesList     = $("ul", "#examplesMenu")
$loadSavedList    = $("ul", "#loadSavedMenu")
$loadDecode       = $("#loadDecode")
$loadDecodeInput  = $("#ioTextarea")
$loadDecodeModal  = $("#ioModal")
$loadDecodeSubmit = $("#ioDecode")

# SAVE MENU
$saveAs           = $("#saveAs")
$saveOverList     = $("ul", "#saveOverMenu")
$saveEncode       = $("#saveEncode")
$saveEncodeOutput = $("#ioTextarea")
$saveEncodeModal  = $("#ioModal")

$themesList       = $("ul", "#themesMenu")
$print            = $("#print")

$editMode         = $("#editMode, #yayGoEdit")
$editMenu         = $("#editMenu")
$editShowSolns    = $("#editShowSolns")
$editClearLocks   = $("#editClearLocks")
$editClearSprites = $("#editClearSpecials")

$playMode         = $("#playMode, #yayGoPlay")
$playMenu         = $("#playMenu")
$playRestart      = $("#playRestart")

refitUI = () ->
	# get available space
	windowWidth = $win.width()
	windowHeight = $win.height()
	menuHeight = $menu.outerHeight(true)
	wrapWidth = windowWidth
	wrapHeight = windowHeight - menuHeight

	# position $wrap under $menu
	$wrap.css("margin-top", menuHeight)
	# resize $wrap to fill window
	$wrap.height(wrapHeight).width(wrapWidth)

	return unless currTheme
	# ask theme to calculate new canvas dimensions
	[mazeWidth, mazeHeight] = currTheme.resize([wrapWidth, wrapHeight])
	# resize $maze to meet the theme's expectations
	$maze.attr("width", mazeWidth).attr("height", mazeHeight)

	# position $maze in centre of $wrap
	overW = mazeWidth > wrapWidth
	overH = mazeHeight > wrapHeight
	$maze.css position: "relative",
		left: (if overW then 0 else Math.floor((wrapWidth - mazeWidth) / 2)) + "px",
		top:  (if overH then 0 else Math.floor((wrapHeight - mazeHeight) / 2)) + "px"

	# add scrollbars to $wrap if needed
	$wrap.css("overflow-x", if overW then "scroll" else "hidden")
	$wrap.css("overflow-y", if overH then "scroll" else "hidden")
	return

setUIMode = (mode) ->
	switch mode
		when "edit"
			$editMode.addClass("active")
			$editMenu.show()
			$playMode.removeClass("active")
			$playMenu.hide()
		when "play"
			$playMode.addClass("active")
			$playMenu.show()
			$editMode.removeClass("active")
			$editMenu.hide()
	return

loadThemesMenu = (themes, active) ->
	$themesList.empty()
	refocus = (i)->->
		$themesList.find("li.active").removeClass("active")
		$themesList.find("li[themeID='#{i}']").addClass("active")
		setTheme i
	for id, th of themes
		$("<li><a tabindex='-1' href='#'>#{th[0]}</a></li>")
		.attr("themeID", id)
		.addClass(if id == active then "active" else "")
		.appendTo($themesList)
		.on("click", refocus(id)) # closure on id
	return

loadExamplesMenu = (examples) ->
	$examplesList.empty()
	handler = (i)->->
		loadExample i
	for id, eg of examples
		$("<li><a tabindex='-1' href='#'>#{eg[0]}</a></li>")
		.attr("egID", id)
		.appendTo($examplesList)
		.on("click", handler(id)) # closure on id
	return

loadStorageMenus = () ->
	$loadSavedList.empty()
	$saveOverList.empty()
	some = false
	for id of mazes
		some = true
		$("<li><a tabindex='-1' href='#'>#{id}</a></li>")
		.appendTo($loadSavedList)
		.on("click", ((i)->-> loadMaze i)(id)) # closure on id
		.clone()
		.appendTo($saveOverList)
		.on("click", ((i)->-> saveOverwrite i)(id)) # closure on id
	if !some
		$("<li><a tabindex='-1' href='#'>None</a></li>")
		.addClass("disabled")
		.appendTo($loadSavedList)
		.clone()
		.appendTo($saveOverList)
	return

window.alert = (message, timeout = 2000) ->
	# raise message
	$m = $("<p/>").text(message).appendTo($info);
	fadeRemove = -> $m.fadeOut "slow", () -> $m.remove()
	$m.on "click", fadeRemove
	setTimeout fadeRemove, timeout
