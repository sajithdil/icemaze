/* IceMaze Generator
 * by Matthew Cudmore 2011
 *
 * Inspired by puzzles along the Ice Path in Pokémon Gold/Silver:
 * http://bulbapedia.bulbagarden.net/wiki/Ice_Path
 */

/*
	Compile: 6g -o ice.6 tile.go coords.go dir.go icemaze.go main.go
	Link: 6l -o icemaze ice.6
	Run: ./icemaze
*/

package icemaze

import "flag"
import "fmt"
import "rand"

var task string

// Any task
var mazeX int
var mazeY int
var mazeBlocks int

// Rand tasks
var rSeed int64 = rand.Int63()
var rGen *rand.Rand

// Longest or Best (optimization) task
var poolSize int
var lenSoln int
var maxSolns int

func init() {

	flag.StringVar(&task, "do", "rand", "Task for the script to do")

	flag.IntVar(&mazeX, "w", 10, "Width of maze")
	flag.IntVar(&mazeY, "h", 10, "Height of maze")
	flag.IntVar(&mazeBlocks, "b", 10, "Blocks to put in maze")

	flag.Int64Var(&rSeed, "seed", rSeed, "Seed for randomizer")

	flag.IntVar(&poolSize, "pool", 100, "Size of pool for optimization selections")
	flag.IntVar(&lenSoln, "slen", -1, "Specific solution length to choose in Best task")
	flag.IntVar(&maxSolns, "maxs", -1, "Specific maximum number non-redundant solutions in Best task")

}

func main() {

	flag.Parse()

	rGen = rand.New(rand.NewSource(rSeed))

	fmt.Println("Ice Maze Generator v1")

	fmt.Printf("Size:    %d by %d\n", mazeX, mazeY)
	fmt.Printf("Blocks:  %d\n", mazeBlocks)
	fmt.Printf("Seed:    %X\n", rSeed)

	switch task {

	case "rand", "Rand":

		m := NewMazeRandomBlocks(mazeX, mazeY, mazeBlocks, rGen)
		soln := m.GetShortestSolution()

		fmt.Println("Random maze:")
		fmt.Println(m.String())
		fmt.Println("Shortest solution length:", len(*soln))
		fmt.Println("Shortest solution:", soln.String())

	case "long", "Long", "longest", "Longest":

		var m *Maze
		var soln *CDPath

		longestSoln := 0

		for i := 0; i < poolSize; i++ {

			m2 := NewMazeRandomBlocks(mazeX, mazeY, mazeBlocks, rGen)
			soln2 := m2.GetShortestSolution()

			if len(*soln2) > longestSoln {
				m = m2
				soln = soln2
				longestSoln = len(*soln)
			}

		}

		paths, _, _ := m.GetAllNRPaths(m.Entry, m.Exit)
		lenPaths := len(paths)

		fmt.Println("Longest maze:")
		fmt.Println(m.String())
		fmt.Println("Non-redundant solutions:", lenPaths)
		fmt.Println("Shortest solution length:", len(*soln))
		fmt.Println("Shortest solution:", soln.String())

	case "best", "Best":

		var m *Maze
		var soln *CDPath
		var sols int

		var bestSoln float32

		for i := 0; i < poolSize; i++ {

			m2 := NewMazeRandomBlocks(mazeX, mazeY, mazeBlocks, rGen)

			if lenSoln > 0 {
				// Require specific length
				lenShort := len(*(m2.GetShortestPathBFS(m2.Entry, m2.Exit)))
				if lenShort != lenSoln {
					// Skip this maze
					continue
				}
			}

			paths, iShort, _ := m2.GetAllNRPaths(m2.Entry, m2.Exit)

			lenPaths := len(paths)
			lenShort := len(paths[iShort])

			if maxSolns > 0 {
				// Require limit to number of n-r possible solutions
				if lenPaths > maxSolns {
					// Skip this maze
					continue
				}
			}

			borderBlocks := m2.CountBorder(TileBlocked)

			score := float32(lenShort) / (float32(lenPaths) + float32(borderBlocks))

			if score > bestSoln {
				bestSoln, m, soln, sols = score, m2, &(paths[iShort]), lenPaths
			}

		}

		if m != nil {

			fmt.Println("Optimal maze:")
			fmt.Println(m.String())
			fmt.Println("Score:", bestSoln)
			fmt.Println("Non-redundant solutions:", sols)
			fmt.Println("Shortest solution length:", len(*soln))
			fmt.Println("Shortest solution:", soln.String())

		} else {

			fmt.Println("No such maze found in pool")

		}

	case "server", "Server", "web", "Web":

		fmt.Println("Starting server...")
		RunServer()

	default:
		flag.PrintDefaults()

	}

}
