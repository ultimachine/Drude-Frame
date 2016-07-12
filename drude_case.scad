
wall_thick = 1;
total_height = 5;
lens_radius = 2;
lens_size = [74.14,134.58,1.1+0.25]+[0.050,0.050,0];
touch_size = [66.04,116.08,0.7]+[2,2,0.3];
touch_offset = [0,1.05,0]; //positive axis direction
touch_cable_offset = [4.5,0.75,0]; // negative axis direction (cable in crnr furthest from orig)
touch_cable_size = [17,2,0]; // z ignored, equal to bezel size
touch_cable_recess = [17,30,15];
screen_size = [64.191, 116.374, 1.213+0.229]+[0.0,0.0,0];
screen_offset = [0,-3.89,0]; // positive axis direction
screen_bend_size = [42,12,10];
screen_bend_offset = [9,-1,0]; // relative to corner of screen, z from size
screen_cable_width = [10,2,0]; // z ignored
screen_cable_offset = [13.5,0,0]; //relative to upper left edge of bend
screen_cable_recess = [10,70,10];

// back parameters
back_height = 1;
drude_size = [73, 49.81,5];
drude_holes = [[4.5, 4.93], [68.78,4.93],[23.16,45.39],[68.78,45.39]];
drude_riser_height = 3; // relative to zero
drude_riser_radius = 3;

// derived
$fn =100;
z_eps = [0,0,0.1];
bezel_radius = lens_radius+wall_thick/2;
bezel_size = [lens_size[0], lens_size[1], 0]+[wall_thick*2, wall_thick*2, total_height];

back_size = [lens_size[0], lens_size[1], 0]+[wall_thick*2, wall_thick*2,back_height];

drude_offset = [wall_thick,back_size[1]-drude_size[1]-wall_thick-15, 1];

mounting_holes = [[drude_riser_radius,drude_riser_height,0],
                                  [bezel_size[0]-drude_riser_radius,drude_riser_height,0],
                                  [drude_riser_radius,bezel_size[1]-drude_riser_height,0],
                                  [bezel_size[0]/2,bezel_size[1]-drude_riser_height,0],
                                  [bezel_size[0]/2,drude_riser_height,0],
                                  [bezel_size[0]-drude_riser_radius,bezel_size[1]-drude_riser_height,0],
                                  [bezel_size[0]-drude_riser_radius,bezel_size[1]/2,0],
                                  [drude_riser_radius,bezel_size[1]/2,0]];

// cover
cover_radius = bezel_radius;
cover_size = [bezel_size[0],bezel_size[1]-drude_offset[1],12]; // plus radius

module rounded_cube(v,r){
hull(){
            for(i = [0,1]){
                for(j = [0,1]){
                    // shrink by radius
                    k = i == 0 ? 1 : -1; 
                    l = j == 0 ? 1 : -1;
                    translate([v[0]*i+r*k, v[1]*j+r*l,0])
            cylinder(r=r,h=v[2]);
                }
            }
        }
    }

module front(){
difference(){
    union(){
        // bezel
        rounded_cube(bezel_size, bezel_radius);
    }
    //lens
    translate((bezel_size-lens_size)/2+[0,0,(bezel_size[2]-lens_size[2])/2])
        rounded_cube(lens_size+[0,0,0.1], lens_radius);
    //touch sensor
    translate([(bezel_size[0]-touch_size[0])/2,
                      (bezel_size[1]-touch_size[1])/2,
                       bezel_size[2]-lens_size[2]-touch_size[2]]
                     +touch_offset)
        cube(touch_size+z_eps);
    //touch cable hole
    translate(bezel_size-[(bezel_size[0]-lens_size[0])/2,
                                           (bezel_size[1]-lens_size[1])/2,
                                            bezel_size[2]+0.1]-touch_cable_offset)
        rotate([0,0,180]){
            // hole
            cube(touch_cable_size+[0,0,bezel_size[2]]+z_eps*2);
            //recess
            cube(touch_cable_recess);
        }
    //screen
    translate([(bezel_size[0]-screen_size[0])/2,
                      (bezel_size[1]-screen_size[1])/2,
                       bezel_size[2]-lens_size[2]-touch_size[2]-screen_size[2]]
                     +touch_offset+screen_offset){
        //screen
        cube(screen_size+z_eps+[0,0,total_height]);
        // screen bend
        translate(screen_bend_offset-[0,0,screen_bend_size[2]/2]){
             cube(screen_bend_size+z_eps);
            translate([0,screen_bend_size[1],0]
                            +screen_cable_offset){
                cube(screen_cable_recess+z_eps);
                            }
                     }
                 }
    for(mt=mounting_holes)
        translate(mt-z_eps)cylinder(r=1.5, h=2.1);
}
}

module back(){
    difference(){
        union(){
            difference(){
                rounded_cube(back_size, bezel_radius);
                //translate(drude_offset-[0,wall_thick,0])
                //    cube(drude_size+[wall_thick*2,wall_thick*2,0]);
            }
            translate(drude_offset+[wall_thick,0,0])
                for(hole = drude_holes){
                    translate(hole)
                    cylinder(r=drude_riser_radius,h=drude_riser_height);
                }
            for(mt = mounting_holes){
                translate(mt)cylinder(r=drude_riser_radius, h=back_size[2]+drude_riser_height);
            }
        }
        translate(drude_offset+[wall_thick,0,0])
        for(hole = drude_holes){
                    translate(hole)
                    cylinder(r=1.5,h=drude_riser_height+0.1);
                }
        //hack
        translate([37.75,64,-0.1])
            cube(screen_cable_width+[0,22,back_size[2]*2]);
        translate([touch_cable_size[0]+touch_cable_offset[0]+wall_thick,bezel_size[1]-wall_thick-touch_cable_offset[1],-0.1])
        rotate([0,0,180]){
            // hole
            cube(touch_cable_size+[0,0,bezel_size[2]]+z_eps*2);
            //recess
            cube(touch_cable_recess);
        }
        // mounting holes
        for(mt = mounting_holes){
            translate(mt-z_eps)cylinder(r=1.5, h=back_size[2]+drude_riser_height+0.2);
        }
    }
}

module cover_base(){
    difference(){
        union(){
            rounded_cube(cover_size-[0,0,cover_radius],cover_radius);
            hull(){
                translate([0,0,cover_size[2]-cover_radius]){
                translate([cover_radius,cover_radius,0])
                    sphere(r=cover_radius,$fn=20);
                translate([cover_size[0]-cover_radius,cover_radius,0])
                    sphere(r=cover_radius,$fn=20);
                translate([cover_radius,cover_size[1]-cover_radius,0])
                    sphere(r=cover_radius,$fn=20);
                translate([cover_size[0]-cover_radius,cover_size[1]-cover_radius,0])
                    sphere(r=cover_radius,$fn=20);
                }
                cube(cover_size-[0,cover_radius,cover_size[2]-1]);
            }
        }
    }
}

module cover(){
    difference(){
        union(){
            cover_base();
        }
        c = cover_size +[0,0,bezel_radius];
        t = c - [wall_thick, wall_thick,wall_thick/2];
        translate([wall_thick/2,wall_thick/2,-0.1])
            scale([t[0]/c[0],t[1]/c[1],t[2]/c[2]])cover_base();
        translate([14,-0.1,2])
            cube([9,5,6]);
        translate([47+wall_thick/2,-0.1,2])
            cube([16,5,8]);
    }
}

module asm(){
    front();
    translate([bezel_size[0],0,0])rotate([0,180,0])back();
}

//asm();

// Generate different components

//front();
back();
//cover();
