package en;

class Mine extends Mob {
	public static var ALL : Array<Entity> = [];
	
	public function new(x,y) {
		super();
		cx = x;
		cy = y;
		setLife(1);
		radius = 9;
		frict = 0.9;
		
		sprite.swap("mine",0);
	}
	
	//override function onTouch(e:Entity) {
		//e.hit(1, this);
	//}
	
	override function unregister() {
		super.unregister();
		ALL.remove(this);
	}
}