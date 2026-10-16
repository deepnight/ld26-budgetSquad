import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.ui.Keyboard;

import mt.deepnight.Color;
import mt.deepnight.Buffer;
import mt.deepnight.SpriteLibBitmap;
import mt.deepnight.Lib;
import mt.deepnight.Sfx;

enum Talker {
	T_Minnie;
	T_Malism;
	T_General;
}

@:bitmap("gfx/tiles.png") class GfxTiles extends BitmapData {}
@:bitmap("gfx/title.png") class GfxLogo extends BitmapData {}

class Game implements haxe.Public { //}
	public static var SFX = Sfx.importDirectory("sfx");
	static var PERLIN_SCALE = 4;
	public static var ME : Game;
	
	var root		: flash.display.MovieClip;
	var buffer		: Buffer;
	var pt0			: flash.geom.Point;
	var time		: Int;
	
	var tiles		: SpriteLibBitmap;
	var fx			: Fx;
	var tw			: mt.deepnight.Tweenie;
	var cm			: mt.deepnight.Cinematic;
	var delayer		: mt.deepnight.Delayer;
	
	var sdm			: mt.DepthManager;
	var scroll		: flash.display.Sprite;
	var viewport	: flash.geom.Rectangle;
	var hero		: en.Hero;
	var lighter		: en.HeroLighter;
	var gunner		: en.HeroGunner;
	var killList	: Array<Entity>;
	var level		: Level;
	
	var curTalk		: Null<Bitmap>;
	var curMessage	: Null<Bitmap>;
	var lockControls: Bool;
	var paused		: Bool;
	var dead		: Bool;
	var playAgain	: Bool;
	
	var debug		: mt.kiroukou.debug.Stats;
	var hole		: Bitmap;
	var perlin		: flash.display.BitmapData;
	var blurZone	: flash.display.BitmapData;
	var darkZone	: flash.display.BitmapData;
	var lightMap	: flash.display.BitmapData;
	
	var best		: Int;
	var score		: Int;
	var combo		: Int;
	var ctimer		: Int;
	
	var hud			: Buffer;
	var cbar		: Sprite;
	var tfScore		: flash.text.TextField;
	var tfCombo		: flash.text.TextField;
	
	var extraLoop	: Null< Void->Void >;
	
