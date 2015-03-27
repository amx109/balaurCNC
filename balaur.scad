/*** custom *****/
use <briefcase.scad>
use <tslot.scad>
use <hinge.scad>
use <LM__UU.scad>
use <LM__UUOP.scad>
use <SRSS__.scad>
use <x_carriage.scad>
use <y_carriage.scad>
use <z_carriage.scad>
use <belts.scad>
use <stepper-motors.scad>
use <ironmongery.scad>
use <pullies.scad>
use <FTSU.scad>
use <toggle_clamp.scad>

/*************************** variables *****************************/ 
$fn=50;

/* suitcase internal dimensions 460x330x160 */
base_height = 3;
A4_width = 210;
A4_length = 297;

tslot_size = 30; // we're going to use 30mm tslot

folded = 0;

//variables to fiddle with Y axis position/A4 bed X axis position
YZaxis_X_position = 0;    // was -80;
Yaxis_position    = -105; //-105 for non-y drive end, 105 for y drive end
Yaxis_Z_position  = folded ? 290 : 110; //110 = Z0, maxZ = 219. build height in Z is 219-110 = 109mm

Yaxis_seperation = 56; //mendel90 uses 56mm width for rails. copy copy

moveBed = 0;
bedleftright = 0; // 1 = left
bed_X_shift = moveBed ? (bedleftright ? -A4_length/2 : A4_length/2) : (folded ? -60 : 0);

nemaTypeX = "JAN";
nemaTypeY = "JAN";
nemaTypeZ = "17SWantai";

brace_wall_thickness = 3;
Zfloor = tslot_size+brace_wall_thickness;
Zheight = case_bottom_int_Y(); //max height of Z axis from Zfloor
threaded = false;

echosize("Print height is", Zheight-110);
echo(str("Item: Aluminium Sheet: (A3) 420x297x3 WxDxH")); //for BOM generation

/************************* render methods *************************/
draw();
*render_for_milling();
*render_for_3d_printing();
*finger_join_example();
*x_carriage(113.5, 93);
/*****************************************************************/

module draw()
{
	/* ***** built from the bottom up *******
	 * 3d_head
	 * bed
	 * y carriage
	 * y axis
	 * z axis
	 * hinge
	 * x axis
	 * base
	 * suitcase
	 */
	
	echosize("gap between A4 print area and tslot",(case_bottom_int_Y()/2)-(A4_width/2)-tslot_size);
	
	translate([YZaxis_X_position,0,0])
	{
		translate([	folded ? -170 : 0,
					0,
					folded ? Yaxis_seperation+18-9 : 0]) //raise the thing
		
		rotate([0,folded ? 87 : 0,0]) //angle to rotate
		{
			/********* Y axis **********/
			Yaxis();
			/********* Z axis *********/
			Zaxis();
		}
	}
	
	/********* X axis *************/
	Xaxis();
	
	/**** base for the whole machine - will sit inside the suitcase
	 **** floor of the machine is the top surface of the base ****
	 **** it is considered origin (or zero) for the Z axis ****/
	translate([0,0,-base_height])
		*base(base_height);
	
	/************* suitcase *************/
	echo(str("Item: Briefcase ",caseX(),"x",caseY(),"x",caseZ()));
	color("Gainsboro")
		translate([0,0,(case_bottom_ext_Z()/2)-base_height-(case_bottom_ext_Z()-case_bottom_int_Z())])
			*briefcase();
	
