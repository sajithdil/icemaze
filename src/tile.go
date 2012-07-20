package icemaze

/* ************************************************** */
/* ********** TILE TYPE                    ********** */
/* ************************************************** */

type Tile uint8

const (
	TileAny Tile = 0x1 << iota
	TileBlocked
	TileUnblockable
	TileGrey     // Searched
	TileBlue     // Accessible pivot/point
	TileYellow   // Path to DeadEnd
	TileRed      // Path to Trap
	TileGreen    // Path to Success (all steps, at pivots and between pivots)
	TileBlank    = 0x0
	TileAll      = 0xff
	TileColoured = TileGrey | TileRed | TileBlue | TileYellow | TileGreen
)

func NewTile(s string) Tile {
	switch s {
	case "TileAny":
		return TileAny
	case "TileBlocked":
		return TileBlocked
	case "TileUnblockable":
		return TileUnblockable
	case "TileGrey":
		return TileGrey
	case "TileBlue":
		return TileBlue
	case "TileYellow":
		return TileYellow
	case "TileRed":
		return TileRed
	case "TileGreen":
		return TileGreen
	case "TileBlank":
		return TileBlank
	case "TileAll":
		return TileAll
	case "TileColoured":
		return TileColoured
	}
	return TileBlank
}

/* ************************* */

// Returns whether the two tiles have any bit in common
func (t1 *Tile) Has(t2 Tile) bool {
	return *t1&t2 > TileAny
}

// Returns whether the first tile has all the bits of the second
func (t1 *Tile) Is(t2 Tile) bool {
	return (*t1&t2)|TileAny == (t2)|TileAny
}

// Returns whether the tile is good and has no bad
func (t *Tile) Good(good, bad Tile) bool {
	return t.Is(good) && !t.Has(bad)
}

/* ************************* */

// Set bit
func (t1 *Tile) Set(t2 Tile) *Tile {
	*t1 |= t2
	return t1
}

// Unset bit if applicable
func (t1 *Tile) Un(t2 Tile) *Tile {
	has := *t1 & t2
	if has > TileAny {
		// Only unset what the tile has
		*t1 ^= has
	}
	return t1
}

// Toggle bit
func (t1 *Tile) Toggle(t2 Tile) *Tile {
	*t1 ^= t2
	return t1
}