	var music		: Sfx;
	var fl_music	: Bool;
		
	
	public function new(r) {
		ME = this;
		haxe.Log.setColor(0xFFFF00);
		root = r;
		root.addEventListener( flash.events.Event.ENTER_FRAME, main );
		pt0 = new flash.geom.Point(0,0);
		lockControls = false;
		paused = false;
		fl_music = true;
		dead = false;
		playAgain = false;
		best = Lib.getCookie("ld26", "best", 0);
		score = 0;
		combo = 0;
		ctimer = 0;
		
		Key.init();
		killList = [];
		fx = new Fx();
		time = 0;
		tw = new mt.deepnight.Tweenie();
		cm = new mt.deepnight.Cinematic();
		delayer = new mt.deepnight.Delayer();
		
		buffer = new Buffer(300,180, Const.UPSCALE, true, 0x0);
		root.addChild(buffer.render);
		buffer.postFilters.push( Color.getContrastFilter(0.4) );
		
		hud = new Buffer(60,40, 2, true, 0x0);
		root.addChild(hud.render);
		//hud.x = Std.int(Const.WID*0.5-hud.width*0.5);
		//hud.x = Std.int(Const.WID*0.5-hud.width*0.5);
		
		tiles = new SpriteLibBitmap(new GfxTiles(0,0) );
		tiles.setDefaultCenter(0,0);
		tiles.setSliceGrid(32,32);
		tiles.sliceGrid("wall", 0,0, 7);
		tiles.sliceGrid("plant", 0,1);
		tiles.sliceGrid("rock", 0,2, 5);
		tiles.sliceGrid("malism", 0,3, 6);
		tiles.defineAnim("heli", 0-5(1));
		tiles.slice("spotLight", 0,4*32, 16,16);
		tiles.slice("torpedo", 16,4*32, 16,16);
		tiles.slice("bullet", 16*2,4*32, 16,16);
		tiles.sliceGrid("minnie", 0,5, 6);
		tiles.defineAnim("heli", 0-5(1));
		tiles.sliceGrid("mine", 0,6, 2);
		tiles.sliceGrid("arrow", 2,6);
		tiles.sliceGrid("gem", 3,6);
		tiles.sliceGrid("potato", 4,6);
		tiles.sliceGrid("breakable", 5,6);
		tiles.sliceGrid("crystal", 6,6);
		tiles.sliceGrid("coral", 0,7, 7);
		tiles.sliceGrid("wallOut", 0,8, 7);
		tiles.sliceGrid("turret", 0,9);
		tiles.sliceGrid("lazer", 1,9);
		tiles.sliceGrid("metal", 0,10, 6);
		
		tiles.slice("rays", 0,480, 127,43);
		tiles.slice("waves", 0,528, 127,43);
		tiles.slice("sky", 0,576, 272,112);
		tiles.slice("sky2", 0,752, 272,112);
		tiles.slice("oceanBg", 0,704, buffer.width,buffer.height);
		tiles.slice("face", 0,896, 16*3, 16*3, 5);
		tiles.defineAnim("noise", 0-1(2));
		tiles.slice("plane", 0,688, 272,64);
		tiles.slice("cloud", 272,688, 5*16,4*16);
		
		blurZone = buffer.clone();
		darkZone = buffer.clone();
		
		viewport = new flash.geom.Rectangle(0,0, Std.int(buffer.width/Const.GRID), Std.int(buffer.height/Const.GRID));
		
		var bg = new Sprite();
		buffer.addChild(bg);
		bg.graphics.beginFill(Const.BG,1);
		bg.graphics.drawRect(0,0,buffer.width,buffer.height);
		
		scroll = new Sprite();
		buffer.addChild(scroll);
		sdm = new mt.DepthManager(scroll);
		
		var s = new Sprite();
		var w = 60;
		var b = 16;
		s.graphics.beginFill(0x00FF00,1);
		s.graphics.drawCircle(0,0,w);
		s.filters = [ new flash.filters.BlurFilter(b,b, 2) ];
		hole = Lib.flatten(s, b);
		
		level = new Level();
		sdm.add(level.rays, Const.DP_WAVES);
		sdm.add(level.waves2, Const.DP_WAVES2);
		sdm.add(level.waves, Const.DP_WAVES);
		//sdm.add(level.oceanBg, Const.DP_BG);
		sdm.add(level.backPerlin, Const.DP_BG);
		sdm.add(level.sky, Const.DP_BG);
		sdm.add(level.walls, Const.DP_WALLS);
		
		perlin = new BitmapData(Math.ceil(buffer.width/PERLIN_SCALE), Math.ceil(buffer.height/PERLIN_SCALE), true, 0x0);
		var bmp = new Bitmap(perlin);
		bmp.scaleX = bmp.scaleY = PERLIN_SCALE*Const.UPSCALE;
		bmp.blendMode = flash.display.BlendMode.ADD;
		bmp.alpha = 0.05;
		//bmp.visible = false;
		root.addChild(bmp);
		
		
		var tf = createField("???");
		tfScore = tf;
		hud.addChild(tf);
		tf.width = 50;
		tf.scaleX = tf.scaleY = 2;
		tf.y = -1;
		tf.filters = [];
		tf.textColor = 0xFFD900;
		tf.filters = [];
		
		var tf = createField("???");
		hud.addChild(tf);
		tfCombo = tf;
		tf.width = 50;
		tf.x = 3;
		tf.y = 23;
		tf.textColor = 0xFF9300;
		
		cbar = new Sprite();
		hud.addChild(cbar);
		cbar.x = 5;
		cbar.y = 20;
		
		//var bmp = new Bitmap(darkZone);
		//bmp.filters = [new flash.filters.GlowFilter(0xFF0000,1, 2,2,5)];
		//root.addChild(bmp);

		#if debug
		//debug = new mt.kiroukou.debug.Stats(Const.WID-70);
		//root.addChild(debug);
		#end

		startGame();
	}
	
