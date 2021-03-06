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
use <gears.scad>
use <springs.scad>

$fn=50;
//			d	  d(b)      l(b)        thread d	  		 l(t)
SRSS__3 = [	3.18, 9.53, 	12.7, 2.41, (3/8)*25.4, 	24, 6.35];
SRSS__6 = [	6.35, 12.70, 	19.1, 5.13, (7/16)*25.4, 	20, 6.35];
SRSS__10 = [9.53, 15.88, 	25.4, 7.77, (9/16)*25.4, 	20, 9.53]; // 9⁄16 inch: 0.5625inch \ 14.2875mm

function SRSS_dia(size) 	= size == 3 ? SRSS__3[0] : size == 6 ? SRSS__6[0] : size == 10 ? SRSS__10[0] : undef;
function SRSS_length(size) 	= size == 3 ? SRSS__3[2] : size == 6 ? SRSS__6[2] : size == 10 ? SRSS__10[2] : undef;

module SRSSBP(size) //plain bushing no thread
{
	if (size == 3)
		_SRSSBP(SRSS__3);
	if (size == 6)
		_SRSSBP(SRSS__6);
	if (size == 10)
		_SRSSBP(SRSS__10);		
}

module SRSSBY(size) //plain bushing, with thread
{
	if (size == 3)
		_SRSSBY(SRSS__3);
	if (size == 6)
		_SRSSBY(SRSS__6);
	if (size == 10)
		_SRSSBY(SRSS__10);
}

module SRSSZP(size) //anti back lash nut, no thread
{
	if (size == 3)
		_SRSSZP(SRSS__3);
	if (size == 6)
		_SRSSZP(SRSS__6);
	if (size == 10)
		_SRSSZP(SRSS__10);
}

module SRSSZY(size) //antiback lash nut, with thread
{
	echo(str("Item: SRSSZY antibacklash bushing ",size,"mm diameter"));
	
	if (size == 3)
		_SRSSZY(SRSS__3);
	if (size == 6)
		_SRSSZY(SRSS__6);
	if (size == 10)
		_SRSSZY(SRSS__10);
}

module _SRSSBP(dims)
{
	shaft_dia = dims[0];
	bushing_outside_dia = dims[1];
	bushing_length = dims[2];
	root_diameter = dims[3];
	thread_bolt_dia = dims[4];
	threads_per_inch = dims[5];
	thread_length = dims[6];
	
	//plain bearing
	difference()
	{
		//the bearing
		translate([0, 0, -bushing_length/2]) //centre it in Z
		{
			union()
			{
				color("Goldenrod") render() cylinder(d=bushing_outside_dia, h=thread_length, center=false);
				translate([0,0,thread_length])
					color("DimGray", 1) render() cylinder(d=bushing_outside_dia, h=bushing_length-thread_length, center=false);
			}
		}
		
		//the bit where the rod goes
		_SRSS_rod(shaft_dia, bushing_length+1);
	}
}

module _SRSSBY(dims)
{
	shaft_dia = dims[0];
	bushing_outside_dia = dims[1];
	bushing_length = dims[2];
	root_diameter = dims[3];
	thread_bolt_dia = dims[4];
	threads_per_inch = dims[5];
	thread_length = dims[6];
	
	//plain bearing with thread
	difference()
	{
		//the bearing
		translate([0,0,thread_length/2-bushing_length/2]) //centre it in Z
		{
			union()
			{
				color("Goldenrod") thread(thread_bolt_dia, 0.5, thread_length, 25.4/threads_per_inch);
				translate([0,0,thread_length/2])
					color("DimGray", 1) render() cylinder(d=bushing_outside_dia, h=bushing_length-thread_length, center=false);
			}
		}
		_SRSS_rod(shaft_dia, bushing_length+1);
	}
}

module _SRSSZP(dims)
{
	shaft_dia = dims[0];
	bushing_outside_dia = dims[1];
	bushing_length = dims[2];
	root_diameter = dims[3];
	thread_bolt_dia = dims[4];
	threads_per_inch = dims[5];
	thread_length = dims[6];
	
