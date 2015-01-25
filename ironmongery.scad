fn=36;

module fillet(x, y, z)
{
	r = x>z ? (x*x)/(2*z) + (z*z)/(2*z) : (z*z)/(2*x) + (x*x)/(2*x);
	
	difference()
	{
		translate([x/2,0,z/2]) cube(size=[x, y, z], center=true);
		translate([x>z?x:r, 0, x>z?r:z]) rotate([90,0,0]) cylinder(r=r, h=y+1, $fn=100, center=true);
	}
}

module linear_rod(diameter, length, threaded=false)
{
	
	echo(str("Item: ", threaded ? "Threaded" : "Linear", " Rod ", diameter, "mm ",length, "mm"));
	
	pitch = diameter/6;
	color("LightGrey") 
	if(threaded)
	{
		linear_extrude(height = length, center = true, convexity = 10, twist = -360 * length / pitch, $fn = fn)
			translate([diameter * 0.1 / 2, 0, 0])
				circle(r = diameter * 0.9 / 2, $fn = fn);
	}
	else
		cylinder(r=diameter/2, h=length, center=true);
}

module bearing(OD, ID, height, description=-1)
{
	echo(str("Item: Bearing ", description==-1 ? "" : description, "  ", ID,"x",OD,"x",height," mm (ID x OD x height)"));
	
	bearingsize = OD; 
	bearingwidth = height;
	screwsize = ID;
	
	color("silver")
	union()
	{
		difference()
		{
			cylinder(h = bearingwidth, r = bearingsize / 2, center = true, $fn = fn);
			cylinder(h = bearingwidth * 2, r = bearingsize / 2 - 1, center = true, $fn = fn);
		}
		difference()
		{
			cylinder(h = bearingwidth - 0.5, r = bearingsize / 2 - 0.5, center = true, $fn = fn);
			cylinder(h = bearingwidth * 2, r = screwsize / 2 + 0.5, center = true, $fn = fn);
		}
		difference()
		{
			cylinder(h = bearingwidth, r = screwsize / 2 + 1, center = true, $fn = fn);
			cylinder(h = bearingwidth + 0.1, r = screwsize / 2, center = true, $fn = fn);
		}
	}
}

module nut(M, washer=false, flat=false)
{
	echo(str("Item: Nut M",M));
	
	nutsize = 0.8 * M;
	nutdiameter = 1.9 * M;
	
	color("Silver")
	translate([0,0,washer? (0.2*M)/2 : 0])
	{
		intersection()
		{
			scale([flat ? 5 : 1, flat ? 5 : 1, 0.5]) sphere(r = 1.05 * M, center = true);
			difference()
			{
				cylinder (h = nutsize, r = nutdiameter / 2, center = true, $fn = 6);
				cylinder(r = M / 2, h = nutsize + 0.1, center = true, $fn = fn);
			}
		}
		if (washer > 0) translate([0,0,-nutsize/2-(0.2*M)/2]) washer(M);
	}
}

module washer(M, dia=-1)
{
	echo(str("Item: Washer M",M," ", dia!=-1 ? dia : ""));
	
	washerdiameter = dia==-1 ? 2 * M : dia;
	washersize = 0.2 * M;
	
	color("silver")
	difference()
	{
		cylinder(r = washerdiameter / 2, h = washersize, center = true, $fn = fn);
		cylinder(r = M / 2, h = washersize + 0.1, center = true, $fn = fn);
	}
}

module bolt(M, length, csk=false, threaded=false)
{
	echo(str("Item: Bolt M",M,"x",length, "mm", csk ? " CSK" : ""));
	
	pitch = M /6;
	
	color("silver")
	union()
	{
		translate([0, 0, -length / 2])
		if (threaded)
		{
			linear_extrude(height = length, center = true, convexity = 10, twist = -360 * length / pitch, $fn = fn)
				translate([M * 0.1 / 2, 0, 0])
					circle(r = M * 0.9 / 2, $fn = fn);
		}
		else
			cylinder(h = length, r = M / 2, center = true, $fn = fn);
		
		difference()
		{
			if(csk)
				cylinder(r1=M/2, r2=M, h=M*0.6, $fn=fn);
			else
				translate([0, 0, M / 2]) cylinder(h = M, r = M, center = true, $fn = fn);
			translate([0, 0, M]) cylinder(h = M, r = M / 2, center = true, $fn = 6);
		}
	}
}

module l_bracket(width, length, thickness)
{
	echo(str("Item: L angle "+width+"mm wide, thickness "+thickness+"mm, length "+length+"mm"));
	color("silver")
	difference()
	{
		union()
		{
			translate([0,0,thickness/2]) 
			cube(size=[width,length,thickness], center=true);
			
			translate([-width/2+thickness/2,0,width/2])
				rotate([0,90,0])
						cube(size=[width,length,thickness], center=true);
		}
	}
}
