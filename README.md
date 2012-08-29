Intro
-----

I was a child enthralled by puzzles and Pokémon.
The [Ice Path](http://bulbapedia.bulbagarden.net/wiki/Ice_Path) of Pokémon
Gold and Silver presented a new type of puzzle, and a brief but exciting
challenge, which stuck with me. Recently I tried to create an "ice maze" of my
own, to share with a friend; I became frustrated with many failed attempts on
paper, and thence decided to write this program to generate and analyze
millions of ice mazes in search of greatness. Also this seemed a timely
opportunity to learn and practise programming in [Go](http://golang.org/).


How to play
-----------

An ice maze is drawn on a grid: Some tiles are filled-in (blocks), and some
are blank (ice). One tile is marked as entrance/start, and another as
exit/finish. On paper, the player shouldn't use a pen, but simply the tip of
one's finger. Beginning on the entrance tile, the player must slide one's
finger in a straight line across the ice until reaching a block, and stop on
the tile before the block. Now a new direction must be chosen, and the player
slides around the maze while seeking a path to the exit. The player may slide
_through_ the exit if there is no block in the way, but must stop at the exit
(by reaching a block) to solve the ice maze.

The primary differences from a traditional maze are that the walls are not
drawn in (thus possible paths are not apparent), disjunct paths may
crisscross, the player cannot reverse all movements, and the player may
encounter and slide across the exit without solving the puzzle.


An ideal maze
--------------

* Has a single solution, no short-cuts
* Has fall-off points, dead-ends, and hidden traps along the exit path
* May include a pot of gold impossible to reach
* Should be minimal, rather than an enormous exhausting labyrinth,
  so that players go in circles wondering "What am I missing?"
* Eludes me


Features
--------

* Web-based front-end
* Create, design, and resize mazes in the browser
* Play (direct an avatar using the arrow keys) to solve in the browser
* Print for offline play
* Back-end designed to run on
  [Google App Engine](https://developers.google.com/appengine/)
* Server can find all solutions, dead-ends, and traps, which are displayed in
  the browser
* Server can generate a random maze to meet user-defined criteria, or optimize
  a given maze without altering locked tiles
