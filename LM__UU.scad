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

function LM8_length() = LM8[4];
function LM8_dia() = LM8[2];

module LM(size)
{
	if (size == 8)
	{
		_LM(LM8[0], LM8[1], LM8[2], LM8[3], LM8[4], LM8[5], LM8[6], LM8[7], LM8[8], LM8[9]);
	}
	if (size == "8L")
	{
		_LM(LM8L[0], LM8L[1], LM8L[2], LM8L[3], LM8L[4], LM8L[5], LM8L[6], LM8L[7], LM8L[8], LM8L[9]);
	}
	if (size == 10)
	{
		_LM(LM10[0], LM10[1], LM10[2], LM10[3], LM10[4], LM10[5], LM10[6], LM10[7], LM10[8], LM10[9]);
	}
	if (size == "10L")
	{
		_LM(LM10L[0], LM10L[1], LM10L[2], LM10L[3], LM10L[4], LM10L[5], LM10L[6], LM10L[7], LM10L[8], LM10L[9]);
	}
}

module _LM(dr, tolerancedr, D, toleranceD, L, toleranceL, B, toleranceB, D1, W)
{
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
//LM(8);
