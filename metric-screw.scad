include <system.scad>
include <shapes.scad>
include <transforms.scad>
include <misc.scad>

include <metric-thread-data.scad>
include <metric-hexnut-data.scad>
include <metric-knurlnut-data.scad>

use <scad-utils/transformations.scad>

// naive, assume head height is same as thread size (generally true for cap heads)
function get_screw_head_h(thread) = lookup(ThreadSize, thread);
function get_screw_head_d(thread) = 2 * lookup(ThreadSize, thread);

module screw(nut, thread, h=10, tolerance=1.05, head_embed=false, with_nut=true, with_head=true, nut_offset=0, orient=[0,0,1], align=[0,0,0])
{
    nut_thread = get(MHexNutThread, nut);
    thread_ = fallback(thread, nut_thread);
    assert(thread_ != undef, "screw: No nut or thread given");
    /*assert(nut!=undef && thread!=undef && nut_thread != thread_, "screw: Mismatched nut and thread");*/

    head_h = get_screw_head_h(nut);
    nut_h = lookup(MHexNutThickness,nut)*tolerance;
    threadsize = lookup(ThreadSize, thread_);

    s = threadsize*tolerance;
    total_h = h;
    size_align(size=[s, s, total_h], orient=-orient, orient_ref=[0,0,1], align=align)
    {
        translate([0,0,head_embed?-head_h:0])
        {
            if(with_head)
            {
                translate([0,0,h/2+.01])
                screw_head(thread=thread_, orient=[0,0,1], align=[0,0,1]);
            }

            screw_thread(thread=thread_, h=h+.1, tolerance=tolerance, orient=[0,0,1], align=[0,0,0]);

            if(with_nut && nut != undef)
            {
                translate([0,0,-h/2+nut_h+nut_offset+(head_embed?head_h:0)])
                screw_nut(nut=nut, tolerance=tolerance, orient=[0,0,1], align=[0,0,-1]);
            }
        }
    }
}

module screw_cut(nut, thread, h=10, tolerance=1.05, head_embed=false, with_nut=true, nut_cut_h=1000, with_head=true, head_cut_h=1000, nut_offset=0, cut_access=true, orient=[0,0,1], align=[0,0,0])
{
    nut_thread = get(MHexNutThread, nut);
    thread_ = fallback(thread, nut_thread);
    assert(thread_ != undef, "screw_cut: No nut or thread given");
    /*assert(nut!=undef && thread!=undef && nut_thread != thread_, "screw_cut: Mismatched nut and thread");*/

    nut_h = get(MHexNutThickness,nut)*tolerance;
    head_h = get_screw_head_h(thread);
    threadsize = get(ThreadSize, thread_);
    assert(threadsize != undef, "screw_cut: threadsize is undef!");

    s = threadsize*tolerance;
    total_h = h;
    assert(s != undef, "screw_cut: s is undef!");
    size_align(size=[s, s, total_h], orient=-orient, orient_ref=[0,0,1], align=align)
    {
        translate([0,0,head_embed?-head_h:0])
        {
            if(with_head)
            {
                translate([0,0,h/2+.01])
                screw_head_cut(thread=thread_, tolerance=tolerance, override_h=head_cut_h, align=[0,0,1]);
            }

            screw_thread_cut(thread=thread_, h=h+.1, tolerance=tolerance, orient=[0,0,1], align=[0,0,0]);

            if(with_nut && nut != undef)
            {
                translate([0,0,-h/2+nut_h+nut_offset+(head_embed?head_h:0)])
                screw_nut_cut(nut=nut, tolerance=tolerance, h=nut_cut_h, align=[0,0,-1]);
            }
        }
    }

    if($show_vit)
    {
        %screw(nut=nut, thread=thread, h=h, tolerance=tolerance, head_embed=head_embed, with_nut=with_nut, with_head=with_head, nut_offset=nut_offset, orient=orient, align=align);
    }
}

module screw_thread(thread, h=10, tolerance=1.00, orient=[0,0,1], align=[0,0,0])
{
    assert(thread!=undef, "screw_thread: thread is undef");
    // TODO render thread
    threadsize = lookup(ThreadSize, thread);
    cylindera(d=threadsize, h=h, orient=orient, align=align);
}

module screw_thread_cut(thread, h=10, tolerance=1.05, orient=[0,0,1], align=[0,0,0])
{
    assert(thread!=undef, "screw_thread_cut: thread is undef");
    threadsize = lookup(ThreadSize, thread);
    cylindera(d=threadsize*tolerance, h=h, orient=orient, align=align);
}

