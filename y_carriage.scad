use <ironmongery.scad>
use <LM__UUOP.scad>


display = true;
y_carriage(56);

module y_carriage(Yaxis_seperation)
{
	echo(str("*************** Y Carriage *******************"));
	
	bearing_type = "LM8";
	Ycarriage_length = LMOP_length(bearing_type)*3+12;
	Ycarriage_width = Yaxis_seperation+LMOP_dia(bearing_type);
	mounting_plate_thickness = 3;
	
	difference()
	{
		union()
		{
			for(i=[1,-1])
			{
				//tubular bearing holders
				color("Gainsboro")
				difference()
				{
					translate([i*Yaxis_seperation/2,0,0]) rotate([90,0,0])
						cylinder(h=Ycarriage_length, d=LMOP_dia(bearing_type)+4.15, $fn=50, center=true); //tube 19.15mm (3/4 inch) OD x 15mm ID x 2.032mm (14 SWG) )wall
					translate([i*Yaxis_seperation/2,0.1,0]) rotate([90,0,0])
						cylinder(h=Ycarriage_length+1, d=LMOP_dia(bearing_type), $fn=50, center=true); //inner diameter hole
					translate([0,0,3+19.15/2-0.5])
						cube(size=[Ycarriage_width*2,Ycarriage_length+1,6], center=true); //top 0.5 cut off
					translate([0,0,-7])
						cube(size=[Ycarriage_width*2,Ycarriage_length+1,6], center=true); //bottom bit cut off
				}
				
				//bearings, for show
				if(display)
				{
					for(j=[1,-1])
					{
						translate([i*(Yaxis_seperation/2),j*(LMOP_length(bearing_type)+6),0])
							rotate([90,0,0])
								LMOP(bearing_type);
					}
				}
			}
			
			//mounting plate
			color("Gainsboro")
			translate([0,0,(LMOP_dia(bearing_type)+4.15)/2-0.5])
			{
				difference()
				{
					//the mounting plate
					//linear_extrude(height=mounting_plate_thickness) roundedSquare(pos=[Ycarriage_width, Ycarriage_length], r=3);
					translate([0,0,mounting_plate_thickness/2]) roundRect([Ycarriage_width, Ycarriage_length, mounting_plate_thickness], 3);
					
					// bits we cut out to make it light and usable
					for(i=[1,-1])
					{
						*#translate([0,(Ycarriage_length/2-20/2)*i,0]) cube(size=[25,20+2,7], center=true); //where there should be nothing
						
						//cutouts for the z carriage
						difference()
						{
							translate([0,(Ycarriage_length/2-5)*i,2.5]) scale([1,1.7,6]) cylinder(d=31, h=1, $fn=50, center=true);
							translate([0,6*i,0]) cube(size=[60, 30, 7], center=true);
						}
					}
					
					//centre bit
					translate([0,0,2]) cube(size=[Ycarriage_width-23, Ycarriage_length/2-10, 5], center=true);
				}
			}
		}
		
		//lets make some holes for bolts
		for(i=[1,-1])
		{
			for(j=[1,-1])
			{
				//holes for the frame bolts
				translate([i*Yaxis_seperation/2,35*j,7.5])
				{
					translate([0,0,5]) cylinder(r=3/2, h=10, $fn=50, center=true);
					translate([0,0,0.9]) cylinder(r1=3, r2=3/2, h=3*0.6, $fn=50, center=true);
					translate([0,0,-3]) cylinder(r=3, h=3.05, $fn=50);
				}
				//holes for the mounting bolts
				translate([i*Yaxis_seperation/2,0,6.5])
				{
					translate([0,0,7.5]) cylinder(r=4/2, h=10, $fn=50, center=true);
					translate([0,0,1.3]) cylinder(r1=4, r2=4/2, h=4*0.6, $fn=50, center=true);
					translate([0,0,-2.9]) cylinder(r=4, h=3.05, $fn=50);
				}
			}
		}
		
		//viewing cube for holes
		*translate([-Yaxis_seperation/2,-50/2,15]) cube(size=[20,20,20], center=true);
	}
	
	//the screws, pulleys et al for show
	if(display)
	{
		for(i=[1,-1])
		{
			for(j=[1,-1])
				color("Gainsboro") translate([i*Yaxis_seperation/2,35*j,10-0.7])
				{
					mirror([0,0,1])
						bolt(3,10, csk=true);
						translate([0,0,5.1]) nut(3, flat=true);
				}
			
			color("Gainsboro") translate([i*Yaxis_seperation/2,0,9])
			{
				mirror([0,0,1]) bolt(4,20, csk=true);
			}
		}
	}
}
