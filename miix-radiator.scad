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

// 3d printed template to cut off aperture in back case
//show_template(); 

// This one is tricky. 
// I suggest that first you should cut of some kind
// of holder for aluminum/brass ingot into wood basement.
// This model should help you with proper shape
//show_basement_cnc();

//
// CONFIGURATION
//
$fn=25;

//Height
H=100;
//Width
W=210;
//Thickness
TH=4;
// Basement internal thickness (under the case)
BT=0.5;
//Basement ledge
BL=3;
//CORNER radius
CR=2;

//Notch width - should depend on your cutter radius
NW=2;
// Radiator rib thickness
RT=1.5;
// Radiator depth
RD=3;
// Vertical radiator height
RVH=8;

// radiator shape proportions
BORDER=3;
OFFSET=50;
BEAMW=20;
BEAMF=0.65;

//
// CNC BASE
//
module show_basement_cnc(
    ingoth=110,
    ingotw=220,
    depth=10,
    cutter_diameter=10,
    z_level_square=50,
) {
    zl=z_level_square;
    cd=cutter_diameter;
    difference() {
        cube([ingotw+4*cd+zl, ingoth+4*cd, depth]);
        translate([cd*2, cd*2, 0]) {
            cube([ingotw, ingoth, depth]);
            translate([-cd, 0, 0])
                cube([cd, cd, depth]);
            translate([ingotw, 0, 0])
                cube([cd, cd, depth]);
            translate([-cd, ingoth-cd, 0])
                cube([cd, cd, depth]);
            translate([ingotw, ingoth-cd, 0])
                cube([cd, cd, depth]);
        }
        translate([ingotw+2*cd, (ingoth+4*cd-zl)/2, 0])
            cube([zl, zl, depth]);
        
        
    }
}

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
module basement(w,h,th,r,sph=false) {
    intersection() {
        cube([w,h,th]);
        translate([r,r,0]) minkowski() {
            cube([w-r*2,h-r*2,th]);
            if(sph) {
                translate([0,0,-r]) sphere(r);
            } else {
                cylinder(r,r,r);
            }
            
        }
    }
}

// Produce notches for radiator
module rnotch(w,h,th,nw,rt, oneside=false) {
difference() {
    cube([w,h,th]);
    mribs = floor((w+rt)/(rt+nw));
    dist = (w+rt - rt*mribs)/mribs;
    for(n=[0:mribs-1]) {
        y = !oneside && n % 2 ? nw : 0;
        translate([n*dist + n*rt - rt, y, 0])
            cube([rt, h-nw, th]);
    }
}
}

module rblock(w, h, beam, rd, rt, nw) {
    hspace = (h - beam * 2) / 3;
    union() {
        rnotch(w, hspace, rd, nw, rt);
        
        translate([0, hspace + beam, 0])
            rnotch(w, hspace, rd, nw, rt);
        
        translate([0, (hspace + beam)*2, 0]) 
            rnotch(w, hspace, rd, nw, rt);
    }
}

module show_radiator() {
    //color("Azure")
    difference() {
        union() {
            translate([BL, BL, 0]) basement(W,H,TH,CR, true);
            basement(W+BL*2,H+BL*2,BT,CR);
        }
        
        border1 = BEAMW;
        border2 = BEAMW*BEAMF;
        hspace1 = H - border1;
        hspace2 = H - border2;
        wspace = (W - OFFSET - BORDER) / 2;
        
        translate([BL+OFFSET, BL+border1/2,TH-RD])
            rblock(wspace, hspace1, BEAMW, RD, RT, NW); 
        
        translate([BL+OFFSET+wspace-NW, BL+border2/2, TH-RD])
            rblock(wspace+NW, hspace2, BEAMW*BEAMF, RD, RT, NW); 
        
        translate([BL+RVH-NW, BL+BORDER, TH-RD]) {
            rotate([0,0,90])
            rnotch(H-BORDER*2, RVH, RD, NW, RT, true);
        }
    }
}