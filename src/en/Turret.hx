package en;

class Turret extends Mob {
	var prioGun		: Bool;
	public function new(x,y) {
		super();
		cx = x;
		cy = y;
		setLife(10);
		score = 100;
		radius = 9;
		collides = true;
		hitWeight = 2;
		oscillo = 0.2;
		prioGun = true;
		
		sprite.swap("turret",0);
	}
	
	
	override function update() {
		super.update();
		if( !cd.hasSet("prioSwitch",rnd(40,80)) )
			prioGun = !prioGun;
			
		var targets = prioGun ? [ game.gunner, game.lighter ] : [ game.lighter, game.gunner ];
		if( !cd.has("shoot") ) {
			for(e in targets) {
				if( checkDistance(e, 120) ) {
					cd.set("shoot", 23);
					new Bullet(this, e);
					break;
				}
			}
		}
	}
}