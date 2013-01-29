# IceMaze (c) 2013 by Matt Cudmore

examples =
	"id": ""

loadExample = (id) ->
	if not examples[id]
		alert "Example #{id} is undefined"
		return

	alert "Example: #{id}"
	loadDecode examples[id]
