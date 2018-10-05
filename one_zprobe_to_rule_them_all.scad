$fa=3;
$fs=0.2;

print_dilation=0.15;// when printing the shape gets dilated typically by 0.15mm
print_dilation_max=0.2;// max 0.2

extruder_to_plate_height=40;
screw_plate_thickness=4;
screw_plate_height=12.5;
screw_plate_hole_distance=24;
screw_plate_hole_height=8;

wire_r=1+print_dilation;

thickness=2;
lever_shaft_length=4;
lever_r=1;
slot_side=lever_r*2;
slot_depth=lever_r*sqrt(2)*2;
slot_width=slot_depth*2;

mechanism_length=30;

mechanism_width=10;

slot_crooked_by=0.05;


m2_hole_r=0.95;

screw_r=1;
screw_l=20;

module sequential_hull(){
	for (i = [0: $children-2])
		hull(){
			children(i);
			children(i+1);
		}
}

module cylinder_sequence(pts){
    for(i=[0 : len(pts)-2]){
        translate([0, 0, pts[i][0]]){
            cylinder(pts[i+1][0]-pts[i][0]+eps, r1=pts[i][1], r2=pts[i+1][1]);
        }
    }
}

module box(low, high){
    translate(low){
        cube(high-low);
    }
}

module rounded_box(l, h, r){
    hull(){
        translate([l[0]+r, l[1]+r, l[2]+r])sphere(r);        
        translate([l[0]+r, l[1]+r, h[2]-r]) sphere(r);
        translate([l[0]+r, h[1]-r, l[2]+r]) sphere(r);
        translate([l[0]+r, h[1]-r, h[2]-r]) sphere(r);
        
        translate([h[0]-r, l[1]+r, l[2]+r]) sphere(r);
        translate([h[0]-r, l[1]+r, h[2]-r]) sphere(r);
        translate([h[0]-r, h[1]-r, l[2]+r]) sphere(r);
        translate([h[0]-r, h[1]-r, h[2]-r]) sphere(r);
    }
}

/*
module mechanism_base(){
    difference(){
        union(){
            
            
            box([0,0,0],[mechanism_width+thickness, mechanism_height, thickness]);
            box([mechanism_width,0,0],[mechanism_width+thickness, mechanism_height, 2*thickness+lever_shaft_length]);
            // top cover - temporarily disabled            
            //box([0,0,thickness+lever_shaft_length],[mechanism_width+thickness, mechanism_height, 2*thickness+lever_shaft_length]);
            
            box([mechanism_width-lever_slot_size,0,0],[mechanism_width, thickness+lever_slot_size*0.5, thickness+lever_shaft_length]);
        }
        translate([mechanism_width-lever_slot_size*0.5, thickness+lever_slot_size*0.5, thickness+lever_shaft_length*0.5])rotate(45,v=[0,0,1])cube([lever_slot_size*sqrt(0.5),lever_slot_size*sqrt(0.5), lever_shaft_length], center=true);
        translate([m2_hole_r+1, thickness+0.25*lever_slot_size, 0])#cylinder(thickness+10, r=m2_hole_r);
    }
    
}*/

module crooked_slot(){
    l=lever_shaft_length+2*print_dilation;
    cr=l*slot_crooked_by;
    translate([thickness, 0, thickness+slot_depth]) rotate(a=90, v=[1,0,0])        
            #hull(){
                // ever so slightly crooked
                //rotate(a=5, v=[0,1,0])cylinder(l, r=0.01, center=true);
                translate([cr,0,-l*0.5])sphere(r=0.01);
                translate([-cr,0,l*0.5])sphere(r=0.01);
            
                translate([slot_depth+cr, -slot_depth, -l*0.5])sphere(r=0.01);
                translate([slot_depth-cr, -slot_depth, l*0.5])sphere(r=0.01);
            
