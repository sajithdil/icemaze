# IceMaze (c) 2013 by Matt Cudmore

examples =
	"id": ""

loadExample = (id) ->
	unless examples[id]?
		alert "Example #{id} is undefined"
		return
	loadMaze decodeMaze examples[id]
	alert "Example: #{id}"
	return
