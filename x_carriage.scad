use <ironmongery.scad>
use <hiwin.scad>
use <stepper-motors.scad>

display = true;
threaded = false;

x_carriage(123.5, 93, "12C");

module x_carriage(width, height, bushing_type)
{
	echo(str("*************** X Carriage *******************"));
	A4_width = 210;
	A4_length = 297;
	bearing_holder_length = 80;
	
	zHeight = 15; //15 == tslot_size/2
	tslot_size = 30;
	bearing_holder_dia = 28.6; //tube 28.6mm (1 1/8 inch) OD x 22mm ID 3.3mm wall
	bearing_holder_wall = 3.3;
	
	bearing_holes = mgn_bushing_holes(bushing_type);
	
	//the bed
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
		render()
		union()
		{
			//this carriage wont have the additional padding
			difference()
			{
				cube(size=[A4_length, A4_width, 3], center=true); //main plate
				
				//centre void
				roundRect([A4_length-50, A4_width-50, 5], 3);
				
				//slot where the connecting plate goes
				for(i=[1,-1])
					translate([0, i*(-width+mgn_rail_height(bushing_type)/2+mgn_bushing_height(bushing_type)/2+(3*4)+3), -10/2+3/2-1])
						union()
						{
							cube(size=[bearing_holder_length, 3, 10], center=true);
							for(i=[1,-1])
								for(j=[1,-1])
									translate([i*(bearing_holder_length/2-3/2), j*3/2, 0])
										cylinder(d=3, h=10, $fn=50, center=true);
						}
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
	
	//x belt attachment
	translate([0, 1, height-(21+7)/2+2])
	{
		rotate([90,0,0])
			carriage_anchor(30, 21);
		
		for(i=[1,-1])
			rotate([-90,0,0]) 
				translate([i*(30-7)/2, (i*-8.5)+1.5, 1.7])
				{ 
					bolt(M=3, length=15, threaded=threaded, comments="socket cap");
					translate([0,0,-9.5])
						nut(M=3,nyloc=true);
				}
	}
	
	//connceting plates and MGN bearings
	for(i=[0,1])
		mirror([0,i,0])
			translate([0, -width, 0])
			{
				// plate to connect breaings to carriage
				color("silver")
				render()
				difference()
				{			
					translate([0, mgn_rail_height(bushing_type)/2+mgn_bushing_height(bushing_type)/2+(3*4)+3, height/2-1/2+2])
						cube(size=[bearing_holder_length, 3, height+1], center=true);
					
					//joinery
					
					//holes for stuff
					for(j=[1,-1])
						translate([j*(bearing_holder_length/2-mgn_bushing_length(bushing_type)/2-1), 0, tslot_size/2]) 
							for(k=[1,-1])
								for(l=[1,-1])
									rotate([90,0,0]) 
										translate([bearing_holes[1]/2*k, bearing_holes[0]/2*l, 0])
											cylinder(d=3, h=100, $fn=50, center=true);
				}
				
				//bushing/plate extended mounts
				for(j=[1,-1])
					translate([j*(bearing_holder_length/2-mgn_bushing_length(bushing_type)/2-1),0,tslot_size/2]) 
						rotate([-90,0,0]) 
							bushing_extended_mount(bushing_type);
				
				//bearings
				for(i=[1,-1])
					translate([i*(bearing_holder_length/2-mgn_bushing_length(bushing_type)/2-1), 0, tslot_size/2]) 
						rotate([-90, 0, 0])
							mgn(bushing_type);
						
				
				//bolts
				for(j=[1,-1])
					translate([j*(bearing_holder_length/2-mgn_bushing_length(bushing_type)/2-1), 0, tslot_size/2])
						for(k=[1,-1])
							for(l=[1,-1])
								rotate([-90,0,0])
									translate([bearing_holes[1]/2*k, bearing_holes[0]/2*l, 0])
											translate([0,0,mgn_bushing_height(bushing_type)+(3*4)+3/2+0.5/2])
												bolt(M=3, length=20, csk=true, threaded=threaded); //length was 3.5+(3*4)+3=18.5
			}
	
	echo(str("************** END X Carriage *****************"));
}

module carriage_anchor(length, height)
{
	height = height+7;
	color("silver")
	render()
	difference()
	{
		union()
		{
			translate([0, -(height-7-10)/2+height/2, 0])
				cube(size=[length, height-7-10, 3], center=true);
			translate([0, 7/2-height/2+7/2+10/2, 0])
				gt2_belt_anchor(length);
			translate([0, 7/2-height/2, 0]) 
				cube(size=[length, 7, 3], center=true);
		}
		
		for(i=[1,-1])
			translate([i*(length/2-3.5), i*(3.5+10/2)+(7/2-height/2+7/2+10/2), 0]) 
				cylinder(d=3, h=10, $fn=50, center=true);
	}
	