	public function updateCombo() {
		cbar.visible = ctimer>0;
		cbar.graphics.clear();
		var w = 20;
		var h = 3;
		cbar.graphics.beginFill(0x0,1);
		cbar.graphics.drawRect(0,0,w,h);
		cbar.graphics.beginFill(0xFF9300,1);
		cbar.graphics.drawRect(0,0,w*ctimer/Const.COMBO_TIMER,h);
		cbar.filters = [
			//new flash.filters.DropShadowFilter(1,90, 0xffffff,0.1, 0,0,1, 1,true),
			new flash.filters.GlowFilter(0x000000,0.8,2,2,4),
		];
		
		tfCombo.visible = combo>0;
		//tfCombo.visible = false;
		tfCombo.text = Std.string((combo+1)+"x combo");
	}
	
	public function addScore(v:Int, ?from:Entity) {
		if( dead )
			return;
		v*=combo+1;
		score+=v;
		if( from!=null && v>0 )
			fx.pop(from.xx, from.yy, v);
		tfScore.text = Std.string(score);
	}
	
	public function addCombo() {
		combo++;
		ctimer = Const.COMBO_TIMER;
		updateCombo();
	}
	
	public function tutorial() {
		#if debug
		playAgain = true;
		#end
		if( playAgain )
			lockControls = false;
		else
			cm.create({
				1600;
				hero = lighter;
				fx.point(lighter, "The shield");
				600;
				message("Minnie is INVINCIBLE and she has a SPOTLIGHT. Use her to scout and tank.", 0x6C006C) > end;
				300;
				hero = gunner;
				fx.point(gunner, "The gun");
				600;
				message("Malism has TORPEDOES but only ONE LIFE. Dont leave her into darkness.", 0xCC6B00) > end;
				message("Use ARROWS or WASD to move, SPACE to switch the submarine you control, M to stop music.") > end;
				message("OBJECTIVE: Kill! Combo! Score! Who cares about the story anyway?", 0xA40000)>end;
				hideMessage();
				lockControls = false;
			});
	}
	
	public function logo() {
		var mask = new Sprite();
		root.addChild(mask);
		mask.graphics.beginFill(0x0, 1);
		mask.graphics.drawRect(0,0,Const.WID, Const.HEI);
		
		var wrapper = new Sprite();
		root.addChild(wrapper);
		wrapper.scaleX = wrapper.scaleY = Const.UPSCALE;
		wrapper.graphics.beginFill(0x040b1d, 1);
		wrapper.graphics.drawRect(0,0,buffer.width, buffer.height);
		
		var scl = 3;
		var perlin = new Bitmap( new BitmapData(Math.ceil(buffer.width/scl), Math.ceil(buffer.height/scl), false, 0x0) );
		wrapper.addChild(perlin);
		perlin.scaleX = perlin.scaleY = scl;
		perlin.blendMode = flash.display.BlendMode.ADD;
		perlin.alpha = 0.12;
		var bd = perlin.bitmapData;
		
		extraLoop = function() {
			var s = 0.5;
			bd.perlinNoise(64,16, 2, 1866, false, true, 1, true,
				[
					new flash.geom.Point(time*0.03*s, time*0.17*s),
					new flash.geom.Point(-time*0.07*s, -time*0.3*s),
				]
			);
		}
		
		var bmp = new Bitmap( new GfxLogo(0,0) );
		wrapper.addChild(bmp);
		
		var tf = createField("A 48h game by Sebastien Benard", true);
		wrapper.addChild(tf);
		tf.x = Std.int( buffer.width*0.5 - tf.width*0.5);
		tf.y = buffer.height - 20;
		tf.blendMode = flash.display.BlendMode.OVERLAY;
		tf.filters = [];
		tf.alpha = 1;
		
		var tf = createField("www.deepnight.net", true);
		wrapper.addChild(tf);
		tf.x = Std.int( buffer.width*0.5 - tf.width*0.5);
		tf.y = buffer.height - 12;
		tf.filters = [];
		tf.alpha = 0.3;
		
		
		delayer.add(function() {
			tw.create(wrapper, "alpha", 0).onEnd = function () {
				mask.parent.removeChild(mask);
				intro();
				wrapper.parent.removeChild(wrapper);
				bd.dispose();
				bmp.bitmapData.dispose();
			}
		}, 1500);
	}
	
