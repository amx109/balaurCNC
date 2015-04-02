//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// NEMA stepper motor model
//
// modified by amran amx109@gmail.com

//                             corner  body    boss    boss          shaft
//               side, length, radius, radius, radius, depth, shaft, length, holes
NEMA17        = [42.3, 47,     53.6/2, 25,     11,     2,     5,     24,     31 ];
NEMAJAN       = [42,   39.2,   53.6/2, 25,     11,     2,     5,     13,     31 ];
NEMA17S       = [42.3, 34,     53.6/2, 25,     11,     2,     5,     24,     31 ];
NEMA17SWantai = [42.1, 33,     53.9/2, 25,     11,     2,     5,     24,     31 ]; //wantai 42BYGHW208
NEMA14        = [35.2, 36,     46.4/2, 21,     11,     2,     5,     21,     26 ];
NEMA23        = [56.4, 51.2,   75.7/2, 28.2,   38.1/2, 1.6,   6.35,  24,     47.1 ];

function NEMA_width(motor)       = motor==17 ? NEMA17[0] : motor=="JAN"? NEMAJAN[0] : motor=="17S"? NEMA17S[0] : motor=="17SWantai"? NEMA17SWantai[0] : motor==14? NEMA14[0] : motor[0];
function NEMA_length(motor)      = motor==17 ? NEMA17[1] : motor=="JAN"? NEMAJAN[1] : motor=="17S"? NEMA17S[1] : motor=="17SWantai"? NEMA17SWantai[1] : motor==14? NEMA14[1] : motor[1];
function NEMA_radius(motor)      = motor[2];
function NEMA_boss_radius(motor) = motor==17 ? NEMA17[4] : motor=="JAN"? NEMAJAN[4] : motor=="17S"? NEMA17S[4] : motor=="17SWantai"? NEMA17SWantai[4] : motor==14? NEMA14[4] : motor[4];
function NEMA_boss_height(motor) = motor==17 ? NEMA17[5] : motor=="JAN"? NEMAJAN[5] : motor=="17S"? NEMA17S[5] : motor=="17SWantai"? NEMA17SWantai[5] : motor==14? NEMA14[5] : motor[5];
function NEMA_shaft_dia(motor)   = motor[6];
function NEMA_shaft_length(motor)= motor==17 ? NEMA17[7] : motor=="JAN"? NEMAJAN[7] : motor=="17S"? NEMA17S[7] : motor=="17SWantai"? NEMA17SWantai[7] : motor==14? NEMA14[7] : motor[7];
function NEMA_hole_pitch(motor)  = motor==17 ? NEMA17[8] : motor=="JAN"? NEMAJAN[8] : motor=="17S"? NEMA17S[8] : motor=="17SWantai"? NEMA17SWantai[8] : motor==14? NEMA14[8] : motor[8];
function NEMA_holes(motor)       = motor=="JAN"? [-NEMAJAN[8]/2, NEMAJAN[8]/2] : [-motor[8]/2, motor[8]/2];

module NEMA(motor) {
    side = NEMA_width(motor);
    length = NEMA_length(motor);
    body_rad = motor[3];
    boss_rad = motor[4];
    boss_height = motor[5];
    shaft_rad = NEMA_shaft_dia(motor) / 2;
    cap = 8;
    
    union()
    {
        color("black")
        render() // black laminations
            translate([0,0, -length / 2])
                intersection()
                {
                    cube([side, side, length - cap * 2],center = true);
                    cylinder(r = body_rad, h = 2 * length, center = true);
                }
        
        color("silver") // aluminium end caps
        render() 
		difference()
		{
			union()
			{
				intersection()
				{
					union()
					{
						translate([0,0, -cap / 2])
							cube([side,side,cap], center = true);
						translate([0,0, -length + cap / 2])
							cube([side,side,cap], center = true);
					}
					cylinder(r = NEMA_radius(motor), h = 3 * length, center = true);
				}
				
				difference()
				{
					cylinder(r = boss_rad, h = boss_height * 2, center = true);                 // raised boss
					cylinder(r = shaft_rad + 2, h = boss_height * 2 + 1, center = true);
				}
				
				cylinder(r = shaft_rad, h = NEMA_shaft_length(motor) * 2, center = true, $fn=25);  // shaft
			}
			
			for(x = NEMA_holes(motor))
				for(y = NEMA_holes(motor))
					translate([x, y, 0])
						cylinder(r = 3/2, h = 9, center = true); //screw holes
		}
        

        translate([0, side / 2, -length + cap / 2])
            rotate([90, 0, 0])
                for(i = [0:3])
                    rotate([0, 0, 225 + i * 90])
                        color(["red", "blue","green","black"][i]) render()
                            translate([1, 0, 0])
                                cylinder(r = 1.5 / 2, h = 12, center = true); //wires


    }
}

module NEMA_screws(motor, n = 4, screw_length = 8, screw_type = M3_pan_screw) {
    for(a = [0: 90 : 90 * (n - 1)])
        rotate([0, 0, a])
            translate([motor[8]/2, motor[8]/2, 0])
                screw_and_washer(screw_type, screw_length, true);
}

module nema_motor(size)
{
	echo(str("Item: NEMA",size," Stepper Motor"));
	if(size == 17) NEMA(NEMA17);
	if(size == "JAN") NEMA(NEMAJAN);
	if(size == "17S") NEMA(NEMA17S);
	if(size == "17SWantai") NEMA(NEMA17SWantai);
	if(size == 14) NEMA(NEMA14);
	if(size == 23) NEMA(NEMA23);
}
nema_motor(17);
