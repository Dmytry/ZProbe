$fa=3;
$fs=0.2;

print_dilation=0.15;// when printing the shape gets dilated typically by 0.15mm
print_dilation_max=0.2;// max 0.2

extruder_to_plate_height=40;
screw_plate_thickness=4;
screw_plate_height=12.5;
screw_plate_hole_distance=24;
screw_plate_hole_height=8;

spring_outer_r=7/2;
spring_inner_r=6/2;

wire_r=1.25/2+print_dilation;

screw_hole_r=0.97;
screw_r=1;
screw_l=20;

thickness=1.2;
lever_shaft_length=spring_outer_r*2+0.5;
lever_r=1;
slot_side=lever_r*2;
slot_depth=lever_r*sqrt(2)*2;
slot_width=slot_depth*2;

lever_length=lever_r*4+screw_r*2+3.5;


mechanism_back_clearance=spring_outer_r;

sag=0.5;

mechanism_front_clearance=spring_outer_r+sag+(lever_length*sin(22.5)-slot_width*0.5);

mechanism_width=slot_width+mechanism_back_clearance+mechanism_front_clearance;

slot_crooked_by=0.0;//not sure if i can get this to work at such dimensions, should try 0.1

// [thickness+sqrt(2)*lever_r, lever_shaft_length*0.5, thickness+slot_depth]

slot_axis_pos=[thickness+sqrt(2)*lever_r, lever_shaft_length*0.5, thickness+mechanism_back_clearance+slot_depth];







leaf_spring_thickness=0.4;
leaf_spring_length=30;

mechanism_length=50;

probe_screw_offset=lever_r*2+screw_r+1.5;

probe_screw_pos=[slot_axis_pos[0]+cos(22.5)*probe_screw_offset, 0, slot_axis_pos[2]+sin(22.5)*probe_screw_offset];

probe_screw_contact_x=0;
probe_screw_contact_z=probe_screw_pos[2]+probe_screw_pos[0]-probe_screw_contact_x-screw_r*2*sqrt(2);// 1.5 necessary

plastic_spring=false;
eps=0.001;

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
        translate([screw_hole_r+1, thickness+0.25*lever_slot_size, 0])#cylinder(thickness+10, r=screw_hole_r);
    }
    
}*/

