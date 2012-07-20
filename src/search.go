package icemaze

import "bytes"
import "fmt"
import "strings"

/* ************************************************** */

type CDStep struct {
	Coords
	Dir
}

func (cds *CDStep) String() string {
	return strings.Join([]string{cds.Coords.String(), cds.Dir.String()}, "")
}

type CDPath []CDStep

func (cdp *CDPath) String() string {
	buffer := bytes.NewBufferString("")
	for i := 0; i < len(*cdp); i++ {
		if i > 0 {
			fmt.Fprint(buffer, "; ")
		}
		fmt.Fprint(buffer, (*cdp)[i].String())
	}
	return string(buffer.Bytes())
}

func (cd1 *CDPath) IsDP(cd2 *CDPath) bool {
	len1, len2 := len(*cd1), len(*cd2)
	if len1 != len2 {
		return false
	}
	for i := 0; i < len1; i++ {
		if (*cd1)[i].Dir != (*cd2)[i].Dir {
			return false
		}
	}
	return true
}

func (cd *CDPath) HasC(c Coords) bool {
	n := len(*cd)
	for i := 0; i < n; i++ {
		if (*cd)[i].Coords.Is(c) {
			return true
		}
	}
	return false
}

/* ************************************************** */

type CoordsGraphNode struct {
	Coords
	Dirs map[Dir]*CoordsGraphNode
	Flag map[int]bool
}

func (nRoot *CoordsGraphNode) ClearFlags(f int) {
	all := make([]*CoordsGraphNode, 0)
	var clearF func(n *CoordsGraphNode)
	clearF = func(n *CoordsGraphNode) {
		// Already cleared?
		for _, v := range all {
			if n == v {
				return
			}
		}
		n.Flag[f] = false, false
		all = append(all, n)
		for _, v := range n.Dirs {
			clearF(v)
		}
	}
	clearF(nRoot)
}

func (m *Maze) GetCoordsGraph(cOrig, cDest Coords) (*CoordsGraphNode, int, bool) {

	accessPts := 0
	solnFound := false

	// Make temp grid with a margin
	//  (in case origin or destination on perimeter)
	mTempGrid := make([][]*CoordsGraphNode, m.Width+2)
	for x := 0; x < m.Width+2; x++ {
		mTempGrid[x] = make([]*CoordsGraphNode, m.Height+2)
	}

	var buildCoordsGraph func(c Coords) *CoordsGraphNode
	var buildDir func(n *CoordsGraphNode, d Dir)

	buildDir = func(n *CoordsGraphNode, d Dir) {

		if m.isDirAccessible(n.Coords, d) {
			c := n.Coords.Copy()
			m.slideCoords(c, d)
			n.Dirs[d] = buildCoordsGraph(*c)
		}

	}

	buildCoordsGraph = func(c Coords) *CoordsGraphNode {

		if mTempGrid[c.X+1][c.Y+1] == nil {

			accessPts++

			n := new(CoordsGraphNode)
			n.Coords = c
			n.Dirs = make(map[Dir]*CoordsGraphNode)
			n.Flag = make(map[int]bool)
			mTempGrid[c.X+1][c.Y+1] = n

			if c.Is(cDest) {

				solnFound = true

			} else {

				buildDir(n, DirNorth)
				buildDir(n, DirEast)
				buildDir(n, DirSouth)
				buildDir(n, DirWest)

			}

		}

		return mTempGrid[c.X+1][c.Y+1]

	}

	return buildCoordsGraph(cOrig), accessPts, solnFound

}

/* ************************************************** */
/* ********** SEARCH and ASSESSMENT METHODS ********* */
/* ************************************************** */

func (m *Maze) HasSolution() (exitFound bool) {
	m.Clear(TileGrey)
	m.checkForExit(m.Entry, &exitFound)
	return
}

/* ************************* */

func (m *Maze) checkForExit(c Coords, e *bool) {

	m.checkForthForExit(c, DirNorth, e)
	m.checkForthForExit(c, DirEast, e)
	m.checkForthForExit(c, DirSouth, e)
	m.checkForthForExit(c, DirWest, e)

}

func (m *Maze) checkForthForExit(c Coords, d Dir, e *bool) {

	// TODO use concurrency?

	if *e {
		// No more searching to do!
		return
	}

	m.slideCoords(&c, d)

	if c.Is(m.Entry) {
		// Back to beginning
		return
	}

	if c.Is(m.Exit) {
		// Exit found!
		*e = true
		return
	}

	if m.isCoordsInside(c) {

		// Tile may instead be on perimeter, as entrance or exit

		if m.Grid[c.X][c.Y].Has(TileGrey) {
			// Already searched from this tile
			// So don't do so again
			return
		}

		m.Grid[c.X][c.Y].Set(TileGrey)

		m.checkForExit(c, e)

	}

}

/* ************************************************** */

