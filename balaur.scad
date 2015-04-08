use <briefcase.scad>
use <tslot.scad>
use <SRSS__.scad>
use <x_carriage.scad>
use <y_carriage.scad>
use <z_carriage.scad>
use <belts.scad>
use <stepper-motors.scad>
use <ironmongery.scad>
use <pullies.scad>
use <toggle_clamp.scad>
use <hiwin.scad>

/*************************** variables *****************************/ 
$fn=50;

A4_width = 210;
A4_length = 297;

tslot_size = 30; // we're going to use 30mm tslot
Yaxis_seperation = 56; //mendel90 uses 56mm width for rails. copy copy

nemaTypeX = "JAN";
nemaTypeY = "JAN";
nemaTypeZ = "17SWantai";

base_height = 3;
wall_material_thickness = 3;
Zfloor = tslot_size+wall_material_thickness;
Zheight = case_bottom_int_Y(); //max height of Z axis from Zfloor
threaded = false; //used to set screw threads on things. mostly for BOM generation 

// to enable folding and X carriage bed moving, change these variables to 0 or 1
folded = 0;
moveBed = 0;
bedleftright = 0; // 1 = along -ve X, 0 = along +ve X - both at max positions

//variables to fiddle with Y axis position/A4 bed X axis position
bed_X_shift = moveBed ? (bedleftright ? -A4_length/2 : A4_length/2) : (folded ? -60 : 0); //sets x carriage position, do not touch
Yaxis_position    = -105; //-105 for non-y drive end, 105 for y drive end
Yaxis_Z_position  = folded ? 290 : 110; //110 = Z0, maxZ = 219. build height in Z is 219-110 = 109mm

echosize("Print height is", Zheight-110);
echo(str("Item: Aluminium Sheet: (A3) 420x297x3 WxDxH")); //for BOM generation

/************************* render methods *************************/
draw();
*render_for_milling();
*render_for_3d_printing();

module draw()
{
	/* intention is for you to view the cnc from side on (toggle clamps to the right)
	*  X axis is left to right
	*  Y axis is front to back
	*  Z is up/down
	*/
	translate([	folded ? -170 : 0,
				0,
				folded ? Yaxis_seperation+18-9 : 0]) //on folded, raise the YZ to enable rotation
		rotate([0,folded ? 87 : 0,0]) //angle to rotate when folded
		{
			Yaxis();
			Zaxis();
		}
	
	Xaxis();
	
	/**** base for the whole machine - will sit inside the suitcase.
	 **** floor of the machine is the top surface of the base ****
	 **** it is considered origin (or zero) for the Z axis    ****/
	translate([0,0,-base_height])
		*base(base_height);
	
	translate([0,0,(case_bottom_ext_Z()/2)-base_height-(case_bottom_ext_Z()-case_bottom_int_Z())])
		*briefcase();
	
	/************* height markers *************/
	translate([-230, 0, -base_height-(case_bottom_ext_Z()-case_bottom_int_Z())])
	{
		%translate([0, 0, case_bottom_ext_Z()-0.5])
			cube(size=[10, 300, 1], center=true); //lip of bottom part
		echosize("height from floor to lip of bottom half",case_bottom_ext_Z());
		%translate([0, 0, case_bottom_ext_Z()+case_lid_int_Z()+0.5])
			cube(size=[folded?1000:10, 300, 1], center=true); //ceiling of top part
		echosize("inner ceiling height when closed", case_bottom_ext_Z()+case_lid_ext_Z());
	}
}

module Xaxis()
{
	echo("***************************************************************");
	echo("*                          X Axis                             *");
	echo("*                                                             *");
	echo("*                                                             *");
	echo("***************************************************************");
	
	x_mgn_bushing_type = "12C";
	
