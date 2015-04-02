//(C) Nathan Zadoks 2011
//CC-BY-SA or GPLv2, pick your poison.
//modified 2014-11-03 by Amran Anjum (amx109) to make sure the tslot is centered on X/Y/Z
//further modified to restore my sanity

$fn=50;

//			size, length, sheet thickness, 'gap', center hole dia, centre cube width
tslot_20   = [20, 0, 1.8, 5, 4.3, 7.3];
tslot_30   = [30, 0, 2, 6, 5, 10.5];
tslot_8x30 = [30, 0, 2, 8, 7, 10.8];
tslot_40   = [40, 0, 2, 8, 6.8, 15.5];

module tslot(size, length)
{
	echo(str("Item: T-Slot size ", size, "mm Length: ", length, "mm"));
	
	if(size == 20)
		_tslot(tslot_20+[0,length,0,0,0,0]);
	if(size == 30)
		_tslot(tslot_30+[0,length,0,0,0,0]);
	if(size == "8x30")
		_tslot(tslot_8x30+[0,length,0,0,0,0]);
	if(size == 40)
		_tslot(tslot_40+[0,length,0,0,0,0]);
}

module tslot_nut(size, M)
{
	echo(str("Item: T-Slot Nut keyed ", size, "mm M",M," thread"));
	
	if(size == 30)
		_tslot_nut(tslot_30+[0,20,0,0,0,0],M);
	if(size == "8x30")
		_tslot_nut(tslot_8x30+[0,20,0,0,0,0],M);
	if(size == 40)
		_tslot_nut(tslot_40+[0,20,0,0,0,0],M);
}
module _tslot(dims)
{
	size=dims[0];		//size of each side
	length=dims[1];		//length. descriptive enough, no?
	thickness=dims[2];	//thickness of the 'sheet'
	gap=dims[3];		//gap, thickness of the lower part of the 'T'
	center_r = dims[4];
	center_cube = dims[5];
	
	start=thickness/sqrt(2);
	
	color([0.5,0.5,0.5])
	render()
	rotate([0,90,0])
	translate([0,0,-length/2])
		linear_extrude(height=length)
			difference()
			{
				union()
				{
					for(d=[0:3]) rotate([0,0,d*90]) polygon(points=[
						[0,0],
						[0,start],
						[size/2-thickness-start,size/2-thickness],
						[gap/2,size/2-thickness],[gap/2,size/2],
						[size/2,size/2],
						[size/2,gap/2],
						[size/2-thickness,gap/2],
						[size/2-thickness,size/2-thickness-start],
						[start,0]
					]);
					square(center_cube,center=true);
				}
				
				circle(r=center_r/2,center=true);
			}
	
}

module _tslot_nut(dims,M)
{
	size=dims[0];		//size of each side
	length=dims[1];		//length. descriptive enough, no?
	thickness=dims[2];	//thickness of the 'sheet'
	gap=dims[3];		//gap, thickness of the lower part of the 'T'
	
	start=thickness/sqrt(2);
	
	render()
		difference()
		{
			rotate([-90,0,90])
			translate([-size/2,-(size/2-(gap+thickness)/2)/2,-length/2]) 
			linear_extrude(height=length)
				intersection(){
					polygon([	[size/2-gap/2,0],
								[size/2-gap/2,thickness],
								[thickness+start,thickness],
								[size/2,size/2-2],
								[size-thickness-start,thickness],
								[size/2+gap/2,thickness],
								[size/2+gap/2,0]]);
					square([size,size/2-(gap+thickness)/2]);
				}
			translate([length/4,0,0]) cylinder(d=M, h=length+2, $fn=50, center=true);
		}
}

tslot(30, 100);
translate([30,0,0]) tslot_nut(30, 5); 
