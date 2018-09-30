// TODO:
// A gear on the top with matching rack generation
// flats for screws that hold the switch
// better magnet housing
// magnet stick out more
// try to retain magnets with a tight press fit within a star cutout or a polygon to permit slight expansion
// retain wires at the static piece

use <third_party/publicDomainGearV1.1.scad>

$fa=3;
$fs=0.2;

// cheap and simple z-probe
// dimensions:
extruder_to_plate_height=40;

print_dilation=0.15;// when printing the shape gets dilated typically by 0.15mm
print_dilation_max=0.2;// max 0.2
print_single_wall=0.5;
eps=1E-3;// epsilon to use so preview is correct

gap=1+2*print_dilation_max;

shaft_r0=16.0/2;
shaft_r1=shaft_r0-1.5*gap;
echo(shaft_r1-thickness);
shaft_r2=35.0/2;
hinge_attachment_h=6.5;
plate_width=40.5;
screw_plate_thickness=4;
screw_plate_height=12.5;
screw_plate_hole_distance=24;
hole_height=8;
screw_radius=3/2+print_dilation_max;
screw_head_radius=6/2+print_dilation_max;
screw_head_height=4+print_dilation_max;

hinge_plate_thickness=4;

base_depth=25;


thickness=1.5;

switch_width=5.8;
switch_length=12.85;
switch_height=6.5;

switch_wire_0=-5.1;
switch_wire_1=0;
switch_wire_2=5.1;
// the switch has two holes in it
switch_hole_r=1;
switch_hole_offset=3.1;
switch_hole_h=1.5;

probe_base_x=6+2*thickness;
probe_base_y=13+2*thickness;

motor_clearance=4;

large=100;

wire_r=1+print_dilation;

magnet_h=2.8; // undilated, sometimes may want 1 dilation or 2 dilations
magnet_r=8/2+print_dilation;
magnet_pocket_snap_depth=2.0-print_dilation;

small_magnet_h=1.0; // undilated, sometimes may want 1 dilation or 2 dilations
small_magnet_r=5/2+print_dilation;

magnet_sticks_out_by=0.5;

gear_thickness=12;
gear_clearance=2*print_dilation;
// 2x larger than lego
mm_per_tooth=PI*2;
gear_pressure_angle=28;



desired_gear_inner_radius=shaft_r2+gap+thickness+magnet_h+2*print_single_wall;

/*	assign(p  = mm_per_tooth * number_of_teeth / pi / 2)  //radius of pitch circle
	assign(c  = p + mm_per_tooth / pi - clearance)        //radius of outer circle
	assign(b  = p*cos(pressure_angle))                    //radius of base circle
	assign(r  = p-(c-p)-clearance)                        //radius of root circle
*/
// assign(r  = mm_per_tooth * (number_of_teeth - 2) / pi / 2 - clearance //radius of root circle, might be one clearance short
// number of teeth does not have to be integer because we are not making a whole gear
number_of_teeth=2 + (desired_gear_inner_radius)*PI*2/mm_per_tooth;

gear_outer_radius = outer_radius(mm_per_tooth, number_of_teeth, gear_clearance);
gear_radius = mm_per_tooth*number_of_teeth / (2*PI);
//gear_inner_radius = mm_per_tooth * (number_of_teeth - 2) / PI / 2 - 2*gear_clearance;


rotate_static_by=45;//$t*90;//90;

function span_in_circle(span_l, circle_r)=sqrt(circle_r*circle_r - 0.25*span_l*span_l);

