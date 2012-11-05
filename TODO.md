TO DO
=====

next
----

* restructure theme as class (to have constructor with maze param)
* add basic theme support for play mode
* support Apple meta keys up to 3
* rewrite in CoffeeScript for fun learing :D

see http://burakkanber.com/blog/physics-in-javascript-rigid-bodies-part-1-pendulum-clock/
for tips on accomplishing animation.

window.requestAnimFrame = (function(){
  return window.requestAnimationFrame  ||
    window.webkitRequestAnimationFrame ||
    window.mozRequestAnimationFrame    ||
    window.oRequestAnimationFrame      ||
    window.msRequestAnimationFrame     ||
    function( callback ){
      window.setTimeout(callback, 1000 / 60);
    };
})();


front-end features
------------------

### menus
  * load themes into "Maze" -> "Theme"
  * load examples into "Maze" -> "Load" -> "Examples"
  * load mazes from localStorage into "Maze" -> "Load" -> "Saved"
  * load "Decode" function
  * save functions (save in slots, using names, or using date+time?)
  * save "Encode" function
  * "Print" function
  * "Solve" function
  * "Analyze" function to display statistics from [analysis](#analyze)
  * "Help" drop-down
    * "How to Edit" dialog
    * "How to Play" dialog
    * "About" dialog with a link to project on github

### reposition entrance/exit
  * drag-and-drop would be ideal

### resize capability
  * extend/crop any edge
  * decide maximum width/height

### init from URL query
  * init with specified theme
  * init with specified example maze
  * init with encoded maze
  * init to play mode, optional "How to Play" dialog

### basic theme
  * draw a simple matte
  * improve blocks to seem raised
  * entrance/exit on border should show direction into or out from maze
  * draw [solve](#solve) results
  * play mode, draw avatar, simple slide animation

### Pokémon GS theme
  * scroll through alternative sprites via modulo `maze.special`
  * ladder sprites available as exit only on ground tiles
  * if exit is on an ice tile, display the exit on an adjacent block
  * walking/sliding avatar as in the game


back-end features
-----------------

### <a id="solve"></a>solve
  * extract directed graph from maze provided by client
  * detect solutions, shortest solution, dead-ends, and traps
  * return results to client

### <a id="analyze"></a>analyze
  * number of **linear solutions** (paths without redundant loops)
  * analyze the shortest solution as follows...
  * number of forks along the path
  * number of forks that lead to **dead-ends** (escapable in reverse)
  * number of forks onto **traps** (inescapable; must restart to solve)
  * indirection of paths to dead-ends and traps (too short is obvious)
  * return results to client

### randomize
  * do not randomize entry/exit positions (must manually reposition)
  * respect tile locks
  * optimize according to user-defined criteria
  * generate a pool of random mazes, choose the best, and return to client
    within the 30-second deadline for HTTP requests on
    [Google App Engine](https://developers.google.com/appengine/)

### optimize criteria
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

* touch swipes to navigate during play mode

* isometric theme (possibly some _FF Tactics Advance_ sprites)

scraps
------

```
isPassable: function(at) {
  if (!this.isMutable(at)) return false;
  return this.is(at, {blocked: false})
    || this.is(at, {entry: true})
    || this.is(at, {exit: true});
},
```

```
// only go one step on ground
if (this.is(from, {ground: true})) break;
```
