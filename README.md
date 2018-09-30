# Z probe for hcmaker7 / ADIMLabs gantry 3d printer

Video of operation: https://youtu.be/guoYLGDIiuw

Print instructions:

I used PLA for this. Triangular infil at 10%, 0.2mm layer height.

Other parts and supplies:

5x1mm magnets, [amazon](https://www.amazon.com/gp/product/B073JZ42VJ)

Microswitches, [amazon](https://www.amazon.com/gp/product/B015W8S8NA)

Screws: [amazon](https://www.amazon.com/gp/product/B017QDHIW6)

Wires: [amazon](https://www.amazon.com/gp/product/B01KQ2JNLI)

Superglue, locktite worked good, any other should work.

Connector for the mainboard: I used some header connectors I had. I'll post a link to an actual connector when I get it.

Assembly instructions: Cut off 3 lengths of wire (I recommend black and red for ground and +5, and green or blue for signal), ~25cm longer than your printhead wire

Solder wires to the microswitch ("c" to signal wire, "nc" to red, "no" to black), route wires through the holes in the probe head as can be seen in the video, all the way to your controller box. 

Connect the red wire to +5 , black to 0, and green to signal of the +z endstop. Look at silkscreen - do not rely on the colours of endstop wires already there.

Screw the probe head to the printhead using m3 x 6mm screws. Secure the microswitch using two m2 screws with nuts. Note that the holes in the print are intentionally tight to prevent screws from loosening.
