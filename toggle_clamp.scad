module toggle_clamp()
{
	color("Silver")
	difference() //base
	{
		translate([0,0, 1/2]) cube(size=[23.8, 23.8, 1], center=true);
		for(i=[1,-1])
		{
			for(j=[1,-1])
			{
				translate([((11.1/2)+((15.9-11.1)/2)/2)*j, (15.9/2)*i, 0])
				{
					union()
					{
						cube(size=[(15.9-11.1)/2, 4.4, 1.1], center=true);
						for(i=[1,-1])
							translate([i*((15.9-11.1)/2)/2,0,0])
								cylinder(d=4.4, h=1.1, $fn=50, center=true);
					}
				}
			}
		}
	}
	
	//clamp end
	color("Silver")
	translate([-17.5-(23.8/2), 0, (3.2/2)+9.5])
		difference()
		{
			cylinder(d=9.5, h=3.2, $fn=50, center=true);
			cylinder(d=4.3, h=3.3, $fn=50, center=true);
		}
	
	color("Silver")
	translate([-23.8/2-15/2, 0, (3.2/2)+9.5]) 
		cube(size=[15,8,3.2], center=true);
	
	//central mount
	color("Silver")
	translate([0, 0, 17/2]) 
	cube(size=[23.8, 1, 17], center=true);
	
	//lever
	color("Red")
	translate([(77.11-20)/2-23.8/2, 0, (3.2/2)+9.5])
		cube(size=[(77.11-20), 9, 3.2], center=true);
		
	//stopper
	color("Silver")
	translate([-17.5-(23.8/2), 0, 20/2])
		cylinder(d=4, h=20, $fn=50, center=true);
	
	color("Black")
	translate([-17.5-(23.8/2), 0, 6/2]) 
		cylinder(d1=4, d2=8, h=6, $fn=50, center=true);
		
}

toggle_clamp();
