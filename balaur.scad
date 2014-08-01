/*
include <MCAD/bearing.scad>
include <MCAD/boxes.scad>
include <MCAD/constants.scad>
include <MCAD/curves.scad>
include <MCAD/gears.scad>
include <MCAD/gridbeam.scad>
include <MCAD/hardware.scad>
include <MCAD/involute_gears.scad>
include <MCAD/layouts.scad>
include <MCAD/libtriangles.scad>

include <MCAD/math.scad>
include <MCAD/metric_fastners.scad>
include <MCAD/motors.scad>
include <MCAD/nuts_and_bolts.scad>
include <MCAD/regular_shapes.scad>
include <MCAD/screw.scad>
include <MCAD/servos.scad>
include <MCAD/shapes.scad>
include <MCAD/stepper.scad>
include <MCAD/teardrop.scad>
include <MCAD/triangles.scad>
include <MCAD/units.scad>
include <MCAD/utilities.scad>
*/

include <MCAD/2Dshapes.scad>
use <MCAD/materials.scad>
use <tslot.scad>


include <suitcase.scad>
use <SK.scad>
use <SC.scad>
use <EGH_CA.scad>

use <MCAD/metric_fastners.scad>

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
heated_bed_height = 3;
rail_width = (case_bottom_int_depth/2)-31;

rod_length = 380;

linear_rod_diameter = 20;
sc20_screw_hole_offset = 40;
x_carriage_mount_bolt_size = 5;
linear_rod_support_x_spacing = 360;

bearing_y_pos= -60;

tslot_x_padding = 20;
x_axis_tslot_width = -(case_bottom_int_depth/2)+tslot_x_padding;

hinge_outer_flange_length = 18;
hinge_width = 50;
hinge_flange_thickness = 1.2;
hinge_barrel_circumference = 5.5;
hinge_inner_hole_distance = 20;
hinge_outer_hole_distance = 41;


hinge_open = 0;
tslot = 1; //set to 1 for tslot design

/* the base that the whole rig sits on */
module base()
{
	color(FiberBoard)
	{
		linear_extrude(height = bed_base_height) roundedSquare(pos=[case_bottom_int_width-6,case_bottom_int_depth-2], r=bed_base_height);
	}
}

/* draw the supports for one linear rail. set distance between supports via linear_rod_support_x_spacing */
module linear_rod_supports()
{
	color(Aluminum)
	{
		for(j=[-1,1])
		{
			 translate([(linear_rod_support_x_spacing/2)*j,0,0]) rotate([0,0,90]) SK(20);
		}
	}
}

module a4Bed()
{
	cube(size=[A4_length,A4_width,heated_bed_height], center=true);
}

module linear_rod(radius, length)
{
	color(Aluminum)
	{
		cylinder(r=radius, h=length, center=true);
	}
}

/**** centered tslot, drawn along x axis ****/
module tslot_centered(length, size)
{
	translate([-length/2,-size/2,size/2]) rotate([0,90,0]) tslot(size=size,length=length,nut=false,gap=8);
}

module x_carriage_mount()
{
	/*
	l_bracket_thickness = 3;
	l_bracket_size = 54;
	l_bracket_length = 50;
	
	l_bracket(l_bracket_size+l_bracket_thickness, l_bracket_length, l_bracket_thickness); */
	
	bracket_size = 54;
	bracket_thickness = 5;
	bracket_sc_length = 50;
	bracket_clamp_overhang_length = 0;
	bracket_pivot_overhang_length = 20;
	upper_bracket_offset = 7;
	angle = (hinge_open == 1) ? 90 : 0;
	
