with
     float_Math.Geometry      .d2,
     float_Math.Geometry      .d3,
     float_math.Algebra.linear.d3;

package Gasp
--
-- Provides a namespace and core declarations for the 'Gasp' game.
--
is
   pragma Pure;

   package Math              renames float_Math;
   package Geometry_2d       renames Math.Geometry.d2;
   package Geometry_3d       renames Math.Geometry.d3;
   package linear_Algebra_3d renames Math.Algebra.linear.d3;

end Gasp;
