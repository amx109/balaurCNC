use <MCAD/metric_fastners.scad>
use <LM__UUOP.scad>
use <MCAD/2Dshapes.scad>

print = false;
y_carriage(56);

module y_carriage(Yaxis_seperation)
{
	//echosize("Y carriage length", 10);
	//echosize("Y carriage bearing holders inner diameter", LM8OP_dia());
	
	Ycarriage_length = LM8OP_length()*3+12;
	Ycarriage_width = Yaxis_seperation+LM8OP_dia();
	mounting_plate_thickness = 3;
	
	difference()
	{
		union()
		{
			for(i=[1,-1])
			{
				//bearing holders
				color("Gainsboro")
				difference()
				{
					translate([i*Yaxis_seperation/2,0,0]) rotate([90,0,0])
						cylinder(h=Ycarriage_length, d=LM8OP_dia()+4.15, center=true); //tube
					translate([i*Yaxis_seperation/2,0.1,0]) rotate([90,0,0])
						cylinder(h=Ycarriage_length+1, d=LM8OP_dia(), center=true); //inner hole
					translate([0,0,-7])
						cube(size=[Ycarriage_width*2,Ycarriage_length+1,6], center=true); //bottom bit cut off
				}
				
				//bearings, for show
				if(!print)
				{
					for(j=[1,-1])
					{
						translate([i*(Yaxis_seperation/2),j*(LM8OP_length()+6),0])
							rotate([90,0,0])
								LMOP(8);
					}
				}
			}
			
			//mounting plate
			color("Gainsboro")
			translate([0,0,(LM8OP_dia()+4.15)/2+mounting_plate_thickness/2])
			{
					//cube(size=[Ycarriage_width,Ycarriage_length,3], center=true);
					for(i=[1,-1])
					{
						translate([i*-Yaxis_seperation/2,0,-mounting_plate_thickness/2])
						{
							linear_extrude(height=mounting_plate_thickness) roundedSquare(pos=[LM8OP_dia()+4.15,Ycarriage_length], r=3);
						}
						
						//cutouts
						#translate([0,(Ycarriage_length/2-20/2)*i,0])
							cube(size=[Yaxis_seperation-(LM8OP_dia()*2)+2,20+0.1,5], center=true);
					}
			}
		}
		
		//holes for the frame bolts
		for(i=[1,-1])
		{
			for(j=[1,-1])
				translate([i*Yaxis_seperation/2,35*j,7.5])
				{
					csk_bolt(3,10);
					translate([0,0,-2.9]) cylinder(h=3, d=6, $fn=50);
				}
			color("Gainsboro") translate([i*Yaxis_seperation/2,0,6.5])
			{
				csk_bolt(4,20);
				translate([0,0,-3.9]) cylinder(h=4, d=8, $fn=50);
			}
		}
	}
	
	
	//the screws, for show
	if(!print)
	{
		for(i=[1,-1])
		{
			for(j=[1,-1])
				color("Gainsboro") translate([i*Yaxis_seperation/2,35*j,7.5])
				{
					csk_bolt(3,10);
						translate([0,0,5.1]) flat_nut(3);
				}
			
			color("Gainsboro") translate([i*Yaxis_seperation/2,0,6.5])
			{
				csk_bolt(4,20);
			}
		}
	}
	
	//show how far to drill down - want max surface area with csk
	*translate([Yaxis_seperation/2,-42,0])
	{
		translate([0,0,7.5])
		{
			 csk_bolt(3,10); // (under the bearings)
			 
		}
		//translate([0,0,6.5]) csk_bolt(4,20); //
	}
}