	grip_height = bushing_length/8;
	backlash_height = bushing_length-thread_length-grip_height;
	backlash_flange_height = backlash_height/10;
	
	//anti backlash bearing
	translate([0,0,-bushing_length/2])
	{
		difference()
		{
			//the bearing
			union()
			{
				//brass bit
				color("Goldenrod") render() cylinder(d=bushing_outside_dia, h=thread_length, center=false);
				
				//top grippy bit
				translate([0,0,bushing_length-grip_height/2]) 
					difference()
					{
						color("DimGray") render() cylinder(d=bushing_outside_dia, h=grip_height, center=true);
						for(i=[0,90])
						{
							rotate([0,0,i]) cube(size=[bushing_outside_dia+3,3,6], center=true);
						}
					}
				
				//main plastic bit
				translate([0,0,backlash_height/2+thread_length])
				{	
					color("DimGray")
					render()
					difference()
					{
						//main bearing body
						cylinder(d=bushing_outside_dia, h=backlash_height, center=true);
						difference()
						{
							//-2 to create a flange of 1mm top and bottom
							cylinder(d=bushing_outside_dia+1, h=backlash_height-backlash_flange_height, center=true); 
							//-1mm spring guage
							cylinder(d=bushing_outside_dia-1, h=backlash_height, center=true);
						}
					}
					
					color("Silver") spring(bushing_outside_dia, 1, backlash_height-backlash_flange_height, backlash_height/1.5);
				}
			}
			
			//the bit where the rod goes
			_SRSS_rod(shaft_dia, 60);
		}
	}
}

module _SRSSZY(dims)
{
	shaft_dia = dims[0];
	bushing_outside_dia = dims[1];
	bushing_length = dims[2];
	root_diameter = dims[3];
	thread_bolt_dia = dims[4];
	threads_per_inch = dims[5];
	thread_length = dims[6];
	
	//anti backlash with thread
	grip_height = bushing_length/10;
	backlash_height = bushing_length-thread_length-grip_height;
	backlash_flange_height = backlash_height/8;
	
	translate([0,0,-bushing_length/2])
	{
		difference()
		{
			//the bearing
			union()
			{
				//top grippy bit
				translate([0,0,bushing_length-grip_height/2]) 
					difference()
					{
						color("DimGray") render() cylinder(d=bushing_outside_dia, h=grip_height, center=true);
						for(i=[0,90])
						{
							rotate([0,0,i]) cube(size=[bushing_outside_dia+3,3,6], center=true);
						}
					}
				
				//main plastic bit
				translate([0,0,backlash_height/2+thread_length])
				{	
					color("DimGray")
					render(convexity = 4)
					difference()
					{
						//main bearing body
						cylinder(d=bushing_outside_dia, h=backlash_height, center=true);
						difference()
						{
							//-2 to create a flange of 1mm top and bottom
							cylinder(d=bushing_outside_dia+1, h=backlash_height-backlash_flange_height, center=true); 
							//-1mm spring guage
							cylinder(d=bushing_outside_dia-1, h=backlash_height, center=true);
						}
					}
					
					color("Silver") spring(bushing_outside_dia, 1, backlash_height-backlash_flange_height, backlash_height/1.5);
				}
				
				//brass bit
				translate([0,0,thread_length/2]) color("Goldenrod") thread(thread_bolt_dia, 0.5, thread_length, 25.4/threads_per_inch);
				
			}
			
			//the bit where the rod goes
			_SRSS_rod(shaft_dia, 60);
		}
	}
}

module SRSS_rod(size, length)
{
	echo(str("Item: SRSS spline rod ",size,"mm diameter ",length,"mm length"));
	
	if (size == 3)
		color("DimGray", 1) _SRSS_rod(SRSS__3[0], length);
	if (size == 6)
		color("DimGray", 1) _SRSS_rod(SRSS__6[0], length);
	if (size == 10)
		color("DimGray", 1) _SRSS_rod(SRSS__10[0], length);
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
translate([55,55,0]) 	SRSSZY(6);
translate([66,66,0]) 	SRSSZY(3);
