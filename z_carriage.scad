use <LM__UU.scad>
use <LM__UUOP.scad>
use <ironmongery.scad>
/***
 * 
 *  Set this variable to false if you want a model that you can display.
 *  otherwise it will show the carriage in display format
 * 
 */
display = 1;

$fn=50;

bearing_gap = 10;
wall_thickness = 2.3;
front_carriage_depth = 19.5; //measured from the axial centre of the smooth rod - hardwired in balaurCNC design - i made this number up (its the only explanation)

z_carriage("LM8", 56);
translate([display? -50 : 0, display? -50 : -35, 0]) z_carriage("LM8", 56);

module z_carriage(bearing_type, Yaxis_seperation)
{
	echo(str("*************** Z Carriage *******************"));
	echo(str("Item: Z Carriage"));
	
	bearing_dia = LM_dia(bearing_type);
	bearing_length = LM_length(bearing_type);
	rod_dia = LM_rod_dia(bearing_type);
	carriage_height = bearing_length*2 + bearing_gap + wall_thickness*2;
	carriage_width = bearing_dia + wall_thickness*2;
	
	difference()
	{
		//bearing holder + inserts + y rod holder + fillets
		color("MediumSeaGreen")
		//render()
		union()
		{
			bearing_holder(carriage_width, carriage_height, bearing_dia);
			bearing_captive_inserts(bearing_dia, bearing_length, show_bearings = display?1:0);
			
			//Y axis rail holders
			color("blue")
			for(i=[0,1]) 
				mirror([i,0,0])
					translate([Yaxis_seperation/2, front_carriage_depth-(front_carriage_depth+bearing_dia/2)/2, -carriage_height/2])
						rail_holders(bearing_type, Yaxis_seperation);
			
			color("pink")
			{
				fillets(Yaxis_seperation, carriage_width, carriage_height); //fillet LHS
				mirror([1,0,0]) fillets(Yaxis_seperation, carriage_width, carriage_height); //fillet RHS
			}
		}
		
		//z threaded rod + nut
		translate([0,front_carriage_depth-4.5,0]) //Y=15
		{
			cylinder(d=7.5, h=80, $fn=50, center=true);
			translate([0,0,carriage_height/2])
				cylinder(d=6*1.9, h=6*0.8, $fn=6, center=true); //nut(6, flat=true);
		}
		
		//holes for the bolts to hold y rails
		for(i=[1,-1])
			for(j=[1,-1])
				translate([Yaxis_seperation/2*i+Yaxis_seperation/7*j, -bearing_dia/2+3.33, -20])
					cylinder(d=3, h=30, $fn=50, center=true);
		
		//translate([0,0,45]) cube(size=[30,40,50], center=true); //allows me to check bearing holder cross section
	}
	
	//clamp bolts + nut for show
	*if(display)
	{
		translate([0,front_carriage_depth-4.5,carriage_height/2])
			nut(6, flat=true);
		
		for(i=[1,-1])
		{
			translate([Yaxis_seperation/2-Yaxis_seperation/7*i, -bearing_dia/2+3.33, -carriage_height/2])
			{
				translate([0,0,24]) bolt(3, 29, 0);
				translate([0,0,-1]) nut(3);
			}
			translate([0, 0, (bearing_length/2+bearing_gap/2-0.25)*i]) LM(rod_dia);
		}
		
		
		translate([	-Yaxis_seperation/2+Yaxis_seperation/7,
					-bearing_dia/2+3.33,-carriage_height/2])
		{
			translate([0,0,23.7]) bolt(3, 29, 0);
			translate([0,0,-1]) nut(3);
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
			//bulk for use as anchor for Z nut+threaded rod
			translate([0, front_carriage_depth-carriage_width/(3*2), 0])
				cube(size=[carriage_width, carriage_width/3, carriage_height], center=true);
			
			//bearing holder
			cylinder(d=carriage_width, h=carriage_height, center=true, $fn=50);
		}
		
		//space for bearings
		cylinder(d=bearing_dia, h=carriage_height+5, center=true, $fn=50);
		
		//cut out for bearing holder
		translate([0,-carriage_width/1.7,0])
			rotate([0,0,45])
				cube(size=[carriage_width,carriage_width,carriage_height+5], center=true);
	}
	*translate([0,-25-carriage_width/2+wall_thickness,0]) cube(size=[50,50,50], center=true);
}

module bearing_captive_inserts(bearing_dia, bearing_length, show_bearings=false)
{
	spacer = 0.25;
	for(i=[1,-1])
	{
		translate([0, bearing_dia/2, (bearing_gap/2-wall_thickness/2)*i])
		{
			translate([0,0,i*-spacer*2]) cube(size=[bearing_dia, bearing_dia/4, wall_thickness], center=true);
			translate([0, 0, (bearing_length+wall_thickness)*i])
				cube(size=[bearing_dia, bearing_dia/4 ,wall_thickness], center=true);
		}
	}
}

