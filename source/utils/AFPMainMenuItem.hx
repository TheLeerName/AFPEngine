package utils;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;

/**
* Menu item for MainMenuState with FlxInputText's focus callbacks
*/
class AFPMainMenuItem extends FlxSprite
{
	/**
	 * menu item name
	 */
	public var menuItem:String;
	/**
	 * is focus gained?
	 */
	public var focusGained:Bool = false;
	/**
	 * function executes when focus gained
	 */
	public var onFocusGain:Int->Void;
	/**
	 * function executes when focus lost
	 */
	public var onFocusLost:Int->Void;
	/**
	 * function executes when left button mouse clicked and focus gained
	 */
	public var onClick:Int->Void;

	public function new(x:Float, y:Float, key:String, id:Int)
	{
		super(x, y);
		this.menuItem = key;
		frames = Paths.getSparrowAtlas('mainmenu/menu_' + key);
		animation.addByPrefix('idle', key + " basic", 24, true);
		animation.addByPrefix('selected', key + " white", 24, true);
		animation.play('idle');
		ID = id;
		screenCenter(X);
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);

		focusGained = FlxG.mouse.overlaps(this, cameras[0]);
		if (focusGained)
		{
			if (onFocusGain != null)
				onFocusGain(ID);
			if (FlxG.mouse.justPressed)
			{
				if (onClick != null)
					onClick(ID);
			}
		}
		else
		{
			if (onFocusLost != null)
				onFocusLost(ID);
		}
	}
}