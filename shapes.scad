include <system.scad>
include <units.scad>
use <misc.scad>
use <transforms.scad>

module cubea(size=[10,10,10], align=[0,0,0], extrasize=[0,0,0], extrasize_align=[0,0,0], orient=[0,0,1], roll=0)
{
    size_align(size=size,extra_size=extrasize, align=align, extra_align=extrasize_align, orient=orient, orient_ref=[0,0,1], roll=roll)
    {
        cube(size+extrasize, center=true);
    }
}

module rcubea(size=[10,10,10], rounding_radius=1, align=[0,0,0], extrasize=[0,0,0], extrasize_align=[0,0,0], orient=[0,0,1], roll=0)
{
    size_align(size=size,extra_size=extrasize, align=align, extra_align=extrasize_align, orient=orient, orient_ref=[0,0,1], roll=roll)
    {
        rcube(size=size+extrasize, rounding_radius=rounding_radius);
    }
}

module rcube(size=[20,20,20], rounding_radius=1)
{
    hull()
    for(x=[-(size[0]/2-rounding_radius),(size[0]/2-rounding_radius)])
    for(y=[-(size[1]/2-rounding_radius),(size[1]/2-rounding_radius)])
    for(z=[-(size[2]/2-rounding_radius),(size[2]/2-rounding_radius)])
    translate([x,y,z])
    sphere(r=rounding_radius);
}


module cylindera(
        h=10,
        r=undef,
        r1=undef,
        r2=undef,
        d=undef,
        d1=undef,
        d2=undef,
        align=[0,0,0],
        orient=[0,0,1],
        extra_h=0,
        extra_r=undef,
        extra_d=undef,
        extra_align=[0,0,0],
        round_radius=undef,
        debug=false
        )
{
    pi=3.1415926536;

    useDia = r == undef && (r1 == undef && r2 == undef);

    r1_ = useDia?((d1==undef?undef:d1)/2):r1;
    r2_ = useDia?((d2==undef?undef:d2)/2):r2;
    r_= useDia?d/2:(r==undef?0:r);
    r1r2max = max(r1,r2) == undef ? max(d1,d2)/2 : max(r1,r2);
    r__ = r_==undef? r1r2max : r_;
    extra_r_ = useDia?((extra_d==undef?0:extra_d)/2):((extra_r==undef)?0:extra_r);

    sizexy=r__*2;
    extra_sizexy=extra_r_*2;

    if(debug)
    {
        echo(useDia, h, r_, r1_, r2_, extra_r_, align);
    }

    // some orient hax here to properly support extra_align
    size_align(size=[sizexy,sizexy,h], extra_size=[extra_sizexy, extra_sizexy, extra_h], orient=orient, orient_ref=[0,0,1], align=align, extra_align=extra_align)
    {
        if(round_radius==undef)
        {
            cylinder(h=h+extra_h, r=r_+extra_r_, r1=r1_, r2=r2_, center=true);
        }
        else
        {
            rcylinder(h=h+extra_h, r=r_+extra_r_, r1=r1_, r2=r2_, round_radius=round_radius);
        }
    }
}

/*translate([10,0,0])*/
/*rotate_extrude()*/
        /*translate([10-2,2,0])*/
/*$fa = 5.6;*/
/*$fs = 0.3;*/
/*circle(r = 100);*/
/*torus(10, 2, align=[0,0,0], orient=[0,0,1]);*/

module torus(radius, radial_width, align=[0,0,0], orient=[0,0,1])
{
    size_align(size=[radius*2+radial_width*2, radius*2+radial_width*2, radial_width*2], align=align, orient=orient)
    rotate_extrude()
    translate([radius, 0, 0])
    circle(radial_width);
}

module rcylinder(d=undef, r1=undef, r2=undef, h=10, round_radius=2, align=[0,0,0], orient=[0,0,1])
{
    useDia = r == undef && (r1 == undef && r2 == undef);

