/***** MCAD ************/
use <MCAD/2Dshapes.scad>
use <MCAD/metric_fastners.scad>
include <MCAD/stepper.scad>
use <MCAD/materials.scad> //colours+material types

/*** custom *****/
use <briefcase.scad>
use <tslot.scad>
use <hinge.scad>
use <LM__UU.scad>
use <LM__UUOP.scad>
use <SRSSBP.scad>
use <z_carriage.scad>

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
bed_base_height = 3;
A4_width = 210;
A4_length = 297;

tslot_size = 30; // we're going to use 30mm tslot

//variables to fuck with Y axis position/hinge/A4 bed
Zheight = 240; //max height of Z axis

hinge_open = 0;
hinge_close_angle = 83; // Z axis must be at max height

Yaxis_X_position = -80;
Yaxis_Z_position = hinge_open? 228 : 110; //110 = Z0, maxZ = 228. build height in Z is 228-110 = 118mm
Yaxis_seperation = 56;
Yaxis_position = 105; //-105 for non-motor end, 105 for motorend

moveBed = 0;
bedleftright = 1; // 0 = left
bed_X_shift = moveBed ? (bedleftright ? -A4_length/2 : A4_length/2) : 0;

nema17SideSize = lookup(NemaSideSize, Nema17); 
brace_wall_thickness = 3;
brace_width = 30;

echosize("Print height is",110-228);

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
	raiseit = hinge_open ? tslot_size+(tslot_size/2) : 0; // THIS DOES NOTHING
	
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
			color("Red")
				a4Bed(padding=0, heated_bed_height=3);
		
		rotate([0,flipit,0])
		{
			/********* Y axis **********/
			Yaxis(Yaxis_Z_position);
			
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
	echosize("briefcase X Y Z",str(caseX(),"x",caseY(),"x",caseZ()));
	*color("Gainsboro")
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

module Yaxis(Yaxis_Z_position) 
{
	echosize("Y axis rod diameter", 8);
	echosize("Y axis rail seperation", 56);
	echosize("Y axis length", case_bottom_int_Y()-10);
	
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
			y_carriage();
			//hotend
			color("DarkGray") translate([-12.5,-12.5,-10.5]) import("E3D_Hot_end.stl");
		}
	}
	
	translate([0,case_bottom_int_Y()/2-brace_wall_thickness-nema17SideSize/2-11,tslot_size+(brace_wall_thickness/2)])
	{
		
		motor(model=Nema17,orientation=[0,180,0], pos=[0,0,lookup(NemaLengthMedium, Nema17)+lookup(NemaRoundExtrusionHeight, Nema17)]);
		//motor(model=Nema14,orientation=[0,180,0], pos=[0,0,lookup(NemaLengthMedium, Nema14)+lookup(NemaRoundExtrusionHeight, Nema14)]);
	}
}

module Zaxis()
{	
	//echosize("Z carriage height", carriage_height);
	//echosize("Z carriage width", carriage_width);
	//echosize("Length for M3 Bolts for Y axis rod clams", 40);
	
	echosize("Z smooth rod", Zheight-6);
	echosize("Z screw rod",  z_screw_rod_length);
	
	z_screw_rod_length = 140;
	
	// in this layout the central smooth rod will be the centreline for the z axis
	
	//we need to mirror cos i was lazy with the bracing and it makes sense that the Z will be symmetrical. 
	//i am sure i will regret this decision and have to rewrite this part soon
	for(i=[0,1])
	{
		mirror([0,i,0])
		{
			translate([0,-case_bottom_int_Y()/2+(nema17SideSize/2+brace_wall_thickness),tslot_size+(brace_wall_thickness/2)])
			{
				translate([-brace_width*2/3,0,0])
				{
					//bracking for Y/Z
					color("blue") brace(brace_wall_thickness, brace_width);
					
					translate([-((nema17SideSize+brace_width)/2)+(nema17SideSize/2)-nema17SideSize/2,0,brace_wall_thickness/2])
					{
						// stepper
						motor(model=Nema17,orientation=[0,180,0], pos=[0,0,lookup(NemaLengthMedium, Nema17)+lookup(NemaRoundExtrusionHeight, Nema17)]);
						
						/*  ///// screw rod //////
						 * 
						 * M8 screw rod isnt 8mm in diameter
						 * specs say major diameter is 7.76(min) and 7.97(max). so we're going with 7.8
						 */
						translate([0,0,(z_screw_rod_length/2+(lookup(NemaLengthMedium, Nema17)+lookup(NemaFrontAxleLength, Nema17)))+2.1])
							linear_rod(diameter=7.8, length=z_screw_rod_length);
						
						//z-motor-threaded-rod coupler
						color("green")
							translate([0,0,58.1])
								rotate([0,-90,45])
									for(j=[0,1])
									{
										mirror([0,0,j]) translate([0,0,-8])import("z_coupling.stl");
									}
					}
				}
			}
		}
	}
	
