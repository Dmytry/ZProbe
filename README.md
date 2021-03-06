# Z probe for hcmaker7 / ADIMLabs gantry 3d printer

Video of operation (click on image to play): 

[![](http://img.youtube.com/vi/guoYLGDIiuw/0.jpg)](http://www.youtube.com/watch?v=guoYLGDIiuw "")

Print instructions:

Install OpenSCAD, convert the .scad file into stl, then use slic3r to convert stl to gcode. Alternatively, download the stl file [from the latest release](/../../releases/latest).

I printed this with PLA. Triangular infil at 10%, 0.2mm layer height. You really don't need much infill as most of the strength and stiffness comes from the walls.

Other parts and supplies:

5x1mm magnets, [amazon](https://www.amazon.com/gp/product/B073JZ42VJ)

Microswitches, [amazon](https://www.amazon.com/gp/product/B015W8S8NA)

Screws: [amazon](https://www.amazon.com/gp/product/B017QDHIW6)

Wires: [amazon](https://www.amazon.com/gp/product/B01KQ2JNLI)

Superglue, locktite worked good, any other should work.

Connector for the mainboard: I used some header connectors I had. I'll post a link to an actual connector when I get it, if it works.

Assembly instructions: Glue magnets into the recesses in the probe head. To do that stick the magnets on a magnetic ruler (or your spatula that came with the printer) first, positioning them to match the holes, then put glue in the holes and press the piece with the magnets to it. (You can't simply glue the magnets one by one because they will snap together.)

Note: to hold the head up you can either use the 5x1 magnets on a little ledge or use a pair of 8x2 magnets pushed hard into the slots in the printhead on the gear side (make sure they're oriented to attract).

Cut off 3 lengths of wire (I recommend black and red for ground and +5, and green or blue for signal), ~25cm longer than your printhead wire.

Solder wires to the microswitch ("c" to signal wire, "nc" to red, "no" to black), route wires through the holes in the probe head as can be seen in the video, all the way to your controller box. 

Connect the red wire to +5 , black to 0, and green to signal of the +z endstop. Look at silkscreen - do not rely on the colours of endstop wires already there (they don't follow the convention).

Screw the probe head to the printhead using m3 x 6mm screws. Secure the microswitch using two m2 screws with nuts. Note that the holes in the print are intentionally tight to prevent screws from loosening. Secure the rack to the side rail using an M4x8 bolt and one of the v-slot nuts that came with the printer. The rack should be able to mesh with the probe head's gear as in the video. Try to position it to mesh with the very middle of the gear's width.

Firmware: [Marlin 1.1.9 fork](https://github.com/Dmytry/Marlin)
