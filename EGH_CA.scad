M4 = 4;
$fn=50;

module egh_ca(size)
{
	if(size == 15)
	{
		egh_ca_(24,4.5,9.5,34,26,4,26,39.8,56.8,10.15,5.7,M4,6,6,5.5,6,15,12.5,6,4.5,3.5,60,20);
	}
}

module egh_ca_(H,H1,N,W,B,B1,C,L1,L,K1,G,M,l,T,H2,H3,Wr,Hr,D,h,d,P,E)
{
	difference()
	{
		//main shape
		cube(size=[L,W,H-H1], center=true);
		translate([0,0,-(((H-H1)-(Hr-H1))/2)-0.05])cube(size=[L+1,Wr,Hr-H1+0.1], center=true);
		//mounting holes
		for(i=[1 : 4])
		{
			rotate([180,0,i*90]) translate([B/2,C/2,-l-(((H-H1)/2)-l)-0.1])  cylinder(d=M, h=1, $fn=50, center=true);
		}
	}
	
	
}

module egr(size, rlength)
{
	if(size == 15)
	{
		egr_(24,4.5,9.5,34,26,4,26,39.8,56.8,10.15,5.7,M4,6,6,5.5,6,15,12.5,6,4.5,3.5,60,20, rlength);
	}
}

module egr_(H,H1,N,W,B,B1,C,L1,L,K1,G,M,l,T,H2,H3,Wr,Hr,D,h,d,P,E, rlength)
{
	cube(size=[rlength,Wr,Hr], center=true);
}

//egh_ca(15);
//egr(15, 500);
