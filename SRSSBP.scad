/*
 * Model of a SRSS BP linear spline bearing for spline shaft
 * http://www.reliance.co.uk/shop/products.php?10282&cPath=656_657_658
 * 
 * This object is for display only. it is not printable
 * 
 * 
 */
use <MCAD/gears.scad>

$fn=50;

SRSSBP_6 = [6.35, 12.70, 19.1];
SRSSBP_10 = [9.53, 15.88, 25.4]; 

function SRSSBP10_length() = SRSSBP_10[2];
function SRSSBP10_dia() = SRSSBP_10[1];

module SRSSBP(size)
{
	if (size == 6)
	{
		color("DimGray", 1) _SRSSBP(SRSSBP_6[0], SRSSBP_6[1], SRSSBP_6[2]);
	}
	if (size == 10)
	{
		color("DimGray", 1) _SRSSBP(SRSSBP_10[0], SRSSBP_10[1], SRSSBP_10[2]);
	}
}

module _SRSSBP(shaft_dia, bushing_outside_dia, bushing_length)
{
	difference()
	{
		//the bearing
		cylinder(d=bushing_outside_dia, h=bushing_length, center=true);
		_SRSSBP_rod(shaft_dia, bushing_length+1);
	}
}

module SRSSBP_rod(size, length)
{
	if (size == 6)
	{
		color("DimGray", 1) _SRSSBP_rod(SRSSBP_6[0], length);
	}
	if (size == 10)
	{
		color("DimGray", 1) _SRSSBP_rod(SRSSBP_10[0], length);
	}
}

module _SRSSBP_rod(dia, length)
{
	//      Circular pitch: Length of the arc from one tooth to the next
	translate([0,0,-length/2])
		linear_extrude(length) gear(number_of_teeth=14,circular_pitch=((3.14*dia)/14)*50,pressure_angle=0,clearance = -dia/11);
	
	 //#translate([0,-dia/2,0]) cylinder(d=dia, h=length, centre=0); //my little alignment cylinder
}


//uncomment to display
SRSSBP(10);
SRSSBP_rod(10, 200);
//SRSSBP_rod(6, 200);
