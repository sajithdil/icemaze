package icemaze

import "bytes"
import "fmt"

/* ************************************************** */
/* ********** DIR TYPE                     ********** */
/* ************************************************** */

type Dir byte

const (
	DirNorth Dir = 'N' // 0
	DirEast  Dir = 'E' // 1
	DirSouth Dir = 'S' // 2
	DirWest  Dir = 'W' // 3
	DirNone  Dir = '?'
)

func (d *Dir) String() string {
	switch *d {
	case DirNorth:
		return "North"
	case DirEast:
		return "East"
	case DirSouth:
		return "South"
	case DirWest:
		return "West"
	}
	// Error:
	return "NullDir"
}

/* ************************* */

func NewDir(n int) Dir {
	switch n {
	case 0:
		return DirNorth
	case 1:
		return DirEast
	case 2:
		return DirSouth
	case 3:
		return DirWest
	}
	return DirNone
}

func (d *Dir) Is(d2 Dir) bool {
	return *d == d2
}

/* ************************* */

func (d *Dir) Opposite() Dir {
	switch *d {
	case DirNorth:
		return DirSouth
	case DirEast:
		return DirWest
	case DirSouth:
		return DirNorth
	case DirWest:
		return DirEast
	case DirNone:
		return DirNone
	}
	// Error:
	return *d
}

/* ************************************************** */

// TODO get rid of this type (used in search.go)

type DirPath []Dir

func (dp *DirPath) String() string {
	buffer := bytes.NewBufferString("")
	for d := range *dp {
		if d > 0 {
			fmt.Fprint(buffer, ", ")
		}
		fmt.Fprint(buffer, (*dp)[d].String())
	}
	return string(buffer.Bytes())
}

func (dp1 *DirPath) Is(dp2 *DirPath) bool {
	len1, len2 := len(*dp1), len(*dp2)
	if len1 != len2 {
		return false
	}
	for i := 0; i < len1; i++ {
		if (*dp1)[i] != (*dp2)[i] {
			return false
		}
	}
	return true
}
