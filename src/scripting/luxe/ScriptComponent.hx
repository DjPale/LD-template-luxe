package scripting.luxe;

import scripting.ScriptManager;

import luxe.Component;

class ScriptComponent extends Component
{
	public var manager(default,null) : ScriptManager;

	var _script : String;

	var _has_update : Bool;

	public function new(script:String, ?_options:luxe.options.ComponentOptions = null)
	{
		if (_options == null)
		{
			_options = {};
		}

		if (_options.name == null || _options.name == '') _options.name = 'ScriptManager';

		super(_options);

        manager = new ScriptManager();
		manager.register_variable('Luxe', Luxe);

        _script = Luxe.resources.text(script).asset.text;
	}

	override function init()
	{
		manager.register_variable('entity', entity);

		load(_script);
	}

	override function ondestroy()
	{
		manager.run_function('destroy');
		manager.clear();
	}

	function load(script:String)
	{
		manager.load_script(script);
		manager.run_function('init');

		_has_update = manager.has_function('update');
		trace('has_update = $_has_update');
	}

	public function reload(script:String)
	{
		_has_update = false;
		manager.run_function('ondestroy');
		load(script);
	}

	override function update(dt:Float)
	{
		if (_has_update)
		{
			manager.run_function('update');
		}
	}
}
