/* 
Info: 
Allows the mounting of magnets (3mm) for the hal-sensor in the idler. Use the extra belt_mounts with zip-ties to fix the open ends of the gt2-belt directly to the carriage. 

Improvement: 
- direct mounting of open belt-ends with zip-ties (with belt_mount_for_carriage.scad) 
- groves secure belt-mount 
- move belt-mount to defined distance from middle (reduce error) --> belt_mount_offset
- allow two lm8uu per rod (extra stability) --> carriage_extra_height
- zip-tie hold the "new" lm8uu

TODO: 
- 
*/

carriage_height       = 24;
carriage_extra_height = 25; // >=24 and zip-tie-tunnels get added
carriage_hinge_offset = 22.5;
belt_mount_offset     = 8; // "outer" side as reference

width  = 76;
heightL = carriage_height;
heightH = carriage_height + carriage_extra_height;


offset = 25;
cutout = 13;
middle = 2*offset - width/2;

$fn=48;

module parallel_joints(reinforced) 
{
    difference() 
    {
        union() 
        {
            intersection() 
            {
                cube([width, 20, 8], center=true);
                rotate([0, 90, 0]) cylinder(r=5, h=width-30, center=true);
            }
            intersection() 
            {
                re = reinforced;
                translate([0,18,4]) rotate([45,0,0]) cube([width,re,re], center=true);
                translate([0,0,20]) cube([width-25,35,40], center=true);
            }
            translate([0, 8, 0]) cube([width-25, 16, 8], center=true);
        }

        rotate([0, 90, 0]) cylinder(r=1.55, h=80, center=true);

        for (x = [-offset, offset]) 
        {
            translate([x, +5.5, 0]) cylinder(r=cutout/2, h=100, center=true);
            translate([x, -4.5, 0]) cube([cutout, 20, 100], center=true);
        }
        
        translate([0, 2, 0]) cylinder(r=middle, h=100, center=true);
        translate([0,-8, 0]) cube([2*middle, 20, 100], center=true);

        rotate([0,90,0]) cylinder(r=3.3, h=29, center=true,$fn=6);
    }
  
    //added features for Traxxas U-joints
    difference()
    {
        union()
        {
            translate([+18,-0.1,0]) sphere(5);
            translate([-18,-0.1,0]) sphere(5);
        }
        
        translate([-25,-5,4]) cube([50,10,3]);
        translate([-25,-5,-7]) cube([50,10,3]);
        rotate([0, 90, 0]) cylinder(r=1.55, h=80, center=true); // screw-hole
    }
}

module lm8uu_mount(d, h) 
{
    difference() 
    {
        intersection() 
        {
            cylinder(r=11, h=h, center=true);
            translate([0, -8, 0]) cube([19, 13, h+1], center=true);
        }
        
        cylinder(d=d, h=h+1, center=true);
    }
}

module belt_mount() 
{
    difference() 
    {
        translate([0, 5, 0]) cube([4, 19, heightL], center=true);
        // belt-grooves  
        for (x = [-2,2]) for (z = [-10:2:+10])
            translate([x,6,z]) rotate([90,0,0]) cylinder(d=1.0, h=10, center=true);
        // mounting-holes for zip-ties
        for (y = [1,11]) for (z = [-8,+8]) 
            translate([0,y,z]) rotate([0,90,0]) cylinder(d=3.3, h= 6, center=true);
    }
}

module carriage() 
{
    hExt = carriage_extra_height;
    for (x = [-30, 30])
        translate([x, 0, 0]) lm8uu_mount(d=15.2, h=heightH);
    translate([belt_mount_offset-2, 0, -hExt/2]) belt_mount();
    difference() 
    {
        union() 
        {
            translate([0, -5.6, 0]) cube([50, 5, heightH], center=true);
            translate([0, -carriage_hinge_offset, -heightH/2+4]) parallel_joints(16);
        }
        
        // Pocket for Magnet --> top endstop sensor.
        translate([-15, -16, -heightH/2+6])  cylinder(d=3.3, h=15, center=true);
        // cutout on top of middle-structure
        translate([0,0,3+heightH/2]) scale([43,1,2*hExt]) rotate([90,0,0]) cylinder(d=1,h=30, center=true);
        
        for (x = [-30, 30]) 
        {
            // cutout for lm8uu_mount;
            translate([x, 0, 0]) cylinder(r=9, h=heightH+1, center=true);
            // Zip tie tunnels.
            for (z = [-8, +8])
                translate([x, 0, -hExt/2 + z]) cylinder(r=13, h=3.5, center=true);
            if (hExt >= 24) for (z = [-8, +8])
                translate([x, 0, +hExt/2 + z]) cylinder(r=13, h=3.5, center=true);
        }
    }
}
carriage();

// look in debug_drive_with_carriage to check endstop alignment
