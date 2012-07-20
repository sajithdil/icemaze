/* IceMaze Generator
 * by Matthew Cudmore 2011
 *
 * Inspired by puzzles along the Ice Path in Pokémon Gold/Silver:
 * http://bulbapedia.bulbagarden.net/wiki/Ice_Path
 */

package icemaze

import (
	"fmt"
	"http"
	"json"
	"os"
	"strconv"
)

/* ************************************************** */

func RunServer() os.Error {
	http.HandleFunc("/", serveIndex)
	http.HandleFunc("/NewMaze.json", serveNewMaze)
	http.HandleFunc("/RandEE.json", serveRandEE)
	http.HandleFunc("/RandB.json", serveRandB)
	http.HandleFunc("/Click.json", serveClick)
	http.HandleFunc("/Clear.json", serveClear)
	http.HandleFunc("/Colours.json", serveColours)
	http.HandleFunc("/Shortest.json", serveShortest)
	http.HandleFunc("/Echo.json", serveEchoMaze)
	return http.ListenAndServe(":8080", nil)
}

/* ************************************************** */

func serveIndex(w http.ResponseWriter, r *http.Request) {
	f := r.URL.Path[1:]
	if f == "index.css" {
		http.ServeFile(w, r, "index.css")
	} else if f == "index.js" {
		http.ServeFile(w, r, "index.js")
	} else {
		f = "index.html"
		http.ServeFile(w, r, "index.html")
	}
	fmt.Println("Served", f, "from", r.Host, "to", r.RemoteAddr)
}

/* ************************************************** */

func (m *Maze) ToJSON() string {
	j, err := json.Marshal(m)
	if err != nil {
		return ""
	}
	return string(j)
}

func JSON_to_Maze(j string) (*Maze, os.Error) {
	m := NewMaze(0, 0)
	err := json.Unmarshal([]byte(j), m)
	if err != nil {
		return nil, err
	}
	return m, err
}

/* ************************* */

type responseUpdateTile struct {
	Do string
	Coords
	Tile
}

type responseUpdateTiles []responseUpdateTile

func (ruts *responseUpdateTiles) UT(do string, c Coords, t Tile) {
	*ruts = append(*ruts, responseUpdateTile{do, c, t})
}

func (ruts *responseUpdateTiles) ToJSON() string {
	j, err := json.Marshal(ruts)
	if err != nil {
		return ""
	}
	return string(j)
}

/* ************************* */

func stringToInt(s string, d int) int {
	i, err := strconv.Atoi(s)
	if err != nil {
		return d
	}
	return i
}

/* ************************************************** */

func serveNewMaze(w http.ResponseWriter, r *http.Request) {
	wid, hei := stringToInt(r.FormValue("w"), 10), stringToInt(r.FormValue("h"), 10)
	blocks := stringToInt(r.FormValue("b"), 0)
	m := NewMaze(wid, hei)
	m.RandEE(rGen)
	m.AddRandBlocks(blocks, rGen)
	fmt.Fprint(w, m.ToJSON())
	fmt.Println("Served new", wid, "by", hei, "maze to", r.RemoteAddr)
}

func serveEchoMaze(w http.ResponseWriter, r *http.Request) {

	m, err := JSON_to_Maze(r.FormValue("m"))

	if err != nil {
		fmt.Fprint(w, "Invalid maze.")
		fmt.Println("Bad request from", r.RemoteAddr)
		return
	}

	fmt.Fprint(w, m.ToJSON())

	fmt.Println("Served echo to", r.RemoteAddr, "for maze:")
	fmt.Println(m.String())

}

func serveRandEE(w http.ResponseWriter, r *http.Request) {

	m, err := JSON_to_Maze(r.FormValue("m"))

	if err != nil {
		fmt.Fprint(w, "Invalid maze.")
		fmt.Println("Bad request from", r.RemoteAddr)
		return
	}

	/*
		_, bOI, cNI, bNI, _, bOX, cNX, bNX := m.RandEE(rGen)

		ruts := make(responseUpdateTiles, 0, 6)

		ruts.UT("Entry", cNI, *m.tileP(cNI))
		ruts.UT("Exit", cNX, *m.tileP(cNX))
		ruts.UT("Set", bOI, *m.tileP(bOI))
		ruts.UT("Set", bNI, *m.tileP(bNI))
		ruts.UT("Set", bOX, *m.tileP(bOX))
		ruts.UT("Set", bNX, *m.tileP(BNX))

		fmt.Fprint(w, ruts.ToJSON())
		fmt.Println("Served", len(ruts), "tile updates to", r.RemoteAddr)

	*/

	m.RandEE(rGen)

	fmt.Fprint(w, m.ToJSON())

	fmt.Println("Served random entry/exit to", r.RemoteAddr)

}

func serveRandB(w http.ResponseWriter, r *http.Request) {

	m, err := JSON_to_Maze(r.FormValue("m"))

	if err != nil {
		fmt.Fprint(w, "Invalid maze.")
		fmt.Println("Bad request from", r.RemoteAddr)
		return
	}

	b := stringToInt(r.FormValue("blocks"), -1)

	if b < 0 {
		b = m.Count(TileBlocked)
	}
	if b <= 0 {
		// Add one block, if none specified
		b = 1
	}

	m.Clear(TileBlocked)
	m.AddRandBlocks(b, rGen)

	fmt.Fprint(w, m.ToJSON())

	fmt.Println("Served", b, "random blocks to", r.RemoteAddr, "for maze:")
	fmt.Println(m.String())

}

