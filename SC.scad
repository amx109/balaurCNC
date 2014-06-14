include <MCAD/nuts_and_bolts.scad>

M6 = 6;
$fn=50;

module SC(size)
{
	if(size == 20)
	{
		_SC(20, 21, 27, 54, 41, 35, 11, 40, 7, M6, 5.2, 40, 50, 70, 96, 12, 32);
	}
}

module _SC(d, h, D, W, H, G, A, J, E, S1, S2, K, L, Kw, Lw, I, LMU_OD)
{
	sides = 2;
	
	difference()
	{
		union()
		{
			//top sqaure bit
			translate([0,0,((I+1)/2)+(H-(I+1))]) cube(size=[L,W,I+1], center=true);
			
			//bottom square bit
			translate([0,0,((G-(I+1))/2)+(H-G)]) cube(size=[L,W-sides,G-(I+1)], center=true);
			
			//cylinderical part at the bottom
			translate([0,0,LMU_OD/2]) rotate([0,90,0]) cylinder(r=LMU_OD/2, h=L, center=true);
		}
		
		//the bit where the rod goes
		translate([0,0,H-(h+1)]) rotate([0,90,0]) cylinder(r=d/2, h=L+1, center=true);
		
		//mounting holes
		for(i=[1 : 4])
		{
			rotate([180,0,i*90]) translate([K/2,J/2,-H-1])  boltHole(size=S1, length=I+1+1);
		}
	}
}