	// a frame made out of tslot - goes in both X and Y directions
	for(i=[0,1])
	{
		//we mirror one side of the X axis
		mirror([0,i,0])
			translate([0, (case_bottom_int_Y()/2)-tslot_size/2, 0])
			{
				//tslot
				translate([0,0,tslot_size/2])
					tslot(tslot_size, case_bottom_int_X());
				
				//tslot nuts+screws for bottom+base
				translate([case_bottom_int_X()/2-10, 0, 0])
				{
					rotate([0, 180, 0])
					{
						for(i=[0:(case_bottom_int_X()-10)/80])
							translate([i*80, 0, 0])
							{ 
								translate([0,0,0.6]) bolt(M=4, length=10, csk=true, threaded=threaded);
								translate([0,0,-5.5]) tslot_nut(tslot_size, M=4);
							}
					}
				}
				
				//tslot butterfly washer for securing 90deg tslot
				for(i=[1,-1])
					translate([i*(case_bottom_int_X()/2-tslot_size/2), -13, tslot_size/2])
					{
						rotate([-90,0,0])
							bolt(M=6, length=10, threaded=threaded, comments="button head");
						rotate([90,0,0])
							tslot_butterfly_washer(tslot_size);
					}
				
				//precision locators for Y/Z axis (doobery's)
				translate([case_bottom_int_X()/2, 0, tslot_size])
				{
					translate([-((case_bottom_int_X()-NEMA_width(nemaTypeZ))/2-12)/2, 0, wall_material_thickness/2]) 
						doobery((case_bottom_int_X()-NEMA_width(nemaTypeZ))/2-12);
					
					translate([-20,0,0])
					{
						translate([0,0,-5.2]) 	tslot_nut(tslot_size, M=4);
						translate([0,0,3]) 		bolt(4,10, threaded=threaded, comments="socket cap");
					}
					translate([-((case_bottom_int_X()-NEMA_width(nemaTypeZ))/2-12)+7,0,0])
					{
						translate([0,0,-5.2])	tslot_nut(tslot_size, M=4);
						translate([0,0,3]) 		bolt(4,10, threaded=threaded, comments="socket cap");
					}
				}
				
				//anchors for Y/Z axis
				translate([-NEMA_width(nemaTypeZ)/2-10, 0, wall_material_thickness/2+tslot_size]) 
					translate([i==0 ? -NEMA_width(nemaTypeY)-3:0, 0, 0]) //move further back on far side cos of Y axis stepper
					{
						anchor();
						translate([-5,0,-7]) tslot_nut(tslot_size, M=4);
						translate([0,0,4]) bolt(4,10,threaded=threaded, comments="socket cap");
					}
			}
		
		//tslot for bracing of x axis, in the y direction
		mirror([i,0,0])
			translate([((case_bottom_int_X())/2)-tslot_size/2, 0, tslot_size/2])
				rotate ([0,0,90])
					tslot(tslot_size, case_bottom_int_Y()-(tslot_size*2));
	}
	
	//mgn linear rails
	for(i=[0,1])
		mirror([0,i,0])
			translate([0, -case_bottom_int_Y()/2+tslot_size+mgn_rail_height(x_mgn_bushing_type)/2, tslot_size/2])
				rotate([-90,0,0])
				{
					mgn_rail("12C", case_bottom_int_X()-(tslot_size*2));
					
					//add ALL the threaded bolts and tslot nuts to secure it
					translate([-(case_bottom_int_X()-(tslot_size*2))/2+mgn_rail_mount_holes(x_mgn_bushing_type)[1], 0, 0])
					{
						bolt(M=3, length=10, threaded=threaded, comments="socket cap");
						translate([0, 0, -9.5]) tslot_nut(tslot_size, M=3);
						
						for(i=[2:2:(case_bottom_int_X()-(tslot_size*2))/mgn_rail_mount_holes(x_mgn_bushing_type)[0]])
							translate([i*mgn_rail_mount_holes(x_mgn_bushing_type)[0], 0, 0])
							{
								bolt(M=3, length=10, threaded=threaded, comments="socket cap");
								translate([0, 0, -9.5]) tslot_nut(tslot_size, M=3);
							}
					}
				}
	
	//x carriage and heated bed
	translate([bed_X_shift, 0, 0])
	{
		echo(case_bottom_int_Y()/2-tslot_size-mgn_rail_height(x_mgn_bushing_type)/2);
		x_carriage(	case_bottom_int_Y()/2-tslot_size-mgn_rail_height(x_mgn_bushing_type)/2,
					-base_height
					-(case_bottom_ext_Z()-case_bottom_int_Z())
					+case_bottom_ext_Z() //all this upto here puts the bed on the lip
					+7,
					x_mgn_bushing_type);
		
		translate([	0,
					0,
					-base_height
					-(case_bottom_ext_Z()-case_bottom_int_Z())
					+case_bottom_ext_Z() //all this upto here puts the bed on the lip
					+7+4])
			a4Bed(5, bed_height=3);
	}
	
	//motor+mounting plate+pulley+belt
	translate([-case_bottom_int_X()/2+NEMA_width(nemaTypeX)/2, 12.22/2, tslot_size+NEMA_length(nemaTypeX)+wall_material_thickness])
	{
		//gimme_belt(type, x1, y1, r1, x2, y2, r2, gap)
		translate([0, 0, 7]) 
			gimme_belt("GT2", 0, 0, 12.22/2, case_bottom_int_X()-tslot_size-6, 0, 12.22/2, 0);
		
		translate([0, 0, 19.5])
			rotate([180, 0, 0])
				pulley("GT2x20_5mm_bore");
		
		nema_motor(nemaTypeX);
		
		translate([0, 0, -NEMA_length(nemaTypeX)-wall_material_thickness/2])
		{
			x_motor_mount_plate(nemaTypeX);
			
			//bolts for the plate
			for(i=[1,-1])
				translate([-NEMA_width(nemaTypeX)/2+tslot_size/2, i*(NEMA_width(nemaTypeX)/2+10/2), 0])
				{
					bolt(M=4, length=10, threaded=threaded, comments="socket cap");
						translate([0, 0, -9.5]) rotate([0, 0, 90])
							tslot_nut(tslot_size, M=4);
				}
			
			//bolts for the motor
			translate([0,0,0])
			rotate([180,0,0])
			for(x = NEMA_holes(nemaTypeY))
					for(y = NEMA_holes(nemaTypeY))
						translate([x, y, 0])
							bolt(M=3, length=40, csk=true, threaded=threaded);
		}
	}
	
