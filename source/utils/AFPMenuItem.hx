package utils;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;

/**
* Menu item for MainMenuState with FlxInputText's focus callbacks
*/
class AFPMenuItem extends FlxSprite
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

	/**
	 * alpha sets when focus gained (mouse cursor overlaps with text)
	 */
	public var focusAlpha:Float = 1;
	/**
	 * alpha sets when focus lost (mouse cursor not overlaps with text)
	 */
	public var unfocusAlpha:Float = 1;

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

	/**
	 * Call this function to set alpha for focus callbacks
	 * 
	 * @param focusAlpha     alpha sets when focus gained (mouse cursor overlaps with text)
	 * @param unfocusAlpha   alpha sets when focus lost (mouse cursor not overlaps with text)
	 */
	public function setFocusAlpha(focusAlpha:Null<Float> = null, unfocusAlpha:Null<Float> = null)
	{
		if (focusAlpha != null)
			this.focusAlpha = focusAlpha;
		if (unfocusAlpha != null)
			this.unfocusAlpha = unfocusAlpha;
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);

		focusGained = FlxG.mouse.overlaps(this, cameras[0]);
		if (focusGained)
		{
			alpha = focusAlpha;
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
			alpha = unfocusAlpha;
			if (onFocusLost != null)
				onFocusLost(ID);
		}
	}
}