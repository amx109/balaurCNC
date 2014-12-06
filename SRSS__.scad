/*
 * Model of a SRSS BP linear spline bearing for spline shaft
 * http://www.reliance.co.uk/shop/products.php?10282&cPath=656_657_658
 * 
 * which is actually a rebadged http://www.haydonkerk.com/LinearActuatorProducts/LinearRails,GuidesSplines/SplinesandLinearGuides/SSSZSplinesGRRails/tabid/264/Default.aspx#PNDiv
 * 
 * This object is for display only. it is not printable
 * 
 * 
 */
use <MCAD/gears.scad>
use <springs.scad>

$fn=50;

SRSS__6 = [6.35, 12.70, 19.1, 5.13, (7/16)*25.4, 20, 6.35];
SRSS__10 = [9.53, 15.88, 25.4, 7.77, (9/16)*25.4, 20, 9.53];

function SRSS__10_length() = SRSS__10[2];
function SRSS__10_dia() = SRSS__10[1];

module SRSSBP(size)
{
	if (size == 6)
	{
		_SRSSBP(SRSS__6[0], SRSS__6[1], SRSS__6[2], SRSS__6[3], SRSS__6[4], SRSS__6[5], SRSS__6[6]);
	}
	if (size == 10)
	{
		_SRSSBP(SRSS__10[0], SRSS__10[1], SRSS__10[2], SRSS__10[3], SRSS__10[4], SRSS__10[5], SRSS__10[6]);
	}
}

module SRSSBY(size)
{
	if (size == 6)
	{
		_SRSSBY(SRSS__6[0], SRSS__6[1], SRSS__6[2], SRSS__6[3], SRSS__6[4], SRSS__6[5], SRSS__6[6]);
	}
	if (size == 10)
	{
		_SRSSBY(SRSS__10[0], SRSS__10[1], SRSS__10[2], SRSS__10[3], SRSS__10[4], SRSS__10[5], SRSS__10[6]);
	}
}

module SRSSZP(size)
{
	if (size == 6)
	{
		_SRSSZP(SRSS__6[0], SRSS__6[1], SRSS__6[2], SRSS__6[3], SRSS__6[4], SRSS__6[5], SRSS__6[6]);
	}
	if (size == 10)
	{
		_SRSSZP(SRSS__10[0], SRSS__10[1], SRSS__10[2], SRSS__10[3], SRSS__10[4], SRSS__10[5], SRSS__10[6]);
	}
}

module SRSSZY(size)
{
	if (size == 6)
	{
		_SRSSZY(SRSS__6[0], SRSS__6[1], SRSS__6[2], SRSS__6[3], SRSS__6[4], SRSS__6[5], SRSS__6[6]);
	}
	if (size == 10)
	{
		_SRSSZY(SRSS__10[0], SRSS__10[1], SRSS__10[2], SRSS__10[3], SRSS__10[4], SRSS__10[5], SRSS__10[6]);
	}
}

module _SRSSBP(shaft_dia, bushing_outside_dia, bushing_length, root_diameter, thread_bolt_dia, threads_per_inch, thread_length)
{
	//plain bearing
	difference()
	{
		//the bearing
		translate([0,0,-bushing_length/2]) //centre it in Z
		{
			union()
			{
				color("Goldenrod") cylinder(d=bushing_outside_dia, h=thread_length, center=false);
				translate([0,0,thread_length])
					color("DimGray", 1) cylinder(d=bushing_outside_dia, h=bushing_length-thread_length, center=false);
			}
		}
		
		//the bit where the rod goes
		_SRSS_rod(shaft_dia, bushing_length+1);
	}
}

module _SRSSBY(shaft_dia, bushing_outside_dia, bushing_length, root_diameter, thread_bolt_dia, threads_per_inch, thread_length)
{
	//plain bearing with thread
	difference()
	{
		//the bearing
		translate([0,0,thread_length/2-bushing_length/2]) //centre it in Z
		{
			union()
			{
				//color("Goldenrod") cylinder(d=bushing_outside_dia, h=thread_length, center=false);
				color("Goldenrod") thread(thread_bolt_dia, 0.5, thread_length, 25.4/threads_per_inch);
				translate([0,0,thread_length/2])
					color("DimGray", 1) cylinder(d=bushing_outside_dia, h=bushing_length-thread_length, center=false);
			}
		}
		_SRSS_rod(shaft_dia, bushing_length+1);
	}
}

