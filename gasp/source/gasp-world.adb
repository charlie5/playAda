with
     openGL.Model.sphere.textured,
     openGL.Model.open_gl,
     openGL.Palette,

     physics.Forge,

     mmi.physics_Model,
     mmi.Forge,

     float_Math.Geometry.d3.Modeller.Forge,

     ada.unchecked_Deallocation,
     ada.Text_IO,
     ada.Streams.Stream_IO;


package body gasp.World
is
   use ada.text_IO;


   gasp_world_Id : constant := 1;

   type Geometry_Model_view is access all Geometry_3d.a_Model;



   ---------
   --  Forge
   --

   package body Forge
   is
      function new_World (Name     : in String;
                          Renderer : in openGL.Renderer.lean.view) return View
      is
         use openGL,
             geometry_3d.Modeller.Forge,
             Math, linear_Algebra_3d;

         Self : constant View := new Item' (mmi.World.Forge.to_World (Name,  gasp_world_Id,
                                                                      standard.physics.Forge.Bullet,
                                                                      Renderer)
                                            with others => <>);
      begin
         Self.start;
         Self.Gravity_is ((0.0, 0.0, 0.0));

         add_Skysphere:
         declare
            starfield_Image    : constant openGL.asset_Name
              := openGL.to_Asset ("assets/starfield-2.jpg");

            the_graphics_Model : constant openGL.Model.sphere.textured.view
              := openGL.Model.sphere.textured.Forge.new_Sphere (Radius       => 10_000.0,
                                                                Image        => starfield_Image,
                                                                is_Skysphere => True);
            the_physics_Model  : constant mmi.physics_Model.view
              := mmi.physics_Model.Forge.new_physics_Model (shape_Info => (mmi.physics_Model.a_Sphere, 0.5),
                                                            mass       => 0.0);
            the_Sprite         :          mmi.Sprite.view;
         begin
            the_Sprite := mmi.Sprite.Forge.new_Sprite ("skybox_Sprite",
                                                       Self,
                                                       the_graphics_Model,
                                                       the_physics_Model,
                                                       owns_graphics => True,
                                                       owns_physics  => True,
                                                       is_Kinematic  => False);
            Self.add (the_Sprite);
         end add_Skysphere;


         add_Asteroid:
         declare
            the_math_Model     : constant Geometry_Model_view
              := new Geometry_3d.a_Model' (mesh_Model_from (the_Model => polar_Model_from ("./gaspra.tab")));

            the_graphics_Model : constant openGL.Model.open_gl.view
              := openGL.Model.open_gl.Forge.new_Model ((1.0, 1.0, 1.0),
                                                       null_Asset,
                                                       the_math_Model,
                                                       null_Asset,
                                                       False);

            the_physics_Model  : constant mmi.physics_Model.view
              := mmi.physics_Model.Forge.new_physics_Model (shape_Info => (mmi.physics_Model.Mesh, the_math_Model),
                                                            mass       => 0.0);
            the_Sprite : mmi.Sprite.view;
         begin
            the_Sprite := mmi.Sprite.Forge.new_Sprite ("asteroid_Sprite",
                                                       Self,
                                                       the_graphics_Model,
                                                       the_physics_Model,
                                                       owns_graphics => True,
                                                       owns_physics  => True,
                                                       is_Kinematic  => False);
            Self.add (the_Sprite);
         end add_Asteroid;


         add_Pod:
         declare
            the_Sprite : constant mmi.Sprite.view
              := mmi.Forge.new_ball_Sprite (in_World => Self.all'Access,
                                            Mass     => 1.0,
                                            Radius   => 0.2,
                                            Color    => openGL.Palette.Red);
         begin
            the_Sprite.is_Visible (False);
            the_Sprite.Site_is ((0.0, 0.0, 200.0));
            Self.add (the_Sprite);
            Self.pod_Sprite := the_Sprite;
         end add_Pod;


         return Self;
      end new_World;

   end Forge;




   overriding
   procedure destroy (Self : in out Item)
   is
   begin
      mmi.World.destroy (mmi.World.item (Self));   -- Destroy the base class.
   end destroy;





   procedure free (Self : in out View)
   is
      procedure deallocate is new ada.unchecked_Deallocation (item'Class, View);
   begin
      if Self /= null then
         destroy (Self.all);
      end if;

      deallocate (Self);
   end free;




   procedure store   (Self : in out Item)
   is
      pragma Unreferenced (Self);

      use          ada.Streams.Stream_IO;
      the_File   : ada.Streams.Stream_IO.File_Type;
      the_Stream : ada.Streams.Stream_IO.Stream_Access;
   begin
      create (the_File, out_File, "World.stream");
      the_Stream := Stream (the_File);

      -- To do.

      close (the_File);
   end store;



   procedure restore   (Self : in out Item)
   is
      use          ada.Streams.Stream_IO;
      the_File   : ada.Streams.Stream_IO.File_Type;
      the_Stream : ada.Streams.Stream_IO.Stream_Access;
   begin
      open (the_File, in_File, "World.stream");
      the_Stream := Stream (the_File);

      -- To do.

      close (the_File);

   exception
      when ada.Streams.Stream_IO.Name_Error =>
         put_Line ("No prior World found.");
   end restore;



   --------------
   --  Attributes
   --

   function Pod (Self : in Item) return mmi.Sprite.view
   is
   begin
      return Self.pod_Sprite;
   end Pod;




   --------------
   --  Operations
   --

   overriding
   procedure evolve (Self : in out Item;   By : in     Duration)
   is
      use Math;
      use type ada.Containers.Count_type;
   begin
      Self.Counter := Self.Counter + 1;

      -- Gravity
      --
      Self.pod_Sprite.apply_Force (-Self.pod_Sprite.Site * 0.00001);

      -- Dampen pod spin.
      --
--        Self.ball_Sprite.Gyre_is (Self.ball_Sprite.Gyre * 0.90);


      mmi.World.evolve (mmi.World.item (Self),  By);     -- Evolve the base mmi world.
   end evolve;


end gasp.World;
