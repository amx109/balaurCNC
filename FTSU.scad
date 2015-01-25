/*
 * Model of a FTSU round rod linear slide support
 * 
 * 
 * This object is for display only. it is not printable (base and top need to be made to overlap)
 * 
 * 
 */

use <LM__UUOP.scad>
use <MCAD/libtriangles.scad>

M4 = 4;
M5 = 5;
$fn=50;

FTSU12 = [12, 11, 14.5, 5.5, 5.4, 4.5, 3, 16, M4, 37.5, 75];
FTSU16 = [16, 14, 18, 7, 7, 5.5, 3, 19, M5, 37.5, 75];

echo(FTSU16[9]);

function FTSU_height(x) = (x==12) ? FTSU12[2] : (x == 16) ? FTSU16[2] : 0;

module FTSU(size, L)
{
	if (size == 12)
	{
		color("silver")
		_FTSU(FTSU12[0], FTSU12[1], FTSU12[2], FTSU12[3], FTSU12[4], FTSU12[5], FTSU12[6], FTSU12[7], FTSU12[8], FTSU12[9], FTSU12[10], L);
	}
	if (size == 16)
	{
		color("silver")
		_FTSU(FTSU16[0], FTSU16[1], FTSU16[2], FTSU16[3], FTSU16[4], FTSU16[5], FTSU16[6], FTSU16[7], FTSU16[8], FTSU16[9], FTSU16[10], L);
	}
}

module _FTSU(d, A, H, A1, A2, d2, H1, H2, K, C, G, L)
{ 
	translate([0,0,H])
		rotate([90,0,0])
			cylinder(d=d, h=L, $fn=50, center=true);
	
	translate([-A/2, -L/2, 0])
		eqlprism(A,L,H);
}

//uncomment to display
FTSU(12, 100);