module sequentialHull(){
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

module shaft(enlarge=0, extra_height=0){
    enlarge_eps=eps*min(abs(enlarge),1.0); //max(-eps, min(eps, enlarge));
    h=plate_width-hinge_attachment_h-abs(shaft_r2-shaft_r1);
    cylinder_sequence([
        [-enlarge_eps, shaft_r0+enlarge],
        [abs(shaft_r1-shaft_r0), shaft_r1+enlarge],
        [h,shaft_r1+enlarge],
        [plate_width-hinge_attachment_h, shaft_r2+enlarge],
        [plate_width+extra_height+gear_thickness, shaft_r2+enlarge]
    ]);
}

module box(low, high){
    translate(low){
        cube(high-low);
    }
}

module place_screws(){
    translate([shaft_r2-screw_plate_thickness-eps, -screw_plate_height-shaft_r2+hole_height, (plate_width-screw_plate_hole_distance)*0.5]){
        rotate(a=90, v=[0,1,0]){
            children();
        }
    }
    translate([shaft_r2-screw_plate_thickness-eps, -screw_plate_height-shaft_r2+hole_height, (plate_width+screw_plate_hole_distance)*0.5]){
        rotate(a=90, v=[0,1,0]){
            children();
        }
    }
}

module static_part_outer(enlarge=0, extra_height=0){// without any holes, used for carving against other pieces
    shaft(enlarge, extra_height);
    extra_gap=2;
    translate([shaft_r2-screw_plate_thickness,-screw_plate_height-shaft_r2+extra_gap]){
        cube(size=[screw_plate_thickness, screw_plate_height+shaft_r2-extra_gap, plate_width]);
    }
    
    translate([shaft_r2-screw_plate_thickness, -4]){
        cube(size=[screw_plate_thickness+motor_clearance-gap, 4, plate_width]);
    }
}

module magnet_pocket(){// the pocket is placed along y axis
    rotate(a=90, v=[1,0,0]) cylinder(h=magnet_h+2*print_dilation_max, r=magnet_r);
    translate([0,0,magnet_pocket_snap_depth*2])
    hull(){
        rotate(a=90, v=[1,0,0]) cylinder(h=magnet_h+2*print_dilation_max, r=magnet_r);
        translate([0,0,large])rotate(a=90, v=[1,0,0]) cylinder(h=magnet_h+2*print_dilation_max, r=magnet_r);
    }
}

magnet_pocket_depth=plate_width-hinge_attachment_h+magnet_r;

// uncomment to view pieces separately
//translate([50,0,0])
module hold_up_magnet_holes(){
    for(i=[0 : 3]){
        translate([shaft_r2-screw_plate_thickness + 0.5*(screw_plate_thickness+motor_clearance-gap), 0, thickness+1.2*small_magnet_r+i*(2*1.2*small_magnet_r+0.7*thickness)]){
            rotate(a=90, v=[1,0,0]) #cylinder(small_magnet_h+eps, r2=small_magnet_r, r1=1.2*small_magnet_r);
        }
    }
}


rotate(a=rotate_static_by, v=[0,0,1]) {
    difference(){
        union(){
            difference(){
                static_part_outer();
                shaft(-thickness);
                place_screws(){
                    cylinder(screw_plate_thickness+2*eps, r=screw_radius);
                }
            }
            intersection(){
                shaft();
                box([-large, -large, 0], [-span_in_circle(magnet_r*2, shaft_r2-print_single_wall)+magnet_h+thickness, large,  plate_width+gear_thickness]);
            }
        }
        
        /*
        hull(){
            translate([-span_in_circle(magnet_r*2, shaft_r2-print_single_wall), 0, plate_width+magnet_r-hinge_attachment_h])
            rotate(a=90, v=[0,1,0])cylinder(h=magnet_h+2*print_dilation_max, r=magnet_r);
            translate([-span_in_circle(magnet_r*2, shaft_r2-print_single_wall), 0, plate_width+gear_thickness-magnet_pocket_snap_depth])rotate(a=90, v=[0,1,0]) cylinder(h=magnet_h+2*print_dilation_max, r=magnet_r);
        }*/
        translate([-span_in_circle((magnet_r-print_dilation_max)*2, shaft_r2-print_single_wall), 0, magnet_pocket_depth])rotate(a=90,v=[0,0,1])magnet_pocket();
        
        hold_up_magnet_holes();
    }
}

module teardrop(r){// sphere with a hat, purpose: avoid overhangs
    union(){
        sphere(r);
        translate([0,0,r*sqrt(0.5)])cylinder(r*sqrt(0.5), r1=r*sqrt(0.5), r2=0);
    }
}

module wire_conduit(){
    #sequentialHull(){
            teardrop(wire_r);
            translate([0,10,0])teardrop(wire_r);
            //translate([-0.5*base_depth - screw_plate_thickness - hinge_plate_thickness  + 0.5*hinge_plate_thickness, 10+0.5*plate_width, 0])teardrop(wire_r);
            /* translate([-0.5*base_depth - screw_plate_thickness - hinge_plate_thickness  - wire_r, 10+0.5*plate_width+0.5*hinge_plate_thickness+wire_r ,0])teardrop(wire_r); */
            translate([-0.5*base_depth - screw_plate_thickness - hinge_plate_thickness + 0.5*hinge_plate_thickness-large, 10+0.5*plate_width+large, 0])teardrop(wire_r);    
        
        }
}

