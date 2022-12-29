package utils;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;

/**
* Extended Alphabet for OptionsState with FlxInputText's focus callbacks
*/
class AFPAlphabet extends Alphabet
{
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

	public function new(x:Float, y:Float, text:String = "", bold:Null<Bool> = true, id:Int = 0)
	{
		super(x, y, text, bold);
		ID = id;
		screenCenter();
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