with
     gasp.World,

     mmi.World,
     mmi.Camera,
     mmi.Window.lumen;     pragma Unreferenced (mmi.Window.lumen);


package mmi.Applet.gasp
--
-- Provides a custom mmi applet, configured with a single 'Gasp' world.
--
is

   type Item is new mmi.Applet.item with private;
   type View is access all Item'Class;



   package Forge
   is
      function new_Applet (Name       : in String;
                           use_Window : in mmi.Window.view) return View;
   end Forge;

   procedure free (Self : in out View);



   function gasp_World (Self : in Item) return standard.gasp.World .view;
   function mmi_World  (Self : in Item) return           mmi.World .view;
   function mmi_Camera (Self : in Item) return           mmi.Camera.view;


   overriding
   procedure freshen (Self : in out Item);



private

   type Item is new mmi.Applet.item with
      record
         pod_Direction : math.Vector_3 := (0.0, 0.0, -1.0);
         pod_Roll      : math.Radians  := 0.0;
      end record;

end mmi.Applet.gasp;
