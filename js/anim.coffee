# IceMaze (c) 2012-2013 by Matt Cudmore

##################################################
# requestAnimationFrame polyfill by Erik Möller
# fixes from Paul Irish and Tino Zijdel
# https://gist.github.com/1579671

do ->
	for v in ['ms', 'moz', 'webkit', 'o']
		window.requestAnimationFrame ?=
			window["#{v}RequestAnimationFrame"]
		window.cancelAnimationFrame ?=
			window["#{v}CancelAnimationFrame"] or
			window["#{v}CancelRequestAnimationFrame"]

	lastTime = 0
	window.requestAnimationFrame ?= (cb, el) ->
		currTime = (new Date).getTime()
		timeToCall = Math.max(0, 16 - (currTime - lastTime))
		lastTime = currTime + timeToCall
		window.setTimeout((-> cb(currTime + timeToCall)), timeToCall)

	window.cancelAnimationFrame ?= (an) ->
		window.clearTimeout(an)

##################################################
# animation factory function

startAnim = (fn, cb, el) ->
	# startAnim returns a controller for the animation.
	# call controls.stop() to end the animation and invoke cb.
	# call controls.cancel() to end without invoking cb.
	# fn receives the elapsed time since start, and the controller.
	# fn should perform drawing, and return true for another frame.
	initTime = null
	currAnim = null
	done = false
	controls = {
		busy: -> !done
		stop: -> if !done then @cancel(); if cb then cb()
		cancel: -> done = true; window.cancelAnimationFrame currAnim
	}
	next = -> currAnim = window.requestAnimationFrame step, el
	step = (currTime) -> if !done
		initTime ?= currTime
		if fn(currTime - initTime, controls) then next()
		else controls.stop()
	next()
	return controls
