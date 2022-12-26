package utils;

import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.group.FlxSpriteGroup;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;

/**
* FlxText with FlxInputText's focus callbacks
*/
class AFPText extends FlxText
{
	/**
	 * is focus gained?
	 */
	public var focusGained:Bool = false;
	/**
	 * function executes when focus gained
	 */
	public var onFocusGain:Void->Void;
	/**
	 * function executes when focus lost
	 */
	public var onFocusLost:Void->Void;
	/**
	 * function executes when left button mouse clicked and focus gained
	 */
	public var onClick:Void->Void;

	/**
	 * color sets when focus gained (mouse cursor overlaps with text)
	 */
	public var focusColor:FlxColor = FlxColor.WHITE;
	/**
	 * color sets when focus lost (mouse cursor not overlaps with text)
	 */
	public var unfocusColor:FlxColor = FlxColor.WHITE;
	/**
	 * color sets when focus gained (mouse cursor overlaps with text)
	 */
	public var focusBorderSize:Float = 1;
	 /**
	  * color sets when focus lost (mouse cursor not overlaps with text)
	  */
	public var unfocusBorderSize:Float = 1;

	/**
	 * Creates a new `AFPText` object at the specified position. (based on `FlxText`)
	 *
	 * @param   x       The x position of the text.
	 * @param   y       The y position of the text.
	 * @param   width   The `width` of the text object. Enables `autoSize` if `<= 0`. (`height` is determined automatically).
	 * @param   text    The actual text you would like to display initially.
	 * @param   size    The font size for this text object.
	 * @param   color   The color of the text.
	 */
	public function new(x:Float, y:Float, width:Float = 0, text:String, size:Int = 16, color:FlxColor = FlxColor.WHITE)
	{
		super(x, y, width, text, size);
		focusColor = unfocusColor = color;
		setFormat(Paths.font("vcr.ttf"), size, color, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scrollFactor.set();
	}

	/**
	 * Call this function to set colors for focus callbacks
	 * 
	 * @param focusColor     color sets when focus gained (mouse cursor overlaps with text)
	 * @param unfocusColor   color sets when focus lost (mouse cursor not overlaps with text)
	 */
	public function setFocusColors(focusColor:Null<FlxColor> = null, unfocusColor:Null<FlxColor> = null)
	{
		if (focusColor != null)
			this.focusColor = focusColor;
		if (unfocusColor != null)
			this.unfocusColor = unfocusColor;
	}

	/**
	 * Call this function to set border sizes for focus callbacks
	 * 
	 * @param focusBorderSize     border size sets when focus gained (mouse cursor overlaps with text)
	 * @param unfocusBorderSize   border size sets when focus lost (mouse cursor not overlaps with text)
	 */
	public function setFocusBorderSizes(focusBorderSize:Null<Float> = null, unfocusBorderSize:Null<Float> = null)
	{
		if (focusBorderSize != null)
			this.focusBorderSize = focusBorderSize;
		if (unfocusBorderSize != null)
			this.unfocusBorderSize = unfocusBorderSize;
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);

		focusGained = overlap(this);
		if (focusGained)
		{
			color = focusColor;
			borderSize = focusBorderSize;
			if (onFocusGain != null)
				onFocusGain();
			if (FlxG.mouse.justPressed && onClick != null)
				onClick();
		}
		else
		{
			color = unfocusColor;
			borderSize = unfocusBorderSize;
			if (onFocusLost != null)
				onFocusLost();
		}
	}

	private function overlap(sprite:FlxSprite):Bool
	{
		var x:Float = FlxG.mouse.getScreenPosition(cameras[0]).x;
		var y:Float = FlxG.mouse.getScreenPosition(cameras[0]).y;
		return x > sprite.x && x < (sprite.x + sprite.width) && y > sprite.y && y < (sprite.y + sprite.height);
	}
}
