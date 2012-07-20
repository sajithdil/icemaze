package icemaze

import "strings"
import "strconv"

/* ************************************************** */
/* ********** COORDS TYPE                  ********** */
/* ************************************************** */

type Coords struct {
	X, Y int
}

func CoordsNil() Coords {
	return Coords{-1, -1}
}

func (c *Coords) String() string {
	return strings.Join([]string{"(", strconv.Itoa(c.X), ",", strconv.Itoa(c.Y), ")"}, "")
}

/* ************************* */

func (c1 *Coords) Is(c2 Coords) bool {
	return c1.X == c2.X && c1.Y == c2.Y
}

func (c *Coords) Copy() *Coords {
	return &Coords{c.X, c.Y}
}

/* ************************* */

func (c *Coords) Step(d Dir) *Coords {
	switch d {
	case DirNorth:
		c.Y++
	case DirEast:
		c.X++
	case DirSouth:
		c.Y--
	case DirWest:
		c.X--
	}
	return c
}

// Return step of copy
func (c *Coords) StepC(d Dir) *Coords {
	return c.Copy().Step(d)
}