module switch_holes(){

}

extra_angle=30;
teeth_to_hide=number_of_teeth*3/4-extra_angle*number_of_teeth/180 - 0.5;
actual_tooth_count=floor(number_of_teeth-teeth_to_hide);

difference(){
    cr=shaft_r2-gap-screw_plate_thickness;
    union(){
        cylinder(plate_width, r=cr);
      
        
        bevel_gear_by=gear_outer_radius-(shaft_r2+gap+thickness);
        intersection(){
            translate([0,0,plate_width+gear_thickness*0.5-bevel_gear_by*0.5]) rotate(a=90-extra_angle, v=[0,0,1]){
                gear(mm_per_tooth, number_of_teeth, gear_thickness+bevel_gear_by, teeth_to_hide=teeth_to_hide, clearance=gear_clearance, backlash         =2*print_dilation, pressure_angle=gear_pressure_angle);
            }
            
            translate([0,0,plate_width-bevel_gear_by])cylinder(gear_thickness+bevel_gear_by+eps, r1=shaft_r2+gap+thickness, r2=shaft_r2+gap+thickness+gear_thickness+bevel_gear_by+eps);

        }
        
        
        box([cr-hinge_plate_thickness, -screw_plate_height-shaft_r2-eps - magnet_sticks_out_by, 0], [cr, 0, plate_width]);
        translate([cr, -screw_plate_height-shaft_r2, 0]){
            difference(){
                hull(){
                    // getting kind of ugly, have to replicate a piece of big cylinder
                    translate([-cr, screw_plate_height+shaft_r2, 0]){
                        intersection(){
                            cylinder(plate_width, r=shaft_r2+gap+thickness);
                            box([-large, -large, -large],[0,0,large]);
                        }
                        
                    }                    
                    box(//part that holds magnets
                    [-hinge_plate_thickness, -hinge_plate_thickness, 0],
                    [base_depth + screw_plate_thickness, -magnet_sticks_out_by, plate_width]
                    );
                    box(// part where switch goes
                    [0.5*(base_depth-switch_width) + screw_plate_thickness - thickness, -extruder_to_plate_height, 0],
                    [0.5*(base_depth+switch_width) + screw_plate_thickness + thickness, -extruder_to_plate_height+1, 0.5*(plate_width+switch_length)]);
                }
                
                box(//cut off unwanted part of the hull
                    [-hinge_plate_thickness, -magnet_sticks_out_by, -eps],
                    [base_depth + screw_plate_thickness, large, plate_width+eps]
                    );
                // cut a hole for the switch
                box(
                    [0.5*(base_depth-switch_width) + screw_plate_thickness - print_dilation, -40-eps, -eps],
                    [0.5*(base_depth+switch_width) + screw_plate_thickness + print_dilation, -40+eps+switch_height+print_dilation, 0.5*(plate_width+switch_length)+10]);
                
                // magnets
                /*
                translate([base_depth + screw_plate_thickness - magnet_r - thickness, eps, thickness+magnet_r]){
                    rotate(a=90, v=[1,0,0]) #cylinder(magnet_h, r=magnet_r);
                }
                translate([base_depth + screw_plate_thickness - magnet_r - thickness, eps, plate_width-thickness-magnet_r]){
                    rotate(a=90, v=[1,0,0]) #cylinder(magnet_h, r=magnet_r);
                }
                
                translate([screw_plate_thickness + magnet_r + thickness, eps, plate_width*0.5]){
                    rotate(a=90, v=[1,0,0]) #cylinder(magnet_h, r=magnet_r);
                }*/
                translate([base_depth + screw_plate_thickness - magnet_r - thickness, eps, thickness+magnet_r]){
                    rotate(a=90, v=[1,0,0]) #cylinder(small_magnet_h, r2=small_magnet_r, r1=1.5*small_magnet_r);
                }
                translate([base_depth + screw_plate_thickness - magnet_r - thickness, eps, plate_width-thickness-magnet_r]){
                    rotate(a=90, v=[1,0,0]) #cylinder(small_magnet_h, r2=small_magnet_r, r1=1.5*small_magnet_r);
                }                
                translate([screw_plate_thickness + magnet_r + thickness, eps, plate_width*0.5]){
                    rotate(a=90, v=[1,0,0]) #cylinder(small_magnet_h, r2=small_magnet_r, r1=1.5*small_magnet_r);
                }             
                
                
            }
        }

        
        difference(){
            cylinder(plate_width, r=shaft_r2+gap+thickness);
            translate([-eps, -eps, -eps]) cube(size=[2*shaft_r2, 2*shaft_r2, plate_width+eps*2]);
            box([shaft_r2-eps-screw_plate_thickness-gap, -large, -eps], [shaft_r2+large, large, large]);
            // motor:
            box([-large, shaft_r2+motor_clearance-gap, -eps], [large, large, large]);
        }
    }
    /* minkowski(){
        static_part_outer();
        sphere(r=gap);
    } */
    static_part_outer(enlarge=gap, extra_height=gear_thickness);
    
    place_screws(){
            translate([0,0,-gap-hinge_plate_thickness-eps])#cylinder(screw_head_height+eps*3, r=screw_head_radius+gap);
        }
    
    translate([0.5*base_depth + screw_plate_thickness + hinge_plate_thickness + print_dilation + cr-hinge_plate_thickness, -40+eps+switch_height+print_dilation-screw_plate_height-shaft_r2, 0.5*plate_width]){
        // wires for the switch
        translate([0,0,switch_wire_0])wire_conduit();
        translate([0,0,switch_wire_1])wire_conduit();
        translate([0,0,switch_wire_2])wire_conduit();
        // holes for screwing the switch in
        sequence=[
            [-large, switch_hole_r*2], 
            [-switch_width*0.5-thickness-print_dilation, switch_hole_r*2], 
            [-switch_width*0.5-thickness-print_dilation, switch_hole_r], 
            [0, switch_hole_r],
            [switch_width*0.5+thickness+print_dilation, switch_hole_r], 
            [switch_width*0.5+thickness+print_dilation, switch_hole_r*2], 
            [large, switch_hole_r*2]
        ];
        
        translate([0, -switch_hole_h, -switch_hole_offset]) rotate(a=90, v=[0,1,0]) {
            //#cylinder(large, r=switch_hole_r+print_dilation, center=true);
            cylinder_sequence(sequence);
        }
        translate([0, -switch_hole_h, switch_hole_offset]) rotate(a=90, v=[0,1,0]){
            //#cylinder(large, r=switch_hole_r+print_dilation, center=true);
            cylinder_sequence(sequence);
        }
    }
    // pocket for the magnet
    translate([0,-shaft_r2-gap-print_single_wall, plate_width-hinge_attachment_h+magnet_r]){
       magnet_pocket();
    }
    
    rotate(a=90, v=[0,0,1]){
        mirror(v=[0,1,0])hold_up_magnet_holes();
    }

    //translate([-eps, -eps, -eps]) cube(size=[2*shaft_r2, 2*shaft_r2, plate_width+eps*2]);
}