func (m *Maze) ReColour(cOrig, cDest Coords) {

	// Red for steps in traps (no way to exit)
	// Yellow for steps in dead ends
	//  (the only way out is to go back opposite from arrival at step)
	// Green for steps in solution
	// Blue for all accessible tiles

	graph, _, _ := m.GetCoordsGraph(cOrig, cDest)

	m.Clear(TileColoured)

	// First, colour graph blue and green (all blue, no green deadends)
	// Check all nodes for traps (blue but not green)
	// Check all nodes for dead-ends (whatever's left)

	var colourBlue func(n *CoordsGraphNode, dFrom Dir)
	var soln func(n *CoordsGraphNode, dFrom Dir) bool
	var colourRed func(n *CoordsGraphNode)
	var trap func(n *CoordsGraphNode) (bool, bool)
	var colourYellow func(n *CoordsGraphNode)

	colourBlue = func(n *CoordsGraphNode, dFrom Dir) {
		// Clear all colours before initial call
		// All accessible nodes are coloured blue

		t := m.tileP(n.Coords)

		if t.Is(TileBlue) {
			// Already flagged
			return
		}

		t.Set(TileBlue)

		n.ClearFlags(0)
		soln(n, dFrom)

		for dTo, v := range n.Dirs {
			colourBlue(v, dTo)
		}

	}

	soln = func(n *CoordsGraphNode, dFrom Dir) bool {
		// Clear 0 Flags before initial call
		// It's a soln if there's access to the exit

		t := m.tileP(n.Coords)

		if t.Is(TileGreen) {
			// Already searched and found soln
			return true
		} else if n.Flag[0] {
			// Already searched
			return false
		}

		// Set searched
		n.Flag[0] = true

		if n.Coords.Is(cDest) {
			// Set soln
			t.Set(TileGreen)
			return true
		}

		dOpposite := dFrom.Opposite()
		for dTo, v := range n.Dirs {
			if (!dTo.Is(dOpposite)) && soln(v, dTo) {
				// Set soln
				t.Set(TileGreen)
				return true
			}
		}

		// No soln
		return false

	}

	colourRed = func(n *CoordsGraphNode) {
		// Clear 1 flags before initial call

		if n.Flag[1] {
			// Already searched [and found trap]
			return
		}

		n.Flag[1] = true

		n.ClearFlags(0)
		trap(n)

		for _, v := range n.Dirs {
			colourRed(v)
		}

	}

	trap = func(n *CoordsGraphNode) (bool, bool) {
		// Clear 0 Flags before initial call
		// It's a trap if there's no access to exit

		t := m.tileP(n.Coords)

		if t.Is(TileRed) {
			// Already searched and found trap
			return true, false
		} else if t.Is(TileGreen) || n.Coords.Is(cDest) {
			// Already found soln
			return false, true
		} else if n.Flag[0] {
			// Already searched
			return false, false
		}

		// Set searched
		n.Flag[0] = true

		for _, v := range n.Dirs {
			_, s := trap(v)
			if s {
				// Found some way out
				return false, true
			}
		}

		// No exit found
		t.Set(TileRed)
		return true, false

	}

	colourYellow = func(n *CoordsGraphNode) {
		// Clear 2 flags before initial call

		if n.Flag[2] {
			// Already searched
			return
		}

		n.Flag[2] = true

		t := m.tileP(n.Coords)
		if t.Good(TileBlue, TileGreen|TileRed) {
			t.Set(TileYellow)
		}

		for _, v := range n.Dirs {
			colourYellow(v)
		}

	}

	// Mark all accessible points and solutions
	colourBlue(graph, DirNone)

	// Mark all traps
	colourRed(graph)

	// Mark all dead-ends
	colourYellow(graph)

}

/*func (m *Maze) ReColour(cOrig, cDest Coords) {

	// Red for steps in traps (no way to exit)
	// Yellow for steps in dead ends (the only way out is to go back opposite from arrival at step)
	// Green for steps in solution
	// Blue for all accessible tiles

	m.Clear(TileColoured)

	graph, _, _ := m.GetCoordsGraph(cOrig, cDest)

	var trap func(n *CoordsGraphNode) (bool, bool)
	var soln func(n *CoordsGraphNode) bool
	var colourForth func(n *CoordsGraphNode)

	trapruns, solnruns, cfruns := 0, 0, 0

	trap = func(n *CoordsGraphNode) (bool, bool) {
		// It's a trap if there's no access to the exit

		t := m.tileP(n.Coords)

		if t.Has(TileColoured) {
			return t.Is(TileRed), t.Is(TileGreen)
		} else if n.Coords.Is(cDest) {
			return false, true
		}

		trapruns++

		t.Set(TileGrey) // Been here

		for _, v := range n.Dirs {
			_, s := trap(v)
			if s {
				// Found some way out
				return false, true
			}
		}

		// No exit found
		t.Set(TileRed)
		return true, false

	}

	soln = func(n *CoordsGraphNode) bool {
		// It's a soln if there's access to the exit

		t := m.tileP(n.Coords)

		if t.Is(TileGreen) { // Already searched and found
			return true
		} else if t.Has(TileGrey | TileRed) { // Already searched
			return false
		}

		solnruns++

		if n.Coords.Is(cDest) {
			t.Set(TileGreen) // Set soln
			return true
		}

		t.Set(TileGrey) // Set searched

		if len(n.Dirs) == 1 {
			t.Set(TileYellow) // Set deadend; not considered a trap
			return false
		}

		for _, v := range n.Dirs {
			if soln(v) {
				t.Set(TileGreen) // Set soln
				return true
			}
		}

		// No soln
		return false

	}

	colourForth = func(n *CoordsGraphNode) {

		if m.tileP(n.Coords).Is(TileBlue) {
			// Reds already flagged traps,
			// Greens already flagged solns,
			// Blues already flagged accessed
			return
		}

		cfruns++

		m.Clear(TileGrey) // Clear flags
		trap(n)
		m.Clear(TileGrey) // Clear flags
		soln(n)

		m.tileP(n.Coords).Set(TileBlue) // Been here

		for _, v := range n.Dirs {
			colourForth(v)
		}

	}

	colourForth(graph)

	fmt.Println("DEBUG: trapruns", trapruns, "solnruns", solnruns, "cfruns", cfruns)

}*/

