fn=36;

module fillet(x, y, z)
{
	r = x>z ? (x*x)/(2*z) + (z*z)/(2*z) : (z*z)/(2*x) + (x*x)/(2*x);
	
	render()
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
	render()
	if(threaded)
	{
		linear_extrude(height = length, center = true, convexity = 10, twist = -360 * length / pitch, $fn = fn)
			translate([diameter * 0.1/2, 0, 0])
				circle(r = diameter*0.9/2, $fn = fn);
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
	render()
	union()
	{
		difference()
		{
			cylinder(h = bearingwidth, r = bearingsize/2, center = true, $fn = fn);
			cylinder(h = bearingwidth * 2, r = bearingsize/2 - 1, center = true, $fn = fn);
		}
		difference()
		{
			cylinder(h = bearingwidth - 0.5, r = bearingsize/2 - 0.5, center = true, $fn = fn);
			cylinder(h = bearingwidth * 2, r = screwsize/2 + 0.5, center = true, $fn = fn);
		}
		difference()
		{
			cylinder(h = bearingwidth, r = screwsize/2 + 1, center = true, $fn = fn);
			cylinder(h = bearingwidth + 0.1, r = screwsize/2, center = true, $fn = fn);
		}
	}
}

module nut(M, washer=false, flat=false, nyloc=false)
{
	echo(str("Item: Nut M",M,nyloc ? " Nyloc":""));
	
	nutsize = 0.8 * M;
	nutdiameter = 1.9 * M;
	
	color("Silver")
	render()
	translate([0,0,washer? (0.2*M)/2 : 0])
	{
		intersection()
		{
			scale([flat ? 5:1, flat ? 5:1, 0.5]) sphere(r = 1.05 * M, center = true);
			difference()
			{
				cylinder (h=nutsize, r=nutdiameter/2, center=true, $fn = 6);
				cylinder(r=M/2, h=nutsize+0.1, center=true, $fn = fn);
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
	render()
	difference()
	{
		cylinder(r = washerdiameter/2, h = washersize, center = true, $fn = fn);
		cylinder(r = M/2, h = washersize + 0.1, center = true, $fn = fn);
	}
}

module bolt(M, length, csk=false, threaded=false, mould=false)
{
	if (!mould) echo(str("Item: Bolt ",threaded ? "Threaded ":"","M",M,"x",length,"mm",csk ? " CSK":""));
	
	pitch = M/6;
	
	color("silver")
	render()
	union()
	{
		translate([0, 0, -length/2])
			if (threaded)
			{
				linear_extrude(height = length, center = true, convexity = 10, twist = -360 * length / pitch, $fn = fn)
					translate([M * 0.1/2, 0, 0])
						circle(r = M * 0.9/2, $fn = fn);
			}
			else
				cylinder(h = length, r = M/2, center = true, $fn = fn);
		
		difference()
		{
			if(csk)
				cylinder(r1=M/2, r2=M, h=M*0.6, $fn=fn);
			else
				translate([0, 0, M/2]) cylinder(h = M, r = M, center = true, $fn = fn);
			
			translate([0, 0, M]) cylinder(h = M, r = M / 2, center = true, $fn = 6);
		}
		
		if(mould)
			translate([0,0,10/2+M*0.6])
				cylinder(d=M*2, h=10, $fn=50, center=true);
	}
}

module l_bracket(width, length, thickness)
{
	echo(str("Item: L angle "+width+"mm wide, thickness "+thickness+"mm, length "+length+"mm"));
	color("silver")
	render(convexity = 3)
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

module roundRect(size, corner_radius)
{
	render()
	hull()
	{
		for(i=[-1,1])
			for(j=[-1,1])
				translate([i*(size[0]/2-corner_radius/2), j*(size[1]/2-corner_radius/2), 0])
					cylinder(d=corner_radius, h=size[2], $fn=50, center=true);
		cube(size=[size[0]/2,size[1]/2,size[2]], center=true);
	}
}

//lifted from MCAD because prisms are ironmongery too, ok?
module eqlprism(rightprismx,rightprismy,rightprismz)
{
	polyhedron(points = [[0,0,0],
						[rightprismx,0,0],
						[rightprismx,rightprismy,0],
						[0,rightprismy,0],
						[rightprismx/2,rightprismy,rightprismz],
						[rightprismx/2,0,rightprismz]] ,
				faces = [[0,1,2,3],[5,1,0],[5,4,2,1],[4,3,2],[0,3,4,5]]
				);
}
