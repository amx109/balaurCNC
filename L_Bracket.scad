use <MCAD/metric_fastners.scad>


module l_bracket(width, length, thickness)
{
	difference()
	{
		union()
		{
			cube(size=[length,width,thickness], center=true);
			
			rotate([0,90,0])
				translate([(thickness/2)-(length/2),0,(length/2)-(thickness/2)])
					cube(size=[length,width,thickness], center=true);
		}
	}
}
