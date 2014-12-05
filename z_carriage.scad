use <SRSSBP.scad>
use <LM__UU.scad>
use <LM__UUOP.scad>
use <MCAD/2Dshapes.scad>
use <MCAD/metric_fastners.scad>
//use <MCAD/materials.scad> //colours+material types

$fn=100;

module z_carriage(bearing_width, bearing_length, Yaxis_seperation, spline=false)
{
	wall_thickness = 3; //thickness
	bearing_gap = 10;
	
	carriage_height = bearing_length*2 + bearing_gap + wall_thickness*2;
	carriage_width = bearing_width + wall_thickness*2;
	
	//bearings
	color(Steel)
	{
		translate([0,0,-(LM8_length()/2)-(bearing_gap/2)])
		{
			LM(8);
			translate([0,0, LM8_length()+bearing_gap]) LM(8);
		}
	}
	
	union()
	{
		bearing_holder(carriage_width, carriage_height);
		
		//captive inserts for the bearings
		translate([0,((LM8_dia()*0.2)/2)-(LM8_dia()/2)-0.5,0])
		{
			translate([0,0,(carriage_height/2)-(wall_thickness/2)])
				cube(size=[carriage_width/1.5,LM8_dia()*0.2,wall_thickness], center=true);
			for(i=[0,1])
			{
				mirror([0,0,i])
				{
					translate([0,0,bearing_gap/2-(wall_thickness/2)-0.2]) // 0.2mm is fudge factor to allow a relaxed-er push fit for the bearing
						cube(size=[carriage_width/1.5,LM8_dia()*0.2,wall_thickness], center=true);
				}
			}
			translate([0,0,-(carriage_height/2)+(wall_thickness/2)])
				cube(size=[carriage_width/1.5,LM8_dia()*0.2,wall_thickness], center=true);
		}
		
		//bridge to join Y axis rod holders
		translate([	0,
					-LM8_dia()+6.5/2,
					-carriage_height/2+carriage_width/3])
			cube(size=[carriage_width*1.66,
						6.5,
						carriage_width/1.5], 
						
						center=true);
		
		//Y axis rod holders
		for(i=[0,1]) 
		{
			mirror([i,0,0])
			{
				translate([Yaxis_seperation/2,-carriage_width/14-1,-carriage_height/2])
				{
					difference()
					{
						//main block
						translate([0,0,0])
							linear_extrude(height=carriage_width/1.5) roundedSquare(pos=[carriage_width+4,carriage_width+4],r=2);
						
						//some stuff to exclude bits around where the carriage will move
						translate([5.14,-6,LM8OP_dia()/2+1]) 		cube(size=[8,20,LM8OP_dia()/2], center=false);
						translate([-13.14,-6,LM8OP_dia()/2+1]) 		cube(size=[8,20,LM8OP_dia()/2], center=false);
						translate([-5,-6,carriage_width/1.5-2.255]) cube(size=[10,20,5], center=false);
						
						//where the rods sit
						translate([0,0,carriage_width/1.5])
							rotate([90,0,0])
								cylinder(r=8/2, h=40, center=true, $fn=50);
								
						//where the bearings+carriage on top will go
						translate([0,6,carriage_width/1.5])
							rotate([90,0,0])
								LMOP_oversize(8);
						
						for(j=[1,-1])
							translate([9*j,-carriage_width/2+1.2,23]) rotate([0,180,0]) bolt(3,40);
					}
					
					//fillets
					difference()
					{
						translate([-carriage_width/2-3.6,2-0.1,8.5/2])
							cube(size=[7,carriage_width-4,8.5], center=true);
						translate([-carriage_width/2-26.9,13,-0.1])
							cylinder(h=9, d=50.1, $fn=100);
					}
					
					difference()
					{
						translate([-carriage_width/2-5.6, -7-0.375, carriage_width/1.5+20/2-5.1])
							cube(size=[11,10.25,30], center=true);
						
						translate([-carriage_width/2+43.5,10.5,34])
							rotate([90,0,0])
								cylinder(h=40, d=101, $fn=100);
					}
					
					//clampy bits for the Y axis rod
					translate([0,-carriage_width/2+1,carriage_width/1.5])
					{
						difference()
						{
							//main block
							
							translate([0,0.25,0.3]) linear_extrude(height=9.7) roundedSquare(pos=[carriage_width+4,6.5],r=2);
							//where the rod goes
							rotate([90,0,0])
								cylinder(r=8/2, h=40, center=true, $fn=50);
							//bolt holes (M3)
							for(j=[1,-1])
								translate([9*j,0.2,20]) rotate([0,180,0]) bolt(3,40);
						}
					}
					
					// bolts for show
					for(j=[1,-1])
							color(Steel) translate([9*j,-carriage_width/2+1.2,26]) rotate([0,180,0]) bolt(3,40);
				}
			}
		}
		
		
		
		//link to Z axis threaded rod
	}
}

module bearing_holder(carriage_width, carriage_height)
{
	//main vertical body of the carriage for the bearings
	difference()
	{
		hull()
		{
			//bulk for use as anchor for x axis holders
			translate([0,-carriage_width/2-1,0])
				cube(size=[carriage_width,carriage_width/3,carriage_height], center=true);
			
			//bearing holder
			cylinder(d=carriage_width, h=carriage_height, center=true);
		}
		
		//space for bearings
		translate([0,0,-0.5])
			cylinder(d=LM8_dia()+0.2, h=carriage_height+5, center=true);
		
		//cut out for bearing holder
		translate([0,carriage_width/1.7,0])
			rotate([0,0,45])
				cube(size=[carriage_width,carriage_width,carriage_height+5], center=true);
	}
}

z_carriage(LM8_dia(), LM8_length(), 56);
