use <LM__UUOP.scad>
use <ironmongery.scad>

display = true;

x_carriage(113.5, 93);

module x_carriage(width, height)
{
	echo(str("*************** X Carriage *******************"));
	A4_width = 210;
	A4_length = 297;
	padding=10;
	
	hole_size = 8;
	hole_spacing = 8;
	hole_perim_spacing = 17;
	
	bearing_holder_length = 80;
	
	//a4 carriage
	translate([0,0,height+4/2])
	{ 
		*color("LightCoral")
			translate([0,0,3]) a4Bed(padding, bed_height=3);
		
		//carriage with holes
		*color("silver")
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
		color("silver")
		union()
		{
			//our carriage wont have the additional padding
			difference()
			{
				cube(size=[A4_length, A4_width, 4], center=true);
				cube(size=[A4_length-50, A4_width-50, 5], center=true);
			}
			
			for(i=[0,1])
			mirror([0,i,0])
			{
				difference()
				{
					translate([0,A4_width/2-20,0]) scale([1.04,0.5,1]) cylinder(d=A4_length-40, h=4, $fn=50, center=true);
					translate([0,A4_width/2-20+11,0]) scale([1,0.5,1.1]) cylinder(d=A4_length-40, h=4, $fn=50, center=true);
				}
			}
			
			for(i=[0,1])
			mirror([i,0,0])
			{
				for(i=[0,1,2])
				{
					translate([0+(i*40),0,0]) cube(size=[10,i==2 ? 80: 50,4], center=true);
				}
				
				for(i=[0,1])
					mirror([0,i,0])
						translate([110,15,0]) rotate([0,0,50]) cube(size=[10,80,4], center=true);
			}
		}
	}
	
	// bearings, plates etc
	for(i=[0,1])
	mirror([0,i,0])
	translate([A4_length/2-bearing_holder_length/2-109, -width, 15])
	{
		//tube bearing holder
		color("Gainsboro")
		rotate([0,90,90])
		difference()
		{
			translate([0,0,0]) rotate([90,0,0])
				cylinder(h=bearing_holder_length, d=28.6, $fn=50, center=true); //tube 28.6mm (1 1/8 inch) OD x 22mm ID 3.3mm wall
			translate([0,0.1,0]) rotate([90,0,0])
				cylinder(h=bearing_holder_length+1, d=LMOP_dia("LM12"), $fn=50, center=true); //inner hole
			translate([0,0,-12])
				cube(size=[50,150+1,10], center=true); //top bit cut off
			translate([0,0,5+14.3-0.5])
				cube(size=[50,150+1,10], center=true); //bottom bit cut off
			
			//lets make some holes for bolts
			for(i=[1,-1])
			{
				//holes for the M3 frame bolts
				translate([0,i*(bearing_holder_length/2-LMOP_length("LM12")/2),11])
				{
					translate([0,0,5]) cylinder(r=4/2, h=10, $fn=50, center=true);
					translate([0,0,0.9]) cylinder(r1=4, r2=4/2, h=4*0.6, $fn=50, center=true);
					translate([0,0,-3]) cylinder(r=4, h=3.05, $fn=50);
				}
			}
			
			//viewing cube
			*translate([0,-34,10]) cube(size=[10,20,10], center=true);
		}
		
		//alu plate to connect to the carriage
		color("silver")
		translate([0, 15.3, (height-8.5)/2-3/2-5])
			cube(size=[bearing_holder_length, 3, height-8.5], center=true);
		
		translate([0,28.6/2-0.5+3, height-20-1-4]) 
		difference()
		{
			
			//alu angle to connect to the carriage
			rotate([0,90,90])
				l_bracket(20, A4_length, 3);
			
			for(i=[1,-1])
				translate([((A4_length)/2-90/2+0.1)*i,0,-1.5-0.1])
					cube(size=[90,10,17+0.2], center=true);
		}	
		
		if(display)
		{
			//bearings, for show
			for(i=[1,-1])
			{
				translate([i*(bearing_holder_length/2-(LMOP_length("LM12")/2)),0,0])
					rotate([0,90,0])
						LMOP("LM12");
			}
			
			for(i=[1,-1])
			{
				//M3 frame bolts
				rotate([0,90,90])
				mirror([0,0,1])
				translate([0,i*(bearing_holder_length/2-LMOP_length("LM12")/2),-13.4])
				{
					bolt(4,10,csk=true);
				}
			}
		}
	}
	
	echo(str("************** END X Carriage *****************"));
}