	/************* height markers *************/
	translate([-230, 0, -base_height-(case_bottom_ext_Z()-case_bottom_int_Z())])
	{
		%translate([0, 0, case_bottom_ext_Z()-0.5])
			cube(size=[10, 300, 1], center=true); //lip of bottom part
		echosize("height from floor of lip of bottom half",case_bottom_ext_Z());
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
	
	// a frame made out of tslot - goes in both X and Y directions
	for(i=[0,1])
	{
		// the tslot for x axis 
		mirror([0,i,0])
			translate([0, (case_bottom_int_Y()/2)-tslot_size/2, 0])
			{
				translate([0,0,tslot_size/2]) tslot(tslot_size, case_bottom_int_X());
				
				//tslot nuts+screws for bottom+base
				
				//tslot connector to secure
				
				//precision locators for Y/Z axis
				translate([case_bottom_int_X()/2, 0, tslot_size])
				{
					translate([-((case_bottom_int_X()-NEMA_width(nemaTypeZ))/2-12)/2, 0, brace_wall_thickness/2]) 
						doobery((case_bottom_int_X()-NEMA_width(nemaTypeZ))/2-12);
					
					translate([-20,0,0])
					{
						translate([0,0,-5.2]) tslot_nut(tslot_size, 4);
						translate([0,0,3]) bolt(4,10, threaded=threaded);
					}
					translate([-((case_bottom_int_X()-NEMA_width(nemaTypeZ))/2-12)+7,0,0])
					{
						translate([0,0,-5.2]) tslot_nut(tslot_size, 4);
						translate([0,0,3]) bolt(4,10, threaded=threaded);
					}
				}
				
				//anchors for Y/Z axis
				translate([-NEMA_width(nemaTypeZ)/2-10, 0, brace_wall_thickness/2+tslot_size]) 
					translate([i==0 ? -NEMA_width(nemaTypeY)-3:0, 0, 0]) //move further back on far side cos of Y axis stepper
					{
						anchor();
						translate([-5,0,-7]) tslot_nut(tslot_size, 4);
						translate([0,0,4]) bolt(4,10,threaded=threaded);
					}
			}
		
		//tslot for bracing of x axis, in the y direction
		mirror([i,0,0])
			translate([((case_bottom_int_X())/2)-tslot_size/2, 0, tslot_size/2])
				rotate ([0,0,90])
					tslot(tslot_size, case_bottom_int_Y()-(tslot_size*2));
	}
	
	//rails for x carriage
	for(i=[0,1])
	mirror([0,i,0])
	translate([0,tslot_size-case_bottom_int_Y()/2,15])
		rotate([0,90,90])
			FTSU(12, 380);
	
	//x carriage
	*translate([YZaxis_X_position+bed_X_shift, 0, 0])
	{
		x_carriage(	case_bottom_int_Y()/2-tslot_size-FTSU_height(12),
					-base_height
					-(case_bottom_ext_Z()-case_bottom_int_Z())
					+case_bottom_ext_Z() //all this upto here puts the bed on the lip
					+7);
	
		color("LightCoral")
			translate([	0,
						0,
						-base_height
						-(case_bottom_ext_Z()-case_bottom_int_Z())
						+case_bottom_ext_Z() //all this upto here puts the bed on the lip
						+7+4])
				a4Bed(5, bed_height=3);
			}
	
	//motor
	translate([-case_bottom_int_X()/2+tslot_size+NEMA_width(nemaTypeX)/2,0,NEMA_width(nemaTypeX)/2])
		rotate([90,0,0])
			nema_motor(nemaTypeX);
	echo("********************** X Axis END *****************************");
}

module Yaxis()
{
	echo("***************************************************************");
	echo("*                          Y Axis                             *");
	echo("*                                                             *");
	echo("*                                                             *");
	echo("***************************************************************");
	
	echosize("Y axis rail seperation", 56);
	echosize("Y axis length", case_bottom_int_Y()-10);
	
	beltBearingX = -Yaxis_seperation/2-8;
	beltBearingY1 = -(case_bottom_int_Y()/2-7.25);
	beltBearingY2 = -beltBearingY1;
	beltBearing_dia = 6;
	
	idlerBearingX = beltBearingX-2;//-Yaxis_seperation/2-0.7;
	idlerBearingY = beltBearingY2-7.5;//147.65;
	idlerBearing_dia = 6;
	
	yDrivePulley_x = -NEMA_width(nemaTypeY)-3;//-16;
	yDrivePulley_y = case_bottom_int_Y()/2-NEMA_width(nemaTypeY)/2-brace_wall_thickness; //case_bottom_int_Y()/2-brace_wall_thickness-14;
	drivePulley_dia = 9.68;
	
