case_width  = 460;
case_depth  = 330;
case_height = 160;

case_lid_ext_width  = 460;
case_lid_ext_depth  = 330;
case_lid_ext_height = 60;
case_lid_int_width  = case_lid_ext_width - (8.9 * 2);
case_lid_int_depth  = case_lid_ext_depth - (8.9 * 2);
case_lid_int_height = 51.0;

case_bottom_ext_width  = 460;
case_bottom_ext_depth  = 330;
case_bottom_ext_height = 100;
case_bottom_int_width  = case_bottom_ext_width - (11.0*2);
case_bottom_int_depth  = case_bottom_ext_depth - (11.0*2);
case_bottom_int_height = 92.0;

A4_width = 210;
A4_depth = 297;

module reference_object()
{
	translate([-50,-80,0])
	{
		cube(size = [50,50,50], center = false);
	}
}

module suitcase()
{
	
}

module a4_bed()
{
	translate([100,10,200])
	{
		cube(size=[A4_depth,A4_width,1]);
	}
}

module draw()
{
	suitcase();
	reference_object();
	
	a4_bed();
}

draw();
