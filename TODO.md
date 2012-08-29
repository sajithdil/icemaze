TO DO
=====

front-end features
------------------

* menus
  * drop-down to choose theme
  * drop-down to load predefined example mazes
    (e.g. original Pokémon GS Ice Path)
  * "Print" function


* reposition entrance/exit
  * drag-and-drop would be ideal


* resize capability
  * extend/crop any edge
  * decide maximum width/height


* play capability
  * arrow keys to navigate from entry to exit
  * wait for theme to finish any animation


* display statistics from [analysis](#analyze)


* init from URL query
  * init with specified theme
  * init with specified example maze
  * init with encoded maze


* basic theme
  * draw a simple matte
  * improve blocks to seem raised
  * entrance/exit on border should show direction into or out from maze
  * draw [solve](#solve) results
  * play mode, draw avatar, simple slide animation


* Pokémon GS theme
  * scroll through alternative sprites via modulo `maze.special`
  * ladder sprites available as exit only on ground tiles
  * if exit is on an ice tile, display the exit on an adjacent block
  * walking/sliding avatar as in the game


back-end features
-----------------

* <a id="solve"></a>solve
  * extract directed graph from maze provided by client
  * detect solutions, shortest solution, dead-ends, and traps
  * return results to client


* <a id="analyze"></a>analyze
  * number of **linear solutions** (paths without redundant loops)
  * analyze the shortest solution as follows...
  * number of forks along the path
  * number of forks that lead to **dead-ends** (escapable in reverse)
  * number of forks onto **traps** (inescapable; must restart to solve)
  * indirection of paths to dead-ends and traps (too short is obvious)
  * return results to client


* randomize
  * do not randomize entry/exit positions (must manually reposition)
  * respect tile locks
  * optimize according to user-defined criteria
  * generate a pool of random mazes, choose the best, and return to client
    within the 30-second deadline for HTTP requests on
    [Google App Engine](https://developers.google.com/appengine/)


* optimize criteria
  * min and max number of linear solutions (no redundant loops);
    1 min, 1 max for a single solution; optimize toward min
  * min, max, and optimal number of:
    * steps in solutions
    * blocked and ground tiles
    * forks along solution paths
    * dead-ends
    * traps


special features
----------------

* in icemaze.js click switch case metac == 3
  and related code in theme-pkmngs.js etc.
  to scroll through alternative tiles

  `this.special = (this.special || 0) + 1;`

  and back-end operations must preserve the value

* keep "recent mazes" or "saved mazes" in local browser storage

* for basic theme, in case of drag-and-drop to reposition entrance/exit,
  animate the entrance/exit orientation when dragged to a new side

* for PkmnGS theme, animated matte during play

* isometric theme (possibly some _FF Tactics Advance_ tiles)
