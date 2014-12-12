fn=36;

fillet(100,10);
module fillet(len,r)
{
	p=r;
	linear_extrude(height=len)
	difference()
	{
		square([p,p]);
		circle(r, $fn = fn );
	}
}

module linear_rod(diameter, length, threaded=false)
{
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

module bearing(OD, ID, height)
{
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

module nut(M, washer=false)
{
	nutsize = 0.8 * M;
	nutdiameter = 1.9 * M;
	
	color("Silver")
	translate([0,0,washer? (0.2*M)/2 : 0])
	{
		intersection()
		{
			scale([1, 1, 0.5]) sphere(r = 1.05 * M, center = true);
			difference()
			{
				cylinder (h = nutsize, r = nutdiameter / 2, center = true, $fn = 6);
				cylinder(r = M / 2, h = nutsize + 0.1, center = true, $fn = fn);
			}
		}
		if (washer > 0) translate([0,0,-nutsize/2-(0.2*M)/2]) washer(M);
	}
}

module washer(M)
{
	washerdiameter = 2 * M;
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
