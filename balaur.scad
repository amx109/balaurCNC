/***** MCAD ************/
use <MCAD/2Dshapes.scad>
//use <MCAD/metric_fastners.scad>

/*** custom *****/
use <briefcase.scad>
use <tslot.scad>
use <hinge.scad>
use <LM__UU.scad>
use <LM__UUOP.scad>
use <SRSS__.scad>
use <z_carriage.scad>
use <y_carriage.scad>
use <belts.scad>
use <stepper-motors.scad>
use <ironmongery.scad>
use <pullies.scad>

/*************************** variables *****************************/ 
$fn=50;

/* suitcase internal dimensions 460x330x160 */
bed_base_height = 3;
A4_width = 210;
A4_length = 297;

tslot_size = 30; // we're going to use 30mm tslot

//variables to fuck with Y axis position/hinge/A4 bed

hinge_open = 0;
hinge_close_angle = 83.5; // Z axis must be at max height

YZaxis_X_position = -80;
Yaxis_position = 	80; //-105 for non-y drive end, 105 for y drive end
Yaxis_Z_position = 	110;//hinge_open? 219 : 110; //110 = Z0, maxZ = 219. build height in Z is 219-110 = 109mm

Yaxis_seperation = 56; //mendel90 uses 56mm width for rails

moveBed = 0;
bedleftright = 1; // 0 = left
bed_X_shift = moveBed ? (bedleftright ? -A4_length/2 : A4_length/2) : 0;

nemaTypeX = 17;
nemaTypeY = 17;
nemaTypeZ = "17S";

ZmotorWidth = NEMA_width(nemaTypeZ);

brace_wall_thickness = 3;
Zfloor = tslot_size+brace_wall_thickness;
Zheight = 240; //max height of Z axis from Zfloor
threaded = 0;

echosize("Print height is", 215-110);

draw();
module draw() /****** built from the bottom up *******/
{
	/*
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
	
	//some if's to set hinge open/closed params
	flipit  = hinge_open ? hinge_close_angle : 0; //the angle of folding
	raiseit = hinge_open ? Yaxis_seperation : 0; 
	
	echosize("gap between A4 print area and tslot",(case_bottom_int_Y()/2)-(A4_width/2)-tslot_size);
	
	translate([YZaxis_X_position,0,raiseit])
	{
		/************* bed *************/
		translate([	bed_X_shift,
					0,
					(case_bottom_ext_Z()
						-((case_bottom_ext_Z()-case_bottom_int_Z())
						+bed_base_height)
						+(3/2)) //heated_bed_height
						-raiseit
						+10]) //x carriage height
			color("LightCoral")
				*a4Bed(padding=0, heated_bed_height=3);
		
