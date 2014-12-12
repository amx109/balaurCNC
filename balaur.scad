/***** MCAD ************/
use <MCAD/2Dshapes.scad>
use <MCAD/metric_fastners.scad>

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
Zheight = 240; //max height of Z axis

hinge_open = 0;
hinge_close_angle = 83.5; // Z axis must be at max height

Yaxis_X_position = 	-80;
Yaxis_position = 	105; //-105 for non-motor end, 105 for motorend
Yaxis_Z_position = 	215;//hinge_open? 215 : 110; //110 = Z0, maxZ = 215. build height in Z is 215-110 = 105mm


Yaxis_seperation = 56;

moveBed = 0;
bedleftright = 1; // 0 = left
bed_X_shift = moveBed ? (bedleftright ? -A4_length/2 : A4_length/2) : 0;

nema17SideSize = NEMA_width(17);
brace_wall_thickness = 3;
brace_width = 30;

echosize("Print height is",215-110);

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
	raiseit = hinge_open ? tslot_size+(tslot_size/2) : 0; 
	
	echosize("gap between A4 print area and tslot",(case_bottom_int_Y()/2)-(A4_width/2)-tslot_size);
	
	translate([Yaxis_X_position,0,raiseit])
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
	translate([0,0,-bed_base_height])
		base();
	
	/************* suitcase *************/
	echosize("briefcase X Y Z",str(caseX(),"x",caseY(),"x",caseZ()));
	color("Gainsboro")
		translate([0,0,(case_bottom_ext_Z()/2)-bed_base_height-(case_bottom_ext_Z()-case_bottom_int_Z())])
			briefcase();
	
	/************* height markers *************/
	translate([-230,0,-bed_base_height-(case_bottom_ext_Z()-case_bottom_int_Z())])
	{
		%translate([0,0,case_bottom_ext_Z()-0.5])
			cube(size=[10,300,1], center=true); //lip of bottom part
		echosize("height from floor of lip of bottom half",case_bottom_ext_Z());
		%translate([0,0,case_bottom_ext_Z()+case_lid_int_Z()+0.5])
			cube(size=[hinge_open?1000:10,300,1], center=true); //ceiling of top part
		echosize("inner ceiling height when closed",case_bottom_ext_Z()+case_lid_ext_Z());
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
			translate([0,(case_bottom_int_Y()/2)-tslot_size/2,0])
			{
				tslot_centered(case_bottom_int_X(), tslot_size);
			}
		}
		
		/*** tslot for bracing of x axis, in the y direction ***/
		mirror([i,0,0])
		{
			translate([((case_bottom_int_X())/2)-tslot_size/2,0,0])
				rotate ([0,0,90])
					tslot_centered(case_bottom_int_Y()-(tslot_size*2),tslot_size);
		}
	}
	
	//rails for the x carriage
	
	//x carriage
	x_carriage();
}

module Yaxis()
{
	echosize("Y axis rod diameter", 8);
	echosize("Y axis rail seperation", 56);
	echosize("Y axis length", case_bottom_int_Y()-10);
	
	xpulley = -Yaxis_seperation/2-8;
	ypulley1 = -105-45.7;
	ypulley2 = -105+255.9;
	
