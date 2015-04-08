//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// modified by amran amx109@gmail.com
//
use <belts.scad>

$fn=50;

pulley_inner_radius = (14.4 / 2) - 2.25; // measured from outer diameter

//                     0                               1   2             3                4    5  6    7     8    9 10   11   12             13 14
T5x10_metal_pulley  = ["T5",                          10, 15,    12.85 / 2,            11.6, 7.9, 7,   5, 19.3, 1.7, 3, 10.7, [0,     0, -2], 0, 3];
T2p5x16_metal_pulley= ["T2.5",                        16, 12.16, 12.16 / 2 - 0.8,         8,  16, 5.7, 5, 16.0, 1.0, 6, 3.75, [0,     0,1.3], 0, 4];
T5x8_plastic_pulley = ["../imported_stls/pulley.stl",  8,  0,    pulley_inner_radius,     0,   0, 0,   5,    0,   0, 6,    4, [-10, -10,  0], 6, 3];
GT2x20_metal_pulley = ["GT2",                         20, 12.2,  12.2 / 2 - 0.75,         8,  10, 8,   5, 18.0, 1.0, 6, 3.75, [0,     0, -1], 0, 3];

GT2x20_5mm_bore = 	  ["GT2a",                        20, 12.22, 12.22 / 2 - 0.75,        7,  16, 8,   5, 16.0, 1.0, 6,    4, [0,     0, -1], 0, 3];
GT2x20_8mm_bore = 	  ["GT2a",                        20, 12.22, 12.22 / 2 - 0.75,        7,  16, 8,   8, 16.0, 1.0, 6,    4, [0,     0, -1], 0, 3];
GT2x16_small = 		  ["GT2_small",                   16, 9.68,   9.68 / 2 - 0.75,        7,  13, 7,   5, 13.0, 1.0, 6,    4, [0,     0, -1], 0, 3];

function pulley_type(type)             = type[0];
function pulley_teeth(type)            = type[1];
function pulley_od(type)               = type[2]; //diameter of the bit where the belt goes around (incl teeth)
function pulley_ir(type)               = type[3]; 
function pulley_width(type)            = type[4]; //the 'length' of the bit where the belt goes around
function pulley_hub_dia(type)          = type[5]; //smooth wall 'hub' where set screw is
function pulley_hub_length(type)       = type[6]; //
function pulley_bore(type)             = type[7]; //centre hole
function pulley_flange_dia(type)       = type[8];
function pulley_flange_thickness(type) = type[9];
function pulley_screw_length(type)     = type[10];
function pulley_screw_z(type)          = type[11];
function pulley_offset(type)           = type[12];
function pulley_nut_y(type)            = type[13];
function pulley_screw(type)            = type[14];

M3_grub_screw = 3;

module metal_pulley(type) {
	
    teeth = pulley_teeth(type);
    ft = pulley_flange_thickness(type);
    tw = pulley_od(type) * PI / (teeth * 2);
	
    color("silver")
    //render()
    {
        difference() {
            union() {
                cylinder(r = pulley_hub_dia(type) / 2, h = pulley_hub_length(type));
                for(z = [pulley_hub_length(type), pulley_hub_length(type) + ft + pulley_width(type)])
                    translate([0, 0, z])
                        cylinder(r = pulley_flange_dia(type) / 2, h = ft);
                translate([0, 0, pulley_hub_length(type) + ft])
                    cylinder(r = pulley_od(type) / 2, h =  pulley_width(type));
            }
            cylinder(r = pulley_bore(type) / 2, h = 100, center = true);
            for(i = [0 : teeth - 1])
                rotate([0, 0, i * 360 / teeth])
                    translate([-tw / 2, pulley_ir(type), pulley_hub_length(type) + ft])
                        cube([tw, 10, pulley_width(type)]);

            translate([0, 0, pulley_screw_z(type)])
                rotate([-90, 0, 0])
                    cylinder(r = pulley_screw(type)/2, h = 20);
        }
    }
}

module pulley(type)
{
	echo(str("Item: Pulley ",type));
	
	if(type == "GT2x20_5mm_bore")
	{
		metal_pulley(GT2x20_5mm_bore);
	}
	if(type == "GT2x20_8mm_bore")
	{
		metal_pulley(GT2x20_8mm_bore);
	}
	if(type == "GT2x16_small")
	{
		metal_pulley(GT2x16_small);
	}
}

pulley("GT2x16_small");