	/****** lower carriage mount plate ******/
	difference()
	{
		/**** lower mount plate ***/
		x_carriage_mount_bracket(bracket_size,
									   bracket_clamp_overhang_length, 
									   bracket_sc_length, 
									   bracket_pivot_overhang_length, 
									   bracket_thickness);
		/**** hole for the hinge ****/
		translate([(hinge_outer_flange_length/2)+((bracket_sc_length/2)-hinge_outer_flange_length)+bracket_pivot_overhang_length,
					0,
					(bracket_thickness/2)-(hinge_flange_thickness/2)+0.05])
			cube(size=[hinge_outer_flange_length+0.1, 
					   hinge_width+0.1,
					   hinge_flange_thickness+0.1], 
					   center=true);
					   
		/***** clamp nut ****/
		translate([-(bracket_sc_length/2)+8,0,-(bracket_thickness/2)-0.1]) csk_bolt(x_carriage_mount_bolt_size,14);
		
		/***** mounting holes for bearing*****/
		for(i=[1 : 4])
		{
			rotate([180,0,i*90])
				translate([sc20_screw_hole_offset/2,sc20_screw_hole_offset/2,(-bracket_thickness/2)-0.1])
					csk_bolt(x_carriage_mount_bolt_size,14);
		}
		
		/****** mounting holes for hinge ******/
		for(i=[1,-1])
		{
			translate([(bracket_size/2)+(hinge_outer_flange_length+(hinge_barrel_circumference/2))/2,
					   i*(hinge_outer_hole_distance/2),
					   -(bracket_thickness)])
				csk_bolt(3,14);
		}
	}
	
	/**** clamp bolt and nut ****/
	translate([-(bracket_sc_length/2)+8,0,-(bracket_thickness/2)-0.1])
	{
		csk_bolt(x_carriage_mount_bolt_size,20);
		if (hinge_open == 0) { translate([0,0,9.5]) flat_nut(5); }
	}
	
	/***** hinge + upper carriage (flippy over bit) *******/
	translate([(bracket_sc_length/2)+bracket_pivot_overhang_length+(hinge_barrel_circumference/2)-0.1,0,(hinge_flange_thickness*1.285)+(bracket_thickness/2)])
	{
		/****** hinge *******/
		mirror([1,0,0]) hinge(hinge_open);
		
		/******* rotate all the things! *******/
		rotate([0,angle,0])
		{
			difference()
			{
				/******* upper bracket *******/
				translate ([-(bracket_sc_length/2)-bracket_pivot_overhang_length-((hinge_barrel_circumference+0.1)/2),
							-upper_bracket_offset/2,
							(bracket_thickness/2)-(hinge_flange_thickness*1.25)])
				x_carriage_mount_bracket(bracket_size-upper_bracket_offset, 
											   bracket_clamp_overhang_length, 
											   bracket_sc_length, 
											   bracket_pivot_overhang_length, 
											   bracket_thickness);
				
				/******** hole for clamp nut *******/
				translate([-bracket_sc_length-bracket_pivot_overhang_length-(hinge_barrel_circumference/2)+8,0,-6])
					csk_bolt(x_carriage_mount_bolt_size,20);
				
				/****** mounting holes for the hinge ******/
				for(i=[1,-1])
				{
					translate([-(hinge_outer_flange_length+(hinge_barrel_circumference/2))/2,
										i*(hinge_inner_hole_distance/2),
										-(bracket_thickness)])
						csk_bolt(3,14);
				}
			}
			
			/*** hinge screws ***/
			for(i=[1,-1])
			{
				translate([-(hinge_outer_flange_length+(hinge_barrel_circumference/2))/2,
									i*(hinge_inner_hole_distance/2),
									-(bracket_thickness/2)-0.3])
				{
					csk_bolt(3,14);
					translate([0,0,6]) flat_nut(3);
				}
			}
		}
	}
}

module x_carriage_tslot_mount()
{
	/*
	l_bracket_thickness = 3;
	l_bracket_size = 54;
	l_bracket_length = 50;
	
	l_bracket(l_bracket_size+l_bracket_thickness, l_bracket_length, l_bracket_thickness); */
	