rack_thickness=gear_thickness*0.5; 

rack_width=mm_per_tooth*2;


rail_grab_thickness=4;
rail_grab_width=20;

module bolt_hole(bolt_r, head_r, depth=large){// vertical, downwards by default
    sequence=[
    [-depth, bolt_r],
    [0,bolt_r],
    [0, head_r],    
    [30, head_r]
    ];
    cylinder_sequence(sequence);
}

module rack_and_support_old(){

    translate([-actual_tooth_count*0.5*mm_per_tooth, shaft_r2+20]){
        extruder_to_shaft_axis_height=screw_plate_height+shaft_r2+extruder_to_plate_height;
        base_to_shaft_axis_height=extruder_to_shaft_axis_height+50;
        h_offset=gear_radius+shaft_r2+0.5*base_depth;
        
        vslot_size=20+print_dilation_max;

        a = mm_per_tooth / PI;

        box([base_to_shaft_axis_height-gear_radius, 0, 0], [base_to_shaft_axis_height, rack_width - 2*a, rack_thickness]);
        difference(){
            //box([-vslot_size,0,0], [rack_width, gear_radius+shaft_r2+0.5*base_depth + vslot_size, rack_thickness]);
            hull(){
                box([base_to_shaft_axis_height-gear_radius-rack_width, 0, 0], [base_to_shaft_axis_height-gear_radius, rack_width - 2*a, rack_thickness]);
                box([-vslot_size, h_offset-vslot_size*0.5 -rail_grab_thickness, -eps], 
                [rail_grab_thickness, h_offset+vslot_size*0.5+rail_grab_thickness, rail_grab_width+eps]            
                );
            }
            box([-vslot_size, h_offset-vslot_size*0.5, -eps],
            [0, h_offset+vslot_size*0.5, rail_grab_width+eps]);
            translate([ 8, h_offset, 0.5*rail_grab_width])rotate(a=90, v=[0,1,0]){
                bolt_hole(2, 4.5);
            }
        }
        
        
        translate([base_to_shaft_axis_height, rack_width-a, rack_thickness*0.5]){
            rack(mm_per_tooth=mm_per_tooth, number_of_teeth=actual_tooth_count, thickness=rack_thickness, height=rack_width /* mm_per_tooth*2 */, clearance=gear_clearance, backlash=2*print_dilation, pressure_angle=gear_pressure_angle);
        }
    }
}