	public function startGame() {
		if( music!=null )
			music.stop();
			
		dead = false;
		paused = true;
		lockControls = true;
		for(e in Entity.ALL)
			e.destroy();

		gunner = new en.HeroGunner(5,-2);
		lighter = new en.HeroLighter(9,-2);
		lighter.cd.set("gravity",10);
		hero = gunner;
		#if debug
		gunner.cx = 3*16+8;
		lighter.cx = 3*16+8;
		gunner.cx = 73;
		gunner.cy = 66;
		hero = lighter;
		#end
		
		score = combo = ctimer = 0;
		addScore(0);
		updateCombo();
		
		for(pt in level.getSpots("mine") )
			new en.Mine(pt.cx, pt.cy);
		for(pt in level.getSpots("seekMine") )
			new en.SeekingMine(pt.cx, pt.cy);
		for(pt in level.getSpots("turret") )
			new en.Turret(pt.cx, pt.cy);
		for(pt in level.getSpots("gem") )
			new en.Gem(pt.cx, pt.cy);
		for(pt in level.getSpots("lazer") )
			new en.Lazer(pt.cx, pt.cy);
		for(pt in level.getSpots("potato") )
			new en.Potato(pt.cx, pt.cy);
		for(pt in level.getSpots("breakable") )
			new en.Breakable(pt.cx, pt.cy);
		for(pt in level.getSpots("crystal") )
			new en.Crystal(pt.cx, pt.cy);
			
		if( playAgain )
			intro();
		else
			logo();
	}
	
	function intro() {
		var wrapper = new Sprite();
		root.addChild(wrapper);
		wrapper.scaleX = wrapper.scaleY = Const.UPSCALE;

		var sky = tiles.get("sky2");
		wrapper.addChild(sky);
		sky.width = buffer.width;
		sky.height = buffer.height;

		var s1 = tiles.get("minnie");
		wrapper.addChild(s1);
		s1.visible = false;
		var s2 = tiles.get("malism");
		wrapper.addChild(s2);
		s2.visible = false;
		
				
		var plane = tiles.get("plane");
		plane.x = 35;
		wrapper.addChild(plane);
		extraLoop = function() {
			plane.x = 40 + Math.cos(time*0.01)*5;
			plane.y = 40 + Math.cos((time)*0.03)*10 + Lib.rnd(0,1);
			if( Std.random(100)<30 )
				fx.cloud(wrapper);
		}
		extraLoop();

		if( best>0 ) {
			var tf = createField("Best score: "+best, true);
			wrapper.addChild(tf);
			tf.filters = [];
			tf.x = buffer.width-tf.width;
			tf.textColor = 0xFFA600;
		}
		
		var tf = createField("");
		wrapper.addChild(tf);
		tf.filters = [];
		
		
		function _drop(s:BSprite, off, ?txt) {
			s.visible = true;
			s.x = plane.x+110+off;
			s.y = plane.y+20;
			s.scaleX = -1;
			tw.create(s, "x", s.x+60, TLinear, 1000);
			tw.create(s, "y", buffer.height, TEaseIn, 1000).onEnd = function() {
				s.destroy();
			}
			delayer.add(function() Game.SFX.fall1().play(0.3), 300);
			if( txt!=null ) {
				tf.visible = true;
				tf.text = txt;
				tf.x = s.x;
				tf.y = s.y+10;
			}
		}
		
		
		var sound = SFX.plane();

		function _endIntro() {
			wrapper.parent.removeChild(wrapper);
			extraLoop = null;
			paused = false;
			plane.destroy();
			sky.destroy();
			sound.stop();
			
			// tutorial
			haxe.Timer.delay(tutorial, 500);
			
			music = SFX.music();
			music.playLoop(9999,Const.MUSIC_VOL);
		}
		
		#if debug
		_endIntro();
		#else
		fx.fadeIn(2000);
		wrapper.visible = false;
		cm.create({
			wrapper.visible = true;
			sound.playLoop(99999, 0.5);
			2500;
			talk(T_Minnie, "Sir! Special ELITE squad waiting your command!") > end;
			talk(T_General, "Bad news, ladies. Headquarters have ordered more budget cuts.") > end;
			talk(T_General, "We... actually have only one cannon and one spotlight left.") > end;
			talk(T_Minnie, "...") > end;
			talk(T_Malism, "Seriously.") > end;
			//talk(T_General, "Good. Due to defense budget restrictions, few changes have been to your equipment.") > end;
			talk(T_General, "Minnie, you take the light. Malism, you have the gun.") > end;
			talk(T_General, "Oh, almost forgot.") > end;
			talk(T_General, "Malism, we also sold your submarine armor on EBay. So you should really avoid bullets now.") > end;
			talk(T_Malism, "Wait, what?!") > end;
			talk(T_General, "GOOD LUCK!") > end;
			100;
			_drop(s1,0, "NooOOoo!");
			600;
			_drop(s2, 10);
			1000;
			fx.fadeIn(1000);
			hideTalk();
			_endIntro();
		});
		#end
	}
	