	//everything that moves along the Y axis goes here
	translate([0,0,Yaxis_Z_position])
	{
		//rails
		for(i=[0,1])
			mirror([i,0,0])
				translate([Yaxis_seperation/2,0,0]) 
					rotate([90,0,0])
						linear_rod(8,case_bottom_int_Y()-(brace_wall_thickness+1)*2); //1mm clearance to the bracing
		
		//carriage
		translate([0,Yaxis_position,0])
		{
			y_carriage(Yaxis_seperation);
			color("DarkGray")
			//render()
			*translate([-12.5,-12.5,-10.5])
			{
				import("E3D_Hot_end.stl"); //hotend
			}
			
			spindle_dia = 28;
			spindle_length = 28;
			shaft_dia = 8;
			shaft_length = 16;
			
			translate([0,0,(spindle_length)/2+15])
			{
				cylinder(d=spindle_dia, h=spindle_length, $fn=50, center=true);
				translate([0,0,-(spindle_length)/2-(shaft_length/2)]) cylinder(d=shaft_dia, h=shaft_length, $fn=50, center=true);
			}
		}
		
		//belt tensioner bearing spindles at either end of Y
		for(i=[-1,1])
			translate([beltBearingX, i*beltBearingY1, -11.3])
			{
				translate([0,0,-4]) nut(3, nyloc=true); //bottom nut
				translate([0,0,19]) linear_rod(3, 60, threaded);
				translate([0,0,25]) nut(3, nyloc=true); //top nut
				for(i=[0,1,2,3,4]) translate([0,0,27.5+2.5*i+0.1*i]) bearing(6, 3, 2.5, "MR63ZZ"); //MR63ZZ*5
				translate([0,0,40.5]) nut(3, nyloc=true); //top top nut
			}
		
		//middle tensioner before belt returns to y carriage
		translate([idlerBearingX, idlerBearingY, 24]) 
		{
			color("silver")
			intersection()
			{
				cube(size=[3,2,18], center=true);
				cylinder(d=3, h=18, $fn=50, center=true);
			}
			for(i=[0,1,2,3,4])
				translate([0, 0, -7.7+2.5*i+0.1*i]) bearing(6, 3, 2.5, "MR63ZZ"); //MR63ZZ
		}
		
		//belts
		translate([0,0,21]) 
		{
			difference() //y carriage belt
			{
				gimme_belt("GT2", beltBearingX, beltBearingY1, beltBearing_dia/2, beltBearingX, beltBearingY2, beltBearing_dia/2);
				translate([beltBearingX+3,Yaxis_position,0]) cube(size=[3,80,10], center=true); //gap in y carriage
				translate([beltBearingX-3,0,0]) cube(size=[3,310,10], center=true); //gap in y carriage
				*translate([-Yaxis_seperation/2-4, 150+1.5, 1.9]) cube(size=[10,8,10], center=true);
			}
			difference() // y pulley (non y drive end) to y drive pulley idler
			{
				gimme_belt("GT2", beltBearingX, beltBearingY1, beltBearing_dia/2, idlerBearingX+7.3, idlerBearingY, beltBearing_dia/2);
				translate([beltBearingX+4.5,0,0]) rotate([0,0,-0.7]) cube(size=[8,310,10], center=true); //gap in y carriage
			}
			difference() // y drive pulley idler to y drive pulley
			{
				gimme_belt("GT2", yDrivePulley_x, yDrivePulley_y, drivePulley_dia/2, idlerBearingX-9.5, idlerBearingY+7.5, beltBearing_dia/2);
				translate([beltBearingX-15,beltBearingY2-5,0]) cube(size=[20,25,10], center=true); //gap in y carriage
			}
			difference() // y drive pulley idler special belt
			{
				gimme_belt("GT2", idlerBearingX, idlerBearingY, beltBearing_dia/2, idlerBearingX, idlerBearingY, beltBearing_dia/2);
				translate([beltBearingX-2.5,beltBearingY2-10.5,0]) cube(size=[5,4,10], center=true); //gap in y carriage
			}
			difference() // y pulley (non y drive end) to y drive pulley
			{
				gimme_belt("GT2", yDrivePulley_x, yDrivePulley_y, drivePulley_dia/2, beltBearingX, beltBearingY2, beltBearing_dia/2);
				translate([beltBearingX,beltBearingY2-10,0]) rotate([0,0,-25]) cube(size=[8,40,10], center=true); //gap in y carriage
			}
		}
		
		//flat plate above bar clamp with holder for extra pulley
		translate([-Yaxis_seperation/2, beltBearingY2, -11.3])
		{
			difference() 
			{
				color("silver")
				//translate([0, 0, 11.3+9.5]) linear_extrude(height=3) roundedSquare(pos=[Yaxis_seperation/2.5,6.5],r=3); //width=22.4
				translate([0, 0, 11.3+9.5+3/2]) roundRect([Yaxis_seperation/2.5, 6.5, 3], 3); //width=22.4
			}
		}
		
		//bottom brace for z carraige at y drive end
		//translate([0, beltBearingY2, -15.5]) linear_extrude(height=3) roundedSquare(pos=[78, 6.7],r=3);
		translate([0, beltBearingY2, -15.5+3/2]) roundRect([78, 6.7, 3], 3);
	}
	