    r1_ = useDia?((d1==undef?undef:d1)/2):r1;
    r2_ = useDia?((d2==undef?undef:d2)/2):r2;
    r_= useDia?[d/2,d/2]:(r==undef?[r1_,r2_]:[r,r]);
    size_align(align=align, orient=orient)
    /*translate([0,0,-h/2])*/
    hull()
    {
        /*a = r_[0]-r_[1];*/
        /*b = h;*/
        /*c = pythag_hyp(a,b);*/
        /*echo(c);*/
        /*d = c;//pythag_leg(a,c);*/
        /*echo(d);*/
        /*translate([0,r1-round_radius,0])*/
        /*cube([d,d,d]);*/
        /*angle2 = -atan2(-h, r1-r2);*/
        /*echo(angle2);*/
        /*x2 = r2-r1 < 0 ? (round_radius*2*cos(angle2)) : (round_radius*2*sin(angle2));*/
        /*echo(x2)*/
        /*translate([0, 0, h/2-round_radius])*/
        /*torus(radius=r_[1]-round_radius, radial_width=round_radius, align=[0,0,0]);*/

        for(z=[-1,1])
        translate([0, 0, z*(-h/2)])
        {
            /*rd = abs(r1-r2);*/
            /*angle1 = atan2(h, abs(r2-r1));*/
            /*x1 = round_radius*2*cos(angle1);*/
            /*echo(angle1, x1);*/
            r__=z!=-1?r_[0]:r_[1];
            torus(radius=r__-round_radius/2, radial_width=round_radius/2, align=[0,0,z]);

            /*translate([0, 0, -round_radius])*/
            /*cubea([r__*2,r__*2,5], align=[0,0,-z]);*/
        }
    }
}

// positive angles go from start to end counterclockwise
// negative angles are allowed
module pie_slice_shape(r, start_angle, end_angle) {
    R = r * sqrt(2) + 1;
    a0 = (4 * start_angle + 0 * end_angle) / 4;
    a1 = (3 * start_angle + 1 * end_angle) / 4;
    a2 = (2 * start_angle + 2 * end_angle) / 4;
    a3 = (1 * start_angle + 3 * end_angle) / 4;
    a4 = (0 * start_angle + 4 * end_angle) / 4;
    intersection() {
        circle(r);
        polygon([
                [0,0],
                [R * cos(a0), R * sin(a0)],
                [R * cos(a1), R * sin(a1)],
                [R * cos(a2), R * sin(a2)],
                [R * cos(a3), R * sin(a3)],
                [R * cos(a4), R * sin(a4)],
                [0,0]
        ]);
    }
}

// positive angles go from start to end counterclockwise
// negative angles are allowed
module pie_slice(r, start_angle, end_angle, h, orient=[0,0,1], align=[0,0,0])
{
    size_align(size=[r*2, r*2, h], orient=orient, orient_ref=[0,0,1], align=align)
    linear_extrude(h)
    {
        pie_slice_shape(r, start_angle, end_angle);
    }
}

module hollow_cylinder(d=10, thickness=1, h=10, taper=false, taper_h=undef, orient=[0,0,1], align=[0,0,0])
{
    outer_d = d+thickness/2;
    inner_d = d-thickness/2;
    size_align(size=[outer_d, outer_d, h], orient=orient, align=align)
    difference()
    {
        /*hull()*/
        union()
        {
            cylindera(h=h-taper_h*2, d=outer_d, orient=[0,0,1], align=[0,0,0]);
            taper_h = taper_h == undef ? (outer_d-inner_d)/4 : taper_h;
            /*taper_h_ = pythag_leg(taper_h, outer_d-inner_d);*/
            /*echo(taper_h_);*/
            if(taper)
            {
                for(z=[-1,1])
                translate([0,0,z*(h/2-taper_h)])
                mirror([0,0,z==-1?1:0])
                difference()
                {
                    cylindera(d1=outer_d, d2=outer_d-inner_d/4, h=taper_h*2, align=[0,0,1]);
                    cylindera(d1=inner_d, d2=outer_d, h=taper_h*2+.1, align=[0,0,1]);
                }
            }
        }

        cylindera(h=h+.4, d=inner_d, orient=[0,0,1], align=[0,0,0]);
    }
}


/**
 * Standard right-angled triangle
 *
 * @param number o_len Lenght of the opposite side
 * @param number a_len Lenght of the adjacent side
 * @param number depth How wide/deep the triangle is in the 3rd dimension
 * @todo a better way ?
 */
