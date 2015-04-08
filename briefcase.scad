/***
 * briefcase sits in front of you, laid flat with handle facing towards you
 * X is width
 * Y is depth
 * Z is height
 */

caseX = 460;
caseY = 335;
caseZ = 160;

case_lid_ext_Z = 60;
case_lid_wall_thickness = 8.2;
case_lid_int_X  = caseX - (case_lid_wall_thickness * 2);
case_lid_int_Y  = caseY - (case_lid_wall_thickness * 2);
case_lid_int_Z = 54.0;

case_bottom_ext_Z = 97;
case_bottom_wall_thickness = 11.0-1.5;
case_bottom_int_X  = caseX - (case_bottom_wall_thickness * 2);
case_bottom_int_Y  = caseY - (case_bottom_wall_thickness * 2) - 1;
case_bottom_int_Z = 89;

function caseX() = caseX;
function caseY() = caseY;
function caseZ() = caseZ;
function case_bottom_ext_Z() = case_bottom_ext_Z;
function case_bottom_int_X() = case_bottom_int_X;
function case_bottom_int_Y() = case_bottom_int_Y;
function case_bottom_int_Z() = case_bottom_int_Z;
function case_lid_ext_Z() = case_lid_ext_Z;
function case_lid_int_Z() = case_lid_int_Z;

module briefcase()
{
	echo(str("Item: Briefcase ",caseX(),"x",caseY(),"x",caseZ()));
	
	color("lightgray")
	render()
	{
		//top part
		translate([0,(case_lid_ext_Z/2)+(caseY/2),(caseY/2)+case_bottom_ext_Z/2])
		{
			rotate([90,0,0])
			{
				difference()
				{
					cube(size = [caseX, caseY, case_lid_ext_Z], center=true);
					translate([0,0,(case_lid_ext_Z-case_lid_int_Z)/2])
					{
						cube(size = [case_lid_int_X, case_lid_int_Y, case_lid_int_Z+0.1], center=true);
					}
				}
			}
		}
		//bottom part
		difference()
		{
			cube(size = [caseX, caseY, case_bottom_ext_Z], center=true);
			translate([0,0,(case_bottom_ext_Z-case_bottom_int_Z)/2])
			{
				cube(size = [case_bottom_int_X, case_bottom_int_Y, case_bottom_int_Z+0.1], center=true);
			}
		}
	}
}