	//y drive (vertical) bits
	translate([-NEMA_width(nemaTypeY)-3, case_bottom_int_Y()/2-NEMA_width(nemaTypeY)/2-brace_wall_thickness, Zfloor+NEMA_length(nemaTypeY)])
	{
		translate([0,0, Yaxis_Z_position-Zfloor-NEMA_length(nemaTypeY)+35])
		{
			rotate([0,0,0]) 
			{
				SRSSZY(6); //srss bushing
				translate([0,0,-6.35]) cylinder(d=(9/16*25.4), h=6.35, $fn=6, center=true); //nut
				translate([0,0,-25.5]) rotate([0,0,0]) gt2_small(); //GT2_16
			}
		}
		
		translate([0, 0, (Zheight-NEMA_length(nemaTypeY)-NEMA_shaft_length(nemaTypeY))/2+NEMA_shaft_length(nemaTypeY)+1])
			SRSS_rod(6, Zheight-NEMA_length(nemaTypeY)-NEMA_shaft_length(nemaTypeY)); //spline shaft
		
		translate([0,0,32/2+NEMA_boss_height(nemaTypeY)+5])
			color("silver") cylinder(d=10, h=32, $fn=50, center=true); //coupler
		
		rotate([0,0,90]) nema_motor(nemaTypeY); //stepper
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
	
	echosize("distance of center axis of smooth rod from inner wall of bracing", 8/2+12);
	
	/*  ///// screw rod //////
	* 
	* M6 screw rod isnt 6mm in diameter
	* specs say major diameter is 5.79(min) and 5.97(max). so we're going with 5.9
	*/
	threaded_rod_dia = 5.9;
	threaded_rod_length = Zheight-NEMA_length(nemaTypeZ)-NEMA_boss_height(nemaTypeZ)-NEMA_shaft_length(nemaTypeZ);
	Z_bearing_type = "LM8";
	
	rod_dia = LM_rod_dia(Z_bearing_type);
	rodYoffset = brace_wall_thickness+LM_dia(Z_bearing_type)/2+1; //distance of centre of y axis (rod) from outside face of brace wall (1mm gap)
	rodY = case_bottom_int_Y()/2-rodYoffset;
	
	echo(str("rody: ",rodY,", rodyoffset: ",rodYoffset,""));
	// in this layout the central smooth rod will be the centreline for the z axis
	// there was regret. we only mirror z lifty bit now
	
	//bracing for Y/Z
	echo(str("*************** Bracing    *******************"));
	color("darkgray")
	translate([0, 0, Zfloor-brace_wall_thickness]) 
		rotate([0,0,90])
			brace(	brace_wall_thickness,
					case_bottom_int_Y(),
					Zheight,
					NEMA_width(nemaTypeZ), //gauge
					net=false);
	
	echo(str("*************** Z lifty bit ******************"));
	for(i=[1,-1])
	{
		translate([0, i*rodY, Zfloor])
		{
			translate([0, -15*i, NEMA_length(nemaTypeZ)])
			{
				rotate([0,0,90]) nema_motor(nemaTypeZ); //stepper
				
				//motor mount
				*rotate([0,0,i==-1 ? 180 : 0])
					motor_mount_plate(nemaTypeZ, rodYoffset+15-brace_wall_thickness-NEMA_width(nemaTypeZ)/2);
				
				//threaded rod
				translate([0, 0, threaded_rod_length/2+NEMA_shaft_length(nemaTypeZ)+2])
					linear_rod(threaded_rod_dia, threaded_rod_length, threaded);
				
				//z-motor-threaded-rod coupler
				echo(str("Item: Shaft Coupler (5mm to 6mm) 25mm (length) x 18mm (dia)")); //for BOM generation
				color("silver")
				translate([0, 0, 25/2+NEMA_boss_height(nemaTypeZ)+1])
					cylinder(d=18, h=25, $fn=50, center=true);
			}
		
			//linear rods
			translate([0, 0, NEMA_length(nemaTypeZ)+(Zheight-NEMA_length(nemaTypeZ))/2-3/2])
				linear_rod(diameter=rod_dia, length=Zheight-NEMA_length(nemaTypeZ)-3);
				
			//z_carriage
			translate([0, 0, Yaxis_Z_position+17.4-Zfloor])
				mirror([0,i==1?1:0,0])
					z_carriage(Z_bearing_type, Yaxis_seperation);
		}
	}
	
	*for(i=[1,-1])
		translate([20/2+NEMA_width(nemaTypeZ)/2+20, i*(case_bottom_int_Y()/2-tslot_size/2+5), (Zheight-3)/2+tslot_size+3])
				rotate([0,90,0])
					tslot(20, Zheight-3);
	
	echo("********************** Z Axis END *****************************");
}

module motor_mount_plate(nemaType, extra_depth)
{
	echo("******************* stepper motor mount **********************");
	
