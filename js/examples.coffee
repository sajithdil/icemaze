# IceMaze (c) 2013 by Matt Cudmore

examples = {
	"id": ["Name", "Encoded"]
}

loadExample = (id) ->
	if eg = examples[id] then alert "Example: #{eg[0]}"
	else return alert "Example[#{id}] is undefined"
	loadMaze decodeMaze eg[1]
