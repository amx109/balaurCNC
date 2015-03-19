/*
 * Model of a LMBXXUUOP linear bearing
 * 
 * 
 * This object is for display only. it is not printable
 * 
 * currently only has info to produce LM8UU bearings
 */
use <ironmongery.scad>

$fn=50;

LM8UUOP =  [8,  15, 24, 17.5, 14.3, 1.1, 1, 6.8, 80]; // opening angle+gap info is from LM10UUOP
LM12UUOP = [12, 22, 32, 22.9, 21,   1.3, 1, 8, 78];
LM16UUOP = [16, 26, 36, 24.9, 24.9, 1.3, 1, 10.8, 78];

function LMOP_dia(type)		= type == "LM8" ? LM8UUOP[1] : type == "LM12" ? LM12UUOP[1] : type == "LM16" ? LM12UUOP[1] : undef;
function LMOP_length(type)	= type == "LM8" ? LM8UUOP[2] : type == "LM12" ? LM12UUOP[2] : type == "LM16" ? LM12UUOP[2] : undef;

module LMOP(size)
{
	echo(str("Item: LM",size,"OPUU bushing"));
	
	if (size == "LM8") _LM__UUOP(LM8UUOP);
	if (size == "LM12") _LM__UUOP(LM12UUOP);
	if (size == "LM16") _LM__UUOP(LM16UUOP);
}

module LMOP_oversize(size)
{
	dims8_oversize = LM8UUOP+[0,0,0,0,0,0,0,-1,-20];
	//match bearing based on bearing outer dia
	if (size == "LM8") //then is an LM8
		_LM__UUOP(dims8_oversize);
}

module _LM__UUOP(dims)
{
	dr = dims[0];
	D = dims[1];
	L = dims[2];
	B = dims[3];
	D1 = dims[4];
	W = dims[5];
	F = dims[6];
	E = dims[7];
	angle = dims[8];
	
	// side length of isosceles triangle is 30
	// use lots of trig - use half the isos tri (gives us a anice right angle triangle to work with)
	xlen = ( sin(angle/2) / (sin(90)/30) )*2;
	ylen = L;
	zlen = sin(180-(90+(angle/2))) / ( sin(90)/30 );
	
	difference()
	{
		//the bearing
		color("Silver") cylinder(d=D, h=L, center=true);
		cylinder(d=dr, h=L+1, center=true);
		
		//the gap in the bearing
		translate([0,-9.6,0])
		{
			union()
			{
				//the triangluar slot
				translate([-xlen/2,-zlen/2+0.07,ylen/2+0.1])
					rotate([-90,0,0])
						eqlprism(xlen, ylen+1, zlen);
				//the gap in the centre
				*translate([0,E+2,0.1])
					cube(size=[E,E/2,L], center=true);
			}
		}
	}
}

//uncomment to display
LMOP("LM8");
translate([30,0,0]) LMOP_oversize("LM8");
