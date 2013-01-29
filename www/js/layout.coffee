
refit = () ->
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

	# redraw maze after possible canvas resize
	redraw()