	//belt idler+tensioner
	translate([case_bottom_int_X()/2-tslot_size/2, 12.22/2, (wall_material_thickness+NEMA_length(nemaTypeX))/2+tslot_size])
	{
		rotate([0, 90, 0])
			tslot(tslot_size, wall_material_thickness+NEMA_length(nemaTypeX));
		
		//bolt+bearings
		translate([0, 0, 23])
		{
			translate([0, 0, 10])
				bolt(M=6, length=30, threaded = threaded, comments="socket cap");
			
			for(i=[0:2])
				translate([0, 0, (i*4.15)])
					bearing(12, 6, 4, "MR126ZZ");
		}
	}
	
	echo("********************** X Axis END *****************************");
}

module Yaxis()
{
	echo("***************************************************************");
	echo("*                          Y Axis                             *");
	echo("*                                                             *");
	echo("*                                                             *");
	echo("***************************************************************");
	
	echosize("Y axis rail seperation", Yaxis_seperation);
	echosize("Y axis length", case_bottom_int_Y()-10);
	
	bearing1 = [-Yaxis_seperation/2-8, -(case_bottom_int_Y()/2-7.25), 0];
	bearing2 = [-Yaxis_seperation/2-8, case_bottom_int_Y()/2-7.25, 0];
	bearing3 = [-Yaxis_seperation/2-15.4, case_bottom_int_Y()/2-13, 0];
	bearing4 = bearing3+[0, -22, 0];
	idlerBearing_dia = 6;
	
	yDriveSplineShaftSize = 6;
	yDrive = [-NEMA_width(nemaTypeY)-3, case_bottom_int_Y()/2-NEMA_width(nemaTypeY)/2-wall_material_thickness, 0];
	drivePulley_dia = 9.68;
	
