/*
include <MCAD/bearing.scad>
include <MCAD/boxes.scad>
include <MCAD/constants.scad>
include <MCAD/curves.scad>
include <MCAD/gears.scad>
include <MCAD/gridbeam.scad>
include <MCAD/hardware.scad>
include <MCAD/involute_gears.scad>
include <MCAD/layouts.scad>
include <MCAD/libtriangles.scad>

include <MCAD/math.scad>
include <MCAD/metric_fastners.scad>
include <MCAD/motors.scad>
include <MCAD/nuts_and_bolts.scad>
include <MCAD/regular_shapes.scad>
include <MCAD/screw.scad>
include <MCAD/servos.scad>
include <MCAD/shapes.scad>
include <MCAD/stepper.scad>
include <MCAD/teardrop.scad>
include <MCAD/triangles.scad>
include <MCAD/units.scad>
include <MCAD/utilities.scad>
*/

include <MCAD/2Dshapes.scad>
include <MCAD/materials.scad>

include <suitcase.scad>
include <SK.scad>

/*
 * functions i should remember to use
 * roundedSquare
 * bearing
 * libtriangles
 * flat_nut
 * bolt
 * washer
 * nema
 * 
 */
 
 
 /* suitcase internal dimensions 460x330x160
  */
base_height = 5;
A4_width = 210;
A4_length = 297;
heated_bed_height = 3;

module base()
{
	color(FiberBoard)
	{
		linear_extrude(height = base_height) roundedSquare(pos=[case_lid_int_width-2,case_lid_int_depth-2], r=base_height);
	}
}

module rod_anchors()
{
	color(Aluminum)
	{
		for(i=[-1,1])
		{
			translate([0,(i*(A4_width/2)),0]){
				for(j=[-1,1])
				{
					 translate([150*j,0,0]) rotate([0,0,90]) SK(20);
				}
			}
		}
	}
}

module a4Bed()
{
	cube(size=[A4_length,A4_width,heated_bed_height], center=true);
}

module draw()
{
	//suitcase();
	translate([0,0,-base_height]) base();
	rod_anchors();
	a4Bed();
}
draw();
