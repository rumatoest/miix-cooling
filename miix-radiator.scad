// For Lenovo Miix 320 radiator size should be about 10x21cm

$fn=5;

//HEIGHT
H=100;
//WIDTH
W=210;
//THICKNESS
TH=4;
// BASE Internal thickness (under case wall)
BT=0.5;
//Basement ledge
BL=4;
//CORNER radius
CR=2;
//Notch width - should depend on your cutter radius
NW=1.5;
// Radiator rib thickness
RT=1.5;
// Radiator depth
RD=3;
// Vertical radiator height
RVH=8;

BORDER=4;
OFFSET=50;
BEAMW=20;
BEAMF=0.5;

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
    
    translate([BL+BORDER+RVH, BL+BORDER, TH-RD]) {
        rotate([0,0,90])
        rnotch(H-BORDER*2, RVH, RD, NW, RT, true);
    }
}