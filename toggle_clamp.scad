//centre of base plate is centre of model

function toggle_clamp_holes() = [(14.2/2-11.1/2)/2+11.1/2, 15.9/2];

module toggle_clamp()
{
	base_plate_dims = [24.4, 23.5, 2];
	hole_seperation_min = 11.1;
	hole_seperation_max = 14.2;
	hole_width = 15.9;
	hole_size = 4.4;
	
	color("Silver")
	render()
	difference()
	{
		//base plate
		translate([0,0, 1/2]) cube(size=base_plate_dims, center=true);
		
		//mounting holes
		for(i=[1,-1])
			for(j=[1,-1])
				translate([i*(hole_seperation_max/2-(hole_seperation_max-hole_seperation_min)/4), j*hole_width/2, 0])
					union()
					{
						cube(size=[(hole_seperation_max-hole_seperation_min)/2, hole_size, 5], center=true);
						for(i=[1,-1])
							translate([i*((hole_seperation_max-hole_seperation_min)/2)/2,0,0])
								cylinder(d=hole_size, h=5, $fn=50, center=true);
					}
	}
	
	//clamp end
	color("Silver")
	render()
	translate([-base_plate_dims[0]/2-17.5, 0, (3.2/2)+9.55])
		difference()
		{
			cylinder(d=9.5, h=3.2, $fn=50, center=true);
			cylinder(d=4.3, h=3.3, $fn=50, center=true);
		}
	
	color("Silver")
	render()
	translate([-23.8/2-15/2, 0, (3.2/2)+9.55]) 
		cube(size=[15,8,3.2], center=true);
	
	//central mount
	color("Silver")
	render()
	translate([0, 0, 17/2]) 
		cube(size=[23.8, 1, 17], center=true);
	
	//lever
	color("Red")
	render()
	translate([(79.25-22.25)/2-base_plate_dims[0]/2, 0, (3.2/2)+9.5])
		cube(size=[(79.25-22.25), 9, 3.2], center=true);
		
	//stopper
	color("Silver")
	render()
	translate([-17.5-(base_plate_dims[0]/2), 0, 20/2])
		cylinder(d=4, h=20, $fn=50, center=true);
	
	color("Black")
	render()
	translate([-17.5-(base_plate_dims[0]/2), 0, 6/2]) 
		cylinder(d1=4, d2=8, h=6, $fn=50, center=true);
		
	echo(str("Item: Toggle Clamp (27Kg)"));
}

toggle_clamp();
