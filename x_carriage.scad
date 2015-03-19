use <LM__UUOP.scad>
use <ironmongery.scad>

display = true;

x_carriage(113.5, 93);

module x_carriage(width, height)
{
	echo(str("*************** X Carriage *******************"));
	A4_width = 210;
	A4_length = 297;
	bearing_holder_length = 80;
	
	zHeight = 15; //15 == tslot_size/2
	bearing_holder_dia = 28.6; //tube 28.6mm (1 1/8 inch) OD x 22mm ID 3.3mm wall
	bearing_holder_wall = 3.3;
	
	echo(str("Item: Aluminium Tube OD:1 1/8\" (28.6mm) x ID:22mm x Wall:3.3mm"));
	
	//a4 carriage
	translate([0,0,height+3/2])
	{
		hole_size = 8;
		hole_spacing = 8;
		hole_perim_spacing = 17;
		padding=10;
		
		//carriage with holes
		*color("Gainsboro")
		render()
		difference()
		{
			cube(size=[A4_length+padding, A4_width+padding, 4], center=true);
			for(i=[0:floor((A4_width-(hole_perim_spacing*2))/(hole_size+hole_spacing))])
				for(j=[0:floor((A4_length-(hole_perim_spacing*2))/(hole_size+hole_spacing))])
					translate([	(-A4_length/2+hole_perim_spacing)+((hole_size+hole_spacing)*j),
								(-A4_width/2+hole_perim_spacing)+((hole_size+hole_spacing)*i),
								0])
						cylinder(d=hole_size, h=10, $fn=50, center=true);
		}
		
		//carriage with swooshy curves
		color("Gainsboro")
		//render()
		union()
		{
			//our carriage wont have the additional padding
			difference()
			{
				cube(size=[A4_length, A4_width, 3], center=true); //main plate
				
				roundRect([A4_length-50, A4_width-50, 5], 3); //centre void
				//slot where the connecting plate goes
				translate([0, 3/2-width+LMOP_dia("LM12")/2+bearing_holder_wall-0.5, 0])
					cube(size=[bearing_holder_length, 3, 10], center=true); 
			}
			
			//arches
			for(i=[0,1])
				mirror([0,i,0])
				{
					difference()
					{
						translate([0,A4_width/2-20,0]) scale([1.04,0.5,1])
							cylinder(d=A4_length-40, h=3, $fn=50, center=true);
						translate([0,A4_width/2-20+11,0]) scale([1,0.5,1.1])
							cylinder(d=A4_length-40, h=3, $fn=50, center=true);
					}
				}
			
			//infill bits
			for(i=[0,1])
				mirror([i,0,0])
				{
					//perpendicular bars
					for(i=[0,1,2])
						translate([0+(i*40),0,0])
							cube(size=[10, i==2 ? 80: 50, 3], center=true);
					
					//end triangle bits
					for(i=[0,1])
						mirror([0,i,0])
							translate([110,15,0])
								rotate([0,0,50])
									cube(size=[10,80,3], center=true);
				}
		}
	}
	
	// bearings, plates etc
	for(i=[0,1])
		mirror([0,i,0])
			translate([0, -width, zHeight])
			{
				//tube bearing holder
				color("Gainsboro")
				rotate([90,90,90])
				difference()
				{
					cylinder(h=bearing_holder_length, d=bearing_holder_dia, $fn=50, center=true); //tube
				
					cylinder(h=bearing_holder_length+1, d=LMOP_dia("LM12"), $fn=50, center=true); //inner hole
					translate([0, -12, 0])
						cube(size=[50, 10, 150+1], center=true); //bottom bit cut off
					translate([0, 10/2+LMOP_dia("LM12")/2+bearing_holder_wall-0.5, 0])
						cube(size=[50, 10, 150+1], center=true); //top bit cut off
					
					//lets make some holes for bolts
					for(i=[1,-1])
						rotate([-90,0,180]) 
							translate([0, i*(bearing_holder_length/2-LMOP_length("LM12")/2), -14])
								cylinder(d=4, h=10, $fn=50, center=true);
				}
				
				//alu plate to connect to the carriage
				color("silver")
				//render()
				difference()
				{
					translate([0, 3/2+LMOP_dia("LM12")/2+bearing_holder_wall-0.5, ((height+3)-(zHeight-4/2-5))/2-(4/2+5)])
						cube(size=[bearing_holder_length, 3, (height+3)-(zHeight-4/2-5)], center=true);
					
					for(i=[1,-1])
						rotate([90,0,0])
							translate([i*(bearing_holder_length/2-LMOP_length("LM12")/2), 0, -13.4])
								cylinder(d=4, h=10, $fn=50, center=true);
				}
				
				if(display)
				{
					//bearings, for show
					for(i=[1,-1])
						translate([i*(bearing_holder_length/2-(LMOP_length("LM12")/2)),0,0])
							rotate([0,90,0])
								LMOP("LM12");
					
					//M3 frame bolts
					for(i=[1,-1])
						rotate([0,90,90])
							mirror([0,0,1])
								translate([0,i*(bearing_holder_length/2-LMOP_length("LM12")/2),-13.4])
								{
									bolt(4,10,csk=true,threaded=true);
									translate([0,0,-5.5]) nut(4);
								}
				}
			}
	
	echo(str("************** END X Carriage *****************"));
}
