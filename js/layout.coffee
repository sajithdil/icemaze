# IceMaze (c) 2012-2013 by Matt Cudmore

refitUI = () ->
	# get jQuery elements
	$win = $(window)
	$menu = $("#menu")
	$wrap = $("#wrap")
	$maze = $("#maze")

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

	return unless theme
	# ask theme to calculate new canvas dimensions
	[mazeWidth, mazeHeight] = theme.resize([wrapWidth, wrapHeight])
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

	# canvas may have been cleared on resize
	theme.redraw()
	return

setUIMode = (mode) ->
	switch mode
		when "edit"
			$("#editMode").addClass("active")
			$("#editMenu").show()
			$("#playMode").removeClass("active")
			$("#playMenu").hide()
		when "play"
			$("#playMode").addClass("active")
			$("#playMenu").show()
			$("#editMode").removeClass("active")
			$("#editMenu").hide()
	return

loadThemesMenu = (themes, active) ->
	$menu = $("ul", "#themes").empty()
	some = false
	refocus = (n)->->
		$menu.find("li.active").removeClass("active")
		$menu.find("li[themeID='#{n}']").addClass("active")
		loadTheme n
	for id, th of themes
		some = true
		$("<li><a tabindex='-1' href='#'>#{th[0]}</a></li>")
		.attr("themeID", id)
		.addClass(if id == active then "active" else "")
		.appendTo($menu)
		.on("click", refocus(id)) # closure on id
	if !some
		$("<li><a tabindex='-1' href='#'>None</a></li>")
		.addClass("disabled")
		.appendTo($menu)
	return

loadExamplesMenu = (examples) ->
	$menu = $("ul", "#loadExamples").empty()
	some = false
	for id, eg of examples
		some = true
		$("<li><a tabindex='-1' href='#'>#{eg[0]}</a></li>")
		.attr("egID", id)
		.appendTo($menu)
		.on("click", ((i)->-> loadExample i)(id)) # closure on id
	if !some
		$("<li><a tabindex='-1' href='#'>None</a></li>")
		.addClass("disabled")
		.appendTo($menu)
	return

loadStorageMenus = () ->
	$loadMenu = $("ul", "#loadSaved").empty()
	$saveMenu = $("ul", "#saveOverwrite").empty()
	some = false
	for id of mazes
		some = true
		$("<li><a tabindex='-1' href='#'>#{id}</a></li>")
		.appendTo($loadMenu)
		.on("click", ((i)->-> loadMaze i)(id)) # closure on id
		.clone()
		.appendTo($saveMenu)
		.on("click", ((i)->-> saveOverwrite i)(id)) # closure on id
	if !some
		$("<li><a tabindex='-1' href='#'>None</a></li>")
		.addClass("disabled")
		.appendTo($loadMenu)
		.clone()
		.appendTo($saveMenu)
	return

window.alert = (message, timeout = 2000) ->
	# raise message
	$m = $("<p/>").text(message).appendTo("#info");
	fadeRemove = -> $m.fadeOut "slow", () -> $m.remove()
	$m.on "click", fadeRemove
	setTimeout fadeRemove, timeout