module screw_head(thread, tolerance=1.00, override_h=undef, orient=[0,0,1], align=[0,0,0])
{
    assert(thread!=undef, "screw_head: thread is undef");

    threadsize = lookup(ThreadSize, thread);
    head_h = get_screw_head_h(thread);
    head_d = get_screw_head_d(thread);
    size_align(size=[head_d, head_d, head_h], orient=orient, align=align)
    difference()
    {
        cylindera(d=head_d, h = fallback(override_h,head_h));
        translate([0,0,head_h/2])
        cylindera(d=threadsize, h = head_d/2);
    }
}

module screw_head_cut(thread, tolerance=1.05, override_h=undef, orient=[0,0,1], align=[0,0,0])
{
    assert(thread!=undef, "screw_head_cut: thread is undef");

    threadsize = lookup(ThreadSize, thread);
    head_h = get_screw_head_h(thread);
    head_d = get_screw_head_d(thread)*tolerance;
    size_align(size=[head_d, head_d, head_h], orient=orient, align=align)
    translate([0,0,-head_h/2])
    cylindera(d=head_d, h=fallback(override_h, head_h), align=[0,0,1]);
}

module screw_nut(nut, tolerance=1.00, override_h=undef, orient=[0,0,1], align=[0,0,0])
{
    assert(nut!=undef, "screw_nut: nut is undef");

    thickness = lookup(MHexNutThickness,nut)*tolerance;
    d = lookup(MHexNutWidthMin, nut)*tolerance;
    facets = lookup(MHexNutFacets, nut);
    cylindera($fn=lookup(MHexNutFacets, nut), d=d, h=fallback(override_h, thickness), orient=orient, align=align);
}

module screw_nut_cut(nut, tolerance=1.05, h=1000, orient=[0,0,1], align=[0,0,0])
{
    assert(nut!=undef, "screw_nut_cut: nut is undef");

    thickness = lookup(MHexNutThickness,nut)*tolerance;
    d = lookup(MHexNutWidthMin, nut)*tolerance;
    size_align(size=[d,d,thickness], orient=orient, align=align)
    {
        translate([0,0,thickness/2])
        {
            screw_nut(nut, tolerance, orient=[0,0,1], align=[0,0,-1]);
            translate([0,0,-thickness+.01])
            {
                cylindera(d=d*1.1, h=h, orient=[0,0,1], align=[0,0,-1]);
            }
        }
    }
}

module nut_trap_cut(nut, thread, trap_offset=10, screw_l=10*mm, screw_l_extra=2*mm, trap_h=10, trap_axis=[0,-1,0], orient=[0,0,1], align=[0,0,0])
{
    nut_thread = get(MHexNutThread, nut);
    thread_ = fallback(thread, nut_thread);
    assert(thread_ != undef, "nut_trap_cut: No nut or thread given");
    /*assert(nut!=undef && thread!=undef && nut_thread != thread_, "nut_trap_cut: Mismatched nut and thread");*/

    threadsize = lookup(ThreadSize, thread_);
    head_h = get_screw_head_h(thread);
    nut_h = lookup(MHexNutThickness,nut)+.5*mm;

    nut_width_min = lookup(MHexNutWidthMin, nut)+.1*mm;
    nut_width_max = lookup(MHexNutWidthMax, nut)+.1*mm;
    s = nut_width_min;
    total_h = nut_h;

    size_align(size=[s, s, total_h], orient=orient, orient_ref=[0,0,1], align=align)
    {
        translate([0,0,nut_h/2-.1])
        screw_thread_cut(thread=thread_, tolerance=1.1, h=screw_l, orient=[0,0,-1], align=[0,0,1]);

        if(screw_l_extra>0)
        translate([0,0,-nut_h/2+.1])
        screw_thread_cut(thread=thread_, tolerance=1.1, h=screw_l_extra+.1, orient=[0,0,1], align=[0,0,-1]);

        hull()
        {
            orient(-orient)
            translate(-.15*mm*trap_axis)
            stack(dist=trap_h, axis=trap_axis)
            {
                orient(orient)
                {
                    rotate([0,0,30])
                    cylindera($fn=lookup(MHexNutFacets, nut), d=nut_width_max, h=nut_h, align=[0,0,0]);
                }

                orient(orient)
                cubea(size=[nut_width_min,nut_width_min,nut_h], align=[0,0,0]);
            }
        }

        if($show_vit)
        {
            translate([0,0, screw_l])
            translate([0,0, -nut_h/2])
            %screw(nut=nut, thread=thread, tolerance=1, with_nut=false, orient=[0,0,-1], align=[0,0,-1]);

            rotate([0,0,30])
            %screw_nut(nut=nut, thread=thread, tolerance=1, orient=[0,0,-1], align=[0,0,0]);
        }

    }
}