	translate([0,0,Yaxis_Z_position])
	{
		//rails
		for(i=[0,1])
			mirror([i,0,0])
				translate([Yaxis_seperation/2,0,0]) 
					rotate([90,0,0])
						linear_rod(8,case_bottom_int_Y()-(wall_material_thickness+1+1)*2); //2mm clearance to the bracing
		
		//y carriage and different heads
		translate([0,Yaxis_position,0])
		{
			y_carriage(Yaxis_seperation);
			
			color("DarkGray")
			//render()
			translate([-12.5,-12.5,-10.5])
			{
				import("E3D_Hot_end.stl"); //hotend
			}
			
			spindle_dia = 28;
			spindle_length = 28;
			shaft_dia = 8;
			shaft_length = 16;
			
			*translate([0,0,(spindle_length)/2+15])
			{
				cylinder(d=spindle_dia, h=spindle_length, $fn=50, center=true);
				translate([0,0,-(spindle_length)/2-(shaft_length/2)]) cylinder(d=shaft_dia, h=shaft_length, $fn=50, center=true);
			}
		}
		
		//y drive (vertical) bits
		translate(yDrive+[0, 0, Zfloor+NEMA_length(nemaTypeY)-Yaxis_Z_position])
		{
			translate([0,0, Yaxis_Z_position-Zfloor-NEMA_length(nemaTypeY)+33])
			{
				//nut and pulley
				translate([0,0,-6.35]) cylinder(d=(9/16*25.4), h=6.35, $fn=6, center=true); 
				translate([0,0,-25.5]) rotate([0,0,0]) pulley("GT2x16_small"); 
				//translate([0,0,-25.5]) rotate([0,0,0]) pulley("GT2x20_8mm_bore"); 
				
				//srss bushing
				SRSSZY(yDriveSplineShaftSize); 
			}
			
			//spline shaft
			translate([0, 0, (Zheight-NEMA_length(nemaTypeY)-NEMA_shaft_length(nemaTypeY))/2+NEMA_shaft_length(nemaTypeY)+1])
				SRSS_rod(6, Zheight-NEMA_length(nemaTypeY)-NEMA_shaft_length(nemaTypeY)); 
			
			//coupler
			translate([0,0,25/2+NEMA_boss_height(nemaTypeY)+2])
				color("silver") cylinder(d=19, h=25, $fn=50, center=true); 
			echo(str("Item: Shaft coupler 5mm to 6.35mm (1/4 inch)")); //for BOM generation
			
			//motor
			rotate([0,0,90]) nema_motor(nemaTypeY);
			
			//screws
			translate([0,0,-NEMA_length(nemaTypeY)-1.2])
			rotate([180,0,0])
			for(x = NEMA_holes(nemaTypeY))
					for(y = NEMA_holes(nemaTypeY))
						translate([x, y, 0])
							bolt(M=3, length=40, csk=true, threaded=threaded);
		}
		
		//belt idler bearings at either end of Y
		for(i=[bearing1, bearing2])
			translate(i+[0,0,-11])
			{
				translate([0,0,36.5]) nut(3, nyloc=true); //top top nut
				for(i=[0:3])
					translate([0,0,26.2+2.5*i+0.1*i])
						bearing(6, 3, 2.5, "MR63ZZ"); //MR63ZZ*5
				translate([0,0,23.3]) nut(3, nyloc=true); //top nut
				translate([0,0,17]) linear_rod(3, 43, threaded);
				translate([0,0,-1]) nut(3, nyloc=true); //bottom nut
			}
		
		//yDrive pulley tensioner
		translate([0,0,-2])
		{
			render()
			for(i=[7.5,46.5])
				translate([0, 0, i])
					difference()
					{
						hull()
						{
							//bits over each bearing
							for(j=[bearing3, bearing4])
								translate(j+[0,0,0])
									cylinder(d=8, h=wall_material_thickness, $fn=50, center=true);
							
							//bit set back from the yDrive shaft
							translate(yDrive+[-SRSS_dia(yDriveSplineShaftSize)/2, 0, 0])
								cylinder(d=6, h=3, $fn=50, center=true);
						}
					
						//holes for the bearing rod
						for(j=[bearing3, bearing4])
								translate(j+[0,0,50/2])
									cylinder(d=3, h=50, $fn=50, center=true);
						
						//centre bit where the yDrive shaft is
						translate(yDrive+[0, 0, 50/2])
							cylinder(d=SRSS_dia(yDriveSplineShaftSize)+0.5, h=70, $fn=50, center=true);
					}
			
			//rod+bearings for tensioner
			for(i=[bearing3, bearing4])
				translate(i+[0,0,0])
				{
					translate([0,0,49]) nut(3, nyloc=true); //top nut
					translate([0,0,26]) nut(3, nyloc=true); //top stopper nut
					translate([0,0,24.5]) washer(M=3, dia=8); //washer
					translate([0,0,27]) linear_rod(3, 50, threaded);
					for(i=[0:1])
						translate([0,0,19.5+2.5*i+0.1*i])
							bearing(6, 3, 2.5, "MR63ZZ"); //MR63ZZ*5
					translate([0,0,17.5]) washer(M=3, dia=8); //washer
					translate([0,0,16]) nut(3, nyloc=true); //bottom stopper nut
					translate([0,0,5]) nut(3, nyloc=true); //bottom nut
				}
		}
		
		//belts
		translate([0, 0, 19])
		{
			//main belt along Y
			difference()
			{
				gimme_belt("GT2", bearing1[0], bearing1[1], idlerBearing_dia/2, bearing2[0], bearing2[1], idlerBearing_dia/2);
				
				//gap in belt for y carriage
				translate([bearing1[0]+3,Yaxis_position,0])
					cube(size=[3,70,10], center=true);
				
				translate([yDrive[0]+5.5,yDrive[1],0])
					cube(size=[3,18,10], center=true);
			}
			
			//belt around tensioner and yDrive pulley
			difference()
			{
				union()
				{
					gimme_belt("GT2", yDrive[0], yDrive[1], drivePulley_dia/2, bearing3[0]+5, bearing3[1]-5.5, idlerBearing_dia/2);
					gimme_belt("GT2", yDrive[0], yDrive[1], drivePulley_dia/2, bearing4[0]+5, bearing4[1]+5.5, idlerBearing_dia/2);
				}
				
				translate([yDrive[0]+4.5,yDrive[1],0])
					cube(size=[6,12.15,10], center=true);
				translate([yDrive[0]+9,yDrive[1],0])
					cube(size=[5.9,23,10], center=true);
			}
		}
	}
	
	echo("********************** Y Axis END *****************************");
}

module Zaxis()
{
	echo("***************************************************************");
	echo("*                          Z Axis                             *");
	echo("*                                                             *");
	echo("*                                                             *");
	echo("***************************************************************");
	
	/*
	* M6 screw rod isnt 6mm in diameter
	* specs say major diameter is 5.79(min) and 5.97(max). so we're going with 5.9
	*/
	
	threaded_rod_dia = 5.9;
	threaded_rod_length = Zheight-NEMA_length(nemaTypeZ)-NEMA_boss_height(nemaTypeZ)-NEMA_shaft_length(nemaTypeZ);
	Z_bushing_type = "12H";
	
	// there was regret. we only mirror z lifty bit now
	
