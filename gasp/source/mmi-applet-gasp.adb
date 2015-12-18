with
     openGL.Palette,

     mmi.Camera.forge,
     mmi.Sprite,
     mmi.Events,

     lace.Observer,
     lace.event.Utility.local,

     ada.Unchecked_Deallocation;


package body mmi.Applet.gasp
is
   use Math;

   package std_Gasp renames standard.Gasp;


   gasp_world_Id  : constant mmi. world_Id := 1;
   gasp_camera_Id : constant mmi.camera_Id := 1;


   procedure define (Self : in View;   Name : in String)
   is
      use openGL.Palette,
          lace.event.Utility;

      the_world_Info : constant world_Info_view     := new world_Info;
      the_World      : constant std_Gasp.World.view := std_Gasp.World.forge.new_World (Name,
                                                                                       Self.Renderer);
      the_Camera     : constant mmi.Camera.View     := mmi.Camera.forge.new_Camera;

   begin
      the_World.restore;
      the_world_Info.World := mmi.World.view (the_World);

      the_Camera.set_viewport_Size (Self.Window.Width,  Self.Window.Height);
      the_Camera.Renderer_is       (Self.Renderer);
      the_Camera.Site_is           ((0.0, 0.0, 100.0));

      the_world_Info.Cameras.append (the_Camera);

      Self.Worlds  .append        (the_world_Info);
      Self.Renderer.Background_is (Black);
   end define;


   package body Forge
   is

      function new_Applet (Name       : in String;
                           use_Window : in mmi.Window.view) return View
      is
         Self : constant View := new Item' (mmi.Applet.Forge.to_Applet (Name, use_Window)
                                              with others => <>);
      begin
         define (Self, Name);
         return Self;
      end new_Applet;

   end Forge;


   procedure free (Self : in out View)
   is
      procedure deallocate is new ada.Unchecked_Deallocation (Item'Class, View);
   begin
      Self.gasp_World.store;
      Self.destroy;
      deallocate (Self);
   end free;


   function gasp_World  (Self : in Item) return standard.gasp.World.view
   is
   begin
      return standard.gasp.World.view (Self.World (gasp_world_Id));
   end gasp_World;


   function mmi_World (Self : in Item) return mmi.World.view
   is
   begin
      return Self.World (gasp_world_Id);
   end mmi_World;


   function mmi_Camera (Self : in Item) return mmi.Camera.view
   is
   begin
      return Self.Camera (gasp_world_Id, gasp_camera_Id);
   end mmi_Camera;



   overriding
   procedure freshen (Self : in out Item)
   is
      use MMI.Keyboard, linear_Algebra, Algebra_3d;
   begin
      freshen (mmi.Applet.item (Self));

      if Self.gasp_World.Pod.Speed /= (0.0, 0.0, 0.0)
      then
         if Self.pod_Direction /= Normalised (Self.gasp_World.Pod.Speed)
         then
            Self.pod_Direction := Normalised (Self.gasp_World.Pod.Speed);
         end if;
      end if;

      Self.gasp_World.Pod.Spin_is (get_Rotation (Look_at (Eye    => Self.gasp_World.Pod.Site,
                                                          Center => Self.gasp_World.Pod.Site + Self.pod_Direction * 10.0,
                                                          Up     => z_Rotation_from (Self.pod_Roll) * (0.0, 1.0, 0.0))));

      Self.Camera (1, 1).Site_is           (Self.gasp_World.Pod.Site);
      Self.Camera (1, 1).world_Rotation_is (Self.gasp_World.Pod.Spin);

      case Self.last_Keypress
      is
         when KP1     => Self.pod_Roll := Self.pod_Roll + 0.05;
         when KP2     => null;
         when KP3     => Self.pod_Roll := Self.pod_Roll - 0.05;

         when KP4     => Self.gasp_World.Pod.apply_Force  (  ((-1.0, 0.0,  0.0) * 0.02) * (Self.gasp_World.Pod.Spin));
         when KP5     => Self.gasp_World.Pod.apply_Force  (  (( 0.0, 0.0,  1.0) * 0.1)  * (Self.gasp_World.Pod.Spin));
         when KP6     => Self.gasp_World.Pod.apply_Force  (  (( 1.0, 0.0,  0.0) * 0.02) * (Self.gasp_World.Pod.Spin));
         when KP8     => Self.gasp_World.Pod.apply_Force  (  (( 0.0, 0.0, -1.0) * 0.1)  * (Self.gasp_World.Pod.Spin));

         when KP7     => Self.gasp_World.Pod.apply_Torque_impulse (0.005 * ( 0.0, -1.0,  0.0));
         when KP9     => Self.gasp_World.Pod.apply_Torque_impulse (0.005 * ( 0.0,  1.0,  0.0));
         when KP_PLUS => Self.gasp_World.Pod.apply_Force          (  (( 0.0,  1.0, 0.0) * 0.02)  * (Self.gasp_World.Pod.Spin));
         when ENTER   => Self.gasp_World.Pod.apply_Force          (  (( 0.0, -1.0, 0.0) * 0.02)  * (Self.gasp_World.Pod.Spin));

         when others  => null;
      end case;
   end freshen;


end mmi.Applet.gasp;
