/***
 * briefcase sits in front of you, laid flat with handle facing towards you
 * X is width
 * Y is depth
 * Z is height
 */

include <MCAD/materials.scad>

caseX = 460;
caseY = 330;
caseZ = 160;

case_lid_ext_Z = 60;
case_lid_wall_thickness = 8.2;
case_lid_int_X  = caseX - (case_lid_wall_thickness * 2);
case_lid_int_Y  = caseY - (case_lid_wall_thickness * 2);
case_lid_int_Z = 54.0;

case_bottom_ext_Z = 100;
case_bottom_wall_thickness = 11.0;
case_bottom_int_X  = caseX - (case_bottom_wall_thickness * 2);
case_bottom_int_Y  = caseY - (case_bottom_wall_thickness * 2);
case_bottom_int_Z = 96.5;

module briefcase()
{
	color(Aluminum)
	{
		//top part
		translate([0,caseY+case_lid_ext_Z,case_bottom_ext_Z])
		{
			rotate([90,0,0])
			{
				difference()
				{
					cube(size = [caseX, caseY, case_lid_ext_Z]);
					translate([case_lid_wall_thickness, case_lid_wall_thickness, case_lid_wall_thickness])
					{
						cube(size = [case_lid_int_X, case_lid_int_Y, case_lid_int_Z]);
					}
				}
			}
		}
		//bottom part
		difference()
		{
			cube(size = [caseX, caseY, case_bottom_ext_Z]);
			translate([case_bottom_wall_thickness,case_bottom_wall_thickness,case_bottom_wall_thickness])
			{
				cube(size = [case_bottom_int_X, case_bottom_int_Y, case_bottom_int_Z]);
			}
		}
	}
}
