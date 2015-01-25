/*
 * Model of a LMBXXUUOP linear bearing
 * 
 * 
 * This object is for display only. it is not printable
 * 
 * currently only has info to produce LM8UU bearings
 */
use <MCAD/libtriangles.scad>

$fn=50;

LM8UUOP =  [8,  15, 24, 17.5, 14.3, 1.1, 1, 6.8, 80]; // opening angle+gap info is from LM10UUOP
LM12UUOP = [12, 22, 32, 22.9, 21,   1.3, 1, 8, 78];
LM16UUOP = [16, 26, 36, 24.9, 24.9, 1.3, 1, 10.8, 78];

function LM8OP_length() = LM8UUOP[2];
function LM8OP_dia() = LM8UUOP[1];

function LM12OP_length() = LM12UUOP[2];
function LM12OP_dia() = LM12UUOP[1];

function LM16OP_length() = LM16UUOP[2];
function LM16OP_dia() = LM16UUOP[1];

module LMOP(size)
{
	echo(str("Item: LM",size,"OPUU bushing"));
	if (size == 8)
	{
		_LM__UUOP(LM8UUOP[0], LM8UUOP[1], LM8UUOP[2], LM8UUOP[3], LM8UUOP[4], LM8UUOP[5], LM8UUOP[6], LM8UUOP[7], LM8UUOP[8]);
	}
	if (size == 12)
	{
		_LM__UUOP(LM12UUOP[0], LM12UUOP[1], LM12UUOP[2], LM12UUOP[3], LM12UUOP[4], LM12UUOP[5], LM12UUOP[6], LM12UUOP[7], LM12UUOP[8]);
	}
	if (size == 16)
	{
		_LM__UUOP(LM16UUOP[0], LM16UUOP[1], LM16UUOP[2], LM16UUOP[3], LM16UUOP[4], LM16UUOP[5], LM16UUOP[6], LM16UUOP[7], LM16UUOP[8]);
	}
}

module LMOP_oversize(size)
{
	//match bearing based on bearing outer dia
	if (size == 15) //then is an LM8
	{
		_LM__UUOP(LM8UUOP[0], LM8UUOP[1], LM8UUOP[2], LM8UUOP[3], LM8UUOP[4], LM8UUOP[5], LM8UUOP[6], LM8UUOP[7]-1, LM8UUOP[8]-20);
	}
}

module _LM__UUOP(dr, D, L, B, D1, W, F, E, angle)
{
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
LMOP(16);
//LMOP_oversize(15);
