with
     openGL.Renderer.lean,
    
     mmi.World,
     mmi.Sprite,

     ada.Containers.Vectors,
     ada.Containers.Hashed_Sets,
     ada.Unchecked_Conversion;


package gasp.World
is

   type Item is limited new mmi.World.item with private;
   type View is access  all item'Class;


   package Forge
   is
      function new_World (Name     : in String;
                          Renderer : in openGL.Renderer.lean.view) return View;
   end Forge;


   overriding
   procedure destroy (Self : in out Item);
   procedure free    (Self : in out View);

   procedure   store (Self : in out Item);
   procedure restore (Self : in out Item);


   overriding
   procedure evolve  (Self : in out Item;   By : in Duration);


   function Pod (Self : in Item) return mmi.Sprite.view;



private

   use type mmi.sprite_Id;
   package  sprite_id_Vectors is new ada.containers.Vectors (Positive, mmi.sprite_Id);

   function Hash              is new ada.Unchecked_Conversion   (mmi.sprite_Id, ada.Containers.Hash_Type);
   package  organ_Sets        is new ada.Containers.hashed_Sets (mmi.sprite_Id, Hash, "=");


   type Item is limited new mmi.World.item with
      record
         Counter    : Natural        := 0;
         pod_Sprite : mmi.Sprite.view;
      end record;

end gasp.World;

