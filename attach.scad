use <misc.scad>

// From Obiscad
//----------------------------------------------------------
//--  Draw a point in the position given by the vector p  
//----------------------------------------------------------
module point(p, r=0.7, fn, fnr=0.4)
{
    fn_= fn==undef ? (floor(2*(r)*PI/fnr)) : fn;
    translate(p)
    sphere(r=r,$fn=fn_);
}

//------------------------------------------------------------------
//-- Draw a vector poiting to the z axis
//-- This is an auxiliary module for implementing the vector module
//--
//-- Parameters:
//--  l: total vector length (line + arrow)
//--  l_arrow: Vector arrow length
//--  mark: If true, a mark is draw in the vector head, for having
//--    a visual reference of the rolling angle
//------------------------------------------------------------------
module vectorz(l=10, l_arrow=4, mark=false, fnr)
{
  //-- vector body length (not including the arrow)
  lb = l - l_arrow;

  //-- The vector is locatead at 0,0,0
  translate([0,0,lb/2])
  union() {

    //-- Draw the arrow
    translate([0,0,lb/2])
      fncylinder(r1=2/2, r2=0.2, h=l_arrow, fnr);

    //-- Draw the mark
    if (mark) {
      translate([0,0,lb/2+l_arrow/2])
      translate([1,0,0])
        cube([2,0.3,l_arrow*0.8],center=true);
    }

    //-- Draw the body
    cylinder(r=1/2, h=lb, center=true, fnr);
  }

  //-- Draw a sphere in the vector base
  sphere(r=1/2, fnr);
}

//-----------------------------------------------------------------
//-- ORIENTATE OPERATOR
//--
//--  Orientate an object to the direction given by the vector v
//--  Parameters:
//--    v : Target orientation
//--    vref: Vector reference. It is the vector of the local frame
//--          of the object that want to be poiting in the direction
//--          of v
//--    roll: Rotation of the object around the v axis
//-------------------------------------------------------------------
module orientate(v,vref=[0,0,1], roll=0)
{
  //-- Calculate the rotation axis
  raxis = v_cross(vref,v);

  //-- Calculate the angle between the vectors
  ang = v_anglev(vref,v);

  //-- Rotate the child!
  rotate(a=roll, v=v)
    rotate(a=ang, v=raxis)
      child(0);
}

// From Obiscad,
//---------------------------------------------------------------------------
//-- Draw a vector
//--
//-- There are two modes of drawing the vector
//-- * Mode 1: Given by a cartesian point(x,y,z). A vector from the origin
//--           to the end (x,y,z) is drawn. The l parameter (length) must 
//--           be 0  (l=0)
//-- * Mode 2: Give by direction and length
//--           A vector of length l pointing to the direction given by
//--           v is drawn
//---------------------------------------------------------------------------
//-- Parameters:
//--  v: Vector cartesian coordinates
//--  l: total vector length (line + arrow)
//--  l_arrow: Vector arrow length
//    mark: If true, a mark is draw in the vector head, for having
//--    a visual reference of the rolling angle
//---------------------------------------------------------------------------

module vector(v,l=0, l_arrow=4, mark=false)
{
  //-- Get the vector length from the coordinates
  mod = mod(v);

  //-- The vector is very easy implemented by means of the orientate
  //-- operator:
  //--  orientate(v) vectorz(l=mod, l_arrow=l_arrow)
  //--  BUT... in OPENSCAD 2012.02.22 the recursion does not
  //--    not work, so that if the user use the orientate operator
  //--    on a vector, openscad will ignore it..
  //-- The solution at the moment (I hope the openscad developers
  //--  implement the recursion in the near future...)
  //--  is to repite the orientate operation in this module

  //---- SAME CALCULATIONS THAN THE ORIENTATE OPERATOR!
  //-- Calculate the rotation axis

  vref = [0,0,1];
  raxis = v_cross(vref,v);
  
  //-- Calculate the angle between the vectors
  ang = v_anglev(vref,v);

  //-- orientate the vector
  //-- Draw the vector. The vector length is given either
  //--- by the mod variable (when l=0) or by l (when l!=0)
  if (l==0)
    rotate(a=ang, v=raxis)
      vectorz(l=mod, l_arrow=l_arrow, mark=mark);
  else
    rotate(a=ang, v=raxis)
      vectorz(l=l, l_arrow=l_arrow, mark=mark);

}

// From Obiscad,
//--------------------------------------------------------------------
//-- Draw a connector
//-- A connector is defined a 3-tuple that consist of a point
//--- (the attachment point), and axis (the attachment axis) and
//--- an angle the connected part should be rotate around the 
//--  attachment axis
//--
//--- Input parameters:
//--
//--  Connector c = [p , n, ang] where:
//--
//--     p : The attachment point
//--     v : The attachment axis
//--   ang : the angle
//--------------------------------------------------------------------
module connector(c)
{
  //-- Get the three components from the connector
  p = c[0];
  v = c[1];
  ang = c[2];

  //-- Draw the attachment poing
  color("Gray") point(p);

  //-- Draw the attachment axis vector (with a mark)
  translate(p)
    rotate(a=ang, v=v)
    color("Gray") vector(unitv(v)*6, l_arrow=2, mark=true);
}

// From Obiscad,
// modified to take roll parameter as param in module instead of attachment points
//-------------------------------------------------------------------------
//--  ATTACH OPERATOR
//--  This operator applies the necesary transformations to the 
//--  child (attachable part) so that it is attached to the main part
//--  
//--  Parameters
//--    a -> Connector of the main part
//--    b -> Connector of the attachable part
//-------------------------------------------------------------------------
module attach(a, b, roll=0)
{
    //-- Get the data from the connectors
    pos1 = a[0];  //-- Attachment point. Main part
    v    = a[1];  //-- Attachment axis. Main part

    pos2 = b[0];  //-- Attachment point. Attachable part
    vref = b[1];  //-- Atachment axis. Attachable part

    //-------- Calculations for the "orientate operator"------
    //-- Calculate the rotation axis
    raxis = v_cross(vref,v);

    //-- Calculate the angle between the vectors
    ang = v_anglev(vref,v);
    //--------------------------------------------------------.-

    //-- Apply the transformations to the child ---------------------------

    //-- Place the attachable part on the main part attachment point
    translate(pos1)
        //-- Orientate operator. Apply the orientation so that
        //-- both attachment axis are paralell. Also apply the roll angle
        rotate(a=roll, v=v)  rotate(a=ang, v=raxis)
        //-- Attachable part to the origin
        translate(-pos2)
        children();
}