	public function credits() {
		checkBestScore();
		
		var wrapper = new Sprite();
		root.addChild(wrapper);
		wrapper.scaleX = wrapper.scaleY = Const.UPSCALE;
		wrapper.alpha = 0;
		tw.create(wrapper,"alpha",1, 1500);
		
		tw.create(tfScore,"alpha",0, 1500);
		
		//var sky = tiles.get("sky2");
		//wrapper.addChild(sky);
		//sky.width = buffer.width;
		//sky.height = buffer.height;
		
		var tf = createField("Your score:",true);
		wrapper.addChild(tf);
		tf.filters = [];
		tf.x = Std.int(buffer.width*0.5-tf.width*0.5);
		tf.y = Std.int(buffer.height*0.2-tf.height*0.5);
		
		var tf = createField(Std.string(score),true);
		wrapper.addChild(tf);
		tf.filters = [];
		tf.textColor = 0xFFEC00;
		tf.scaleX = tf.scaleY = 4;
		tf.x = Std.int(buffer.width*0.5-tf.width*0.5);
		tf.y = Std.int(buffer.height*0.3-tf.height*0.5);
		
		var n = 0;
		function _line(txt:String) {
			var tf = createField(txt, true);
			wrapper.addChild(tf);
			tf.x = Std.int(buffer.width*0.5-tf.width*0.5);
			tf.y = Std.int(buffer.height*0.95-tf.height*0.5) + n*12;
			tf.alpha = 0;
			tf.filters = [ new flash.filters.GlowFilter(0x0,0.8, 8,8,2) ];
			var d = 1500;
			tw.create(tf, "alpha", 1, TEase, d);
			tw.create(tf, "y", tf.y-60, TEase, d).onEnd = function() {
				//tf.parent.removeChild(tf);
				cm.signal();
			}
			n++;
		}
		
		cm.create({
			1500;
			_line("Thank you for playing!")>end;
			_line("A game by Deepnight (twitter: DeepnightFR)")>end;
			_line("Don't hesitate to leave a comment :)")>end;
		});
	}
	
	
	public function checkBestScore() {
		if( score>best )
			best = score;
		Lib.setCookie("ld26", "best", best);
	}
	
	public function gameOver() {
		checkBestScore();
		dead = true;
		playAgain = true;
		hero = gunner;
		lockControls = true;
		
		fx.blood(1500);
		delayer.add(startGame, 1500);
	}
	
	
	public function createField(str:String, ?adjustSize=false) {
		var f = new flash.text.TextFormat();
		f.font = "def";
		f.size = 8;
		f.color = 0xffffff;
		
		var tf = new flash.text.TextField();
		tf.width = adjustSize ? 500 : 300;
		tf.height = 50;
		tf.mouseEnabled = tf.selectable = false;
		tf.defaultTextFormat = f;
		tf.embedFonts = true;
		tf.htmlText = str;
		tf.multiline = tf.wordWrap = true;
		if( adjustSize ) {
			tf.width = tf.textWidth+5;
			tf.height = tf.textHeight+5;
		}
		tf.filters = [ new flash.filters.GlowFilter(0x0,1, 2,2,4) ];
		
		return tf;
	}
	
	
	