function get(key, dict) =
    let(x = search(key, dict))
    let(kv = dict[x[0]])
    kv[1];


if(false)
{
    nut1 = MHexNutM3;
    nut2 = MHexNutM5;
    nut3 = MKnurlInsertNutM3_3_42;
    nut4 = MKnurlInsertNutM3_5_42;

    /*translate([0,20,0])*/
    /*translate([0,20,0])*/
    /*for(axis1=[0:len(AXES)-1])*/
    /*[>for(axis2=AXES)<]*/
    /*translate(20*AXES[axis1])*/
    /*{*/
        /*ta = v_rotate(90, AXES[axis1])*AXES[axis1];*/
        /*echo(AXES[axis1], ta);*/
        /*nut_trap_cut(nut=nut1, trap_axis=ta, orient=AXES[axis1]);*/
    /*}*/

    /*stack(d=30, axis=[1,0,0])*/
    /*{*/
        /*stack(d=20, axis=[0,1,0])*/
        /*{*/
            /*nut_trap_cut(nut=nut1, trap_axis=[0,0,1], orient=[1,0,0]);*/
            /*nut_trap_cut(nut=nut1, trap_axis=[0,0,1], orient=[-1,0,0]);*/
        /*}*/

        /*stack(d=20, axis=[1,0,0])*/
        /*{*/
            /*nut_trap_cut(nut=nut1, trap_axis=[0,0,1], orient=[0,1,0]);*/

            /*nut_trap_cut(nut=nut1, trap_axis=[0,0,1], orient=[0,-1,0]);*/
        /*}*/
    /*}*/

    box_w = 100;
    box_h = 10;
    box_d = 10;
    o = 10;

    $show_vit = true;
    $fs= 0.5;
    $fa = 4;

    difference()
    {
        cubea([box_w,box_d/2,box_h], align=[1,1,1]);

        test_cuts();
    }
    /*difference()*/
    /*{*/
        /*cubea([box_w,box_d/2,box_h], align=[1,-1,1]);*/

        /*test_cuts();*/
    /*}*/

}

module test_cuts()
{
    union()
    {
        offset = 0;
        /*offset = -5;*/
        translate([0,offset,0])
        translate([5,0,0])
        stack(dist=10,axis=[1,0,0])
        {
            screw_cut(nut=nut1, h=box_h, head_embed=false, orient=[0,0,-1], align=[0,0,1]);
            screw_cut(thread=ThreadM5, h=box_h, head_embed=false, orient=[0,0,-1], align=[0,0,1]);
            screw_cut(nut=nut1, h=box_h, head_embed=false, orient=[0,0,1], align=[0,0,1]);

            screw_cut(nut=nut1, h=box_h*mm, nut_offset=0*mm, head_embed=true, orient=[0,0,-1], align=[0,0,1]);
            screw_cut(nut=nut2, h=box_h*mm, nut_offset=3*mm, head_embed=false, orient=[0,0,-1], align=[0,0,1]);
            screw_cut(nut=nut3, h=box_h, head_embed=false, orient=[0,0,-1], align=[0,0,1]);
            screw_cut(nut=nut4, h=box_h, head_embed=false, orient=[0,0,-1], align=[0,0,1]);

            /*translate([0,5,0])*/
            translate([0,0,box_h/2])
                nut_trap_cut(nut=nut1, h=5, head_embed=false, trap_h=10, trap_axis=[0,-1,0], orient=[0,0,-1], align=[0,0,0]);

            translate([0,0,box_h/2])
                nut_trap_cut(nut=nut1, h=5, head_embed=false, trap_h=10, trap_axis=[0,1,0], orient=[0,0,1], align=[0,0,0]);

            translate([0,0,box_h/2])
                nut_trap_cut(nut=nut1, h=box_d, head_embed=false, trap_h=10, screw_l_extra=2*mm, trap_axis=[0,0,1], orient=[0,1,0], align=[0,0,0]);

            translate([0,0,box_h/2])
                nut_trap_cut(nut=nut1, h=box_d, head_embed=false, trap_h=10, screw_l_extra=2*mm, trap_axis=[0,0,-1], orient=[0,1,0], align=[0,0,0]);
        }
    }
}