		rotate([0,flipit,0])
		{
			/********* Y axis **********/
			Yaxis();
			
			/********* Z axis *********/
			Zaxis();
			
			/**** ze hinge *****/
		}
	}
	
	/********* X axis *************/
	*Xaxis();
	
	/**** base for the whole machine - will sit inside the suitcase
	 **** floor of the machine is the top surface of the base ****/
	translate([0,0,-bed_base_height])
		*base();
	
	/************* suitcase *************/
	echosize("briefcase X Y Z",str(caseX(),"x",caseY(),"x",caseZ()));
	color("Gainsboro")
		translate([0,0,(case_bottom_ext_Z()/2)-bed_base_height-(case_bottom_ext_Z()-case_bottom_int_Z())])
			*briefcase();
	
	/************* height markers *************/
	translate([-230, 0, -bed_base_height-(case_bottom_ext_Z()-case_bottom_int_Z())])
	{
		%translate([0, 0, case_bottom_ext_Z()-0.5])
			cube(size=[10, 300, 1], center=true); //lip of bottom part
		echosize("height from floor of lip of bottom half",case_bottom_ext_Z());
		%translate([0, 0, case_bottom_ext_Z()+case_lid_int_Z()+0.5])
			cube(size=[hinge_open?1000:10, 300, 1], center=true); //ceiling of top part
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
	/***** a frame made out of tslot - goes in both X and Y directions ******/
	for(i=[0,1])
	{
		/***** the tslot for x axis *****/
		mirror([0,i,0])
		{
			translate([0, (case_bottom_int_Y()/2)-tslot_size/2, 0])
			{
				tslot_centered(case_bottom_int_X(), tslot_size);
			}
		}
		
		/*** tslot for bracing of x axis, in the y direction ***/
		mirror([i,0,0])
		{
			translate([((case_bottom_int_X())/2)-tslot_size/2, 0, 0])
				rotate ([0,0,90])
					tslot_centered(case_bottom_int_Y()-(tslot_size*2), tslot_size);
		}
	}
	
	//rails for the x carriage
	
	//x carriage
	x_carriage();
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
	beltBearingY1 = -(case_bottom_int_Y()/2-7.33);
	beltBearingY2 = -beltBearingY1;
	beltBearing_dia = 6;
	
	idlerBearingX = -Yaxis_seperation/2-0.7;
	idlerBearingY = 147.65;
	idlerBearing_dia = 6;
	
	yDrivePulley_x = -16;
	yDrivePulley_y = case_bottom_int_Y()/2-brace_wall_thickness-14;
	drivePulley_dia = 9.68;
	
	translate([0,0,Yaxis_Z_position])
	{
		//rails
		*for(i=[0,1])
			mirror([i,0,0])
				translate([Yaxis_seperation/2,0,0]) 
					rotate([90,0,0])
						linear_rod(8,case_bottom_int_Y()-(brace_wall_thickness+1)*2); //1mm clearance to the bracing
		
		//carriage
		*translate([0,Yaxis_position,0])
		{
			y_carriage(Yaxis_seperation); 
			color("DarkGray") translate([-12.5,-12.5,-10.5]) import("E3D_Hot_end.stl"); //hotend
		}
		
		//belts
		translate([0,0,21]) 
		{
			difference() //y carriage belt
			{
				gimme_belt("GT2", beltBearingX, beltBearingY1, beltBearing_dia/2, beltBearingX, beltBearingY2, beltBearing_dia/2);
				translate([beltBearingX+3,Yaxis_position,0]) cube(size=[3,80,10], center=true); //gap in y carriage
				translate([-Yaxis_seperation/2-4, 150+1.5, 1.9]) cube(size=[10,8,10], center=true);
			}
			difference() //bearing to bearing
			{
				gimme_belt("GT2", beltBearingX, beltBearingY2, beltBearing_dia/2, beltBearingX+Yaxis_seperation/3.5, beltBearingY2, beltBearing_dia/2);
				translate([beltBearingX+10, beltBearingY2-9, 0]) rotate([0,0,-19]) cube(size=[35,15,10], center=true);
			}
			difference() //bearing to y drive pulley
			{
				gimme_belt("GT2", beltBearingX+Yaxis_seperation/3.5, beltBearingY2, beltBearing_dia/2, yDrivePulley_x, yDrivePulley_y, drivePulley_dia/2);
				translate([beltBearingX+10, beltBearingY2-9, 0]) rotate([0,0,-19]) cube(size=[35,15,10], center=true);
			}
			difference() //y drive pulley to back of idler bearing
			{
				gimme_belt("GT2", yDrivePulley_x, yDrivePulley_y, drivePulley_dia/2, idlerBearingX+6.3, idlerBearingY+4, idlerBearing_dia/2);
				translate([beltBearingX+18,beltBearingY2,0]) rotate([0,0,49]) cube(size=[12,20,10], center=true);
			}
			difference() //idler bearing to carriage mount
			{
				gimme_belt("GT2", idlerBearingX, idlerBearingY, idlerBearing_dia/2, idlerBearingX, beltBearingY2-10, beltBearing_dia/2);
				translate([beltBearingX+9.3,beltBearingY2-10.5,0]) cube(size=[10,15,10], center=true);
			}
		}
		
		//drive pulley for Y axis belt
		translate([yDrivePulley_x, yDrivePulley_y, 39])
		{
			SRSSZY(3); //srss bushing
			translate([0,0,-3.2]) cylinder(d=(9/16*25.4), h=6.35, $fn=6, center=true); //nut
			translate([0,0,-6.4]) rotate([180,0,0]) gt2_small(); //GT2_16
		}
		
		//belt tensioner bearing spindle
		for(i=[-1,1])
		{
			translate([beltBearingX, i*beltBearingY1, -11.3])
			{
				translate([0,0,-4]) nut(3); //bottom nut
				translate([0,0,19]) linear_rod(3, 55, threaded);
				translate([0,0,25]) nut(3); //top nut
				for(i=[0,1,2,3,4]) translate([0,0,27.5+2.5*i+0.1*i]) bearing(6, 3, 2.5, "MR63ZZ"); //MR63ZZ*5
				translate([0,0,40.5]) nut(3); //top top nut
			}
		}
		
		//more belt tensioner
		translate([-Yaxis_seperation/2, beltBearingY2, -11.3])
		{
			//belt tensioner bearing spindle
			translate([Yaxis_seperation/7, 0, 0])
			{ 
				translate([0,0,-4]) nut(3); //bottom nut
				translate([0,0,19]) linear_rod(3, 55, 0);
				translate([0,0,25]) nut(3); //top nut
				for(i=[0,1,2,3,4]) translate([0,0,27.5+2.5*i+0.1*i]) bearing(6, 3, 2.5, "MR63ZZ"); //MR63ZZ*5
				translate([0,0,40.5]) nut(3); //top top nut
			}
			
			//belt tensioner bearing spindle thats part of the tslot
			difference() 
			{
				color("silver")
				translate([0, 0, 11.3+9.5]) linear_extrude(height=3) roundedSquare(pos=[Yaxis_seperation/2.5,6.5],r=3); //width=22.4
				//TODO bolt holes
			}
			
			translate([-0.7,-2.5,24+18/2-0.2])
			{
				color("silver")
				intersection()
				{
					cube(size=[3,1.5,18], center=true);
					translate([0,-0.5,0]) cylinder(d=3, h=18, $fn=50, center=true);
				}
				for(i=[0,1,2,3,4]) translate([0, -0.5, -7.7+2.5*i+0.1*i]) bearing(6, 3, 2.5, "MR63ZZ"); //MR63ZZ
			}
		}
		
		//bottom brace for motor end
		translate([0, beltBearingY2, -15.5]) cube(size=[78,6.7,3], center=true);
	}
	
	translate([yDrivePulley_x, yDrivePulley_y, Zfloor+NEMA_length(nemaTypeZ)])
	{
		translate([0, 0, (Zheight-NEMA_length(nemaTypeZ))/2])
			SRSS_rod(3, Zheight-NEMA_length(nemaTypeZ)); //srss rod
		for(i=[0:3])
			translate([0,0,3.96875/2+(3.96875*i)+0.1*i]) bearing(9.525, 3.175, 3.96875, "R2ZZ");
	}
	
	//stepper
	translate([-NEMA_width(nemaTypeY), case_bottom_int_Y()/2-NEMA_width(nemaTypeY)/2-brace_wall_thickness, Zfloor+NEMA_length(nemaTypeY)])
	{
		nema_motor(nemaTypeY);
		translate([0,0,5/2+NEMA_boss_height(nemaTypeY)]) cylinder(d=45, h=5, $fn=50, center=true);
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
	* specs say major diameter is 5.79(min) and 5.97(max). so we're going with 7.8
	*/
	threaded_rod_dia = 5.9;
	threaded_rod_length = 200;
	
	rod_dia = 8;
	rodX = 0;
	rodYoffset = brace_wall_thickness+LM8_dia()/2+1; //distance of centre of rod from outside face of brace wall
	rodY = case_bottom_int_Y()/2-rodYoffset;
	// in this layout the central smooth rod will be the centreline for the z axis
	//there was regret. we only mirror z axis now
	
	//bracing for Y/Z
	echo(str("*************** Bracing    *******************"));
	*color("SteelBlue")
	translate([0, 0, Zfloor-brace_wall_thickness]) 
		rotate([0,0,90]) 
			brace(brace_wall_thickness, case_bottom_int_Y(), Zheight+brace_wall_thickness, Yaxis_seperation);
	
	echo(str("*************** Z lifty bit ******************"));
	for(i=[1,-1])
	{
		translate([0, i*rodY, Zfloor])
		{
			//z lifty bit
			translate([0, i*(-22/2-4), NEMA_length(nemaTypeZ)])
			{
				nema_motor(nemaTypeZ); //stepper
				
				rotate([0,0,i==-1 ? 180 : 0])
					motor_mount_plate(rodYoffset-brace_wall_thickness, i==1 ? 1 : 0);
					
				for(i=[1,-1])
					for(j=[1,-1])
						if((i!=-1 || j!=1) || !1) //exclude our conflicting screw hole
							translate([i*NEMA_hole_pitch(nemaTypeZ)/2,j*NEMA_hole_pitch(nemaTypeZ)/2, 2])
								bolt(3, 20);
				
				//threaded rod
				translate([0, 0, threaded_rod_length/2+NEMA_shaft_length(nemaTypeZ)/2+2])
					 linear_rod(threaded_rod_dia, threaded_rod_length, threaded);
				
				//z-motor-threaded-rod coupler
				color("silver")
						translate([0, 0, 25/2+NEMA_boss_height(nemaTypeZ)+1])
							cylinder(d=18, h=25, $fn=50, center=true);
			}
		
			//linear rods
			translate([rodX, 0, NEMA_length(nemaTypeZ)+(Zheight-NEMA_length(nemaTypeZ))/2])
				linear_rod(diameter=rod_dia, length=Zheight-NEMA_length(nemaTypeZ));
		}
	}
	
	//z_carriage for non motor end
	*translate([0, -rodY, Yaxis_Z_position+17.4])
		z_carriage(LM8_dia(), LM8_length(), Yaxis_seperation);
	
	//z_carriage + ball spline for the Ymotor end
	*translate([0, rodY, Yaxis_Z_position+17.4])
		rotate([0,0,180]) 
			z_carriage(LM8_dia(), LM8_length(), Yaxis_seperation, true);
	
	echo(str("*************** Z bar clamps ****************"));
	//z bar clamp
	translate([0, -rodY, Zfloor+Zheight-5/2])
	{
		color("MediumSeaGreen")
		difference()
		{
			cube(size=[20, 17, 5], center=true); // main block
			translate([-8, 0, 0]) cube(size=[15, 1, 6], center=true); // gap
			cylinder(d=8, h=10, $fn=50, center=true); //gap for the z rod
			for(i=[1,-1])
				translate([i*7, 0, 0])
					rotate([90,0,0])
					{
						cylinder(d=3, h=30, $fn=50, center=true); // gap for the bolt
						translate([0,0,-7.7]) nut(3, flat=true);
					}
		}
	}
	
	//clamp bolt+nut for show
	translate([0, -rodY, Zfloor+Zheight-5/2])
	{
		for(i=[1,-1])
		{
			translate([i*7, -9.7, 0])
			rotate([90,0,0])
			{
				bolt(3, 22, csk=true, threaded=threaded);
				translate([0,0,-7.7]) nut(3, flat=true);
			}
		}
	}
	
	//z bar clamp - y drive end
	translate([0, rodY, Zfloor+Zheight-5/2])
	{
		union()
		{
			color("MediumSeaGreen")
			difference()
			{
				translate([0, 0, 0]) cube(size=[20, 17, 5], center=true); // main block
				translate([8, 0, 0]) cube(size=[15, 1, 6], center=true); // gap
				cylinder(d=8, h=10, $fn=50, center=true); //gap for the z rod
				translate([7, 0, 0]) 
				rotate([-90,0,0])
				{
					cylinder(d=3, h=30, $fn=50, center=true); // gap for the bolt
					translate([0,0,-7.5]) cylinder(d=3*1.9, h=3*0.8, $fn=6, center=true); //gap for nut
				}
			}
			
			color("MediumSeaGreen")
			difference()
			{
				translate([-18, -3/2, 0]) cube(size=[17, 20, 5], center=true); // main block
				translate([-16, -5.5, 1]) cylinder(d=9.525, h=4, $fn=50, center=true); //seat for the bearing
				translate([-16, -5.5, 0]) cylinder(d=3.2, h=6, $fn=50, center=true); //gap for the y axis spline rod
				translate([-24, 0, 0])
					rotate([-90,0,0])
					{
						cylinder(d=3, h=30, $fn=50, center=true); // gap for the bolt
						translate([0,0,-10.5]) cylinder(d=3*1.9, h=3*0.8, $fn=6, center=true); //gap for nut
					}
			}
		}
		
		// R2 ZZ bearing
		// ID x OD x thickness
		// 1/8" x 3/8" x 5/32" inch
		// 3.175 x 9.525 x 3.96875 mm
		translate([-16, -5.5, 0]) bearing(9.525, 3.175, 3.96875, "R2ZZ");
		*translate([-24, 10, 0]) 
			rotate([-90,0,0])
				{
					bolt(3, 28, csk=true, threaded=threaded);
					translate([0,0,-23]) nut(3, flat=true);
				}
		*translate([7, 10, 0]) 
			rotate([-90,0,0])
				{
					bolt(3, 25, csk=true, threaded=threaded);
					translate([0,0,-20]) nut(3, flat=true);
				}
	}
	echo("********************** Z Axis END *****************************");
}

module motor_mount_plate(ZrodYoffset, YDrive=false)
{
	echo("******************* stepper motor mount **********************");
	plate_height = 2;
	color("MediumSeaGreen")
	//render()
	difference()
	{
		union()
		{
			//translate([0, -ZmotorWidth/2+NEMA_boss_radius(nemaTypeZ)+4+ZrodYoffset, plate_height/2])
			translate([0, 2.35, plate_height/2])
				cube(size=[ZmotorWidth, ZmotorWidth, plate_height], center=true); //bottom plate
			
			hull()
			{
				if(YDrive)
				translate([-16, 9.5, (4*4)/2])
					cylinder(d=11.6, h=4*4, $fn=50, center=true); // support for Y drive rod - 4 bearings high
					
				translate([0, NEMA_boss_radius(nemaTypeZ)+4, plate_height+20/2])
					cylinder(d=14, h=20, $fn=50, center=true); //z rod support
			}
			
			for(i=[0,1])
			mirror([YDrive ? 0 : i, 0, 0])
			translate([5.9, NEMA_boss_radius(nemaTypeZ)+4-2.5, plate_height-0.1])
				rotate([0,0,-25])
					fillet(ZmotorWidth/2-14/2, 5, 20); //support for main rod
			
			difference()
			{
				translate([0, ZmotorWidth/2-0.4, plate_height]) rotate([0,0,-90])
					fillet(5,ZmotorWidth,5); //extra fillet for the 90 deg angle
					
				for(i=[0,1])
					mirror([YDrive ? 0 : i, 0, 0])
						translate([NEMA_hole_pitch(nemaTypeZ)/2,NEMA_hole_pitch(nemaTypeZ)/2,0])
							cylinder(d=7, h=10, $fn=50, center=true); //gap for the screw head
			}
			
			difference()
			{
				translate([0, ZmotorWidth/2+2.35-brace_wall_thickness/2, 20/2+plate_height])
					cube(size=[ZmotorWidth, brace_wall_thickness, 20], center=true); //attachment face for brace wall
					
				for(i=[1,-1])
					translate([i*15,ZmotorWidth/2+2.35+0.1,17])
						rotate([-90,0,0])
							cylinder(d=5, h=10, $fn=50, center=true); //bolt holes for bracing attachment
			}
		}
		
		translate([0,NEMA_boss_radius(nemaTypeZ)+4,20]) cylinder(d=8, h=50, $fn=50, center=true); // Z rod
		translate([0,0,0]) cylinder(d=NEMA_boss_radius(nemaTypeZ)*2, h=50, $fn=50, center=true);// nema sticky out bit at the top
		translate([0, 0, 25/2+NEMA_boss_height(nemaTypeZ)+1]) cylinder(d=18, h=25, $fn=50, center=true); // where the coupler is
		
		if(YDrive)
		translate([-16,9.5,0])
		{
			translate([0,0,20]) cylinder(d=3.18, h=50, $fn=50, center=true); //y drive rod
			translate([0,0,30/2-0.1]) cylinder(d=9.6, h=30, $fn=50, center=true); //space for R2ZZ bearings, OD x ID x height (9.525, 3.175, 3.96875)
		}
		
		for(i=[1,-1])
			for(j=[1,-1])
				if((i!=-1 || j!=1) || !YDrive) //exclude our conflicting screw hole
					translate([i*NEMA_hole_pitch(nemaTypeZ)/2,j*NEMA_hole_pitch(nemaTypeZ)/2,0])
						cylinder(d=3, h=10, $fn=50, center=true);
	}
	
	for(i=[1,-1]) //screws for show
			for(j=[1,-1])
				if((i!=-1 || j!=1) || !YDrive) //exclude our conflicting screw hole
				translate([i*NEMA_hole_pitch(nemaTypeZ)/2,j*NEMA_hole_pitch(nemaTypeZ)/2,3])
				{
					translate([0,0,-0.5]) washer(3);
					bolt(3,5+plate_height);
				}
				
	for(i=[1,-1])
		translate([i*15,ZmotorWidth/2+2.35+0.1,17])
			rotate([-90,0,0])
			{
				bolt(5,10, csk=true);
				translate([0,0,-5]) nut(5);
			}
}

/*** thing carrying the bed ***/
module x_carriage()
{
	
}

module brace(wall_thickness, width, height, gauge)
{
	
	/* 
	 * |#########|
	 * |         |  we model this!
	 * |_       _|
	 */
	 
	 render()
	 for(i=[1,-1])
	 {
		 //bottom bit where the motor sits
		 color("blue")
		 translate([(width/2-ZmotorWidth/2-wall_thickness)*i, 0, wall_thickness/2])
			cube(size=[ZmotorWidth, gauge, wall_thickness], center=true);
			
		color("green")
		translate([(width/2-wall_thickness/2)*i, 0, height/2])
			cube(size=[wall_thickness, gauge, height], center=true);
		
		color("red")
		translate([0, wall_thickness/2+gauge/2, height-gauge/2]) 
			cube(size=[width, wall_thickness, gauge], center=true);
	 }
}

/***** the base that the whole rig sits on - the top of this is considered origin (or zero) for the Z axis ****/
module base()
{
	//bottom of the base is z=0
	echosize("baseboard",str(case_bottom_int_X(),"x",case_bottom_int_Y(),"x",bed_base_height));
	color("GhostWhite")
		linear_extrude(height = bed_base_height) roundedSquare(pos=[case_bottom_int_X(),case_bottom_int_Y()], r=bed_base_height);
}

module a4Bed(padding, heated_bed_height) //padding in addition to a4 size
{
	cube(size=[A4_length+padding,A4_width+padding,heated_bed_height], center=true);		
	echosize("A4 bed",str(A4_length+padding,"x",A4_width+padding,"x",heated_bed_height));
}

/**** centered tslot, drawn along x axis ****/
module tslot_centered(length, size)
{
	echo(str("Item: "));
	translate([0,0,size/2]) rotate([0,90,0]) tslot(size=size, length=length, gap=8);
}

module echosize(name, size)
{
	echo(str("Size of ",name,": ",size,"mm"));
}