	public function hideTalk() {
		if( curTalk!=null ) {
			var bmp = curTalk;
			curTalk = null;
			tw.create(bmp, "y", Const.HEI, TLinear, 200).onEnd = function() {
				bmp.parent.removeChild(bmp);
				bmp.bitmapData.dispose();
			}
		}
	}
	
	public function hideMessage() {
		if( curMessage!=null ) {
			var bmp = curMessage;
			curMessage = null;
			bmp.parent.removeChild(bmp);
			bmp.bitmapData.dispose();
		}
	}
	
	public function message(text:String, ?col=0x3A3D89) {
		hideMessage();
		var wrapper = new Sprite();
		
		if( !cm.turbo )
			Game.SFX.talk4().play();
		
		var bg = new Sprite();
		wrapper.addChild(bg);
		bg.graphics.beginFill(col,1);
		bg.graphics.drawRect(0,0, 230, 24);
		bg.filters = [
			new flash.filters.GlowFilter(0x0,1, 4,4,1, 1,true),
			new flash.filters.GlowFilter(0xFFFFFF,1, 2,2,10),
			new flash.filters.GlowFilter(0x0,1, 2,2,10),
		];
		
		var tf = createField("HOW TO PLAY", true);
		wrapper.addChild(tf);
		tf.x = bg.width-tf.textWidth-1;
		tf.y = bg.y-10;
		tf.alpha = 0.5;
		
		var tf = createField(text);
		wrapper.addChild(tf);
		tf.x = bg.x+3;
		tf.y = bg.y+1;
		tf.width = bg.width-6;
		tf.height = bg.height;
		tf.filters = [ new flash.filters.DropShadowFilter(1,90, 0x0,0.7, 2,0) ];
		
		curMessage = Lib.flatten(wrapper,3);
		root.addChild(curMessage);
		curMessage.scaleX = curMessage.scaleY = Const.UPSCALE;
		curMessage.x = Std.int(Const.WID*0.5-curMessage.width*0.5);
		curMessage.y = Const.HEI-curMessage.height;
		curMessage.alpha = 0;
		tw.create(curMessage, "alpha", 1, 300);
	}
	