	plate_height = 3;
	
	color("MediumSeaGreen")
	render()
	difference()
	{
		union()
		{
			//bottom plate
			translate([0, extra_depth/2, plate_height/2])
				cube(size=[NEMA_width(nemaType), NEMA_width(nemaType)+extra_depth, plate_height], center=true); 
			
			//y rod cylindrical holder
			translate([0, 15, plate_height+20/2])
				cylinder(d=14, h=20, $fn=50, center=true); 
			
			//supports for y rod holder
			for(i=[0,1])
				mirror([i, 0, 0])
					translate([5.9, 15-2.5, plate_height-0.1])
						rotate([0,0,-25])
							fillet(NEMA_width(nemaType)/2-14/2, 5, 20); 
			
			//fillet for the 90 deg angle
			difference()
			{
				translate([0, NEMA_width(nemaType)/2-(3-extra_depth)+0.1, plate_height-0.1])
					rotate([0,0,-90])
						fillet(5,NEMA_width(nemaType),5); 
				
				//gap for the stepper screws
				for(i=[0,1])
					mirror([i, 0, 0])
						translate([NEMA_hole_pitch(nemaTypeZ)/2, NEMA_hole_pitch(nemaTypeZ)/2, 0])
							cylinder(d=7, h=10, $fn=50, center=true); 
			}
			
			//attachment face for brace wall
			difference()
			{
				translate([0, NEMA_width(nemaType)/2+extra_depth-plate_height/2, 20/2+plate_height])
					cube(size=[NEMA_width(nemaType), plate_height, 20], center=true); 
					
				//bolt holes for bracing attachment
				for(i=[1,-1])
					translate([i*15,NEMA_width(nemaType)/2+2.35+0.1,17])
						rotate([-90,0,0])
							cylinder(d=5, h=10, $fn=50, center=true);
			}
		}
		
		translate([0,NEMA_boss_radius(nemaTypeZ)+4,20]) cylinder(d=8, h=50, $fn=50, center=true); // Y rod
		translate([0,0,0]) cylinder(d=NEMA_boss_radius(nemaTypeZ)*2, h=50, $fn=50, center=true); // nema boss - bit at the top of the motor
		
		for(i=[1,-1])
			for(j=[1,-1])
					translate([i*NEMA_hole_pitch(nemaTypeZ)/2,j*NEMA_hole_pitch(nemaTypeZ)/2,0])
						cylinder(d=3, h=10, $fn=50, center=true); //screw holes
	}
	
