use <SRSSBP.scad>
use <LM__UU.scad>
use <LM__UUOP.scad>
use <MCAD/2Dshapes.scad>
use <MCAD/metric_fastners.scad>

/***
 * 
 *  Set this variable to true if you want a model that you can print.
 *  otherwise it will show the carriage in display format
 * 
 */
print = false;

$fn=100;

bearing_gap = 10;
wall_thickness = 3;
rod_dia = 8;
rear_carriage_depth = 15; //measured from the axial centre of the smooth rod - hardwired to 21 in balaurCNC design - gives 1mm gap to bracing

z_carriage(LM8_dia(), LM8_length(), 56);

module z_carriage(bearing_dia, bearing_length, Yaxis_seperation, spline=false)
{
	carriage_height = bearing_length*2 + bearing_gap + wall_thickness*2;
	carriage_width = bearing_dia + wall_thickness*2;
	
	union()
	{
		bearing_holder(carriage_width, carriage_height, bearing_dia);
		bearing_captive_inserts(bearing_dia, bearing_length, show_bearings = print?0:1);
		
		for(i=[0,1]) 
		{
			mirror([i,0,0])
			{
				//Y axis rod holders
				translate([Yaxis_seperation/2,0,-carriage_height/2])
				{
					rail_holders(bearing_dia, bearing_length, Yaxis_seperation);
				}
				
				difference()
				{
					union()
					{
						translate([Yaxis_seperation/10+carriage_width/2-0.1, 0,0])
						{
							//vertical fillet
							difference()
							{
								//width of fillet should be muliple of yaxis_sep, yet distance from origin should relate to carriage width
								translate([	0,
											(carriage_width/1.21)/2-rear_carriage_depth,
											-carriage_height/4])
									cube(size=[	Yaxis_seperation/5,
												carriage_width/1.21,
												carriage_height/2], 
												center=true);
								
								translate([60/2-Yaxis_seperation/10,0,0])
									rotate([90,0,0])
										cylinder(h=40, d=60, center=true, $fn=100);
							}
						}
						
						//side fillet
						translate([	Yaxis_seperation/(8.6*2)+carriage_width/2-0.1, 
									(rear_carriage_depth+bearing_dia/4)/2-rear_carriage_depth, 
									carriage_height/18-carriage_height/2])
						{
							cube(size=[Yaxis_seperation/8.6,
										rear_carriage_depth+bearing_dia/4,
										carriage_height/9], 
										center=true);
						}
					}
					
					translate([	-20/2+(Yaxis_seperation/(8.6*2)+carriage_width/2-0.1)+(Yaxis_seperation/(8.6*2)),
								-rear_carriage_depth+rear_carriage_depth+bearing_dia/4,
								40/2-carriage_height/2-0.1])
						cylinder(h=40, d=20, center=true, $fn=100);						
				}
				
			}
		}
		//link to Z axis threaded rod
	}
}

module bearing_captive_inserts(bearing_dia, bearing_length, show_bearings=false)
{
	for(i=[1,-1])
	{
		translate([0,-bearing_dia/2+1,(bearing_gap/2-wall_thickness/2)*i])
		{
			cube(size=[bearing_dia,bearing_dia/4,wall_thickness], center=true);
			translate([0,0,(bearing_length+wall_thickness)*i])
				cube(size=[bearing_dia,bearing_dia/4,wall_thickness], center=true);
		}
		
		if(show_bearings)
		{
			color("Silver")
			{
				translate([0,0,(bearing_length/2+bearing_gap/2)*i])
				LM(rod_dia);
			}
		}
	
	}
}

module bearing_holder(carriage_width, carriage_height, bearing_dia)
{
	//main vertical body of the carriage for the bearings
	difference()
	{
		hull()
		{
			//bulk for use as anchor for x axis holders
			translate([0,(carriage_width/3)/2-rear_carriage_depth,0])
				cube(size=[carriage_width,carriage_width/3,carriage_height], center=true);
			
			//bearing holder
			cylinder(d=carriage_width, h=carriage_height, center=true);
		}
		
		//space for bearings
		translate([0,0,-0.5])
			cylinder(d=bearing_dia, h=carriage_height+5, center=true);
		
		//cut out for bearing holder
		translate([0,carriage_width/1.7,0])
			rotate([0,0,45])
				cube(size=[carriage_width,carriage_width,carriage_height+5], center=true);
	}
}

module rail_holders(bearing_dia, bearing_length, Yaxis_seperation)
{
	//re-compute all the things!
	carriage_height = bearing_length*2 + bearing_gap + wall_thickness*2;
	carriage_width = bearing_dia + wall_thickness*2;
	
	//the lower block
	difference()
	{
		//main block
		translate([0,carriage_width/2-rear_carriage_depth,0])
			linear_extrude(height=carriage_height/4.5) roundedSquare(pos=[Yaxis_seperation/2.5,carriage_width],r=3);
		
		//where the rods sit
		translate([0,0,carriage_height/4.5])
		{
			rotate([90,0,0])
				cylinder(r=rod_dia/2, h=40, center=true, $fn=50);
		
			//the bit with the bearings+carriage on top
			translate([0,3.5,0])
			{
				union()
				{
					//where ze bearing goes
					rotate([90,0,0])
						LMOP_oversize(bearing_dia);
					//side bits
					for(k=[1,-1])
					{
						translate([10.74*k,0,-0.871]) cube(size=[Yaxis_seperation/5,bearing_length,carriage_height/7], center=true);
					}
					//top bit where the rod is because openscad
					translate([0,0,2.319]) cube(size=[Yaxis_seperation/5,bearing_length,carriage_height/7], center=true);
				}
			}
		}
		
		//bolt holes
		for(j=[1,-1])
			translate([Yaxis_seperation/7*j,-rear_carriage_depth+3.33,23]) rotate([0,180,0]) bolt(3,40);
	}
	
	//clampy bits for the Y axis rod
	translate([	0,
				print? 10 : 6.5/2-rear_carriage_depth,
				print? -0.5 : carriage_height/4.5])
	{
		difference()
		{
			//main block
			translate([0,0,0.5]) linear_extrude(height=9) roundedSquare(pos=[Yaxis_seperation/2.5,6.5],r=2);
			//where the rod goes
			rotate([90,0,0])
				cylinder(r=rod_dia/2, h=40, center=true, $fn=50);
			//bolt holes (M3)
			for(j=[1,-1])
				translate([Yaxis_seperation/7*j,0,20]) rotate([0,180,0]) bolt(3,40);
		}
	}
	
	//bolts for show
	if(!print)
	{
		for(j=[1,-1])
				color("Silver") translate([Yaxis_seperation/7*j,-rear_carriage_depth+3,26]) rotate([0,180,0]) bolt(3,40);
	}	
}