	bracket_size = 34;
	bracket_thickness = 5;
	bracket_sc_length = 39.8;
	bracket_clamp_overhang_length = 0;
	bracket_pivot_overhang_length = 20;
	upper_bracket_offset = 7;
	angle = (hinge_open == 1) ? 90 : 0;
	screw_hole_offset = 26;
	
	color(Stainless)
	
	/****** lower carriage mount plate ******/
	difference()
	{
		/**** lower mount plate ***/
		x_carriage_mount_bracket(bracket_size,
									   bracket_clamp_overhang_length, 
									   bracket_sc_length, 
									   bracket_pivot_overhang_length, 
									   bracket_thickness);
									   
		/**** hole for the hinge ****/
		translate([(hinge_outer_flange_length/2)+((bracket_sc_length/2)-hinge_outer_flange_length)+bracket_pivot_overhang_length,
					0,
					(bracket_thickness/2)-(hinge_flange_thickness/2)+0.05])
			cube(size=[hinge_outer_flange_length+0.1, 
					   hinge_width+0.1,
					   hinge_flange_thickness+0.1], 
					   center=true);
					   
		/***** mounting holes for bearing*****/
		for(i=[1 : 4])
		{
			rotate([180,0,i*90])
				translate([screw_hole_offset/2,screw_hole_offset/2,(-bracket_thickness/2)-0.1])
					csk_bolt(x_carriage_mount_bolt_size-1,14);
		}
		
		/****** mounting holes for hinge ******/
		for(i=[1,-1])
		{
			translate([(bracket_size/2)+(hinge_outer_flange_length+(hinge_barrel_circumference/2))/2,
					   i*(hinge_outer_hole_distance/2),
					   -(bracket_thickness)])
				$csk_bolt(3,14);
		}
	}
	
	color(Brass)
	/**** clamp bolt and nut ****/
	translate([-(bracket_sc_length/2)+8,0,-(bracket_thickness/2)-0.1])
	{
		csk_bolt(x_carriage_mount_bolt_size,18);
		if (hinge_open == 0) { translate([0,0,9.5]) flat_nut(5); }
	}
	
	/***** hinge + upper carriage (flippy over bit) *******/
	translate([(bracket_sc_length/2)+bracket_pivot_overhang_length+(hinge_barrel_circumference/2)-0.1,0,(hinge_flange_thickness*1.285)+(bracket_thickness/2)])
	{
		/****** hinge *******/
		//color(Brass) mirror([1,0,0]) hinge(hinge_open);
		
		/******* rotate all the things! *******/
		rotate([0,angle,0])
		{
			color(Stainless)
			difference()
			{
				/******* upper bracket *******/
				translate ([-(bracket_sc_length/2)-bracket_pivot_overhang_length-((hinge_barrel_circumference+0.1)/2),
							0,
							(bracket_thickness/2)-(hinge_flange_thickness*1.25)])
				x_carriage_mount_bracket(bracket_size, 
											   bracket_clamp_overhang_length, 
											   bracket_sc_length, 
											   bracket_pivot_overhang_length, 
											   bracket_thickness);
				
				/******** hole for clamp nut *******/
				translate([-bracket_sc_length-bracket_pivot_overhang_length-(hinge_barrel_circumference/2)+8,0,-6])
				{
					csk_bolt(x_carriage_mount_bolt_size,20);
					
				}
				
				/****** mounting holes for the hinge ******/
				for(i=[1,-1])
				{
					translate([-(hinge_outer_flange_length+(hinge_barrel_circumference/2))/2,
										i*(hinge_inner_hole_distance/2),
										-(bracket_thickness)])
						csk_bolt(3,14);
				}
			}
			
			//calibration block - todo - delete
			translate([-bracket_sc_length-bracket_pivot_overhang_length-(hinge_barrel_circumference/2)+12.5+0.3,
						0,
						6])
				$cube(size=[4.4,15,5], center=true);
			
			/*** hinge screws ***/
			for(i=[1,-1])
			{
				translate([-(hinge_outer_flange_length+(hinge_barrel_circumference/2))/2,
									i*(hinge_inner_hole_distance/2),
									-(bracket_thickness/2)-0.3])
				{
					csk_bolt(3,12);
					translate([0,0,6]) flat_nut(3);
				}
			}
		}
	}
}

