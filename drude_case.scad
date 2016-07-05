
wall_thick = 2;
total_height = 5;
lens_radius = 2;
lens_size = [74.14,134.58,1.1+0.25]+[0.140,0.140,0];
touch_size = [66.04,116.08,0.7]+[2,2,0.3];
touch_offset = [0,1.05,0]; //positive axis direction
touch_cable_offset = [4.5,0.75,0]; // negative axis direction (cable in crnr furthest from orig)
touch_cable_size = [15,2,0]; // z ignored, equal to bezel size
touch_cable_recess = [15,30,1.0]+[0,0,0.1];
screen_size = [64.191, 116.374, 1.213+0.229]+[0.14,0.14,0];
screen_offset = [0,-3.89,0]; // positive axis direction
screen_bend_size = [42,12,1];
screen_bend_offset = [9,-1,0]; // relative to corner of screen, z from size
screen_cable_width = [9,2,0]; // z ignored
screen_cable_offset = [10,0,0]; //relative to upper left edge of bend
screen_cable_recess = [9,80,0.5];

// derived
$fn =100;
z_eps = [0,0,0.1];
bezel_radius = lens_radius+wall_thick/2;
bezel_size = [lens_size[0], lens_size[1], 0]+[wall_thick, wall_thick, total_height];

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
        translate(screen_bend_offset-[0,0,screen_bend_size[2]]){
             cube(screen_bend_size+z_eps);
            translate([0,screen_bend_size[1],
                            -bezel_size[2]+lens_size[2]+touch_size[2]+screen_size[2]+screen_bend_size[2]-0.1]
                            +screen_cable_offset){
                cube(screen_cable_width+[0,0,bezel_size[2]]+z_eps);
                cube(screen_cable_recess+z_eps);
                            }
                     }
                 }
}