module crooked_slot(){
    l=lever_shaft_length+2*print_dilation;
    cr=l*slot_crooked_by;
    translate([thickness, 0, thickness+slot_depth+mechanism_back_clearance]) rotate(a=90, v=[1,0,0]) {       
            hull(){
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
    hull(){
        #translate([thickness,0,thickness+slot_depth+mechanism_back_clearance])cylinder(slot_depth+0.1, r=screw_r+0.5);
        translate([thickness+slot_depth,0,thickness+slot_depth+mechanism_back_clearance])cylinder(slot_depth+0.1, r=screw_r+0.5);
    }
}
module housing(positive=true, negative=true){
    l=lever_shaft_length+2*print_dilation;
    cr=l*slot_crooked_by;
    difference(){
        if(positive){
            hull(){
                box([0, -l*0.5-thickness, 0], [mechanism_length+thickness, l*0.5+thickness, mechanism_width+thickness]);
                translate([probe_screw_contact_x, 0, probe_screw_contact_z])
                rotate(a=90, v=[1,0,0])cylinder(l+thickness*2, r=screw_r+1, center=true);
            }
            
            box([slot_axis_pos[0]+lever_length, -l*0.5-thickness, mechanism_width+thickness], [mechanism_length+thickness, l*0.5+thickness, mechanism_width+2*thickness]);
            
            
        }
            
        
        if(negative)union(){
            hull(){
                box([thickness+slot_depth+cr, -l*0.5, thickness+mechanism_back_clearance], [mechanism_length+thickness+1, l*0.5, thickness+mechanism_back_clearance+slot_width]);
                
            }  
            crooked_slot();
            box([thickness+slot_depth+cr, -l*0.5, thickness], [mechanism_length+thickness+1, l*0.5, thickness+mechanism_back_clearance]);
            
            box([-10, -l*0.5, thickness+mechanism_back_clearance+slot_width], [mechanism_length+thickness+1, l*0.5, mechanism_width+thickness+0.1]);
            // I'm too tired and lazy to figure out the formula.  
            
            translate([probe_screw_contact_x, 0, probe_screw_contact_z])
            rotate(a=90, v=[1,0,0])#cylinder(20, r=screw_hole_r, center=true);
            
            // a bunch of holes for fixing the spring piece
            
            for(i=[1:4]){
                translate([i*7.5+15, 0, thickness+mechanism_back_clearance+slot_width*0.5])
                rotate(a=90, v=[1,0,0])#cylinder(20, r=screw_hole_r, center=true);
            }
            
            // a cut-out for the wire
            n=10;
            translate([slot_axis_pos[0],0,slot_axis_pos[2]])
            for(k=[0:n-1]){
                alpha_1=-22.5+45*k/n;
                alpha_2=-22.5+45*(k+1)/n;
                hull(){
                    translate([cos(alpha_1)*probe_screw_offset, 0, sin(alpha_1)*probe_screw_offset]) rotate(90,v=[1,0,0]){
                        cylinder(l, r=wire_r*2);
                    }
                    translate([cos(alpha_2)*probe_screw_offset, 0, sin(alpha_2)*probe_screw_offset]) rotate(90,v=[1,0,0]){
                        cylinder(l, r=wire_r*2);
                    }
                }
            }
        
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
    
    wedge_r=0.2;
    
    
    end_of_leaf_spring=lever_r*4+screw_r*2+2+leaf_spring_length;
    difference(){
    
        union(){
            sequential_hull(){// butt, 5 contact points
                translate([0,0,lever_r*attach])sphere(r=lever_r-slot_crooked_by*(lever_shaft_length-lever_r*attach));
                translate([lever_r*1.5,0,0])cylinder(l, r=lever_r);
                translate([0, 0, lever_shaft_length-lever_r])sphere(r=lever_r-slot_crooked_by*(lever_shaft_length-lever_r)/lever_shaft_length);
            }
            
            sequential_hull(){
                translate([lever_r*1.5,0,0])cylinder(l, r=lever_r);
                translate([lever_r*2+screw_r*2+2,0,0])cylinder(l, r=lever_r);
                translate([lever_r*4+screw_r*2+3.5,0,0])cylinder(l, r=wedge_r);
                if(plastic_spring){
                    translate([end_of_leaf_spring,0,0])cylinder(l, r=leaf_spring_thickness*0.5);
                    translate([end_of_leaf_spring+2*(screw_r+print_dilation+1),0,0])cylinder(l, r=screw_r+print_dilation+thickness);
                }
            }
            hull(){
                
                translate([probe_screw_offset, 0, l*0.5])rotate(a=22.5, v=[0,0,1])rotate(a=-90, v=[1,0,0]){
                    cylinder(lever_r*3.3, r=screw_r+1, center=true);
                }
                translate([probe_screw_offset, 0, 0])rotate(a=22.5, v=[0,0,1])rotate(a=-90, v=[1,0,0]){
                    cylinder(lever_r*3.3, r=screw_r+1, center=true);
                }
            }
        }
        
        translate([probe_screw_offset, 0, l*0.5])rotate(a=22.5, v=[0,0,1])rotate(a=-90, v=[1,0,0]){
            #translate([0,0,-2])cylinder(screw_l, r=screw_hole_r);
        }
        translate([probe_screw_offset, 0, l*0.5])cylinder(screw_l, r=wire_r);
        
        if(plastic_spring)translate([end_of_leaf_spring+2*(screw_r+print_dilation+1),0,0])cylinder(l, r=screw_r+print_dilation);
    }
}


module lever_clamped(){
    intersection(){// lop off bottom
        box([-100,-100,0],[100,100,100]);
        lever();
    }
}

module lever_visualize(a=22.5){
        translate(slot_axis_pos)rotate(90, v=[1,0,0])rotate(a, v=[0,0,1]){
        lever_clamped();
    }
}

module spring_endpiece(){
    difference(){
        cylinder_sequence([
            [0, spring_inner_r],
            [spring_inner_r*1, spring_inner_r],
            [spring_inner_r*1+(spring_outer_r-spring_inner_r), spring_outer_r],
            [spring_inner_r*2.3, spring_outer_r]
        ]);
        translate([0,0,spring_inner_r*2.7])rotate(45, v=[1,0,0])#cube([spring_outer_r*2,spring_outer_r*sqrt(2),spring_outer_r*sqrt(2)], center=true);
    }
}

module spring_backing_piece(){
    l=lever_shaft_length;
    r=0.2;
    wedge_scale=1.5;
    piece_length=20;
    hull(){
        cylinder(l,r=r);
        translate([spring_outer_r*wedge_scale, -spring_outer_r*0.25*wedge_scale,0])cylinder(l,r=r);
        translate([spring_outer_r*wedge_scale, spring_outer_r*0.25*wedge_scale,0])cylinder(l,r=r);
    }
    translate([spring_outer_r*wedge_scale,0,0])
    difference(){
        {
            box([0,/* -mechanism_back_clearance-slot_width*0.5+print_dilation */ -screw_r-thickness, 0], [piece_length, /* mechanism_front_clearance+slot_width*0.5-print_dilation-sag */screw_r+thickness, l]);
        }
        hull(){
            translate([screw_r+thickness,0,0])cylinder(l, r=screw_r+print_dilation);
            translate([piece_length-screw_r-thickness,0,0])cylinder(l, r=screw_r+print_dilation);
        }
    }
}

//mechanism_base();

// Prints
housing();
translate([0,10,0])lever_clamped();
translate([15,10,0])spring_endpiece();
translate([15+2*spring_outer_r+1,10,0])spring_endpiece();

translate([28,10,0])spring_backing_piece();

// Visualization

translate([0,-20,0]){
    //%housing(false, true);
}



%lever_visualize();

% translate([0,-40,0]){
    l=lever_shaft_length+2*print_dilation;
    difference(){
        box([0, -l*0.5+0.01, 0], [mechanism_length+thickness, l*0.5-0.01, mechanism_width+thickness]);
        housing(false, true);
    }
    lever_visualize();
}
