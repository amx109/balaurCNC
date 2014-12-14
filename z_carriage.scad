use <SRSS__.scad>
use <LM__UU.scad>
use <LM__UUOP.scad>
use <MCAD/2Dshapes.scad>
use <pullies.scad>
use <ironmongery.scad>
/***
 * 
 *  Set this variable to false if you want a model that you can display.
 *  otherwise it will show the carriage in display format
 * 
 */
display = 1;

$fn=100;

bearing_gap = 10;
wall_thickness = 3;
rod_dia = 8;
rear_carriage_depth = 15; //measured from the axial centre of the smooth rod - hardwired to 21 in balaurCNC design - gives 1mm gap to bracing

translate([display? -50 : 0,display? -50 : -32, 0]) z_carriage(LM8_dia(), LM8_length(), 56);
z_carriage(LM8_dia(), LM8_length(), 56, motor_end=true);

module z_carriage(bearing_dia, bearing_length, Yaxis_seperation, motor_end=false)
{
	carriage_height = bearing_length*2 + bearing_gap + wall_thickness*2;
	carriage_width = bearing_dia + wall_thickness*2;
	
	Yaxis_pulley_offsetZ = 7.2;
	
	union()
	{
		difference()
		{
			//bearing holder + inserts
			union()
			{
				color("MediumSeaGreen") bearing_holder(carriage_width, carriage_height, bearing_dia);
				bearing_captive_inserts(bearing_dia, bearing_length, show_bearings = display?1:0);
			}
			
			if(motor_end) //bits to allow Y axis control
			{
				translate([14,-9,Yaxis_pulley_offsetZ])
				{
					translate([0,0, 0.5+SRSS__3_length()])
						cylinder(d=SRSS__3_dia()+2, h=SRSS__3_length()+2, $fn=50, center=true); //srss bushing
					translate([0,0,10.9]) cylinder(d=(9/16*25.4), h=6.35, $fn=50, center=true); 
					translate([0,0,0]) cylinder(d=13+1, h=15+2, $fn=50, center=true); //GT2_16
				} 
			}
			
			//translate([0,0,43]) cube(size=[30,40,50], center=true); //allows me to check bearing holder cross section
		}
		
		difference() //need to make those bolt holes somehow..
		{
			union()
			{
				//Y axis rod holders
				for(i=[0,1]) 
				{
					mirror([i,0,0])
					{
						translate([Yaxis_seperation/2,0,-carriage_height/2])
						{
							rail_holders(LM8OP_dia(), LM8OP_length(), Yaxis_seperation);
						}
					}
				}
				
				//fillet LHS
				difference()
				{
					fillets(Yaxis_seperation, carriage_width, carriage_height);
					if(motor_end)
					{
						translate([14,-9,-32]) cylinder(d=3.5, h=80, $fn=50, center=true); //srss rod axle
						translate([14,-9,Yaxis_pulley_offsetZ]) cylinder(d=13+1, h=15+2, $fn=50, center=true); //GT2_16
					}
				}
				
				//fillet RHS
				mirror([1,0,0]) fillets(Yaxis_seperation, carriage_width, carriage_height);
			}
			
			//holes for the bolts
			for(i=[1,-1])
				for(j=[1,-1])
					translate([Yaxis_seperation/2*i+Yaxis_seperation/7*j,-rear_carriage_depth+3.33,-20]) linear_rod(3, 30);
		}
		
