class Const implements haxe.Public {
	static var _uniq = 0;
	static var DP_SCROLL = _uniq++;
	static var DP_BG = _uniq++;
	//static var DP_PERLIN = _uniq++;
	static var DP_WAVES2 = _uniq++;
	static var DP_ENTITY = _uniq++;
	static var DP_FX = _uniq++;
	static var DP_BEHIND_WALLS = _uniq++;
	static var DP_WALLS = _uniq++;
	static var DP_WAVES = _uniq++;
	static var LOWQ = false;
	
	static var BG = 0x251F36;
	static var COMBO_TIMER = 30*10;
	static var MUSIC_VOL = 0.4;
	
	static var WID = Std.int(flash.Lib.current.stage.stageWidth);
	static var HEI = Std.int(flash.Lib.current.stage.stageHeight);
	static var UPSCALE = 3;
	
	static var GRID = 16;
	static var WATER_LEVEL = 7;
	static var WATER_LEVEL_F = WATER_LEVEL*GRID;
}
