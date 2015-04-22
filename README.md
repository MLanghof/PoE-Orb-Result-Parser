# PoE Orb Result Parser
---------------------

This autohotkey script is intended to facilitate the documentation of currency usage results.

To be clear: **This is not a hack and does not use any information that the player could not directly obtain himself.**
It works solely on the data the game writes to the clipboard when you Ctrl+C over an item.

###Currently supported orbs:
* Fusings
* Jewelers
* Chromes

Alteration support might come at some point (anyone is free to contribute though!).

###How to use:
Usage is quite simple:
1. Directly before you use your first orb, hover over the item and press Ctrl+N. A confirmation tooltip will appear.
2. After every orb you use, hover over the item and press Ctrl+C. The logged result will be shown in a tooltip.
3. If you want to use a different orb or work on a different item, start at 1. Results will be saved in a different file.

**By default, the tool will figure out what orb you used by itself.** No need to fiddle around with files when you go from jeweler to fuse, just hit Ctrl+N again before starting to fuse.

**Any common mistakes should be covered by error messages.** Keep in mind though that the tool doesn't know what the item looked like before you used your orb, unless you tell it. So if you're fusing 20% quality items, make sure to perform step 1 when the item is 20% quality (and don't change quality between fuses)!

There's also a short ###VIDEO LINK### video showing the process in action.

Note: The tooltips will only show up if your Path of Exile is in *Windowed* or *Windowed Fullscreen* mode!

###Place for further information, questions, feedback:
Please use the forum thread: ###FORM THREAD LINK###

If you find any bugs, feel free to open an issue here!