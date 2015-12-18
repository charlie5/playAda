with
     mmi.Window.lumen,
     mmi.Applet.gasp,

     ada.Calendar,
     ada.Exceptions,
     ada.Text_IO;


procedure launch_solo_Gasp
--
-- Launches the solo version of the Gasp 'game'.
--
--
is
   use ada.Calendar, ada.Exceptions, ada.Text_IO;


   the_Window       : constant mmi.Window.view
     := mmi.Window.view (mmi.Window.lumen.Forge.new_Window ("Window.gasp",  1600, 1000));

   the_Applet       :          mmi.Applet.gasp.view
     := mmi.Applet.gasp.forge.new_Applet ("Applet.gasp",
                                          use_window => the_Window);
   next_render_Time :          ada.Calendar.Time
     := ada.Calendar.clock;

begin
   while the_Applet.is_open
   loop
      the_Applet.gasp_World.evolve (by => 1.0/60.0);       -- Evolve the Gasp world.
      the_Applet.freshen;                                  -- Handle any new (generally user) events and update the screen.

      next_render_Time := next_render_Time + 1.0/60.0;
      delay until next_render_Time;
   end loop;

   mmi.Applet.gasp.free (the_Applet);

exception
   when E : others =>
      new_Line (2);
      put_Line ("Fatal error in main environment task");
      new_Line;
      put_Line (Exception_Information (E));
      new_Line (2);
end launch_solo_Gasp;