	color("silver")
	render()
	translate([0, 7/2-height/2+7/2+10/2, 5])
	difference()
	{
		union()
		{
			cube(size=[length, 11, 3], center=true);
			for(i=[1,-1])
				translate([i*(length/2-3.5), i*(3.5+10/2), 0]) 
				{
					translate([0, i*-10/2, 0])
						cube(size=[7,10,3], center=true);
					cylinder(d=7, h=3, $fn=50, center=true);
				}
		}	
		
		for(i=[1,-1])
			translate([i*(length/2-3.5), i*(3.5+10/2), 0]) 
			{
				cylinder(d=3, h=20, $fn=50, center=true);
			}
	}
}

module gt2_belt_anchor(length)
{
	//gt2 dimensions - 6mm width, 2mm pitch, 0.7mm tooth depth
	difference()
	{
		cube(size=[length, 10, 3], center=true);
		
		//cut outs for gt2 teeth grip - optimised for 3mm end mill
		for(i=[0:4:(length/2)+1])
		{
			translate([(length/2)-i*2, 0, 10/2+3/2-0.7])
			{
				cube(size=[6,7,10], center=true);
				//tbones for the end mill process
				for(j=[1,-1])
					for(k=[1,-1])
						translate([j*1.5, k*7/2, 0])
							cylinder(d=3, h=10, $fn=50, center=true);
			}
		}
	}
}

module bushing_extended_mount(bushing_type)
{
	bearing_holes = mgn_bushing_holes(bushing_type);
	color("grey")
	render()
	difference()
	{
		union()
		{
			//plate that wraps around the bushing
			translate([0, 0, mgn_rail_height(bushing_type)/2+mgn_bushing_height(bushing_type)/2])
				cube(size=[mgn_bushing_length(bushing_type)+2, mgn_bushing_width(bushing_type)+1, 3], center=true);
			//extra height to meet carriage plate
			translate([0, 0, mgn_rail_height(bushing_type)/2+mgn_bushing_height(bushing_type)/2+(3*4)/2+3/2-0.1/2])
				cube(size=[mgn_bushing_length(bushing_type)+2, mgn_bushing_width(bushing_type)+1, 3*4+0.1], center=true);
		}
		
		//cut outs for the mill drill bit (done to avoid 'dog bone' issues)
		for(k=[1,-1])
			translate([k*(mgn_bushing_length(bushing_type)/2-3/2), 0, mgn_rail_height(bushing_type)/2+mgn_bushing_height(bushing_type)/2-3/2])
				cube(size=[3, mgn_bushing_width(bushing_type)+10, 3], center=true);
		
		//simplified model of the bushing
		translate([0, 0, mgn_rail_height(bushing_type)/2])
			cube(size=[mgn_bushing_length(bushing_type), mgn_bushing_width(bushing_type), mgn_bushing_height(bushing_type)], center=true);
			
		//bushing mount holes
		for(k=[1,-1])
				for(l=[1,-1])
					translate([bearing_holes[1]/2*k, bearing_holes[0]/2*l, 0])
						cylinder(d=3, h=50, $fn=50, center=true);
		
		//weight saving holes
		for(i=[-2:1])
		{
			for(j=[1,-1])
			{
				translate([0+(i*14*(i==-2?0:1)), j*7.5, 20]) 
					cylinder(d=3, h=40, $fn=50, center=true);
				
				translate([3+(i*7), j*3, 20]) 
					cylinder(d=3, h=40, $fn=50, center=true);
			}
		}
	}
}