                translate([slot_depth+cr, slot_depth, -l*0.5])sphere(r=0.01);
                translate([slot_depth-cr, slot_depth, l*0.5])sphere(r=0.01);
                
                //translate([slot_depth, -slot_depth, 0])cylinder(l, r=0.01, center=true);
                //translate([slot_depth, slot_depth, 0])cylinder(l, r=0.01, center=true);
            }
}
module housing(positive=true, negative=true){
    l=lever_shaft_length+2*print_dilation;
    cr=l*slot_crooked_by;
    difference(){
        if(positive){
            box([0, -l*0.5-thickness, 0], [mechanism_length+thickness, l*0.5+thickness, mechanism_width+thickness]);
        }
            
        
        if(negative)union(){
            hull(){
                box([thickness+slot_depth+cr+10, -l*0.5, thickness], [mechanism_length+thickness+1, l*0.5, thickness+slot_width]);
                crooked_slot();
            }
            box([-1, -l*0.5, thickness+slot_depth*2], [mechanism_length+thickness+1, l*0.5, mechanism_width+thickness+1]);
            // slot           
        
        }
    }
}

/*

module lever(){
    lever_h=lever_r+lever_slot_size*0.5*sqrt(0.5);
    sequential_hull(){
        cylinder(lever_shaft_length-2*print_dilation, r=lever_r);        
        translate([0,lever_r+lever_slot_size*0.5*sqrt(0.5),0])cylinder(lever_shaft_length-2*print_dilation, r=lever_r);        
        translate([-lever_r*2,lever_h+lever_r*2,0])cylinder(lever_shaft_length-2*print_dilation, r=lever_r);
    }
    hull(){
        translate([0,lever_r+lever_slot_size*0.5*sqrt(0.5),0])cylinder(lever_shaft_length-2*print_dilation, r=lever_r);        
        //translate([0,lever_h+lever_shaft_length, print_dilation+0.5*lever_shaft_length])sphere(r=0.1);
    }
}*/

module lever(){
    extra_clearance=0.5;
    l=lever_shaft_length-extra_clearance;
    attach=0.75;
    
    // butt, 5 contact points
    sequential_hull(){
        translate([slot_crooked_by*(lever_shaft_length-lever_r*attach),0,lever_r*attach])sphere(r=lever_r);
        translate([lever_r*1.5,0,0])cylinder(l, r=lever_r);
        translate([slot_crooked_by*(lever_shaft_length-lever_r)/lever_shaft_length, 0, lever_shaft_length-lever_r])sphere(r=lever_r);
    }
    hull(){
        translate([lever_r*1.5,0,0])cylinder(l, r=lever_r);
        translate([lever_r*2+screw_r*2+2,0,0])cylinder(l, r=lever_r);
        translate([lever_r*5+screw_r*2+2,0,0])cylinder(l, r=0.1);
    }
    translate([lever_r*2+screw_r+2, 0, l*0.5])rotate(a=22.5, v=[0,0,1])rotate(a=-90, v=[1,0,0]){
        #cylinder(screw_l, r=screw_hole_r);
    }
}

module lever_clamped(){
    intersection(){// lop off bottom
        box([-100,-100,0],[100,100,100]);
        lever();
    }
}

module lever_visualize(a=22.5){
    translate([thickness+sqrt(2)*lever_r, lever_shaft_length*0.5, thickness+slot_depth])rotate(90, v=[1,0,0])rotate(a, v=[0,0,1]){
    %lever();
}
}
//mechanism_base();

// Prints
housing();
translate([0,10,0])lever();

// Visualization

translate([0,-20,0]){
    %housing(false, true);
}



lever_visualize();

translate([0,-40,0]){
    l=lever_shaft_length+2*print_dilation;
    difference(){
        box([0, -l*0.5+0.01, 0], [mechanism_length+thickness, l*0.5-0.01, mechanism_width+thickness]);
        housing(false, true);
    }
    lever_visualize();
}