module l_bracket(size, length, thickness)
{
	difference()
	{
		union()
		{
			translate([0,-thickness/2, 0]) cube(size=[length,size,thickness], center=true);
			rotate([90,0,0]) translate([0,(-size/2),(length+(thickness*2)+1)/2]) cube(size=[length,(size-thickness)+0.1,thickness], center=true);
		}
		
		//mounting holes
		for(i=[1 : 4])
		{
			rotate([180,0,i*90]) translate([40/2,40/2,-1.51])  csk_bolt(5,14);
		}
	}
}

module x_carriage_mount_bracket(bearing_size, clamp_overhang, length, pivot_overhang, thickness)
{	
	translate([(clamp_overhang+pivot_overhang)/2,0,0])
		cube(size=[clamp_overhang+length+pivot_overhang, bearing_size,thickness], center=true);
}

module hinge(open)
{
	//open can be 1 or 0. 1 = open, 0 = closed
	
	hinge_inner_flange_width = 28;
	hinge_inner_flange_length = 12;
	angle = (open == 1) ? 270 : 0;
	
	union()
	{
		//cylinder
		rotate ([90,0,0])
		{
			difference()
			{
				cylinder(r=hinge_barrel_circumference/2, h=hinge_width, center=true);
				cylinder(r=hinge_barrel_circumference/3.6, h=hinge_width+10, center=true);
				cylinder(r=hinge_barrel_circumference, h=hinge_inner_flange_width, center=true);
			}
		}
		
		//big outer flange
		translate([((hinge_outer_flange_length+(hinge_barrel_circumference/2))/2),
					0,
					-(hinge_barrel_circumference/2)+(hinge_flange_thickness/2)])
		{
			difference()
			{
				cube(size=[hinge_outer_flange_length+(hinge_barrel_circumference/2),
						   hinge_width, 
						   hinge_flange_thickness],
						   center=true);
				translate([-(hinge_outer_flange_length-hinge_inner_flange_length)/2,0,0]) 
					cube(size=[hinge_inner_flange_length+0.1+(hinge_barrel_circumference/2), 
							   hinge_inner_flange_width+2, 
							   hinge_flange_thickness+1],
							   center=true);
				
				//mounting holes
				for(i=[1,-1])
				{
					rotate([180,0,0])
						translate([0,i*(hinge_outer_hole_distance/2),-(hinge_flange_thickness/2)-0.1])
							csk_bolt(3,14);
				}
			}
		}
	}
	
	//inner flange
	rotate([0,angle,0])
	{
		union()
		{
			//cylinder
			rotate ([90,0,0])
			{
				difference()
				{
					cylinder(r=hinge_barrel_circumference/2, h=hinge_inner_flange_width-1, center=true);
					cylinder(r=hinge_barrel_circumference/3.6, h=hinge_inner_flange_width+10, center=true);
				}
			}
			
			translate([0,0,-(hinge_barrel_circumference/2)+(hinge_flange_thickness/2)])
			{
				difference()
				{
					//inner flange
					translate([((hinge_inner_flange_length-1+(hinge_barrel_circumference/2))/2),0,0]) 
						cube(size=[(hinge_inner_flange_length-1)+(hinge_barrel_circumference/2),
									hinge_inner_flange_width, hinge_flange_thickness],
									center=true);
						
					//mounting holes
					for(i=[1,-1])
					{
						translate([(hinge_outer_flange_length+(hinge_barrel_circumference/2))/2,
									i*(hinge_inner_hole_distance/2),
									-(hinge_flange_thickness/2)-0.1])
							csk_bolt(3,14);
					}
				}
			}
		}
	}
}