	public function talk(c:Talker, text) {
		hideTalk();
		
		var name = "???";
		var col = 0x3A3D89;
		var faceId = 2;
		switch( c ) {
			case T_Minnie :
				col = 0x853679;
				name = "Minnie";
				faceId = 3;
				if( !cm.turbo ) Game.SFX.talk3().play();
			case T_Malism :
				col = 0xAC531E;
				name = "Malism";
				faceId = 4;
				if( !cm.turbo ) Game.SFX.talk2().play();
			case T_General :
				col = 0x465032;
				name = "General Cheap";
				faceId = 2;
				if( !cm.turbo ) Game.SFX.talk1().play();
		}
		var wrapper = new Sprite();
		
		var bg = new Sprite();
		wrapper.addChild(bg);
		bg.graphics.beginFill(col,1);
		bg.graphics.drawRect(0,0, 230, 32);
		bg.filters = [
			new flash.filters.GlowFilter(0x0,1, 4,4,1, 1,true),
			new flash.filters.GlowFilter(0xFFFFFF,1, 2,2,10),
			new flash.filters.GlowFilter(0x0,1, 2,2,10),
		];
		bg.x = 46;
		bg.y = 8;

		var tf = createField("PRESS SPACE TO CONTINUE", true);
		wrapper.addChild(tf);
		tf.x = bg.x + bg.width-tf.textWidth-1;
		tf.y = bg.y+bg.height;
		tf.textColor = col;
		tf.filters = [];

		var tf = createField("<font color='"+Color.intToHex(Color.brightnessInt(col,0.6))+"'>"+name.toUpperCase()+"</font>\n"+text);
		wrapper.addChild(tf);
		tf.x = bg.x+3;
		tf.y = bg.y+1;
		tf.width = bg.width-6;
		tf.height = bg.height;
		tf.filters = [ new flash.filters.DropShadowFilter(1,90, 0x0,0.7, 2,0) ];
		
		var face = tiles.get("face", faceId);
		wrapper.addChild(face);
		//face.x = buffer.width-face.width;
		
		curTalk = Lib.flatten(wrapper,3);
		root.addChild(curTalk);
		curTalk.scaleX = curTalk.scaleY = Const.UPSCALE;
		curTalk.x = Std.int(Const.WID*0.5-curTalk.width*0.5);
		curTalk.y = Const.HEI-curTalk.height;
		curTalk.alpha = 0;
		tw.create(curTalk, "alpha", 1, 300);
		
		var noise = tiles.getAndPlay("face", "noise");
		root.addChild(noise);
		noise.x = curTalk.x+3*Const.UPSCALE;
		noise.y = curTalk.y+3*Const.UPSCALE;
		noise.scaleX = noise.scaleY = Const.UPSCALE;
		tw.create(noise, "alpha", 0, TEaseIn, 300).onEnd = function() {
			noise.parent.removeChild(noise);
			noise.destroy();
		}
	}
	

	
	function main(_) {
		tw.update();
		cm.update();
		delayer.update();
		
		// Controls
		if( !lockControls && !paused ) {
			var s = hero.speed * (hero.isUnderwater() ? 0.6 : 1);
			if( Key.isDown(Keyboard.LEFT) || Key.isDown(Keyboard.Q)  || Key.isDown(Keyboard.A) ) {
				hero.sprite.scaleX = 1;
				hero.engine = true;
				hero.dx-=s;
			}
			if( Key.isDown(Keyboard.RIGHT) || Key.isDown(Keyboard.D) ) {
				hero.sprite.scaleX = -1;
				hero.engine = true;
				hero.dx+=s;
			}
			if( ( Key.isDown(Keyboard.UP) || Key.isDown(Keyboard.Z)  || Key.isDown(Keyboard.W) ) && hero.isUnderwater()  ) {
				hero.engine = true;
				hero.dy-=s;
			}
			if( Key.isDown(Keyboard.DOWN) || Key.isDown(Keyboard.S) ) {
				hero.engine = true;
				hero.dy+=s;
			}
			if( Key.isToggled(Keyboard.SPACE) && curTalk==null ) {
				hero = hero==gunner ? lighter : gunner;
				if( hero==gunner )
					SFX.tech1().play(0.4);
				else
					SFX.tech2().play(0.4);
				fx.glow(hero);
			}
		}
		
		if( Key.isToggled(Keyboard.ESCAPE) )
			cm.skip();
		
		if( Key.isToggled(Keyboard.L) ) {
			Const.LOWQ = !Const.LOWQ;
			var tf = createField("Set to "+(Const.LOWQ ? "LOW" : "HIGH")+" quality",true);
			root.addChild(tf);
			tf.textColor = Const.LOWQ ? 0xFFB148 : 0x86FF00;
			tf.filters = [];
			tf.scaleX = tf.scaleY = 2;
			tf.x = Std.int(Const.WID*0.5-tf.width*0.5);
			tw.create(tf, "alpha", 0, 1500).onEnd = function() {
				tf.parent.removeChild(tf);
			}
			if( Const.LOWQ ) {
				level.backPerlin.bitmapData.fillRect(level.backPerlin.bitmapData.rect, 0x0);
			}
		}
		
		if( Key.isToggled(Keyboard.M) ) {
			fl_music = !fl_music;
			if( music!=null )
				music.setVolume( fl_music ? Const.MUSIC_VOL : 0);
		}
		
		//if( Key.isToggled(Keyboard.H) )
			//tutorial();
		
		if( Key.isToggled(Keyboard.SPACE) && ( curTalk!=null || curMessage!=null ) ) {
			cm.signal();
			hideTalk();
			hideMessage();
		}
		
		// Updates
		if( extraLoop!=null )
			extraLoop();
		if( !paused ) {
			for(s in Entity.ALL)
				s.update();
			for(e in killList)
				e.unregister();
			killList = [];
			if( time%3==0 )
				fx.plankton();
		}
		fx.update();
		level.update();
		BSprite.updateAll();
		
		// Scrolling
		viewport.x = hero.xx;
		viewport.y = hero.yy;
		//viewport.x = gunner.xx + (lighter.xx-gunner.xx)/2;
		//viewport.y = gunner.yy + (lighter.yy-gunner.yy)/2;
		var vx = buffer.width*0.5 - (viewport.x - viewport.width*0.5);
		var vy = buffer.height*0.5 - (viewport.y - viewport.height*0.5);
		if( vx>-8 ) vx=-8;
		if( vx<(-level.wid+viewport.width+1)*Const.GRID ) vx=(-level.wid+viewport.width+1)*Const.GRID;
		if( vy>-8 ) vy=-8;
		if( vy<(-level.hei+viewport.height)*Const.GRID ) vy=(-level.hei+viewport.height)*Const.GRID;
		var recal = 0.15;
		scroll.x = Std.int( scroll.x + (vx-scroll.x)*recal );
		scroll.y = Std.int( scroll.y + (vy-scroll.y)*recal);
		//level.oceanBg.x = -scroll.x;
		level.backPerlin.x = -scroll.x;
		level.backPerlin.y = -scroll.y;
		
		// Post filters
		buffer.update();
		hud.update();
		darkZone.fillRect(darkZone.rect, Color.addAlphaF(Const.BG));
		var bbd = buffer.getBitmap();
		if( Const.LOWQ )
			blurZone.fillRect(blurZone.rect,Color.addAlphaF(Const.BG, 0.8));
		else {
			blurZone.copyPixels(bbd, bbd.rect, pt0);
			blurZone.applyFilter( blurZone, blurZone.rect, pt0, Color.getColorizeMatrixFilter(Const.BG, 0.8, 0.2));
			blurZone.applyFilter( blurZone, blurZone.rect, pt0, new flash.filters.BlurFilter(4,4,1));
		}
		var ct = new flash.geom.ColorTransform();
		for(e in Entity.LIGHTS) {
			ct.alphaMultiplier = e.lightPower;
			
			hole.scaleX = hole.scaleY = 1.25 * e.lightScale;
			hole.x = e.xx + scroll.x - hole.width*0.5;
			hole.y = e.yy + scroll.y - hole.height*0.5;
			blurZone.draw(hole, hole.transform.matrix, ct, flash.display.BlendMode.ERASE);
			
			hole.scaleX = hole.scaleY = 2 * e.lightScale;
			hole.x = e.xx+scroll.x - hole.width*0.5;
			hole.y = e.yy+scroll.y - hole.height*0.5;
			darkZone.draw(hole, hole.transform.matrix, ct, flash.display.BlendMode.ERASE);
		}
		ct.alphaMultiplier = 1;
		var wlevel = Const.WATER_LEVEL*Const.GRID + scroll.y;
		if( wlevel>=0 ) {
			darkZone.fillRect(new flash.geom.Rectangle(0,0,buffer.width,wlevel), 0x0);
			blurZone.fillRect(new flash.geom.Rectangle(0,0,buffer.width,wlevel), 0x0);
			level.backPerlin.bitmapData.fillRect(new flash.geom.Rectangle(0,0,buffer.width,wlevel), 0x0);
		}
		var min = 0;
		ct.alphaMultiplier = Math.min(1, Math.max(0, 0.8 + 0.2*(hero.yy-min-Const.WATER_LEVEL*Const.GRID)/(150+min) )); // depth opacity
		ct.alphaMultiplier = 1;
		bbd.draw(blurZone, ct);
		bbd.draw(darkZone, ct);
		
		//if( time%2==0 ) {
			//perlin.perlinNoise(8,8, 2, 1866, false,true, 1, true,
				//[ new flash.geom.Point(time*0.1, time*0.03), new flash.geom.Point(time*0.025,time*0.11) ]
			//);
		//}
		if( ctimer>0 ) {
			ctimer--;
			if( ctimer<=0 ) {
				combo = 0;
				addScore(0);
			}
			updateCombo();
		}
		time++;
	}
}