	//bracing for Y/Z
	echo(str("*************** Bracing *******************"));
	color("darkgray")
	translate([0, 0, Zfloor-wall_material_thickness]) 
		rotate([0,0,90])
			brace(	wall_material_thickness,
					case_bottom_int_Y(),
					Zheight,
					NEMA_width(nemaTypeZ), //gauge
					net=false);
	
	echo(str("*************** Z lifty bit ******************"));
	for(i=[0,1])
		mirror([0,i,0])
			translate([0, -case_bottom_int_Y()/2+wall_material_thickness, tslot_size+wall_material_thickness])
			{
				//stepper section
				translate([0, NEMA_width(nemaTypeZ)/2, NEMA_length(nemaTypeZ)])
				{
					//threaded rod
					translate([0, 0, threaded_rod_length/2+NEMA_shaft_length(nemaTypeZ)+2])
						linear_rod(threaded_rod_dia, threaded_rod_length, threaded);
					
					//z-motor-threaded-rod coupler
					echo(str("Item: Shaft Coupler (5mm to 6mm) 25mm (length) x 18mm (dia)")); //for BOM generation
					color("silver")
					translate([0, 0, 25/2+NEMA_boss_height(nemaTypeZ)+1])
						cylinder(d=18, h=25, $fn=50, center=true);
					
					//stepper
					rotate([0,0,90])
						nema_motor(nemaTypeZ);
					
					//screws
					for(x = NEMA_holes(nemaTypeX))
						for(y = NEMA_holes(nemaTypeX))
							translate([x, y, -NEMA_length(nemaTypeX)+5])
								rotate([180, 0, 0])
									bolt(M=3, length=40, csk=true, threaded=threaded);
				}
				
				//mgn rail
				translate([	0,
							mgn_rail_height(Z_bushing_type)/2,
							(Zheight-NEMA_length(nemaTypeZ)-wall_material_thickness*2)/2+NEMA_length(nemaTypeZ)])
					rotate([0, 90, 90])
						rotate([0, 0, 180]) //rotated so 'start' of rail is at the bottom
							mgn_rail(Z_bushing_type, Zheight-NEMA_length(nemaTypeZ)-wall_material_thickness*2);
				
				//mgn bushings, and z carriage
				translate([0, 0, Yaxis_Z_position-20.3])
				{
					//brass nut
					color("khaki")
					translate([0, NEMA_width(nemaTypeZ)/2, 0])
						nut(M=6);
					
					//brass nut mounting plate
					translate([0, 3/2+mgn_rail_height(Z_bushing_type)+mgn_bushing_height(Z_bushing_type)/2+wall_material_thickness, 0])
						rotate([0, 90, 90])
							z_carriage_nut_mount(Z_bushing_type);
					
					//z bushing
					translate([0, mgn_rail_height(Z_bushing_type)/2, 0])
						rotate([0, 90, 90])
							mgn(Z_bushing_type);
					
					//z carriage
					translate([0, mgn_rail_height(Z_bushing_type)+mgn_bushing_height(Z_bushing_type)/2, 0])
						z_carriage(Z_bushing_type, Yaxis_seperation, wall_material_thickness);
					
					//z carriage bushing screws
					for(j=[1,-1])
						for(k=[1,-1])
							translate([j*mgn_bushing_holes(Z_bushing_type)[0]/2, 20, k*mgn_bushing_holes(Z_bushing_type)[1]/2])
								rotate([-90,0,0])
								{
									bolt(M=3, length=15, threaded=threaded, comments="socket cap");
									translate([0, 0, -0.5])
										washer(M=3);
								}
					
					//z carriage other screws
					for(j=[1,-1])
					{
						//top
						translate([j*(mgn_bushing_width(Z_bushing_type)/2+8/2), 2.8, mgn_bushing_length(Z_bushing_type)/2-3])
							rotate([90, 0, 0])
							{
								bolt(M=3, length=20, csk=true, threaded=threaded);
								translate([0, 0, -14])
									nut(M=3, nyloc=true);
							}
						
						//bottom middle
						translate([j*(mgn_bushing_width(Z_bushing_type)/2+4), 2.8, -mgn_bushing_length(Z_bushing_type)/2+2])
							rotate([90, 0, 0])
							{
								bolt(M=3, length=20, csk=true, threaded=threaded);
								translate([0, 0, -14])
									nut(M=3, nyloc=true);
							}
						
						//bottom outer
						translate([j*(mgn_bushing_width(Z_bushing_type)/2+25.5), 2.8, -mgn_bushing_length(Z_bushing_type)/2+3])
							rotate([90, 0, 0])
							{
								bolt(M=3, length=10, csk=true, threaded=threaded);
								translate([0, 0, -5])
									nut(M=3, nyloc=true);
							}
					}
				}
			}
	
	echo("********************** Z Axis END *****************************");
}

