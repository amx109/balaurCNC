include <MCAD/materials.scad>

case_width  = 460;
case_depth  = 330;
case_height = 160;

case_lid_ext_width  = case_width;
case_lid_ext_depth  = case_depth;
case_lid_ext_height = 60;
case_lid_wall_thickness = 8.2;
case_lid_int_width  = case_lid_ext_width - (case_lid_wall_thickness * 2);
case_lid_int_depth  = case_lid_ext_depth - (case_lid_wall_thickness * 2);
case_lid_int_height = 54.0;

case_bottom_ext_width  = case_width;
case_bottom_ext_depth  = case_depth;
case_bottom_ext_height = 100;
case_bottom_wall_thickness = 11.0;
case_bottom_int_width  = case_bottom_ext_width - (case_bottom_wall_thickness * 2);
case_bottom_int_depth  = case_bottom_ext_depth - (case_bottom_wall_thickness * 2);
case_bottom_int_height = 96.5;

module suitcase()
{
	color(Aluminum)
	{
		//top part
		translate([0,case_bottom_ext_depth+case_lid_ext_height,case_bottom_ext_height])
		{
			rotate([90,0,0])
			{
				difference()
				{
					cube(size = [case_lid_ext_width, case_lid_ext_depth, case_lid_ext_height]);
					translate([case_lid_wall_thickness, case_lid_wall_thickness, case_lid_wall_thickness])
					{
						cube(size = [case_lid_int_width, case_lid_int_depth, case_lid_int_height]);
					}
				}
			}
		}
		//bottom part
		difference()
		{
			cube(size = [case_bottom_ext_width, case_bottom_ext_depth, case_bottom_ext_height]);
			translate([case_bottom_wall_thickness,case_bottom_wall_thickness,case_bottom_wall_thickness])
			{
				cube(size = [case_bottom_int_width, case_bottom_int_depth, case_bottom_int_height]);
			}
		}
	}
}
