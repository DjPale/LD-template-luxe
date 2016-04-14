package util;

import luxe.collision.shapes.Shape;
import luxe.collision.shapes.Polygon;
import luxe.importers.tiled.TiledObjectGroup;
import luxe.importers.tiled.TiledMap;

class TiledMapHelper
{
    private function new()
    {
    }

    public static function object_to_shape(obj: TiledObject, ?_scale: Float = 1.0) : Shape
    {
        var ret = null;

        if (obj.object_type == TiledObjectType.rectangle)
        {
            var r = Polygon.rectangle(
                obj.pos.x * _scale, obj.pos.y * _scale,
                obj.width , obj.height ,
                false);

            r.scaleX = _scale;
            r.scaleY = _scale;

            ret = r;
        }
        else if (obj.object_type == TiledObjectType.polygon)
        {
            var p = obj.polyobject;
            var r = new Polygon(p.origin.x * _scale, p.origin.y * _scale, p.points);

            r.scaleX = _scale;
            r.scaleY = _scale;

            ret = r;
        }

        return ret;
    }

    public static function apply_tile_shader(map: TiledMap, shader: phoenix.Shader)
    {
        if (map.visual == null) return;

        var layers = map.visual.geometry.keys();

        for (lname in layers)
        {
            for (row in map.visual.geometry[lname])
            {
                for (geom in row)
                {
                    if (geom != null)
                    {
                        geom.shader = shader;
                        trace(geom.shader);
                    }
                }
            }
        }
    }
}