module triangle(o_len, a_len, depth, align=[0,0,0], orient=[0,0,1])
{
    size_align(size=[a_len, depth, o_len], align=align, orient=orient)
    rotate([90,0,0])
    translate([-a_len/2, -o_len/2, -depth/2])
    linear_extrude(height=depth)
    {
        polygon(points=[[0,0],[a_len,0],[0,o_len]], paths=[[0,1,2]]);
    }
}

/**
 * Rounded Standard right-angled triangle
 *
 * @param number o_len Lenght of the opposite side
 * @param number a_len Lenght of the adjacent side
 * @param number depth How wide/deep the triangle is in the 3rd dimension
 * @todo a better way ?
 */
module rtriangle(o_len, a_len, depth, rounding_radius=2, align=[0,0,0], orient=[0,0,1])
{
    size = [a_len-rounding_radius, depth-rounding_radius, o_len-rounding_radius];
    r_x = rounding_radius;
    r_y = rounding_radius;
    r_z = -rounding_radius;

    hyp = pythag_hyp(o_len,a_len);
    a_z = atan(a_len/o_len);

    translate([0,0,size[2]+2])
    color([1,0,0])
    rotate([90,90,0])
    pie_slice(r=2, start_angle=0, end_angle=a_z, h=depth);

    /*translate([size[0]+4,0,0])*/
    /*color([1,0,0])*/
    /*rotate([90,90,0])*/
    /*pie_slice(r=2, start_angle=90, end_angle=90+a_z, h=depth);*/

    size_align(size=size, align=align, orient=orient)
    /*hull()*/
    for(x=[-(size[0]/2)+rounding_radius,(size[0]/2)-r_x])
    for(y=[-(size[1]/2)+rounding_radius,(size[1]/2)-r_y])
    for(z=[-(size[2]/2)+rounding_radius,(size[2]/2)-r_z])
    translate([x,y,z])
    if(x<=1 || z<=1)
    sphere(r=rounding_radius);
}

/*debug();*/

module debug()
{
    $fs = 0.1;
    $fa = 1;

    /*triangle_a(45, 5, 5);*/
    /*triangle(15, 10, 5, align=[1,1,1], orient=[0,0,-1]);*/
    /*triangle(15, 10, 5, align=[1,1,1], orient=[0,0,1]);*/

    triangle(10, 30, 5, align=[1,1,1], orient=[0,0,1]);
    translate([0,-10,0])
    rtriangle(10, 30, 5, align=[1,1,1], orient=[0,0,1]);
}

/**
 * Standard right-angled triangle (tangent version)
 *
 * @param number angle of adjacent to hypotenuse (ie tangent)
 * @param number a_len Lenght of the adjacent side
 * @param number depth How wide/deep the triangle is in the 3rd dimension
 */
module triangle_a(tan_angle, a_len, depth)
{
    linear_extrude(height=depth)
    {
        polygon(points=[[0,0],[a_len,0],[0,tan(tan_angle) * a_len]], paths=[[0,1,2]]);
    }
}

// Tests:
module test_triangles()
{
    // Generate a bunch of triangles by sizes
    for (i = [1:10])
    {
        translate([i*7, -30, i*7])
        {
            triangle(i*5, sqrt(i*5+pow(i,2)), 5);
        }
    }

    // Generate a bunch of triangles by angle
    for (i = [1:85/5])
    {
        translate([i*7, 22, i*7])
        {
            triangle_a(i*5, 10, 5);
        }
    }
}