module z_carriage_nut_mount(Z_bushing_type)
{
	color("lightgray")
	render()
	difference()
	{
		union()
		{
			cube(size=[mgn_bushing_length(Z_bushing_type)-20, mgn_bushing_width(Z_bushing_type)-1, wall_material_thickness], center=true);
			for(i=[1,-1])
				for(j=[1,-1])
					translate([i*mgn_bushing_holes(Z_bushing_type)[0]/2, j*mgn_bushing_holes(Z_bushing_type)[1]/2], 0)
						cylinder(d=8.5, h=wall_material_thickness, $fn=50, center=true);
		}
		
		//screw holes
		for(i=[1,-1])
			for(j=[1,-1])
				translate([i*mgn_bushing_holes(Z_bushing_type)[0]/2, j*mgn_bushing_holes(Z_bushing_type)[1]/2], 0)
					cylinder(d=3, h=10, $fn=50, center=true);
		
		//hole for the nut
		translate([0, 0, 0.1])
			cube(size=[4.8, 10, wall_material_thickness], center=true);
		
		//track for the thread
		translate([0, 0, 3/2])
			cube(size=[100, 6, 3], center=true);
	}
}

module x_motor_mount_plate(nemaType)
{
	color("lightgray")
	render()
	union()
	{
		difference()
		{
			cube(size=[NEMA_width(nemaType),NEMA_width(nemaType),3], center=true);
			for(x = NEMA_holes(nemaType))
					for(y = NEMA_holes(nemaType))
						translate([x, y, 0])
							cylinder(d=3, h=10, $fn=50, center=true);
		}
		
		for(i=[1,-1])
			translate([-NEMA_width(nemaType)/2+tslot_size/2, i*(NEMA_width(nemaType)/2+10/2)+0.1/2, 0 ])
			{
				difference()
				{
					cube(size=[tslot_size, 10+0.1, wall_material_thickness], center=true);
					translate([0, 0, 0])
						cylinder(d=4, h=10, $fn=50, center=true);
				}
			}
	}
}

module brace(wall_thickness, width, height, gauge, net=false)
{
	/* 
	 * |#########|
	 * |         |  we model this!
	 * |_       _|
	 * 
	 * width = |#########|
	 * gauge = the 'depth' of the vertical bits
	 * 
	 * model this lying flat in its net layout then rotate+transform into position
	 */
	
	extra_depth = 20; //in -ve X of the horizontal brace bar for the vertical sections
	
	for(i=[1,-1])
	{
		//bottom motor plate
		color("lightblue")
		render()
		translate([net ? i*24+7:i*width/2, net ? i*gauge*0.85+48:0, net ? 0:wall_thickness/2]) 
			union()
			{
				difference()
				{
					union()
					{
						//z stepper platform
						translate([i*-(NEMA_width(nemaTypeZ)+wall_thickness)/2, 0, 0])
						{
							difference()
							{
								cube(size=[NEMA_width(nemaTypeZ)+wall_thickness, gauge, wall_thickness], center=true);
								
								translate([i*-(((NEMA_width(nemaTypeZ)+wall_thickness)/2)-NEMA_width(nemaTypeZ)/2),0,0]) //screw holes
									for(i=[1,-1])
										for(j=[1,-1])
											translate([(i*NEMA_hole_pitch(nemaTypeZ)/2), j*NEMA_hole_pitch(nemaTypeZ)/2, 0])
												cylinder(d=3, h=10, $fn=50, center=true);
							}
						}
						
						//y drive stepper platform
						if(i==1) //(only want this on one side)
							translate([-(NEMA_width(nemaTypeY)+wall_thickness)/2, gauge/2+(NEMA_width(nemaTypeY)+3)/2, 0])
							difference()
							{
								cube(size=[NEMA_width(nemaTypeY)+wall_thickness, NEMA_width(nemaTypeY)+3, wall_thickness], center=true);
								
								translate([i*-1.5,1.5,0]) //screw holes
									for(i=[1,-1])
										for(j=[1,-1])
											translate([(i*NEMA_hole_pitch(nemaTypeY)/2), j*NEMA_hole_pitch(nemaTypeY)/2, 0])
												cylinder(d=3, h=10, $fn=50, center=true);
							}
						
						//toggle clamp section
						translate([i*-tslot_size/2, -12/2-gauge/2, 0])
							cube(size=[tslot_size, 12, wall_thickness], center=true); 
					}
					
					//finger joints
					translate([i*(6/2-3), -extra_depth/2, 6/3-0.5+1])
						mirror([i==-1? 1:0,0,0])
							finger_join(1, 1, gauge+extra_depth);	//poisiton shape 3mm in from long edge, 1mm up from floor.
				}
				
				//rear anchor section
					translate([i*-tslot_size/2, (gauge/2+5/2)+(i==1? NEMA_width(nemaTypeY)+3:0), 0])
						cube(size=[tslot_size, 5, wall_thickness], center=true);
			}
		
		//vertical bits
		color("lightgreen")
		render()
		translate([	net ? i*(((-gauge-extra_depth)/2)-gauge/2+3)+7: i*(width/2-wall_thickness/2), 
					0,
					net ? 0:height/2])
			rotate([net ? (i==1?180:0):90, net ? (i==1 ? 0:180):0, net ? (i==1 ? 0:180):(i==1 ? 90:-90)])
				difference()
				{
					union()
					{
						//vertical part
						translate([i*-extra_depth/2, 0, 0]) 
							cube(size=[gauge+extra_depth, height, wall_thickness], center=true);
						
						//depth extension
						*translate([i*-(gauge/2+extra_depth/2), height/2-gauge/2, 0])
							cube(size=[extra_depth, gauge, wall_thickness], center=true);
					}
					
					//finger joints for bottom of vertical...
					translate([i*-(extra_depth/2-8/2), -height/2-6/2+1, -1-3/2]) 
						rotate([0, 0, -90])
							mirror([0, i==-1? 1:0,0])
								finger_join(0, 1, gauge+extra_depth-8); //position shape 1mm in from long edge, 1 from ceiling
					//...top of the vertical
					translate([i*-extra_depth/2, height/2+6/2-1, -6/2+3/2-1]) 
						rotate([0, 0, i==1 ? -90:90])
							mirror([i==1 ? 1:0, 0, 0])
								finger_join(0, 1, gauge+extra_depth); //position shape 1mm in from long edge, 1 from ceiling
					//...and horizontal brace bit (this should be illegal. im very sorry. not sorry.)
					translate([i*-(gauge/2+extra_depth), (height/2-gauge/2), -1.5-1]) 
						mirror([0, 0, i == -1 ? 1:0])
							rotate([0, i == 1? 180:0, 0]) 
									finger_join(1, 1, gauge);
					
					//holes for motor mount
					*for(j=[1,-1])
						translate([15*j,-height/2+NEMA_length(nemaTypeZ)+20,0])
							cylinder(d=4, h=25, $fn=50, center=true);
							
					//cutout bit to make it fit over the doobery
					translate([i*-(gauge/2+12+10/2), -height/2-4/2+3, 0])
						cube(size=[10, 4, 4], center=true);
				}
	}
	