module rail_holders(bearing_type, Yaxis_seperation)
{
	//re-compute all the things!
	bearing_dia = LM_dia(bearing_type);
	bearing_length = LM_length(bearing_type);
	rod_dia = LM_rod_dia(bearing_type);
	carriage_height = bearing_length*2 + bearing_gap + wall_thickness*2;
	carriage_width = bearing_dia + wall_thickness*2;
	
	//the lower block
	difference()
	{
		//main block
		translate([0,0.00295,carriage_height/4.5/2])
			roundRect([Yaxis_seperation/2.5, front_carriage_depth+bearing_dia/2, carriage_height/4.5], 3);
			//cube(size=[Yaxis_seperation/2.5, front_carriage_depth+bearing_dia/2, carriage_height/4.5], center=true);
		
		//where the rods sit
		translate([0,0,carriage_height/4.5])
		{
			rotate([90,0,0])
				cylinder(r=rod_dia/2, h=40, center=true, $fn=50);
		
			//the bit with the bearings+carriage on top
			translate([0,6.5,0])
			{
				union()
				{
					//where ze bearing goes
					translate([0, -((front_carriage_depth+bearing_dia/2)-bearing_length)/2, 0]) 
						rotate([90,0,0])
							LMOP_oversize(bearing_type);
					//side bits
					for(k=[1,-1])
						translate([10.74*k, 0, -0.971])
							cube(size=[Yaxis_seperation/5, front_carriage_depth+bearing_dia/2, carriage_height/7], center=true);
					
					//top bit where the rod is because openscad
					translate([0,0,2.219])
						cube(size=[Yaxis_seperation/5, front_carriage_depth+bearing_dia/2, carriage_height/7], center=true);
				}
			}
		}
	}
	
	//clampy bits for the Y axis rod
	translate([	0,
				display? 6.5/2-(front_carriage_depth+bearing_dia/2)/2 : 17.5,
				display? carriage_height/4.5 : -0.5])
	{
		difference()
		{
			//main block
			translate([0,0,0.5+9/2])
				//linear_extrude(height=9) roundedSquare(pos=[Yaxis_seperation/2.5, 6.5],r=3);
				roundRect([Yaxis_seperation/2.5, 6.5, 9], 3);
			//where the rod goes
			rotate([90,0,0])
				cylinder(r=rod_dia/2, h=40, center=true, $fn=50);
			//bolt holes (M3)
			for(j=[1,-1])
				translate([Yaxis_seperation/7*j, 0.08, 0]) cylinder(d=3, h=100, $fn=50, center=true);
		}
	}
}

module fillets(Yaxis_seperation, carriage_width, carriage_height)
{
	bearing_dia = carriage_width - wall_thickness*2;
	
	//big big fillet. mega fillet
	
	difference()
	{
		//width of fillet should be muliple of yaxis_sep, yet distance from origin should relate to carriage width
		translate([	Yaxis_seperation/(6*2)+carriage_width/2-0.1-3/2,
					front_carriage_depth-(front_carriage_depth+bearing_dia/2)/2,
					-carriage_height/4])
			cube(size=[Yaxis_seperation/6+5,
						front_carriage_depth+bearing_dia/2,
						carriage_height/2], 
						center=true);
		
		//rear most fillet
		translate([Yaxis_seperation/2-(Yaxis_seperation/2.5)/2+1+3, -7/2-bearing_dia/2+6.52, -carriage_height/2+carriage_height/4.5+carriage_height*(0.5/2)-0.55])
			rotate([90,0,0])
				cylinder(h=7, d=carriage_height*0.5, center=true, $fn=100);
		
		//front shallow fillet to make sure no clash with bearing
		translate([(carriage_height*1.1)/2+carriage_width/2, 30/2-1, 0])
			rotate([90,0,0])
				cylinder(h=30, d=carriage_height*1.1, center=true, $fn=100);
		
		//vertical curved fillet that meets the bearing holder
		translate([	Yaxis_seperation/2-(Yaxis_seperation/2.5)/2 - (front_carriage_depth+bearing_dia/2+3)/2,
					-bearing_dia/2,
					40/2-carriage_height/2-0.1])
			cylinder(h=40, d=front_carriage_depth+bearing_dia/2+3, center=true, $fn=100);
		
		//make way for the clampy bits for the Y axis rod
		translate([Yaxis_seperation/2,
					6.5/2-front_carriage_depth,
					-carriage_height/2+carriage_height/4.5-1])
				//translate([0,0,0.5]) linear_extrude(height=9) roundedSquare(pos=[Yaxis_seperation/2.5+0.5,6.5+0.5],r=3);
				translate([0,0,0.5+9/2]) roundRect([Yaxis_seperation/2.5+0.5,6.5+0.5, 9], 3);
	}
}


