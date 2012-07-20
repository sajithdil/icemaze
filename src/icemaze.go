/* IceMaze Generator
 * by Matthew Cudmore 2011
 *
 * Inspired by puzzles along the Ice Path in Pokémon Gold/Silver:
 * http://bulbapedia.bulbagarden.net/wiki/Ice_Path
 */

package icemaze

import "bytes"
import "fmt"
import "rand"

/* ************************************************** */
/* ********** MAZE TYPE                    ********** */
/* ************************************************** */

/*	|Y|_|_|_|_|
 *	|_|_|_|_|_|
 *	|O|_|_|_|X|
 *
 *	O marks the origin (0, 0) of this 5x3 maze.
 */

type Maze struct {
	Width, Height int
	Entry, Exit   Coords
	Grid          [][]Tile
}

func NewMaze(wid, hei int) *Maze {
	m := Maze{Width: wid, Height: hei}

	m.Grid = make([][]Tile, wid)
	for i := range m.Grid {
		m.Grid[i] = make([]Tile, hei)
	}

	return &m
}

// Returns a possible maze
func NewMazeRandomBlocks(wid, hei, blocks int, r *rand.Rand) *Maze {
	m := NewMaze(wid, hei)
	m.RandEE(r)
	m.AddRandBlocks(blocks, r)
	for !m.HasSolution() {
		m.Clear(TileBlocked)
		m.AddRandBlocks(blocks, r)
	}
	return m
}

/* ************************* */

// Return pointer to actual tile in maze
func (m *Maze) tileP(c Coords) *Tile {
	if m.validCoords(c) {
		return &m.Grid[c.X][c.Y]
	}
	return new(Tile)
}

// Return pointer to copy of tile from maze
func (m *Maze) tileC(c Coords) *Tile {
	if m.validCoords(c) {
		var p Tile = m.Grid[c.X][c.Y]
		return &p
	}
	return new(Tile)
}

/* ************************* */

func (m *Maze) Clear(t Tile) {
	for x := 0; x < m.Width; x++ {
		for y := 0; y < m.Height; y++ {
			m.Grid[x][y].Un(t)
		}
	}
}

func (m *Maze) ClearTiles() {
	for x := 0; x < m.Width; x++ {
		for y := 0; y < m.Height; y++ {
			m.Grid[x][y] = TileBlank
		}
	}
}

/* ************************* */

/* ************************* */
/* ***** OUTPUT METHODS **** */
/* ************************* */

func (m *Maze) String() string {

	buffer := bytes.NewBufferString("")

	// Print northern border
	fmt.Fprint(buffer, "  ")
	for x := 0; x < m.Width; x++ {
		if m.Entry.Y == m.Height && m.Entry.X == x {
			// Print entry on northern perimeter
			fmt.Fprint(buffer, "_1")
		} else if m.Exit.Y == m.Height && m.Exit.X == x {
			// Print exit on northern perimeter
			fmt.Fprint(buffer, "_2")
		} else {
			// Print northern border
			fmt.Fprint(buffer, " _")
		}
	}
	fmt.Fprintln(buffer)

	// Print grid
	for y := m.Height - 1; y >= 0; y-- {

		// Print western border
		if m.Entry.X == -1 && m.Entry.Y == y {
			// Print entry on western border
			fmt.Fprint(buffer, "1>")
		} else if m.Exit.X == -1 && m.Exit.Y == y {
			// Print exit on western perimeter
			fmt.Fprint(buffer, "<2")
		} else {
			// Print western border
			fmt.Fprint(buffer, "  ")
		}

		// Print row
		for x := 0; x < m.Width; x++ {
			if m.Entry.X == x && m.Entry.Y == y {
				// Print internal entry
				fmt.Fprint(buffer, "|1")
			} else if m.Exit.X == x && m.Exit.Y == y {
				// Print internal exit
				fmt.Fprint(buffer, "|2")
			} else if m.Grid[x][y].Has(TileRed) {
				fmt.Fprint(buffer, "|R")
			} else if m.Grid[x][y].Has(TileYellow) {
				fmt.Fprint(buffer, "|Y")
			} else if m.Grid[x][y].Has(TileGreen) {
				fmt.Fprint(buffer, "|G")
			} else if m.Grid[x][y].Has(TileBlue) {
				fmt.Fprint(buffer, "|B")
			} else if m.Grid[x][y].Has(TileBlocked) {
				// Print blocked tile
				fmt.Fprint(buffer, "|#")
			} else {
				// Print unblocked tile
				fmt.Fprint(buffer, "|_")
			}
		}

		// Print eastern border
		if m.Entry.X == m.Width && m.Entry.Y == y {
			// Print entry on eastern border
			fmt.Fprintln(buffer, "|<1")
		} else if m.Exit.X == m.Width && m.Exit.Y == y {
			// Print exit on eastern perimeter
			fmt.Fprintln(buffer, "|>2")
		} else {
			// Print eastern border
			fmt.Fprintln(buffer, "|")
		}
	}

	// Print southern border
	fmt.Fprint(buffer, "  ")
	for x := 0; x < m.Width; x++ {
		if m.Entry.Y == -1 && m.Entry.X == x {
			// Print entry on southern perimeter
			fmt.Fprint(buffer, " 1")
		} else if m.Exit.Y == -1 && m.Exit.X == x {
			// Print exit on southern perimeter
			fmt.Fprint(buffer, " 2")
		} else {
			// Print southerm border
			fmt.Fprint(buffer, "  ")
		}
	}
	fmt.Fprintln(buffer)

	return string(buffer.Bytes())

}

