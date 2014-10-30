# BalaurCNC

from https://en.wikipedia.org/wiki/Balaur

" A balaur is quite large, has fins, feet, and is polycephalous (it usually has three, sometimes seven, or even twelve serpent heads)"

seems very apt, especially as some twit has taken 'Cerberus' for a delta CNC.

# Goals

A self contained, portable CNC device that can (in order of importance)

* 3D print
* laser cut paper
* mill pcbs

# Why

CNC's, their design, build, maintenance and running is like catnip for all types of engineers. I use all three devices frequently enough to warrant having such a device.

And because i can.

# Design

## Assumptions

To make the print easy to store and be portable at the same time, it makes sense to enclose it within a case of some kind. (note the popfab, http://vimeo.com/45911972,  was in large part inspiration for this. However no documentation exists for the design or build).

Due to this requirement, the type of kinematics to use becomes obvious; a delta or polar kinematics system would be too large or incredibly difficult to implement.

Supporting all three uses on one head is also orders-of-magnitude more difficult, so a swappable head system a la popfab will be employed.

Finally, due to the multi-use nature of the device, one design constraint seems to be the bed size; ie it must be able to handle all three use cases. Standard paper sizes in the EU are A4, so this will be the size aimed for.

* Use an aluminium storage case as enclosure
* Traditional serial kinematics
* A4 bed
  * Must be heated for 3D printing
* Multiple replaceable heads

### Design Refinements

* Y folds down flat
*







## Aluminium Storage Suitacse

http://www.ebay.co.uk/itm/400536151068?ssPageName=STRK:MEWNX:IT&_trksid=p3984.m1497.l2649

ALUMINIUM ELECTRICIAN LOCKABLE FLIGHT CASE TOOL CHEST BOX BRIEFCASE

Advertised dimensions: 18 X 13 X 6 INCH'S

Measured dimensions: 

case_width  = 460;
case_depth  = 330;
case_height = 160;

## A4 Bed

A4 = 210 x 297 mm

The RepRap site has an example of an A4 heated bed

http://reprap.org/wiki/PCB_Heatbed#MK2_A4

a picture

http://reprap.org/wiki/File:Big_Heatbed.JPG

A4 PCB copper clad board - http://www.ebay.co.uk/itm/210x297mm-Double-Sided-Copper-Clad-PCB-Epoxy-Glass-Fibre-/200995771271?pt=UK_BOI_Electrical_Components_Supplies_ET&hash=item2ecc481387

## Extruder

based on 

http://forums.reprap.org/read.php?94,147175,183883

there seems to be an acceptable lightweight geared stepper motor that can be used for a direct drive hot end.

http://www.2engineers.com/shop/geared150/

possible alternative - http://www.aliexpress.com/item/25byhj60-04a-25mm-stepper-motor-metal-gear-box/1268200073.html 

## Hotends

All metal hot end chosen for future filament materials experimentation. Also no danger of borking the hot end from accidental high temps

The choice was between the E3D and prusa:

* http://e3d-online.com/E3D-HotEnds/E3D-DirectFeed-HotEnds/E3D-V5-3mm-Direct-All-Metal-HotEnd
* https://www.reprapsource.com/en/show/6891

both have their quirks, though the E3D hotend is better documented. In the end i chose the E3D because of that, and the its availability. The prusa hotend is believed to be superior but it wasnt available, and i dont think i'll ever be printing to a level where i will extract the full potential of it.

### Drive Gear

http://www.ebay.co.uk/itm/MK8-Drive-Gear-for-1-7-3mm-plastic-filament-35-more-power-than-MK7-Best-in-test-/281302443633?pt=LH_DefaultDomain_0&hash=item417eeea671

# CNC Implementation

## kinematics
### linear rod+bearings
2x sk20 = - 24 GBP - http://www.ebay.co.uk/itm/x4pcs-SK20-Shaft-Support-ID20mm-Samic-CNC-XYZ-/310353341727?pt=LH_DefaultDomain_3&hash=item4842802d1f 
2x sc20 = 26.5 GBP - http://www.ebay.co.uk/itm/x2pcs-New-SC20-Housing-ID20mm-Samic-Linear-Bearing-CNC-SMA20-/221072318760?pt=LH_DefaultDomain_3&hash=item3378efe128
2x 500mm 20mm round rail = 24.68 GBP - http://www.ebay.co.uk/itm/EGR-15-20-25mm-1m-Linear-Motion-Carriage-Guide-Rail-Slide-Block-Flange-Block-/400704914081?pt=LH_DefaultDomain_3&var=&hash=item5d4bdfc2a1

total = 75.18

OR

kit (with 4x sc20) = 68 gbp - http://www.ebay.co.uk/itm/x2-20mm-Rails-500mm-x4-SK20-x4-SC20UU-CNC-Axis-Custom-3d-Printer-/221440004481?pt=UK_BOI_Metalworking_Milling_Welding_Metalworking_Supplies_ET&hash=item338eda5181

### linear slide + bearings
all items from hinwin.com and http://www.ebay.co.uk/itm/EGR-15-20-25mm-1m-Linear-Motion-Carriage-Guide-Rail-Slide-Block-Flange-Block-/400704914081?pt=LH_DefaultDomain_3&var=&hash=item5d4bdfc2a1

1m slide = EGR 15-1000 = 75gbp
2 x egh15ca = 2 x 21 gbp = 42gbp
total = 117 gbp

http://www.lmbearings.com/index.php?p=linear-guides

http://www.wmh-trans.co.uk/Products/HIWIN_LINEAR_GUIDE_RAILS_EGR15

#### Beam Deflection Calculations

from http://www.engineersedge.com/beam-deflection-menu.htm
http://www.engineersedge.com/beam_bending/beam_bending3.htm
http://www.engineersedge.com/beam_bending/calculators_protected/beam_deflection_3.htm



## hinged X axis

### hinge




# Electronics

Beaglebone Black with machinekit, custom stepper drivers and magic sauce

## laser
lens

http://www.ebay.co.uk/sch/i.html?_trksid=p2047675.m570.l1313.TR1.TRC0.A0.H0.X405-G-2&_nkw=405-G-2&_sacat=0&_from=R40

laser
http://www.ebay.co.uk/sch/i.html?_trksid=p2050601.m570.l1313&_nkw=Nichia+3+watt+9mm&_sacat=0&_from=R40

from https://www.kickstarter.com/projects/1537608281/lazerblade-the-affordable-laser-cutter-engraver

# Software
http://www.machinekit.io/useful - Linux CNC packaged into Debian with a RT kernel for the beaglebone black


http://www.openbuilds.com/threads/new-build-5-controller-cam-options-your-opinions-please.452/

