package macros;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Compiler;
#end

using StringTools;

/**
 * Creates callbacks for all not inline variables (not properties!) in class
 *
 * To build, write this before class: `@:build(macros.SetCallbacksBuilding.build())`
 */
class SetCallbacksBuilding {
	/**
	 * Creates callbacks for all not inline variables (not properties!) in class
	 *
	 * For variable `strumTime` it will be `strumTime_setCallback`
	 *
	 * Example: `strumTime_setCallback = function () { trace("strumTime changed to " + strumTime); };`
	 * @param callbackName Name to add for callback variables
	 */
	public static function build(callbackName:String = "_setCallback") #if macro :Array<Field> #end {
		#if macro
		var fields:Array<Field> = [];
		fields = Context.getBuildFields();

		for(f in fields) {
			switch(f.kind) {
				case FVar(t, e):
					if (!f.name.endsWith(callbackName) && !f.access.contains(AInline))
					{
						f.kind = FProp("default", "set", t, e);
						fields.push({
							pos: Context.currentPos(),
							name: f.name + callbackName,
							kind: FVar(macro:Void->Void, macro function (){}),
							access: f.access
						});
						fields.push({
							pos: Context.currentPos(),
							name: "set_" + f.name,
							kind: FFun({
								expr: {
									pos: Context.currentPos(),
									expr: EBlock([
										{
											pos: Context.currentPos(),
											expr: EBinop(Binop.OpAssign, {
												pos: Context.currentPos(),
												expr: EConst(CIdent(f.name))
											}, {
												pos: Context.currentPos(),
												expr: EConst(CIdent("value"))
											})
										},
										{
											pos: Context.currentPos(),
											expr: ECall({
												pos: Context.currentPos(),
												expr: EConst(CIdent(f.name + callbackName))
											}, [])
										},
										{
											pos: Context.currentPos(),
											expr: EReturn({
												pos: Context.currentPos(),
												expr: EConst(CIdent("value"))
											})
										}
									]),
								},
								args: [{
									name: "value",
									type: t,
									opt: false,
								}],
								ret: t
							}),
							access: f.access
						});
					}
				default:
					// nothing
			}
		}
		return fields;
		#end
	}
}