/* ************************************************** */
/* ********** INTERNAL UTILITIES           ********** */
/* ************************************************** */

// Returns whether the given coordinates are in the maze's grid
func (m *Maze) validCoords(c Coords) bool {
	return !(c.X < 0 || c.X >= m.Width ||
		c.Y < 0 || c.Y >= m.Height)
}

func (m *Maze) goodCoords(c Coords, good, bad Tile) bool {
	return m.validCoords(c) &&
		m.Grid[c.X][c.Y].Good(good, bad)
}

func (m *Maze) blockableCoords(c Coords) bool {
	return m.goodCoords(c, TileAny, TileBlocked|TileUnblockable)
}

func (m *Maze) validDir(c Coords, dir Dir) bool {
	c.Step(dir)
	return m.validCoords(c)
}

func (m *Maze) goodDir(c Coords, dir Dir, good, bad Tile) bool {
	c.Step(dir)
	return m.goodCoords(c, good, bad)
}

func (m *Maze) isDirAccessible(c Coords, dir Dir) bool {
	// Allow entrance or exit on periphery as accessible dir

	// But not if they're adjacent on periphery
	periph, side := m.isCoordsPerim(c)
	if periph && dir != side.Opposite() {
		// Can move only into maze from periphery
		return false
	}

	c.Step(dir)
	return c.Is(m.Entry) || c.Is(m.Exit) ||
		m.goodCoords(c, TileAny, TileBlocked)
}

func (m *Maze) slideCoords(c *Coords, dir Dir) {
	for m.isDirAccessible(*c, dir) {
		c.Step(dir)
	}
}

func (m *Maze) isCoordsInside(c Coords) bool {
	return !(c.X < 0 || c.X >= m.Width ||
		c.Y < 0 || c.Y >= m.Height)
}

// Returns whether the coordinates border the maze, and on which side
func (m *Maze) isCoordsPerim(c Coords) (bool, Dir) {
	// Check West East South North
	if c.Y >= 0 && c.Y < m.Height {
		if c.X == -1 {
			return true, DirWest
		} else if c.X == m.Width {
			return true, DirEast
		}
	} else if c.X >= 0 && c.X < m.Width {
		if c.Y == -1 {
			return true, DirSouth
		} else if c.Y == m.Height {
			return true, DirNorth
		}
	}
	return false, DirNone
}

func (m *Maze) getNearestCoordsInside(c Coords) Coords {
	if c.X < 0 {
		c.X = 0
	} else if c.X >= m.Width {
		c.X = m.Width - 1
	}
	if c.Y < 0 {
		c.Y = 0
	} else if c.Y >= m.Height {
		c.Y = m.Height - 1
	}
	return c
}

func (m *Maze) getNextGoodCoords(c Coords, good, bad Tile) (Coords, bool) {

	if !m.isCoordsInside(c) {
		c.X, c.Y = 0, 0
	}

	if m.goodCoords(c, good, bad) {
		return c, true
	}

	for area := m.Width * m.Height; area > 0; area-- {

		if m.goodCoords(c, good, bad) {
			return c, true
		}

		c.X++

		if c.X >= m.Width {
			c.X = 0
			c.Y++
		}

		if c.Y >= m.Height {
			c.Y = 0
		}

	}

	//fmt.Println("DEBUG: Found no good coords")
	return Coords{-1, -1}, false

}

// Return random coordinates within the grid, being good, having no bad
func (m *Maze) getRandGoodCoords(good, bad Tile, r *rand.Rand) (Coords, bool) {
	x, y := r.Intn(m.Width), r.Intn(m.Height)
	return m.getNextGoodCoords(Coords{x, y}, good, bad)
}

// Return random coordinates around the perimeter of the maze
func (m *Maze) getRandPerimCoords(r *rand.Rand) (c Coords, d Dir) {
	d = NewDir(r.Intn(4))
	switch d {
	case DirNorth:
		c = Coords{r.Intn(m.Width), m.Height}
	case DirEast:
		c = Coords{m.Width, r.Intn(m.Height)}
	case DirSouth:
		c = Coords{r.Intn(m.Width), -1}
	case DirWest:
		c = Coords{-1, r.Intn(m.Height)}
	}
	return
}

