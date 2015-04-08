/* models some HIWIN linear rails and bearing blocks
 * 
 * 
 */

M4 = 4;
M3 = 3;
$fn=50;

EGH_CA_15 = [24,4.5,9.5,34,26,4,26,39.8,56.8,10.15,5.7,M4,6,6,5.5,6,15,12.5,6,4.5,3.5,60,20];
MGN_12C	=	[13,3,7.5,27,20,3.5,15,21.7,34.7,0,0.8,M3,3.5,2.5,12,8,6,4.5,3.5,25,10];
MGN_12H =	[13,3,7.5,27,20,3.5,20,32.4,45.4,0,0.8,M3,3.5,2.5,12,8,6,4.5,3.5,25,10];

function mgn_bushing_length(type) = type == "12C" ? MGN_12C[8] : type == "12H" ? MGN_12H[8] : undef;
function mgn_bushing_width(type)  = type == "12C" ? MGN_12C[3] : type == "12H" ? MGN_12H[3] : undef;
function mgn_bushing_height(type) = type == "12C" ? MGN_12C[0]-MGN_12C[1] : type == "12H" ? MGN_12H[0]-MGN_12H[1] : undef;
function mgn_bushing_holes(type)  = type == "12C" ? [MGN_12C[4],MGN_12C[6]] : "12H" ? [MGN_12H[4],MGN_12H[6]] : undef;
function mgn_rail_mount_holes(type) = type == "12C" ? [MGN_12C[19],MGN_12C[20]] : "12H" ? [MGN_12H[19],MGN_12H[20]] : undef;
function mgn_rail_height(type)    = type == "12C" ? MGN_12C[15] : type == "12H" ? MGN_12H[15] : undef;

module egh_ca(size)
{
	if(size == 15)
	{
		egh_ca_(EGH_CA_15);
	}
}

module mgn(size)
{
	echo(str("Item: MGN",size," bushing"));
	
	if(size == "12C")
	{
		mgn_(MGN_12C);
	}
	if(size == "12H")
	{
		mgn_(MGN_12H);
	}
}

module mgn_rail(size, length)
{
	echo(str("Item: MGN",size," Rail, Length:",length));
	
	if(size == "12C" || size == "12H")
	{
		mgn_rail_(MGN_12C, length);
	}
}

module egr(size, rlength)
{
	if(size == 15)
	{
		egr_(EGH_CA_15, rlength);
	}
}

module egh_ca_(dims)
{
	H = dims[0];
	H1 = dims[1];
	N = dims[2];
	W = dims[3];
	B = dims[4];
	B1 = dims[5];
	C = dims[6];
	L1 = dims[7];
	L = dims[8];
	K1 = dims[9];
	G = dims[10];
	M = dims[11];
	l = dims[12];
	T = dims[13];
	H2 = dims[14];
	H3 = dims[15];
	Wr = dims[16];
	Hr = dims[17];
	D = dims[18];
	h = dims[19];
	d = dims[20];
	P = dims[21];
	E = dims[22];
	
	translate([0, 0, Hr/2]) 
	difference()
	{
		//main shape
		cube(size=[L, W, H-H1], center=true);
			translate([0,0,-(((H-H1)-(Hr-H1))/2)-0.05])
				cube(size=[L+1, Wr, Hr-H1+0.1], center=true);
		
		//mounting holes
		for(i=[1,-1])
			for(j=[1,-1])
				translate([i*C/2, j*B/2, ((H-H1)/2)-l/2+0.1])
					cylinder(d=M, h=l, $fn=50, center=true);
	}
	
	
}

module mgn_(dims)
{
	H = dims[0];
	H1 = dims[1];
	N = dims[2];
	W = dims[3];
	B = dims[4];
	B1 = dims[5];
	C = dims[6];
	L1 = dims[7];
	L = dims[8];
	G = dims[9];
	Gn = dims[10];
	M = dims[11];
	l = dims[12];
	H2 = dims[13];
	Wr = dims[14];
	Hr = dims[15];
	D = dims[16];
	h = dims[17];
	d = dims[18];
	P = dims[19];
	E = dims[20];
	
	color("LightGrey")
	render()
	translate([0, 0, Hr/2]) 
	difference()
	{
		//main shape
		cube(size=[L, W, H-H1], center=true);
			translate([0,0,-(((H-H1)-(Hr-H1))/2)-0.05])
				cube(size=[L+1, Wr, Hr-H1+0.1], center=true);
		
		//mounting holes
		for(i=[1,-1])
			for(j=[1,-1])
				translate([i*C/2, j*B/2, ((H-H1)/2)-l/2+0.1])
					cylinder(d=M, h=l, $fn=50, center=true);
	}	
}

module egr_(dims, rlength)
{
	H = dims[0];
	H1 = dims[1];
	N = dims[2];
	W = dims[3];
	B = dims[4];
	B1 = dims[5];
	C = dims[6];
	L1 = dims[7];
	L = dims[8];
	K1 = dims[9];
	G = dims[10];
	M = dims[11];
	l = dims[12];
	T = dims[13];
	H2 = dims[14];
	H3 = dims[15];
	Wr = dims[16];
	Hr = dims[17];
	D = dims[18];
	h = dims[19];
	d = dims[20];
	P = dims[21];
	E = dims[22];
	
	cube(size=[rlength, Wr, Hr], center=true);
}

module mgn_rail_(dims, length)
{
	H = dims[0];
	H1 = dims[1];
	N = dims[2];
	W = dims[3];
	B = dims[4];
	B1 = dims[5];
	C = dims[6];
	L1 = dims[7];
	L = dims[8];
	G = dims[9];
	Gn = dims[10];
	M = dims[11];
	l = dims[12];
	H2 = dims[13];
	Wr = dims[14];
	Hr = dims[15];
	D = dims[16];
	h = dims[17];
	d = dims[18];
	P = dims[19];
	E = dims[20];
	
	color("WhiteSmoke")
	//render()
	difference()
	{
		cube(size=[length, Wr, Hr], center=true); //the rail
		
		//mounting holes (from the top)
		translate([-length/2+E, 0, 0])
		{
			translate([0, 0, Hr/2-h/2+0.1/2]) cylinder(d=D, h=h+0.1, $fn=50, center=true);
			translate([0, 0, -Hr/2+(Hr-h)/2]) cylinder(d=d, h=Hr-h+0.1, $fn=50, center=true);
			
			for(i=[1:(length-E)/P])
				translate([i*P, 0, 0])
				{
					translate([0, 0, Hr/2-h/2+0.1/2]) cylinder(d=D, h=h+0.1, $fn=50, center=true);
					translate([0, 0, -Hr/2+(Hr-h)/2]) cylinder(d=d, h=Hr-h+0.1, $fn=50, center=true);
				} 
		}
	}
}

translate([0,40,0])
{
	egh_ca(15);
	#egr(15, 500);
}
mgn("12C");
translate([63,0,0]) mgn("12H");
mgn_rail("12C", 400);

aa = mgn_rail_mount_holes("12C");
echo(aa);