	//rails
	translate([0,0,Yaxis_Z_position])
	{
		for(i=[0,1])
		{
			mirror([i,0,0])
			{
				translate([Yaxis_seperation/2,0,0]) //mendel90 uses 56mm width for rails
				{
					rotate([90,0,0])
						linear_rod(8,case_bottom_int_Y()-8); //1mm clearance to the bracing -> 3+1 * 2
				}
			}
		}
		
		//carriage
		translate([0,Yaxis_position,0])
		{
			y_carriage(Yaxis_seperation);
			//hotend
			*color("DarkGray") translate([-12.5,-12.5,-10.5]) import("E3D_Hot_end.stl");
		}
		
		//belts
		translate([0,0,21]) 
		{
			difference()
			{
				gimme_belt("GT2", xpulley, ypulley1, 6/2, xpulley, ypulley2, 6/2);
				translate([xpulley+3,Yaxis_position,0]) cube(size=[3,80,10], center=true); //gap in y carriage
				translate([-Yaxis_seperation/2-4,150+1.5,1.9]) cube(size=[10,7,10], center=true);
			}
			difference()
			{
				gimme_belt("GT2", xpulley, ypulley2, 6/2, xpulley+21.7, ypulley2-3, 10/2);
				translate([xpulley+25/2-3,ypulley2-4,0]) cube(size=[25,10,10], center=true);
			}
			difference()
			{
				gimme_belt("GT2", xpulley+7, ypulley2+6.5, 6/2, xpulley+21.7, ypulley2-3, 10/2);
				translate([xpulley+25/2,ypulley2+5.5,0]) cube(size=[25,11,10], center=true);
			}
			difference()
			{
				gimme_belt("GT2", xpulley+7.3, ypulley2-3.3, 6/2, xpulley+7.3, ypulley2-10, 6/2);
				translate([xpulley+9.3,ypulley2-10.5,0]) cube(size=[10,15,10], center=true);
				translate([xpulley+9.3,ypulley2-3,0]) cube(size=[5,5,10], center=true);
			}
		}
		
		//pulleys for Y axis belt
		translate([-14, case_bottom_int_Y()/2-brace_wall_thickness-7, 39])
		{
			SRSSZY(3); //srss bushing
			translate([0,0,-6.3]) rotate([180,0,0]) gt2_small(); //GT2_16
		}
		
		//belt tensioner bearings
		translate([-Yaxis_seperation/2, case_bottom_int_Y()/2-7.3, 9.5])
		{
			difference()
			{
				color("silver")linear_extrude(height=3) roundedSquare(pos=[Yaxis_seperation/2.5,6.5],r=3); //width=22.4
				//TODO bolt holes
			}
			
			translate([-Yaxis_seperation/7, -0.03, 9.5-30.5])
			{
				translate([0,0,-4]) nut(3); //bottom nut
				translate([0,0,19]) linear_rod(3, 55, 0);
				translate([0,0,25]) nut(3); //top nut
				for(i=[0,1,2,3,4]) translate([0,0,27.5+2.5*i+0.1*i]) bearing(6, 3, 2.5); //MR63ZZ*5
				translate([0,0,40.5]) nut(3); //top top nut
				
				
				//spinde for tension bearings
				translate([7.3,-2.5,24+18/2]) 
				color("silver")
				intersection()
				{
					cube(size=[3,1.5,18], center=true); 
					translate([0,-0.5,0]) cylinder(d=3, h=18, $fn=50, center=true);
				}
				for(i=[0,1,2,3,4]) translate([7.3, -3, 27.5+2.5*i+0.1*i]) bearing(6, 3, 2.5); //MR63ZZ
			}
		}
		
		//belt tensioner bearings
		translate([-Yaxis_seperation/2, -case_bottom_int_Y()/2+7.3, 9.5])
		{
			translate([-Yaxis_seperation/7, 0.03, 6.5-30.5])
			{
				translate([0,0,-1]) nut(3); //bottom nut
				translate([0,0,19]) linear_rod(3, 50, 0);
				translate([0,0,25]) nut(3); //top nut
				for(i=[0,1,2,3,4]) translate([0, 0, 27.5+2.5*i+0.1*i]) bearing(6, 3, 2.5); //MR63ZZ*5
				translate([0, 0, 40.5]) nut(3); //top top nut
			}
		}
		
	}
	
	//srss axle
	translate([-14, case_bottom_int_Y()/2-brace_wall_thickness-7, 190/2+tslot_size+brace_wall_thickness+NEMA_length(17)])
		SRSS_rod(3, 190);
}

module Zaxis()
{
	//echosize("Z carriage height", carriage_height);
	//echosize("Z carriage width", carriage_width);
	//echosize("Length for M3 Bolts for Y axis rod clams", 40);
	
	echosize("Z smooth rod", Zheight-6);
	echosize("Z screw rod",  z_screw_rod_length);
	echosize("distance of center axis of smooth rod from inner wall of bracing", 8/2+12);
	
