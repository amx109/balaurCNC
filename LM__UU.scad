/*
 * Model of a LMXXUU linear bearing
 * 
 * 
 * This object is for display only. it is not printable
 * 
 * currently only has info to produce LM8UU bearings
 */

$fn=50;

LM8 = [8, 0, 15, -0.011, 24, 0, 17.5, 0, 14.3, 1.1];
LM8L = [8, 0, 16, 0, 46, 0, 33, 0, 15.2, 0];
LM10 = [10, 0, 19, 0, 29, 0, 22, 0, 18, 1.3];
LM10L = [10, 0, 19, 0, 46, 0, 33, 0, 15.2, 0];

function LM_rod_dia(type) 	= type == "LM8" ? LM8[0] : type == "LM10" ? LM10[0] : undef;
function LM_dia(type) 		= type == "LM8" ? LM8[2] : type == "LM10" ? LM10[2] : undef;
function LM_length(type) 	= type == "LM8" ? LM8[4] : type == "LM10" ? LM10[4] : undef;

module LM(size)
{
	echo(str("Item: LM",size,"UU bushing"));
	
	if (size == "LM8")
		_LM(LM8);
	if (size == "LM8L")
		_LM(LM8L);
	if (size == "LM10")
		_LM(LM10);
	if (size == "LM10L")
		_LM(LM10L);
}

module _LM(dims)
{
	dr = dims[0];
	tolerancedr = dims[1];
	D = dims[2];
	toleranceD = dims[3];
	L = dims[4];
	toleranceL = dims[5];
	B = dims[6];
	toleranceB = dims[7];
	D1 = dims[8];
	W = dims[9];
	
	color("Silver")
	{
		difference()
		{
			cylinder(d=D, h=L, center=true);
			cylinder(d=dr, h=L+1, center=true);
		}
	}
}

//uncomment to display
LM("LM8");

