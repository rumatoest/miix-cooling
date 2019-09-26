 /*
TABLET RADIATOR GENERATOR

This libarary should help you to create radiators for
tablet like devices. 

To make it real you should be familiar with CNC devices.

Originally it was created for Lenovo Miix devices 
where "heater" is located near the one side of tablet 
and this region is about 1/3 or 1/4 of all width.

Thus current radiator model goal is to move heat away from
one side of tablet and distribute it uniformly across 
all available surface.

NOTE:
 - For Lenovo Miix 320 radiator size should be about 22x8.5cm
*/


//
// OUTPUT
//

// Displays radiator model
show_radiator();

//3D printed template to help with manual aperture cutting
//show_template(); 


//
// CONFIGURATION
//
$fn=25;

// Main block height
H=84; 
// Main block width
W=222; 
// Main block thickness (Z axis)
TH=2.45; 
// CORNER radius
CR=2; 
// Basement ledge width
BL=3; 
// Basement ledge thickness (under the case)
BT=0.5; 

//
// RADIATOR CFG
//
// Internal offset/border
R_BRD=6; 
// Nuber of block separated by offset
R_S=3; 

// Minimum notch width. WARNING this value depends on CNC end mill radius
R_NT=2.4; 
// Rib thickness
R_T=2; 
// Round notch corners
R_RN=true;

// Notch deepth at hot side
R_DH=0.6; 
// Deepth at cool side
R_DC=2.1; 

// Hot side width
R_HW=60; 
// Cool side width
R_CW=60; 

//
// TEMPLATE MODULES
//
module show_template(tw=4, th=2, hold=8, holdw=30, holdh=0.4) {
    color("DarkKhaki")
    translate([hold, hold, 0])
    difference() {
        cube([W+2*tw, H+2*tw, th]);
        translate([tw+CR, tw+CR, 0])
        minkowski() {
            cube([W-CR*2, H-CR*2, th]);
            cylinder(th,CR,CR);
        }
    }

    // Template handles
    color("SandyBrown") {
        translate([0,(H+2*tw-holdw)/2, 0])
            cube([hold, holdw, holdh]);
        translate([W+2*tw+hold,(H+2*tw-holdw)/2, 0])
            cube([hold, holdw, holdh]);
        translate([(W+2*tw-holdw)/2, 0, 0])
            cube([holdw, hold, holdh]);
        translate([(W+2*tw-holdw)/2, H+2*tw+hold, 0])
            cube([holdw, hold, holdh]);
    }
}


//
// RADIATOR MODULES
//
function max_odd_items(dist, item, space) = 
    floor((dist-space) / (item + space));

function space_items(dist, item, count) =
    (dist - item*count)/(count + 1);

module basement(w,h,th,r) {
    translate([r,r,0]) 
    minkowski() {
        cube([w-r*2, h-r*2, th*0.5]);
        cylinder(th*0.5,r,r);
    }
}

module notch(w,h,d) {
   if (R_RN) {
       r=h/2;
       translate([r,r,0]) cylinder(d, r, r);
       translate([r,0,0]) cube([w-h, h, d]);
       translate([w-r,r,0]) cylinder(d, r, r);
   } else {
       cube([w, h, d]);
   }
}

module radiator_cutting() {
    w=W-R_BRD *2;
    mxh=H-R_BRD *2;
    blkh=(mxh-R_BRD*(R_S-1)) / R_S;
    //echo("Block height", blkh);
    mxi=max_odd_items(blkh, R_T, R_NT);
    //echo("Total ribs", mxi);
    spc=space_items(blkh,R_T, mxi);
    echo("NOTE: radiator notch width", spc);
    ioff=0;
    for (iz=[0:R_S-1]) {
        izoff=iz*(R_BRD+blkh);
        for (i=[0:mxi]) {
            ioff=i*(R_T+spc)+izoff;
            translate([0,ioff,0]) notch(w, spc, TH+0.1);
        }
    }
}

module radiator_depth() {
    h=H-R_BRD;
    hh=TH-R_DH;
    hc=TH-R_DC;
    tw=W-R_HW-R_CW;
    
    translate([0,R_BRD/2,0])
        cube([R_HW, h, hh]);
    
    translate([R_HW,R_BRD/2,hh])
        rotate([-90,0,0])
        linear_extrude(height = h, center = false)
        polygon([[0,0],[0,hh],[tw,hh],[tw,hh-hc]]);
    
    translate([W-R_CW,R_BRD/2,0])
        cube([R_CW, h, TH-R_DC]);
}

module show_radiator() {
    //color("Azure")
    difference() {
        union() {
            translate([BL, BL, 0]) 
                basement(W,H,TH,CR);
            color("LightSteelBlue")
            basement(W+BL*2,H+BL*2,BT,CR);
        }
        translate([BL+R_BRD, BL+R_BRD, 0])
            radiator_cutting();
    }
    
    translate([BL, BL, 0])
        color("SteelBlue")
        radiator_depth();
 
}