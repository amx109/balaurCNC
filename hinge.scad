use <MCAD/metric_fastners.scad>


hinge_outer_flange_length = 18;
hinge_width = 50;
hinge_flange_thickness = 1.2;
hinge_barrel_circumference = 5.5;
hinge_inner_hole_distance = 20;
hinge_outer_hole_distance = 41;

module hinge(open)
{
	//open can be 1 or 0. 1 = open, 0 = closed
	
	hinge_inner_flange_width = 28;
	hinge_inner_flange_length = 12;
	angle = (open == 1) ? 270 : 0;
	
	union()
	{
		//cylinder
		rotate ([90,0,0])
		{
			difference()
			{
				cylinder(r=hinge_barrel_circumference/2, h=hinge_width, center=true);
				cylinder(r=hinge_barrel_circumference/3.6, h=hinge_width+10, center=true);
				cylinder(r=hinge_barrel_circumference, h=hinge_inner_flange_width, center=true);
			}
		}
		
		//big outer flange
		translate([((hinge_outer_flange_length+(hinge_barrel_circumference/2))/2),
					0,
					-(hinge_barrel_circumference/2)+(hinge_flange_thickness/2)])
		{
			difference()
			{
				cube(size=[hinge_outer_flange_length+(hinge_barrel_circumference/2),
						   hinge_width, 
						   hinge_flange_thickness],
						   center=true);
				translate([-(hinge_outer_flange_length-hinge_inner_flange_length)/2,0,0]) 
					cube(size=[hinge_inner_flange_length+0.1+(hinge_barrel_circumference/2), 
							   hinge_inner_flange_width+2, 
							   hinge_flange_thickness+1],
							   center=true);
				
				//mounting holes
				for(i=[1,-1])
				{
					rotate([180,0,0])
						translate([0,i*(hinge_outer_hole_distance/2),-(hinge_flange_thickness/2)-0.1])
							csk_bolt(3,14);
				}
			}
		}
	}
	
	//inner flange
	rotate([0,angle,0])
	{
		union()
		{
			//cylinder
			rotate ([90,0,0])
			{
				difference()
				{
					cylinder(r=hinge_barrel_circumference/2, h=hinge_inner_flange_width-1, center=true);
					cylinder(r=hinge_barrel_circumference/3.6, h=hinge_inner_flange_width+10, center=true);
				}
			}
			
			translate([0,0,-(hinge_barrel_circumference/2)+(hinge_flange_thickness/2)])
			{
				difference()
				{
					//inner flange
					translate([((hinge_inner_flange_length-1+(hinge_barrel_circumference/2))/2),0,0]) 
						cube(size=[(hinge_inner_flange_length-1)+(hinge_barrel_circumference/2),
									hinge_inner_flange_width, hinge_flange_thickness],
									center=true);
						
					//mounting holes
					for(i=[1,-1])
					{
						translate([(hinge_outer_flange_length+(hinge_barrel_circumference/2))/2,
									i*(hinge_inner_hole_distance/2),
									-(hinge_flange_thickness/2)-0.1])
							csk_bolt(3,14);
					}
				}
			}
		}
	}
}