	z_screw_rod_length = 150;
	
	// in this layout the central smooth rod will be the centreline for the z axis
	//we need to mirror cos i was lazy with the bracing and it makes sense that the Z will be symmetrical. 
	//i am sure i will regret this decision and have to rewrite this part soon
	for(i=[0,1])
	{
		mirror([0,i,0])
		{
			translate([0, -case_bottom_int_Y()/2+nema17SideSize/2+brace_wall_thickness, tslot_size+(brace_wall_thickness/2)])
			{
				//bracking for Y/Z
				color("SteelBlue") translate([-brace_width*2/3,0,0]) brace(brace_wall_thickness, brace_width);
				
				//z lifty bit
				translate([-nema17SideSize/2-30.5, 0, brace_wall_thickness/2])
				{
					// stepper
					translate([0,0,NEMA_length(17)]) nema_motor(17);
					
					translate([0,0,NEMA_length(17)+NEMA_boss_height(17)+NEMA_shaft_length(17)])
					{
						/*  ///// screw rod //////
						* 
						* M8 screw rod isnt 8mm in diameter
						* specs say major diameter is 7.76(min) and 7.97(max). so we're going with 7.8
						*/
						translate([0,0,z_screw_rod_length/2+2.1])
							linear_rod(diameter=7.8, length=z_screw_rod_length, threaded=0);
						
						//z-motor-threaded-rod coupler
						color("silver")
								#translate([0,0,2]) rotate([0,0,0]) cylinder(d=20, h=25, $fn=50, center=true);
					}
					
					translate([0,0,Yaxis_Z_position]) rotate([0,0,90]) nut(8);
					
				}
				
			}
			
			//linear rods
			translate([0,-case_bottom_int_Y()/2+brace_wall_thickness+16,tslot_size+brace_wall_thickness+Zheight/2])
					linear_rod(diameter=8, length=Zheight-6);
		}
	}
	
	// smooth rod for idle Z end and idle z_carriage
	translate([0,-case_bottom_int_Y()/2+brace_wall_thickness+8/2+12,Yaxis_Z_position+17.8])
		z_carriage(LM8_dia(), LM8_length(), Yaxis_seperation);
	
	// ball spline for the Ymotor end + z_carriage
	echosize("length of spline shaft",198);
	translate([0,case_bottom_int_Y()/2-brace_wall_thickness-16,Yaxis_Z_position+17.8])
		rotate([0,0,180]) 
			z_carriage(LM8_dia(), LM8_length(), Yaxis_seperation, motor_end=true);
}

/*** thing carrying the bed ***/
module x_carriage()
{
	
}

module brace(brace_wall_thickness, brace_width)
{
	echosize("brace height accross Y", brace_width+5);
	echosize("brace width on vertical bits", nema17SideSize+brace_width);
	
	/*  build half and get it mirrored. cos we lazy yo  */
	
	//bottom bit
	cube(size=[nema17SideSize+brace_width,
				nema17SideSize,
				brace_wall_thickness], 
				center=true);
				
	//side bit that goes vertically to the sky
	translate([0, (-nema17SideSize-brace_wall_thickness)/2, (Zheight/2)-brace_wall_thickness/2])
		cube(size=[	nema17SideSize+brace_width,
					brace_wall_thickness,
					Zheight],
					center=true);
					
	//bracing
	translate([	brace_wall_thickness/2-(nema17SideSize+brace_width)/2-brace_wall_thickness-4, 
				(case_bottom_int_Y()/4)-(nema17SideSize/2)-3,
				Zheight-(brace_wall_thickness/2)-(brace_width)/2-5/2])
		#cube(size=[brace_wall_thickness,
					case_bottom_int_Y()/2+0.1,
					brace_width+5], // i added 5 to give more girth to the bracing. its a bit cheaty cheaty re parametric design
					center=true);
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
	translate([0,0,size/2]) rotate([0,90,0]) tslot(size=size, length=length, gap=8);
}

module echosize(name, size)
{
	echo(str("************************* Size of ",name,": ",size,"mm"));
}