if(false)
{
    /*hollow_cylinder(thickness=5, h=10, taper=true, orient=[0,0,1], align=[0,0,1]);*/
    /*cylindera(d=10, h=10, orient=[0,0,1], align=[0,0,1]);*/
    /*translate([10,0,0])*/
    /*{*/
    /*hollow_cylinder(d=10, thickness=4, h=10, taper=true, taper_h=.5, orient=[0,0,1], align=[0,0,1]);*/
    /*cylindera(d=8, h=10, orient=[0,0,1], align=[0,0,1]);*/
    /*}*/

    /*%pie_slice(r=10, start_angle=-30, end_angle=270, h=10);*/

    /*cubea([10,10,10],[1,0,0]);*/
    /*%cubea([10,10,10],[1,0,0],[5,5,5],[1,1,1]);*/

    /*%cubea([10,10,10],[-1,0,1]);*/
    /*%cubea([10,10,10],[-1,0,1],[1,1,1],[-1,0,1]);*/
    /*%cylindera(h=10, r=10/2, align=[-1,1,1], extra_r=5/2, extra_h=2, extra_align=[-1,1,1], $fn=100);*/

    /*%cylindera(h=10, d=10, align=[-1,1,1], extra_d=5, extra_h=2, extra_align=[-1,1,1], $fn=100);*/
    /*%cylindera(h=10, d=10, align=[1,1,1], extra_d=15, extra_h=2, extra_align=[1,1,1], $fn=100);*/

    /*%cylindera(h=10, d=10, align=[1,-1,1], extra_d=5, extra_h=2, extra_align=[-1,-1,1], $fn=100);*/
    /*%cylindera(h=10, d=10, align=[1,1,1], extra_d=5, extra_h=2, extra_align=[1,1,1], $fn=100);*/

    /*%cylindera(h=10, d=10, align=[1,0,0], extra_d=10);*/

    /*hull_pairwise()*/
    /*sphere(30/2);*/

    /*translate([30,0,0])*/
    /*rcubea(s=[35,35,35], rounding_radius=10);*/
    /*rcubea(s=[35,35,35], align=[0,-1,0]);*/

    /*translate([60,0,0])*/
    /*sphere(30/2);*/


    cylindera(h=20, r=5*mm, align=[0,1,0], orient=[0,0,1], $fn=100);

/*size_align(size=[5,5,20], orient=[0,1,0], orient_ref=[0,0,1])*/
/*size_align(size=[5,5,20], orient=[0,1,0], orient_ref=[0,1,0], align=[0,1,0])*/
/*size_align(size=[5,20,5], orient=[0,0,1], orient_ref=[0,1,0], align=[0,0,0])*/
/*rotate([90,0,0])*/
/*cylinder(d=5, h=20, center=true);*/

/*cylindera(d=10, h=10, orient=[0,1,0], align=[0,0,1]);*/
}


if(false)
{
    r=5*mm;
    for(axis=concat(AXES,-AXES))
    translate(axis*r*2)
    {
        c= v_abs(axis*.3 + v_clamp(v_sign(axis),0,1)*.7);
        color(c)
        cylindera(h=20, r=r, align=axis, orient=axis, extra_h=r, extra_align=-axis, $fn=100);
    }
}

if(false)
{
    stack(dist=50, axis=[0,1,0])
    {
        stack(dist=10, axis=[0,0,-1])
        {
            /*cylindera(orient=[0,0,-1], align=[0,0,-1]);*/
            pie_slice(r=30, h=5, start_angle=0, end_angle=120, orient=[0,0,1], align=[0,0,-1]);
            pie_slice(r=30, h=5, start_angle=0, end_angle=120, orient=[0,0,-1], align=[0,0,1]);
            /*pie_slice(r=30, h=5, start_angle=-90, end_angle=180, align=[0,0,-1]);*/
            /*pie_slice(r=30, h=5, start_angle=90, end_angle=270, align=[0,0,-1]);*/
            /*pie_slice(r=30, h=5, start_angle=0, end_angle=270, align=[0,0,-1]);*/
        }

        stack(dist=10, axis=[0,1,0])
        {
            /*cylindera(orient=[0,1,0], align=[0,1,0]);*/
            pie_slice(r=30, h=5, start_angle=0, end_angle=120, orient=[0,-1,0], align=[0,1,0]);
            pie_slice(r=30, h=5, start_angle=0, end_angle=120, orient=[0,1,0], align=[0,1,0]);
            pie_slice(r=30, h=5, start_angle=-90, end_angle=180, orient=[0,1,0], align=[0,1,0]);
            pie_slice(r=30, h=5, start_angle=90, end_angle=270, orient=[0,1,0], align=[0,1,0]);
            pie_slice(r=30, h=5, start_angle=0, end_angle=270, orient=[0,1,0], align=[0,1,0]);
        }
    }
}
