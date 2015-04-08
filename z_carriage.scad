use <ironmongery.scad>
use <hiwin.scad>

$fn=50;

z_carriage("12H", 56, 3);

module z_carriage(bearing_type, Yaxis_seperation, wall_material_thickness)
{
	/* rather than build this model from one solid block it was decided that 
	 * this part would be modelled so that it can be built up from 3mm sheet aluminium.
	 * each layer is drawn and modelled seperately with special actions for certain layers
	 */ 
	
	layers = 4; //how many layers deep we want the part to be
	bushing_holder_dims = [mgn_bushing_width(bearing_type)+8, wall_material_thickness*layers, mgn_bushing_length(bearing_type)+2];
	
	color("darkgray")
	render()
	difference()
	{
		union() //main body of carraige
		{
			for(i=[0:layers])
				//color([ 0.01*i, 0.15*i, 0.2*i ]) //uncomment this to show each layer in a diff colour
				translate([0, 3/2-(wall_material_thickness*i), 0])
					difference()
					{
						union()
						{
							//main body
							cube(size=[bushing_holder_dims[0], wall_material_thickness, bushing_holder_dims[2]], center=true);
							
							//top bolt hole surround
							for(j=[1,-1])
								translate([j*bushing_holder_dims[0]/2, 0, bushing_holder_dims[2]/2-8/2])
									rotate([90,0,0])
										cylinder(d=8, h=wall_material_thickness, $fn=50, center=true);
							
							//front half of carriage section
							if(i<3)
							{
								//bottom fillet
								for(j=[0,1])
									mirror([j,0,0])
										translate([bushing_holder_dims[0]/2-0.1/2, -0.1/2, -bushing_holder_dims[2]/2])
											fillet(22/2+0.1, wall_material_thickness+0.1, 22/2);
							}
							
							//rear half of carriage section
							if (i>2)
								for(j=[1,-1])
								{
									translate([j*Yaxis_seperation/2, 0, -12.7])
									{
										if(j==1) //LHS
										{
											//cylinder holder for the rails
											rotate([90,0,0])
												cylinder(d=22, h=wall_material_thickness, $fn=50, center=true);
											//attachment to bushing holder
											translate([j*-15/2, 0, 0])
												cube(size=[15, wall_material_thickness, 22], center=true);
										}
										else //RHS
										{
											//roundrect for rail holder and y-belt idle bearing
											if(j==-1)
												translate([0.5, 0, 0])
													rotate([90, 0, 0])
														roundRect([23, 22, wall_material_thickness], 3);
										}
										
										//additional screw clamp hole surrounds at the bottom
										translate([j*22/2,0,-22/2+8/2])
										{
											rotate([90,0,0])
												cylinder(d=8, h=wall_material_thickness, $fn=50, center=true);
											translate([j*-11/2, 0, 0])
												cube(size=[11, wall_material_thickness, 8], center=true);
										}
									}
									
									//pillar for extra strengthing of wall adjacent to bushing
									translate([j*bushing_holder_dims[0]/2, 0, bushing_holder_dims[2]/4-8/2])
										cube(size=[8, wall_material_thickness, bushing_holder_dims[2]/2], center=true);
									
									//fillet from rail to bushing wall
									mirror([j==-1?1:0, 0, 0])
										translate([bushing_holder_dims[0]/2+8/2-0.1, 0, -3.2])
											fillet(12+0.1, wall_material_thickness, bushing_holder_dims[2]/2);
								}
						}
						
						//tbone for layer 1 - cnc mill feature
						if(i==1)
						{
							for(j=[1,-1])
								for(k=[1,-1])
									translate([j*mgn_bushing_width(bearing_type)/2, 0, k*(mgn_bushing_length(bearing_type)/2-3/2)])
										rotate([90,0,0])
											cylinder(d=3, h=3.05, $fn=50, center=true);
						}
					}
		}
		
		/**** all the things to remove from the carriage model ****/
		
		//ensure 1mm gap from the brace wall
		translate([0, -13-10/2+1, 0])
			cube(size=[100, 10, 50], center=true);
		
		//room for the bushing+everything behind it
		translate([0, -mgn_rail_height(bearing_type)/2-mgn_bushing_height(bearing_type)/2, 0])
		{
			*rotate([0,90,90])
				#mgn(bearing_type); //for visual display purposes
			
			translate([0,mgn_rail_height(bearing_type)/2-20/2,0])
				cube(size=[mgn_bushing_width(bearing_type), mgn_bushing_height(bearing_type)+20, mgn_bushing_length(bearing_type)], center=true);

			cube(size=[mgn_bushing_width(bearing_type), wall_material_thickness*(4), mgn_bushing_length(bearing_type)+10], center=true);
			
		}
		
		//top bolt holes
		for(i=[1,-1])
			translate([i*bushing_holder_dims[0]/2, 0, bushing_holder_dims[2]/2-8/2])
				rotate([90,0,0])
					cylinder(d=3, h=40, $fn=50, center=true);
		
		//bottom bolt holes
		for(i=[1,-1])
			translate([i*bushing_holder_dims[0]/2, 0, -bushing_holder_dims[2]/2+3])
				rotate([90,0,0])
					cylinder(d=3, h=40, $fn=50, center=true);
		
		//bottom bolt holes #2 (out wide)
		for(i=[1,-1])
			translate([i*(Yaxis_seperation/2+22/2), 0, -12.7-22/2+8/2])
				rotate([90,0,0])
					cylinder(d=3, h=40, $fn=50, center=true);
		
		//bushing screw holes
		for(i=[1,-1])
			for(j=[1,-1])
				rotate([90,0,0])
					translate([i*mgn_bushing_holes(bearing_type)[0]/2, j*mgn_bushing_holes(bearing_type)[1]/2, 0])
							cylinder(d=3, h=50, $fn=50, center=true);
		
		//the y carriage rails
		for(i=[1,-1])
			translate([i*Yaxis_seperation/2, 100/2-4.5, -12.7])
				rotate([90,0,0])
						cylinder(d=8, h=115-2, $fn=50, center=true);
		
		//y belt idler bearing spindle
		translate([-Yaxis_seperation/2-8, -9, -10])
			cube(size=[3, 3, 40], center=true);
			
	}
	