		//clamp bolts for show
		if(display)
		{
			for(i=[1,-1])
				translate([(motor_end ? -1 : 1)*Yaxis_seperation/2-Yaxis_seperation/7*i,-rear_carriage_depth+3.33,-carriage_height/2])
				{
					translate([0,0,24]) bolt(3, 29, 0);
					translate([0,0,-1]) nut(3);
				}
			translate([(motor_end ? 1 : -1)*Yaxis_seperation/2-(motor_end ? 1 : -1)*Yaxis_seperation/7,-rear_carriage_depth+3.33,-carriage_height/2])
			{
				translate([0,0,motor_end ? 26.7 : 23.7]) bolt(3, motor_end ? 32 : 29, 0);
				translate([0,0,-1]) nut(3);
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
			//bulk for use as anchor for y axis holders
			//translate([0, (carriage_width/3)/2-rear_carriage_depth, 0])
				//cube(size=[carriage_width, carriage_width/3, carriage_height], center=true);
			translate([0, (carriage_width/3)/2-rear_carriage_depth, -carriage_height/2])
			{
				linear_extrude(height=carriage_height) roundedSquare(pos=[carriage_width,carriage_width/3],r=3);
				
			}
				
			
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

module bearing_captive_inserts(bearing_dia, bearing_length, show_bearings=false)
{
	for(i=[1,-1])
	{
		color("MediumSeaGreen")
		translate([0,-bearing_dia/2,(bearing_gap/2-wall_thickness/2)*i])
		{
			cube(size=[bearing_dia,bearing_dia/4,wall_thickness], center=true);
			translate([0,0,(bearing_length+wall_thickness)*i])
				cube(size=[bearing_dia,bearing_dia/4,wall_thickness], center=true);
		}
		
		if(show_bearings)
		{
				translate([0,0,(bearing_length/2+bearing_gap/2)*i]) LM(rod_dia);
		}
	}
}

module rail_holders(bearing_dia, bearing_length, Yaxis_seperation)
{
	//re-compute all the things!
	carriage_height = bearing_length*2 + bearing_gap + wall_thickness*2;
	carriage_width = bearing_dia + wall_thickness*2;
	
	//the lower block
	color("MediumSeaGreen")
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
	}
	
	//clampy bits for the Y axis rod
	translate([	0,
				display? 6.5/2-rear_carriage_depth : 11,
				display? carriage_height/4.5 : -0.5])
	{
		color("MediumSeaGreen")
		difference()
		{
			//main block
			translate([0,0,0.5])
				linear_extrude(height=9) roundedSquare(pos=[Yaxis_seperation/2.5,6.5],r=3);
			//where the rod goes
			rotate([90,0,0])
				cylinder(r=rod_dia/2, h=40, center=true, $fn=50);
			//bolt holes (M3)
			for(j=[1,-1])
				translate([Yaxis_seperation/7*j,0,0]) linear_rod(3,100);
		}
	}
}

module z_threaded_rod_link()
{
}

module fillets(Yaxis_seperation, carriage_width, carriage_height)
{
	bearing_dia = carriage_width - wall_thickness*2;
	
	//big big fillet. mega fillet
	color("MediumSeaGreen")
	union()
	{
		difference()
		{
			//width of fillet should be muliple of yaxis_sep, yet distance from origin should relate to carriage width
			translate([	Yaxis_seperation/(6*2)+carriage_width/2-0.1-3/2, 
						(carriage_width/1.21)/2-rear_carriage_depth,
						-carriage_height/4])
				cube(size=[Yaxis_seperation/6+3,
							carriage_width/1.21,
							carriage_height/2], 
							center=true);
			
			//rear most fillet
			translate([carriage_height*0.5/2+carriage_width/2, -11.9, 0])
				rotate([90,0,0])
					cylinder(h=7, d=carriage_height*0.5, center=true, $fn=100);
					
			//front shallow fillet
			translate([carriage_height*1.1/2+carriage_width/2, 6.5, 0])
				rotate([90,0,0])
					cylinder(h=30, d=carriage_height*1.1, center=true, $fn=100);
					
			//vertical curved fillet that meets the bearing holder
			translate([carriage_width/2+(Yaxis_seperation/2-(Yaxis_seperation/2.5)/2-carriage_width/2)+0.2-20/2-0.1,
				-rear_carriage_depth+rear_carriage_depth+bearing_dia/4,
				40/2-carriage_height/2-0.1])
				cylinder(h=40, d=20, center=true, $fn=100);
		
			//make way for the clampy bits for the Y axis rod
			translate([	Yaxis_seperation/2,
						6.5/2-rear_carriage_depth,
						-carriage_height/2+carriage_height/4.5-1])
					translate([0,0,0.5]) linear_extrude(height=9) roundedSquare(pos=[Yaxis_seperation/2.5+0.5,6.5+0.5],r=3);
		}
	}
}