	//width spanning brace
	color("red")
	render()
	translate([net ? gauge*3-3:0, net ? (width-height)/2:-(gauge/2+extra_depth-wall_thickness/2), net ? 0:height-gauge/2])
		rotate([net ? 180:90, 0, net ? 90:0])
			difference()
			{
				cube(size=[width, gauge, wall_thickness], center=true);
				
				//finger join for vertical section
				for(i=[0,1])
					mirror([i,0,0])
					{
						translate([width/2+6/2-1, 0, -1.5-1])
								finger_join(0, 1, gauge);
						
						//finger join for top-square section
						translate([-width/2+(20+25)/2, gauge/2+6/2-1, -6/2+3/2-1])
							rotate([0,0,-90])
								mirror([1,0,0])
									finger_join(0, 1, 20+25);
					}
			}
	
	color("white")
	render()
	for(i=[0,1])
		translate([net ? -5.5:0,0,0]) 
		mirror([i, 0, 0])
			translate([net ? i*-25:-width/2+20/2, net ? i*(gauge+extra_depth+5)-125:-extra_depth/2, net ? 0:height-3/2])
				rotate([net ? 180:0, 0, 0]) 
				difference()
				{
					union()
					{
						cube(size=[20, gauge+extra_depth, 3], center=true);
						
						translate([20/2-0.1, -(gauge+extra_depth)/2, 0])
							rotate([-90,0,0])
								fillet(25,3,20);
						
						translate([(20+25)/2+5, -(gauge+extra_depth)/2+3/2, 1])
							cube(size=[15, 3, 1], center=true);
					}
					
					//hole for the linear rod
					*translate([1.5, extra_depth/2, 0]) 
						cylinder(d=8, h=10, $fn=50, center=true);
					
					
					//curvy bits
					translate([20/2+0.1, gauge/2+extra_depth/2+0.01, 0])
						rotate([90,0,-90])
							fillet(20,10,22);
					
					translate([-20/2-6/2+3, 0, -1.5-1+0.01])
						rotate([0, 180, 0])
							finger_join(1, 1, gauge+extra_depth);
					
					translate([25/2, -(gauge+extra_depth)/2-6/2+3, -3/2-1+0.01])
						rotate([0, 0, -90])
							mirror([0,0,1])
								finger_join(1, 1, 20+25);
				}
}

module finger_join(male, type, length)
{
	/*
	 * male - defines which end of the join you want. male/female isnt really an accurate description (i couldnt think of anything better)
	 * type - 0 for finger, 1 for 'normal' flat, 2 for magic
	 * 
	 */
	
	finger_width = 7;
	moo = length/finger_width;
	