func serveClick(w http.ResponseWriter, r *http.Request) {

	m, err := JSON_to_Maze(r.FormValue("m"))

	if err != nil {
		fmt.Fprint(w, "Invalid maze.")
		fmt.Println("Bad request from", r.RemoteAddr)
		return
	}

	button := r.FormValue("button")
	x, y := stringToInt(r.FormValue("x"), -1), stringToInt(r.FormValue("y"), -1)

	c := Coords{x, y}
	in_maze, t := m.isCoordsInside(c), m.tileP(c)
	on_periph, _ := m.isCoordsPerim(c)

	ruts := make(responseUpdateTiles, 0, 5)

	fmt.Println("Incoming", button, "click (", x, ",", y, ")")

	switch button {

	case "left":
		// Toggle block, or position Entry

		if in_maze {

			if t.Is(TileBlocked) {
				t.Un(TileBlocked)
				ruts.UT("Set", c, *t)
			} else if !t.Is(TileUnblockable) {
				t.Set(TileBlocked)
				ruts.UT("Set", c, *t)
			}

		} else if on_periph && !c.Is(m.Exit) {

			_, bOI, bNI := m.SetEntry(c)
			ruts.UT("Entry", m.Entry, *m.tileP(m.Entry))
			ruts.UT("Set", bOI, *m.tileP(bOI))
			ruts.UT("Set", bNI, *m.tileP(bNI))

		}

	case "right":
		// Toggle unblockable, or position Exit

		if in_maze {

			if t.Is(TileUnblockable) {
				t.Un(TileUnblockable)
			} else {
				if t.Is(TileBlocked) {
					t.Un(TileBlocked)
				}
				t.Set(TileUnblockable)
			}
			ruts.UT("Set", c, *t)

		} else if on_periph && !c.Is(m.Entry) {

			_, bOX, bNX := m.SetExit(c)
			ruts.UT("Exit", m.Exit, *m.tileP(m.Exit))
			ruts.UT("Set", bOX, *m.tileP(bOX))
			ruts.UT("Set", bNX, *m.tileP(bNX))

		}

	case "middle":
		// Toggle grey, or (alternative) position Exit

		if in_maze {

			if t.Is(TileGrey) {
				t.Un(TileGrey)
			} else {
				t.Set(TileGrey)
			}
			ruts.UT("Set", c, *t)

		} else if on_periph && !c.Is(m.Entry) {

			_, bOX, bNX := m.SetExit(c)
			ruts.UT("Exit", m.Exit, *m.tileP(m.Exit))
			ruts.UT("Set", bOX, *m.tileP(bOX))
			ruts.UT("Set", bNX, *m.tileP(bNX))

		}

	}

	fmt.Fprint(w, ruts.ToJSON())
	fmt.Println("Served", len(ruts), "tile updates to", r.RemoteAddr)

}

func serveClear(w http.ResponseWriter, r *http.Request) {

	m, err := JSON_to_Maze(r.FormValue("m"))

	if err != nil {
		fmt.Fprint(w, "Invalid maze.")
		fmt.Println("Bad request from", r.RemoteAddr)
		return
	}

	what := r.FormValue("clear")
	clear := NewTile(what)

	ruts := make(responseUpdateTiles, 0, 5)

	for x := 0; x < m.Width; x++ {
		for y := 0; y < m.Height; y++ {
			c := Coords{x, y}
			t := m.tileP(c)
			if t.Has(clear) {
				t.Un(clear)
				ruts.UT("Set", c, *t)
			}
		}
	}

	// Ensure entry/exit ports are still unblockable
	_, _, bNI := m.SetEntry(m.Entry)
	ruts.UT("Set", bNI, *m.tileP(bNI))
	_, _, bNX := m.SetExit(m.Exit)
	ruts.UT("Set", bNX, *m.tileP(bNX))

	fmt.Fprint(w, ruts.ToJSON())

	fmt.Println("Served", len(ruts), "tile updates to", r.RemoteAddr)

}

func serveShortest(w http.ResponseWriter, r *http.Request) {

	m, err := JSON_to_Maze(r.FormValue("m"))

	if err != nil {
		fmt.Fprint(w, "Invalid maze.")
		fmt.Println("Bad request from", r.RemoteAddr)
		return
	}

	success := m.GetShortestSolution()

	resp := []CDPath{}
	if success != nil {
		resp = []CDPath{*success}
	}

	resp2, _ := json.Marshal(resp)
	fmt.Fprint(w, string(resp2))

	fmt.Println("Served shortest path to", r.RemoteAddr)

}

func serveColours(w http.ResponseWriter, r *http.Request) {

	m, err := JSON_to_Maze(r.FormValue("m"))

	if err != nil {
		fmt.Fprint(w, "Invalid maze.")
		fmt.Println("Bad request from", r.RemoteAddr)
		return
	}

	m.ReColour(m.Entry, m.Exit)

	fmt.Fprint(w, m.ToJSON())

	fmt.Println("Served colours to", r.RemoteAddr, "for maze:")
	fmt.Println(m.String())

}

/*func serveNRSolns(w http.ResponseWriter, r *http.Request) {
	m, err := JSON_to_Maze(r.FormValue("m"))
	if err != nil {
		fmt.Fprint(w, "Invalid maze.")
		fmt.Println("Bad request from", r.RemoteAddr)
		return
	}
	paths, _, _ := m.GetAllNRPaths(m.Entry, m.Exit)
	resp, _ := json.Marshal(paths)
	fmt.Fprint(w, string(resp))
	fmt.Println("Served nr solutions to", r.RemoteAddr)
}*/
