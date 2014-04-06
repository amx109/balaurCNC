/*
 * Model of a SKXX round rod linear slide supprt
 * 
 * 
 * This object is for display only. it is not printable (base and top need to be made to overlap)
 * 
 * currently only has info to produce SK20 supports 
 */

include <MCAD/nuts_and_bolts.scad>

M6 = 6;
$fn=50;

module SK(size)
{
	if (size == 20)
	{
		_SK(20, 31, 30, 60, 20, 51, 10, 30, 45, 6.6, M6, M6);
	}
}

module _SK(d, h, E, W, L, F, G, P, B, S, clamping_bolt, mounting_bolts)
{
	union()
	{
		//base
		difference()
		{
			translate([0,0,G/2]) cube(size=[W, L, G], center=true); //base block
			//mounting holes
			for(i=[-1,1])
			{
				translate([i*(B/2),0,(G+0.5)]) rotate([180,0,0]) boltHole(size=mounting_bolts, length=G+1);
			}
		}
		
		//top
		difference()
		{
			translate([0,0,F/2+G/2]) cube(size=[P, L, F-G], center=true);
			translate([0,0,h+G/2]) rotate([90,0,0]) cylinder(r=d/2, h=L+1, center=true);
		}
	}
}

//uncomment to display
//SK(20);