	// smooth rod for idle Z end and idle z_carriage
	translate([0,-case_bottom_int_Y()/2+brace_wall_thickness+8/2+12,0])
	{
		translate([0,0,tslot_size+brace_wall_thickness+Zheight/2])
			linear_rod(diameter=8, length=Zheight-6);
		
		echosize("distance of center axis of smooth rod from inner wall of bracing", 8/2+12);
		
		translate([0,0,Yaxis_Z_position+17.8])
			z_carriage(LM8_dia(), LM8_length(), Yaxis_seperation);
	}
	
	// ball spline for the Ymotor end + z_carriage
	translate([0,case_bottom_int_Y()/2-brace_wall_thickness-16,0])
	{
		translate([0,0,tslot_size+brace_wall_thickness+lookup(NemaLengthMedium, Nema17)+198/2])
			SRSSBP_rod(10, 198);
		echosize("length of spline shaft",198);
		
		translate([0,0,Yaxis_Z_position+17.8+1.4])	
			rotate([0,0,180])
					z_carriage(SRSSBP10_dia(), SRSSBP10_length(), Yaxis_seperation, spline=true);
	}
}

/*** thing carrying the bed ***/
module x_carriage()
{
	
}

/** thing carrying the 'head' along Y ****/
module y_carriage()
{
	echosize("Y carriage length", 10);
	
	
	for(i=[1,-1])
	{
		difference()
		{
			translate([i*Yaxis_seperation/2,0,0]) rotate([90,0,0]) cylinder(h=LM8OP_length()*3+12, d=LM8OP_dia()+4.15, center=true);
			translate([i*Yaxis_seperation/2,0.1,0]) rotate([90,0,0]) cylinder(h=LM8OP_length()*3+13, d=LM8OP_dia(), center=true);
			translate([0,0,-8]) cube(size=[Yaxis_seperation+LM8_dia()*2,LM8OP_length()*3+20,10], center=true);
		}
		for(j=[1,-1])
		{
			translate([i*(Yaxis_seperation/2),j*(LM8OP_length()+6),0]) rotate([90,0,0]) LMOP(8);
		}
	}
	
	translate([0,0,LM8_dia()/2+3]) cube(size=[Yaxis_seperation+LM8_dia(),50,3], center=true);
	
	
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
	translate([	brace_wall_thickness/2-(nema17SideSize+brace_width)/2-brace_wall_thickness,
				(case_bottom_int_Y()/4)-(nema17SideSize/2)-3,
				Zheight-(brace_wall_thickness/2)-(brace_width)/2-5/2])
		cube(size=[	brace_wall_thickness,
					case_bottom_int_Y()/2+0.1,
					brace_width+5], // i added 5 to give more girth to the bracing. its a bit cheaty cheaty re parametric design
					center=true);
}


/***** the base that the whole rig sits on - the top of this is considered origin (or zero) for the Z axis ****/
module base()
{
	//bottom of the base is z=0
	color(FiberBoard)
	{
		linear_extrude(height = bed_base_height) roundedSquare(pos=[case_bottom_int_X(),case_bottom_int_Y()], r=bed_base_height);
		echosize("baseboard",str(case_bottom_int_X(),"x",case_bottom_int_Y(),"x",bed_base_height));
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
	color("LightGrey")
	{
		cylinder(r=diameter/2, h=length, center=true);
	}
}

module echosize(name, size)
{
	echo(str("************************* Size of ",name,": ",size,"mm"));
}