/* ************************************************** */

func (m *Maze) GetShortestSolution() *CDPath {

	return m.GetShortestPathBFS(m.Entry, m.Exit)

}

func (m *Maze) GetShortestPathBFS(cOrig, cDest Coords) (success *CDPath) {

	m.Clear(TileColoured)

	queue := make([]Coords, 1)
	paths := make([]CDPath, 1)

	queue[0] = cOrig
	paths[0] = make(CDPath, 0)

	m.tileP(cOrig).Set(TileGrey)

	pushStep := func(cAt Coords, dTo, dFrom Dir, pFrom CDPath) {

		// Valid direction?
		if success != nil ||
			dTo.Is(dFrom) || !m.isDirAccessible(cAt, dTo) {
			// Don't search this way
			return
		}

		// Add dir to path
		pNext := make(CDPath, len(pFrom)+1)
		copy(pNext, pFrom)
		pNext[len(pFrom)] = CDStep{cAt, dTo}

		// Get next coords
		m.slideCoords(&cAt, dTo)

		// Check for end-of-search point
		if cAt.Is(cDest) {
			success = &pNext
			return
		}

		// Marked already?
		if m.tileP(cAt).Is(TileGrey) {
			// Don't search; already been this way
			return
		}

		// Mark
		m.tileP(cAt).Set(TileGrey)

		// Append to queue
		queue = append(queue, cAt)
		paths = append(paths, pNext)

	}

	for success == nil && len(queue) > 0 {

		// Pop first
		step := queue[0]
		path := paths[0]
		queue = queue[1:]
		paths = paths[1:]

		prevDir := DirNone
		if len(path) > 0 {
			prevDir = path[len(path)-1].Dir
		}

		pushStep(step, DirNorth, prevDir, path)
		pushStep(step, DirEast, prevDir, path)
		pushStep(step, DirSouth, prevDir, path)
		pushStep(step, DirWest, prevDir, path)

	}

	return

}

/* ************************************************** */

// Returns a list of all non-redundant paths from Origin to Destination.
// Returns (list_nrpaths, index_shortest, index_longest).
func (m *Maze) GetAllNRPaths(cOrig, cDest Coords) ([]CDPath, int, int) {

	nrpaths := make([]CDPath, 0, 100)

	success := func(p CDPath) {
		nrpaths = append(nrpaths, p)
	}

	extendCD := func(c Coords, d Dir, p CDPath) CDPath {
		p2 := make(CDPath, len(p)+1)
		copy(p2, p)
		p2[len(p)] = CDStep{c, d}
		return p2
	}

	var branch func(c Coords, d, x Dir, p CDPath)

	branchFrom := func(c Coords, x Dir, p CDPath) {
		branch(c, DirNorth, x, p)
		branch(c, DirEast, x, p)
		branch(c, DirSouth, x, p)
		branch(c, DirWest, x, p)
	}

	branch = func(c Coords, d, x Dir, p CDPath) {

		// Valid direction?
		if d.Is(x) || !m.isDirAccessible(c, d) {
			return
		}

		// Add step to path
		p = extendCD(c, d, p)

		// Get next coords
		m.slideCoords(&c, d)

		// Check for end-of-search point
		if c.Is(cDest) {
			success(p)
			return
		}

		// Marked already?
		if p.HasC(c) {
			// Redundant
			// Don't search; already been this way
			return
		}

		// Branch onward
		branchFrom(c, d, p)

	}

	// Begin searching out from origin
	branchFrom(cOrig, DirNone, make(CDPath, 0))

	// Find shortest, longest paths
	var shorti, shortlen, longi, longlen int
	var short1, long1 bool
	for i := 0; i < len(nrpaths); i++ {
		ilen := len(nrpaths[i])
		if !short1 || ilen < shortlen {
			shorti, shortlen, short1 = i, ilen, true
		}
		if !long1 || ilen > longlen {
			longi, longlen, long1 = i, ilen, true
		}
	}

	return nrpaths, shorti, longi

}