module rack_and_support_v2(x, y){// tooth profile middle line relatively to top of the centre of the v-slot beam
    // right is x
    // up is y    
    addendum = mm_per_tooth / PI;
    vslot_size=20+print_dilation_max;
    
    translate([x, y, rack_thickness*0.5]) rotate(a=90, v=[0,0,1]){
       %cylinder(100,r=1);
       rack(mm_per_tooth=mm_per_tooth, number_of_teeth=actual_tooth_count, thickness=rack_thickness, height=rack_width+2*addendum, clearance=gear_clearance, backlash=2*print_dilation, pressure_angle=gear_pressure_angle);
    }
    
    rack_stem_min_x=x+addendum;
    rack_stem_max_x=rack_stem_min_x+rack_width;

    box([rack_stem_min_x, y-gear_radius, 0], [rack_stem_max_x, y, rack_thickness]);
    difference(){
        hull(){
            box([rack_stem_min_x, y-gear_radius-rack_width, 0],[rack_stem_max_x, y-gear_radius, rack_thickness]);
            box([-0.5*vslot_size-rail_grab_thickness, -vslot_size, 0], [0.5*vslot_size+rail_grab_thickness, rail_grab_thickness, rail_grab_width]);
        }
        
        #
        box([-0.5*vslot_size, -vslot_size, -eps],
            [0.5*vslot_size, 0, rail_grab_width+eps]);
            translate([0, 8, 0.5*rail_grab_width])rotate(a=-90, v=[1,0,0]){
                #bolt_hole(2, 4.5);
            }
    }
        
    vslot_size=20+print_dilation_max;
}

module rack_and_support(){
    extruder_to_shaft_axis_height=screw_plate_height+shaft_r2+extruder_to_plate_height;
    base_to_shaft_axis_height=extruder_to_shaft_axis_height+50;
    h_offset=gear_radius+shaft_r2+0.5*base_depth-5;
    mirror(v=[1,0,0])
    translate([90, -15, 0]) rotate(a=90, v=[0,0,1])rack_and_support_v2(h_offset,base_to_shaft_axis_height);
}

mirror(v=[1,0,0])
%translate([55.5,79,0])rotate(a=180, v=[0,0,1])rack_and_support_old();
rack_and_support();