module _SRSSZP(shaft_dia, bushing_outside_dia, bushing_length, root_diameter, thread_bolt_dia, threads_per_inch, thread_length)
{
	backlash_height = bushing_length-thread_length-3;
	backlash_flange_height = 4;
	
	//anti backlash bearing
	translate([0,0,-bushing_length/2])
	{
		difference()
		{
			//the bearing
			union()
			{
				//brass bit
				color("Goldenrod") cylinder(d=bushing_outside_dia, h=thread_length, center=false);
				
				//top grippy bit
				translate([0,0,3/2+bushing_length-3]) 
					difference()
					{
						color("DimGray") cylinder(d=bushing_outside_dia, h=3, center=true);
						for(i=[0,90])
						{
							rotate([0,0,i]) cube(size=[bushing_outside_dia+3,3,6], center=true);
						}
					}
				
				//main plastic bit
				translate([0,0,backlash_height/2+thread_length])
				{	
					color("DimGray")
					difference()
					{
						//main bearing body
						cylinder(d=bushing_outside_dia, h=backlash_height, center=true);
						difference()
						{
							//-2 to create a flange of 1mm top and bottom
							cylinder(d=bushing_outside_dia+1, h=backlash_height-backlash_flange_height, center=true); 
							//-1mm spring guage
							cylinder(d=bushing_outside_dia-1, h=backlash_height-1, center=true);
						}
					}
					
					color("Silver") spring(bushing_outside_dia, 1, backlash_height-backlash_flange_height, 5);
				}
			}
			
			//the bit where the rod goes
			_SRSS_rod(shaft_dia, 60);
		}
	}
}

module _SRSSZY(shaft_dia, bushing_outside_dia, bushing_length, root_diameter, thread_bolt_dia, threads_per_inch, thread_length)
{
	//anti backlash with thread
	backlash_height = bushing_length-thread_length-3;
	backlash_flange_height = 4;
	
	translate([0,0,-bushing_length/2])
	{
		difference()
		{
			//the bearing
			union()
			{
				//brass bit
				translate([0,0,thread_length/2]) color("Goldenrod") thread(thread_bolt_dia, 0.5, thread_length, 25.4/threads_per_inch);
				
				//top grippy bit
				translate([0,0,3/2+bushing_length-3]) 
					difference()
					{
						color("DimGray") cylinder(d=bushing_outside_dia, h=3, center=true);
						for(i=[0,90])
						{
							rotate([0,0,i]) cube(size=[bushing_outside_dia+3,3,6], center=true);
						}
					}
				
				//main plastic bit
				translate([0,0,backlash_height/2+thread_length])
				{	
					color("DimGray")
					difference()
					{
						//main bearing body
						cylinder(d=bushing_outside_dia, h=backlash_height, center=true);
						difference()
						{
							//-2 to create a flange of 1mm top and bottom
							cylinder(d=bushing_outside_dia+1, h=backlash_height-backlash_flange_height, center=true); 
							//-1mm spring guage
							cylinder(d=bushing_outside_dia-1, h=backlash_height-1, center=true);
						}
					}
					
					color("Silver") spring(bushing_outside_dia, 1, backlash_height-backlash_flange_height, 5);
				}
			}
			
			//the bit where the rod goes
			_SRSS_rod(shaft_dia, 60);
		}
	}
}

module SRSS_rod(size, length)
{
	if (size == 6)
	{
		color("DimGray", 1) _SRSS_rod(SRSS__6[0], length);
	}
	if (size == 10)
	{
		color("DimGray", 1) _SRSS_rod(SRSS__10[0], length);
	}
}

module _SRSS_rod(dia, length)
{
	//Circular pitch: Length of the arc from one tooth to the next
	translate([0,0,-length/2])
		linear_extrude(length) gear(number_of_teeth=14,circular_pitch=((3.14*dia)/14)*50,pressure_angle=0,clearance = -dia/11);
	
	//#translate([0,-dia/2,0]) cylinder(d=dia, h=length, centre=0); //my little alignment cylinder
}

//uncomment to display
translate([0,0,0]) 		SRSS_rod(10, 100);
translate([40,-40,0]) 	SRSSBP(10);
translate([-40,-40,0]) 	SRSSBY(10);
translate([-40,40,0]) 	SRSSZP(10);
translate([40,40,0]) 	SRSSZY(10);
