/*
TABLET RADIATOR GENERATOR

This libarary should help you to create radiators for
tablet like devices. 

To make real it you should be familiar with CNC devices.

Right now it is aimed on Lenovo Miix devices where "heater"
located near to one side of tablet and this region 
is about 1/3 or 1/4 of available width.

Thus current radiator model goal is to move heat away from
one side of tablet and distribute it uniformly across 
all available surface.

NOTE:
 - For Lenovo Miix 320 radiator size should be about 10x21cm
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

//Height
H=80;
//Width
W=222;
//Total thickness
TH=2.4;
// Basement internal thickness (under the case)
BT=0.5;
// Basement ledge width
BL=3;
// CORNER radius
CR=2;

// Radiator ribs configuration
// Border size
R_BRD=8;
//Min notch thickness - should depend on your cutter radius
R_NT=2.5;
// Rib thickness
R_T=2;
// Split into blocks
R_S=2;
// Deepth at hot side
R_DH=0.5;
// Deepth at cool side
R_DC=2;

R_HW=50;
R_CW=80;

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
    floor((dist + item) / (item + space));

function space_items(dist, item, count) =
    (dist - item*count)/(count + 1);

module basement(w,h,th,r) {
    translate([r,r,0]) 
    minkowski() {
        cube([w-r*2, h-r*2, th*0.5]);
        cylinder(th*0.5,r,r);
    }
}

module radiator_cutting() {
    w=W-R_BRD *2;
    mxh=H-R_BRD *2;
    blkh=(mxh-R_BRD*(R_S-1)) / R_S;
    
    mxi=max_odd_items(blkh,R_T,R_NT);
    spc=space_items(blkh,R_T,mxi);
    echo("Notch width:", spc);
    ioff=0;
    for (iz=[0:R_S-1]) {
        izoff=iz*(R_BRD+blkh);
        for (i=[0:mxi]) {
            ioff=i*(R_T+spc)+izoff;
            
            translate([0,ioff,0]) cube([w, spc, TH]);
        }
    }
}

module radiator_depth() {
    hh=TH-R_DH;
    hc=TH-R_DC;
    tw=W-R_HW-R_CW;
    
    cube([R_HW, H, hh]);
    
    translate([R_HW,0,hh])
        rotate([-90,0,0])
        linear_extrude(height = H, center = false)
        polygon([[0,0],[0,hh],[tw,hh],[tw,hh-hc]]);
    
    // Quick solution
    //translate([R_HW,0,0])
        //cube([tw, H, TH-(R_DC+R_DH)/2]);
    
    translate([W-R_CW,0,0])
        cube([R_CW, H, TH-R_DC]);
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
        radiator_depth();
 
}