	difference()
	{
		union()
		{
			//the 'step'
			cube(size=[6, length, 6], center=true);
			
			//fingers
			if(type==0)
			{
				for(i=[-moo/4:moo/4])
					translate([	male ? 1:-1,
								male ? i*finger_width*2+finger_width/2:i*finger_width*2+finger_width*1.5, 
								male ? -2:2.5])
						cube(size=[4, finger_width, 4], center=true);
			}
			else 
			{
				if(type==1 && male)
				{
					translate([1, 0, -2])
						cube(size=[4, length, 4], center=true);
				}
			}
		}
		
		//extra bit to lop off any overlapping finger cutouts
		translate([0, length/2+20/2, male == 1? -3:3])
			cube(size=[10, 20, 10], center=true);
	}
}

module finger_join_example()
{
	color("lightgreen")
	render()
	translate([100/2-3/2, 0, 100/2+3/2-3])
		rotate([0, 90, 0])
			difference()
			{
				cube(size=[100,50,3], center=true);
				
				//position shape 1mm in from long edge, 1 from ceiling
				translate([100/2+6/2-1, 0, -1.5-1]) //finger has 1mm depth. cut 1.5mm
					finger_join(0, 1, 50);
			}
	
	
	render()
	difference()
	{
		cube(size=[100,50,3], center=true);
	
		//poisiton shape 3mm in from long edge, 1mm up from floor.
		translate([100/2+6/2-3, 0, 1.5+1]) //finger depth is 3mm. cut 2mm.
			finger_join(1, 1, 50);
	}
}

module base(height)
{
	echo(str("Item: Dibond baseboard: ",case_bottom_int_X(),"x",case_bottom_int_Y(),"x",height," W x D x H"));
	color("GhostWhite")
	render()
	translate([0,0,height/2]) roundRect([case_bottom_int_X(), case_bottom_int_Y(), height], height);
}

module a4Bed(padding, bed_height) //padding in addition to a4 size
{
	echo(str("Item: Dibond bed ",A4_length+padding,"x",A4_width+padding,"x",bed_height," W x D x H"));
	
	color("LightCoral")
	render()
	cube(size=[A4_length+padding, A4_width+padding, bed_height], center=true);
}

module doobery(length, net=false)
{
	color("silver")
	render()
		difference()
		{
			//alu strip
			cube(size=[length,tslot_size,wall_material_thickness], center=true);
			
			//holes for the M4 threaded bolts
			translate([length/2-20, 0, 0])
				cylinder(d=4, h=10, $fn=50, center=true);
			translate([-(length/2-7), 0, 0])
				cylinder(d=4, h=10, $fn=50, center=true);
				
			//holes for the toggle clamp
		}
	
	if(!net)
		translate([25-length/2,0,3/2])
			toggle_clamp();
}

module anchor(net=false)
{
	color("silver")
	render()
	{
		difference()
		{
			translate([0, net ? 0:-wall_material_thickness/2, 0])
				cube(size=[10, tslot_size-wall_material_thickness, wall_material_thickness], center=true);
			cylinder(d=4, h=10, $fn=50, center=true);
		}
		
		translate([net ? -10-3-1:(11-10)/2, 0, net ? 0:wall_material_thickness])
			difference()
			{
				translate([0, net ? 0:-wall_material_thickness/2, 0]) 
					cube(size=[11, tslot_size-wall_material_thickness, wall_material_thickness], center=true);
				translate([-0.5,0,0])
					cylinder(d=4, h=10, $fn=50, center=true);
			}
	}
}

module tslot_experimental_butterfly_washer(tslot_size, M)
{
	difference()
	{
		union()
		{	
			translate([0, 0, 0])
			difference()
			{
				cube(size=[tslot_gap(tslot_size), 15+15+15, 3], center=true);
				cylinder(d=M, h=10, $fn=50, center=true);
			}
			
			translate([0, 0, 0])
			difference()
			{
				cube(size=[tslot_gap(tslot_size)+4, 15, 3], center=true);
				cylinder(d=M, h=10, $fn=50, center=true);
			}
		}
		
		for(i=[1,-1])
			translate([0, i*(15/2+30/2), 2])
				#cube(size=[10,30,3], center=true);
	}
}

module render_for_milling()
{
	translate([0, 0, -3]) 
		rotate([0,0,90])
			color("black")
				cube(size=[420, 297, 1], center=true); //A3
				
	translate([3,51,0]) 
		brace(	wall_material_thickness,
				case_bottom_int_Y(),
				Zheight,
				NEMA_width(nemaTypeZ), //gauge
				net=1);
	
	for(i=[0,1])
	{
		translate([-90, 197-2-(i*30), 0])
			anchor(net=true);
		
		translate([-95-3-(i*34), 0, 0]) 
			rotate([0, 0, 90])
				doobery((case_bottom_int_X()-NEMA_width(nemaTypeZ))/2-12, net=true);
	}
}

module render_for_3d_printing()
{
	
}

module echosize(name, size)
{
	echo(str("Size of ",name,": ",size,"mm"));
}