	//screws for stepper
	for(i=[1,-1])
			for(j=[1,-1])
				translate([i*NEMA_hole_pitch(nemaTypeZ)/2,j*NEMA_hole_pitch(nemaTypeZ)/2,plate_height+1])
				{
					bolt(M=3,length=4+plate_height, threaded=threaded);
					translate([0,0,-0.5]) washer(3);
				}
	
	//brace wall screws+nuts
	for(i=[1,-1])
		translate([i*15, NEMA_width(nemaType)/2+3+0.1, 17])
			rotate([-90,0,0])
			{
				bolt(4,10, csk=true, threaded=threaded);
				translate([0,0,-5.5])
					nut(4);
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
						translate([i*-(NEMA_width(nemaTypeZ)+wall_thickness+2.45)/2, 0, 0])
						{
							difference()
							{
								cube(size=[NEMA_width(nemaTypeZ)+wall_thickness+2.45, gauge, wall_thickness], center=true);
								
								translate([i*-(((NEMA_width(nemaTypeZ)+wall_thickness+2.45)/2)-NEMA_width(nemaTypeZ)/2),0,0]) //screw holes
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
					for(j=[1,-1])
						translate([15*j,-height/2+NEMA_length(nemaTypeZ)+20,0])
							cylinder(d=4, h=25, $fn=50, center=true);
							
					//bit to make it fit over the doobery
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
					
					translate([1.5, extra_depth/2, 0]) 
						cylinder(d=8, h=10, $fn=50, center=true);
					
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

*translate([0, 0, Zfloor-brace_wall_thickness]) 
		rotate([0,0,90])
			brace(	brace_wall_thickness,
					case_bottom_int_Y(),
					Zheight,
					NEMA_width(nemaTypeZ), //gauge
					net=false);

module finger_join(male, type, length)
{
	/*
	 * male - defines which end of the join you want. male/female isnt really an accurate description (i couldnt think of anything better)
	 * type - 0 for finger, 1 for 'normal' flat, 2 for magic
	 * 
	 */
	
	finger_width = 7;
	moo = length/finger_width;
	
	render()
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

module base(base_height)
{
	//bottom of the base is z=0
	echo(str("Item: Dibond baseboard: ",case_bottom_int_X(),"x",case_bottom_int_Y(),"x",base_height," W x D x H"));
	color("GhostWhite")
		//linear_extrude(height = base_height) roundedSquare(pos=[case_bottom_int_X(),case_bottom_int_Y()], r=base_height);
		translate([0,0,base_height/2]) roundRect([case_bottom_int_X(), case_bottom_int_Y(), base_height], base_height);
}

module a4Bed(padding, bed_height) //padding in addition to a4 size
{
	echo(str("Item: Dibond bed ",A4_length+padding,"x",A4_width+padding,"x",bed_height," W x D x H"));
	cube(size=[A4_length+padding, A4_width+padding, bed_height], center=true);		
	echosize("A4 bed",str(A4_length+padding, "x", A4_width+padding, "x",bed_height));
}

module doobery(length, net=false)
{
	color("silver")
	render()
		difference()
		{
			//alu strip
			cube(size=[length,tslot_size,brace_wall_thickness], center=true);
			
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
			translate([0, net ? 0:-brace_wall_thickness/2, 0])
				cube(size=[10, tslot_size-brace_wall_thickness, brace_wall_thickness], center=true);
			cylinder(d=4, h=10, $fn=50, center=true);
		}
		
		translate([net ? -10-3-1:(11-10)/2, 0, net ? 0:brace_wall_thickness])
			difference()
			{
				translate([0, net ? 0:-brace_wall_thickness/2, 0]) 
					cube(size=[11, tslot_size-brace_wall_thickness, brace_wall_thickness], center=true);
				translate([-0.5,0,0])
					cylinder(d=4, h=10, $fn=50, center=true);
			}
	}
}

module render_for_milling()
{
	translate([0, 0, -3]) 
		rotate([0,0,90])
			color("black")
				cube(size=[420, 297, 1], center=true); //A3
				
	translate([3,51,0]) 
		brace(	brace_wall_thickness,
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