module x_carriage()
{
	/***** linear slide and bearing+y mount ******/	
	color(Aluminum) egr(15, case_lid_int_width-6); //slide
	translate([bearing_y_pos,0,8])
	{
		color([0.7,0.7,0.7]) egh_ca(15); //bearing
		translate([-10,0,12.25]) x_carriage_tslot_mount();
	}
}

module y_carriage()
{
	y_height = 200;
	
	for(i=[0,-1])
	{
		mirror([0,i,0])
			translate([0,x_axis_tslot_width,y_height/2]) rotate([0,90,0]) tslot_centered(y_height, 30);
		mirror([i,0,0])
			translate([19,0,y_height]) rotate([90,0,0]) linear_rod(4, case_bottom_int_depth-80);
	}
	
	
	translate([-12.5,-12.5,11])
	{
		import("E3D_Hot_end.stl");
		translate([-81,30,-57.5]) rotate([90,0,0]) import("E3d-Fan-Mount.stl");
	}
}

module z_carriage()
{
	
}

module drawX();
{
	if(tslot)
	{
		/***** x axis tslot, plus linear slides and bearings ******/
		for(i=[0,1])
		{
			mirror([0,i,0])
			{
				translate([0,x_axis_tslot_width,15])
				{
					/***** the tslot for x axis *****/
					tslot_centered(case_lid_int_width-6, 30);
					translate([0,0,15+(12.5/2)]) x_carriage();
				}
			}
			
			/*** bracing for x, in y direction ***/
			mirror([i,0,0])
			{
				translate([((case_lid_int_width-6)/2)-15,0,15])
					rotate ([0,0,90])
						tslot_centered(case_lid_int_depth-2-60-(tslot_x_padding/2), 30);
			}
		}
		
	}
	else
	{
		/***** linear rods and bearings with x carriage mount *****/
		for(i=[0,1])
		{
			mirror([0,i,0])
			{
				translate([-30.8,-rail_width,0])
				{
					linear_rod_supports();
					translate([0,0,36]) rotate([0,90,0]) linear_rod(linear_rod_diameter/2, rod_length);
					
					translate([bearing_y_pos,0,0])
					{
						//upward facing bearings
						color(Aluminum) translate([0,0,17]) SC(20);
						
						//inwards facing bearings
						//color(Aluminum) translate([0,(i*145),36]) {rotate([i*90,0,0]) SC(20);}
						
						//outwards facing bearings
						//color(Aluminum) translate([0,(i*107),36]) {rotate([i*270,0,0]) SC(20);}
						color(Aluminum) translate([0,0,59.5]) x_carriage_mount();
						
						//x_carriage();
					}
				}
			}
		}
	}
}

module draw() /****** built from the bottom up *******/
{
	/************* height markers *************/
	translate([-230,0,-20])
	{
		%translate([0,0,case_bottom_ext_height])
			cube(size=[10,300,1], center=true); //lip of bottom part
		%translate([0,0,case_bottom_ext_height+case_lid_ext_height])
			cube(size=[10,300,1], center=true); //ceiling of top part
	}
	
	
	/************* suitcase *************/
	$color([0,1,0]) translate([-230,-165,-20]) suitcase();
	
	/**** base for the whole machine - will sit inside the suitcase ****/
	$translate([0,0,-bed_base_height]) base();
	
	darwX();
	//x_carriage();
	
	if(hinge_open)
	{
		translate([bearing_y_pos+36,0,30+24+10+29.05]) rotate([0,90,0]) y_carriage();
	}
	else
	{
		translate([bearing_y_pos,0,30+24+10]) rotate([0,00,0]) y_carriage();
	}
	$y_carriage();
	
	z_carriage();
	
	/************* bed *************/
	translate([-40,0,70])
	{
		$color(Aluminum) a4Bed();
		translate([0,0,3]) a4Bed();
	}
	
	
	
	
	
}


draw();
