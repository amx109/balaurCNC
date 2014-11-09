/***** MCAD ************/
use <MCAD/2Dshapes.scad>
use <MCAD/metric_fastners.scad>
include <MCAD/stepper.scad>
//use <MCAD/materials.scad> //colours+material types //already included in briefcase.scad

/*** custom *****/
include <briefcase.scad>
use <tslot.scad>
use <SK.scad>
use <SC.scad>
use <EGH_CA.scad>
use <hinge.scad>

/*
 * functions i should remember to use
 * roundedSquare
 * bearing
 * libtriangles
 * flat_nut
 * bolt
 * washer
 * nema
 * 
 */

/*************************** variables *****************************/ 
$fn=50;

/* suitcase internal dimensions 460x330x160 */
bed_base_height = 5;
A4_width = 210;
A4_length = 297;

tslot_size = 30; // we're going to use 30mm tslot

//variables to fuck with Y axis position/hinge/bed
Yaxis_X_position = -80;
Zheight = 240; //max height of Z axis
hinge_open = 0;
moveBed = 1;
bedleftright = 1;
bed_X_shift = moveBed ? (bedleftright ? -A4_length/2 : A4_length/2) : 0;



/*************************** modules *****************************/ 

module echosize(name, size)
{
	echo(str("************************* Size of ",name,": ",size,"mm"));
}

/***** the base that the whole rig sits on - the top of this is considered origin (or zero) for the Z axis ****/
module base()
{
	//bottom of the base is z=0
	color(FiberBoard)
	{
		linear_extrude(height = bed_base_height) roundedSquare(pos=[case_bottom_int_X,case_bottom_int_Y], r=bed_base_height);
		echosize("baseboard",str(case_bottom_int_X,"x",case_bottom_int_Y,"x",bed_base_height));
	}
}

module a4Bed(padding, heated_bed_height) //padding in addition to a4 size
{
	cube(size=[A4_length+padding,A4_width+padding,heated_bed_height], center=true);		
	echosize("A4 bed",str(A4_length+padding,"x",A4_width+padding,"x",heated_bed_height));
}

/**** centered tslot, drawn along x axis ****/
module tslot_centered(length, size)
{
	translate([0,0,size/2]) rotate([0,90,0]) tslot(size=size, length=length, gap=8);
}

module linear_rod(diameter, length)
{
	color(Aluminum)
	{
		cylinder(r=diameter/2, h=length, center=true);
	}
}

/*** thing carrying the bed ***/
module x_carriage()
{
	
}

/** thing carrying the 'head' along Y ****/
module y_carriage()
{
	
}

module Yaxis()
{
	//rails
	for(i=[0,1])
	{
		mirror([i,0,0])
		{
			 translate([(tslot_size/2)+10,0,Zheight]) rotate([90,0,0]) linear_rod(8,case_bottom_int_Y);
		}
	}
	
	//carriage
	
	
	//hotend
	color(Steel) translate([-12.5,-12.5,113.6]) import("E3D_Hot_end.stl");
}

module Zaxis()
{
	for(i=[0,1])
	{
		mirror([0,i,0])
		{
			//smooth guide rails
			translate([0,(case_bottom_int_Y/2)-(tslot_size/2),(Zheight/2)+tslot_size]) 
					linear_rod(diameter=10, length=Zheight);
			
			//stepper
			translate([-(lookup(NemaSideSize, Nema17)/2)-10,(case_bottom_int_Y/2)-(lookup(NemaSideSize, Nema17)/2),tslot_size])
			{
				motor(model=Nema17,orientation=[0,180,0], pos=[0,0,lookup(NemaLengthMedium, Nema17)+lookup(NemaRoundExtrusionHeight, Nema17)]);
				//threaded rod for Z movement
				translate([0,0,(Zheight/2)+58])
					linear_rod(diameter=5, length=Zheight);
			}
		}
	}
}

module Xaxis()
{
	/***** a frame made out of tslot - goes in both X and Y directions ******/
	for(i=[0,1])
	{
		/***** the tslot for x axis *****/
		mirror([0,i,0])
		{
			translate([0,(case_bottom_int_Y/2)-tslot_size/2,0])
			{
				tslot_centered(case_bottom_int_X, tslot_size);
			}
		}
		
		/*** tslot for bracing of x axis, in the y direction ***/
		mirror([i,0,0])
		{
			translate([((case_bottom_int_X)/2)-tslot_size/2,0,0])
				rotate ([0,0,90])
					tslot_centered(case_bottom_int_Y-(tslot_size*2),tslot_size);
		}
	}
	
	//rails for the x carriage
	
	
	//x carriage
	x_carraige();
}

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
	
	//some if's to set hinge open vars
	flipit  = hinge_open ? 90 : 0;
	raiseit = hinge_open ? tslot_size+(tslot_size/2) : 0;
	
	echosize("gap between A4 print area and tslot",(case_bottom_int_Y/2)-(A4_width/2)-tslot_size);
	
	translate([Yaxis_X_position,0,raiseit])
	{
		/************* bed *************/
		translate([bed_X_shift,0,3/2+case_bottom_ext_Z+10-raiseit])
			color("Red")
				a4Bed(padding=0, heated_bed_height=3);
				
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
	Xaxis();
	
	/**** base for the whole machine - will sit inside the suitcase ****/
	translate([0,0,-bed_base_height]) base();
	
	/************* suitcase *************/
	echosize("briefcase X Y Z",str(caseX,"x",caseY,"x",caseZ));
	$color([0,1,0]) translate([-230,-165,-20]) briefcase();
	
	/************* height markers *************/
	translate([-230,0,0])
	{
		%translate([0,0,case_bottom_ext_Z-0.5])
			cube(size=[10,300,1], center=true); //lip of bottom part
		echosize("height from floor of lip of bottom half",case_bottom_ext_Z);
		%translate([0,0,case_bottom_ext_Z+case_lid_int_Z+0.5])
			cube(size=[10,300,1], center=true); //ceiling of top part
		echosize("inner ceiling height when closed",case_bottom_ext_Z+case_lid_ext_Z);
	}
}

draw();
