package ;
import flixel.group.FlxGroup;
import flixel.FlxState;
import flixel.util.FlxPoint;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.util.FlxRect;
/**
 * ...
 * @author Potato Studios
 */
 class LevelModel extends FlxGroup
{
        /**
         * Map
         */
        public var state:FlxState; // state displaying the level
        public var levelSize:FlxPoint; // width and height of level (in pixels)
        public var tileSize:FlxPoint; // default width and height of each tile (in pixels)
        public var numTiles:FlxPoint; // how many tiles are in this level (width and height)
        public var floorGroup:FlxGroup; // floor (rendered beneath the walls - no collisions)
        public var wallGroup:FlxGroup; // all the map blocks (with collisions)
        public var guiGroup:FlxGroup; // gui elements
         
        /**
         * Player
         */
        public var player:Entity;
        public var playerStart:FlxPoint = new FlxPoint(120, 120);
         
        /**
         * Constructor
         * @param   state       State displaying the level
         * @param   levelSize   Width and height of level (in pixels)
         * @param   blockSize   Default width and height of each tile (in pixels)
         */
        public function new(state:FlxState, levelSize:FlxPoint, tileSize:FlxPoint):Void
		{
            super();
            this.state = state;
            this.levelSize = levelSize;
            this.tileSize = tileSize;
            this.numTiles = new FlxPoint(Math.floor(levelSize.x / tileSize.x), Math.floor(levelSize.y / tileSize.y));
            // setup groups
            this.floorGroup = new FlxGroup();
            this.wallGroup = new FlxGroup();
            this.guiGroup = new FlxGroup();
            // create the level
            this.create();
        }
         
        /**
         * Create the whole level, including all sprites, maps, blocks, etc
         */
        public function create():Void
		{
            createMap();
            createHumans();
            createGUI();
            addGroups();
            createCamera();
        }
         
        /**
         * Create the map (walls, decals, etc)
         */
        private function createMap():Void {
        }
         
        /**
         * Create the player, bullets, etc
         */
        private function createHumans():Void {
            player = new Human();
        }
         
        /**
         * Create text, buttons, indicators, etc
         */
        private function createGUI():Void {
        }
         
        /**
         * Decide the order of the groups. They are rendered in the order they're added, so last added is always on top.
         */
        private function addGroups():Void {
           // add(floorGroup);
           // add(wallGroup);
            //add(player);
            //add(guiGroup);
        }
         
        /**
         * Create the default camera for this level
         */
        private function createCamera():Void {

        }
         
        /**
         * Update each timestep
         */
        override public function update():Void {
            super.update();
           //Collide
        }
    }