/* ************************************************** */
/* ********** SIMPLE COUNT METHODS         ********** */
/* ************************************************** */

func (m *Maze) countGoodTiles(good, bad Tile) (total int) {
	for x := 0; x < m.Width; x++ {
		for y := 0; y < m.Height; y++ {
			if m.goodCoords(Coords{x, y}, good, bad) {
				total++
			}
		}
	}
	return
}

func (m *Maze) Count(t Tile) (total int) {
	for x := 0; x < m.Width; x++ {
		for y := 0; y < m.Height; y++ {
			if m.Grid[x][y].Is(t) {
				total++
			}
		}
	}
	return
}

func (m *Maze) CountBorder(t Tile) (total int) {
	for x := 0; x < m.Width; x++ {
		if m.Grid[x][0].Is(t) {
			total++
		}
		if m.Grid[x][m.Height-1].Is(t) {
			total++
		}
	}
	for y := 0; y < m.Height; y++ {
		if m.Grid[0][y].Is(t) {
			total++
		}
		if m.Grid[m.Height-1][y].Is(t) {
			total++
		}
	}
	return
}

/* ************************************************** */
/* ********** ENTRY and EXIT METHODS       ********** */
/* ************************************************** */

func (m *Maze) SetEntry(c Coords) (cOI, bOI, bNI Coords) {

	if oldEntry, _ := m.isCoordsPerim(c); oldEntry {
		cOI, bOI = m.Entry, m.getNearestCoordsInside(m.Entry)
		m.tileP(bOI).Un(TileUnblockable)
	} else {
		cOI, bOI = CoordsNil(), CoordsNil()
	}

	m.Entry, bNI = c, m.getNearestCoordsInside(c)
	m.tileP(bNI).Un(TileBlocked).Set(TileUnblockable)

	return
}

func (m *Maze) SetExit(c Coords) (cOX, bOX, bNX Coords) {

	if oldExit, _ := m.isCoordsPerim(c); oldExit {
		cOX, bOX = m.Exit, m.getNearestCoordsInside(m.Exit)
		m.tileP(bOX).Un(TileUnblockable)
	} else {
		cOX, bOX = CoordsNil(), CoordsNil()
	}

	m.Exit, bNX = c, m.getNearestCoordsInside(c)
	m.tileP(bNX).Un(TileBlocked).Set(TileUnblockable)

	return
}

// Set random entry and exit points around the perimeter of the maze
// Return old and new entry coords and borders, old and new exit coords and borders
func (m *Maze) RandEE(r *rand.Rand) (cOI, bOI, cNI, bNI, cOX, bOX, cNX, bNX Coords) {

	cNI, _ = m.getRandPerimCoords(r)
	cNX, _ = m.getRandPerimCoords(r)

	for cNI.Is(cNX) {
		// Resolve collision
		cNX, _ = m.getRandPerimCoords(r)
	}

	cOI, bOI, bNI = m.SetEntry(cNI)
	cOX, bOX, bNX = m.SetExit(cNX)

	return
}

/* ************************************************** */
/* ********** ADDING and REMOVING BLOCKS   ********** */
/* ************************************************** */

func (m *Maze) AddBlock(x, y int) {
	p := Coords{x, y}
	if m.blockableCoords(p) {
		m.tileP(p).Set(TileBlocked)
	}
}

func (m *Maze) ToggleBlock(x, y int) {
	p := Coords{x, y}
	if m.goodCoords(p, TileAny, TileUnblockable) {
		m.tileP(p).Toggle(TileBlocked)
	}
}

func (m *Maze) AddRandBlocks(num int, r *rand.Rand) {
	good, bad := TileAny, TileBlocked|TileUnblockable
	for c, any := m.getRandGoodCoords(good, bad, r); any && num > 0; num-- {
		m.tileP(c).Set(TileBlocked)
		c, any = m.getRandGoodCoords(good, bad, r)
	}
}

func (m *Maze) ToggleRandBlocks(num int, r *rand.Rand) {
	good, bad := TileAny, TileUnblockable
	for c, any := m.getRandGoodCoords(good, bad, r); any && num > 0; num-- {
		m.tileP(c).Toggle(TileBlocked)
		c, any = m.getRandGoodCoords(good, bad, r)
	}
}

func (m *Maze) RemoveRandBlocks(num int, r *rand.Rand) {
	good, bad := TileAny, TileUnblockable
	for c, any := m.getRandGoodCoords(good, bad, r); any && num > 0; num-- {
		m.tileP(c).Un(TileBlocked)
		c, any = m.getRandGoodCoords(good, bad, r)
	}
}
