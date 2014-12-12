use <MCAD/metric_fastners.scad>
use <LM__UUOP.scad>
use <MCAD/2Dshapes.scad>
use <pullies.scad>

display = true;
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
				//tubular bearing holders
				color("Gainsboro")
				difference()
				{
					translate([i*Yaxis_seperation/2,0,0]) rotate([90,0,0])
						cylinder(h=Ycarriage_length, d=LM8OP_dia()+4.15, $fn=50, center=true); //tube
					translate([i*Yaxis_seperation/2,0.1,0]) rotate([90,0,0])
						cylinder(h=Ycarriage_length+1, d=LM8OP_dia(), $fn=50, center=true); //inner hole
					translate([0,0,-7])
						cube(size=[Ycarriage_width*2,Ycarriage_length+1,6], center=true); //bottom bit cut off
				}
				
				//bearings, for show
				if(display)
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
			translate([0,0,(LM8OP_dia()+4.15)/2])
			{
				for(i=[1,-1])
				{
					difference()
					{
						//h section
						union()
						{
							translate([i*-Yaxis_seperation/2,0,0])
								linear_extrude(height=mounting_plate_thickness) roundedSquare(pos=[LM8OP_dia()+4.15,Ycarriage_length], r=3);
							linear_extrude(height=mounting_plate_thickness) roundedSquare(pos=[Ycarriage_width,Ycarriage_length/2], r=3);
						}
						
						//centre cutout
						translate([0,0,-0.1]) 
									linear_extrude(height=mounting_plate_thickness+0.2) 
										roundedSquare(pos=[Ycarriage_width-LM8OP_dia()-10,Ycarriage_length/2-10], r=3);
					}
					
					//cutouts
					//#translate([0,(Ycarriage_length/2-20/2)*i,0]) cube(size=[Yaxis_seperation-(LM8OP_dia()*2)+2,20+0.1,5], center=true);
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
					csk_bolt(3,10);
					translate([0,0,-2.9]) cylinder(h=3, d=6, $fn=50);
				}
				//holes for the mounting bolts
				color("Gainsboro") translate([i*Yaxis_seperation/2,0,6.5])
				{
					csk_bolt(4,20);
					translate([0,0,-3.9]) cylinder(h=4, d=8, $fn=50);
				}
			}
		}
	}
	
	//the screws, pulleys et al for show
	if(display)
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