	//for visual display part placing verification, please ignore
	*#union() //the y carriage tubey bits + y belt pully
	{
		for(i=[1,-1])
			translate([i*Yaxis_seperation/2, 100/2-5.5, -12.7])
			{
				rotate([90,0,0]) 
					cylinder(d=19.15, h=100, $fn=50, center=true);
				
				//y carriage square plate
				translate([0, -10, 19.15/2+1])
					cube(size=[19.15, 80, 3], center=true);
			}
		
		//the y carriage rails
		for(i=[1,-1])
				translate([i*Yaxis_seperation/2, 100/2-4.5, -12.7])
					rotate([90,0,0])
							cylinder(d=8, h=115-2, $fn=50, center=true);
		
		//y belt stuff
		translate([-Yaxis_seperation/2-8, -8.75, 9-9])
		{
			cylinder(d=3, h=40, $fn=50, center=true);
			translate([0,0,9])
				cylinder(d=6, h=15, $fn=50, center=true);
		}
		
		translate([0,-9,0])
		{
			rotate([0,90,90])
				mgn_rail(bearing_type, 100);
		}
		
		for(i=[1,-1])
			translate([i*bushing_holder_dims[0]/2, -9, -bushing_holder_dims[2]/2+3])
				rotate([90,0,0])
				{
					bolt(M=3, length=15);
					translate([0,0,-13])
						rotate([0,0,35])
						nut(M=3);
				}
		for(i=[1,-1])
			translate([i*(Yaxis_seperation/2+22/2), -10.2, -12.7-22/2+8/2])
				rotate([90,0,0])
				{
					bolt(M=3, length=10, csk=true);
					translate([0,0,-5])
						rotate([0,0,25])
							nut(M=3);
				}
	}
}

module z_carriage_render_for_milling()
{
	
}
