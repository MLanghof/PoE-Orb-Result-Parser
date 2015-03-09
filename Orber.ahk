
; Name of the file that stores the last recorded item.
LastClipboard_FileName := "LastClipboardItem.clip"


#Persistent
Menu, Tray, Icon, Fuse.ico
LINK_CHAR := "-"
PreviousLinks := ""

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setup the mode in which files are written. ;;
;;   AUTO: Guesses on a best-effort basis.    ;;
;;   FUSE: One file per item name.            ;;
;;   ROLL: One file per item with same        ;;
;;         base, sockets and links.           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FileMode := "FUSE"

; Look up what the last parsed item was, so we can continue where we ended.
ClipSaved := ClipboardAll
FileRead, Clipboard, *c C:\Company Logo.clip ; Note the use of *c, which must precede the filename. 

ParseClipboardItem(LastName, LastRarity, LastAffixes, LastSocketCount, LastLinkSetup, LastItemlevel, LastQuality)

Clipboard := ClipSaved   ; Restore the original clipboard. Note the use of Clipboard (not ClipboardAll).
ClipSaved =   ; Free the memory in case the clipboard was very large.

return



ParseClipboardItem(ByRef Name, ByRef Rarity, ByRef Affixes, ByRef SocketCount, ByRef LinkSetup, ByRef Itemlevel, ByRef Quality)
{
	Loop, Parse, Clipboard, `n, `r
	{
		Line := A_LoopField
		If A_Index = 1
		{
			If (Line != "Rarity: Rare") and (Line != "Rarity: Unique") and (Line != "Rarity: Magic") and (Line != "Rarity: Normal")
			{
				ToolTip Not a normal`, magic`, rare or unique item!
				Sleep 1500
				ToolTip  ; Turn off the tip.
				return
			}
			Rarity := SubStr(Line, 9)
		}
		If A_Index = 2
			Name := Line
		If A_Index = 3
		{
			; For magic and rare items, include the second line
			If (Line != "--------" and Rarity != "Unique")
				Name := Name . ", " . Line
		}
		
		If InStr(Line, "Sockets:")
		{
			LinkSetup := 0
			SocketCount := (StrLen(Line) - 9) // 2
			
			CurrentLinkLength := 1
			Loop, Parse, Line
			{
				If (A_Index <= 10)
					Continue
					
				If (A_LoopField = LINK_CHAR)
				{
					CurrentLinkLength++
				}
				If (A_LoopField = A_Space)
				{
					LinkSetup := linkSetup * 10 + CurrentLinkLength
					CurrentLinkLength := 1
				}
			}
			; Apparently all socket outputs end with a space after the last socket, so no extra line of "finishing" the last link is necessary. Lazy GGG...
		}
		
		
		If InStr(Line, "Itemlevel:")
		{
			Itemlevel := SubStr(Line, 12)
			AffixStart := A_Index + 2
		}
		
		If (AffixStart and A_Index == AffixStart)
			PotentialImplicit := Line
			
		If (AffixStart and A_Index == AffixStart + 1)
		{
			If (Line != "--------") ; No implicit
				Affixes := PotentialImplicit . "`n" . Line
			Else
				Implicit := PotentialImplicit
		}
		
		If (AffixStart and A_Index > AffixStart + 1)
		{
			If (Line == "--------") ; Something else below (like corrupted or flask info)
				Break
			Affixes .= (Affixes ? "`n" : "") . Line
		}
	}
}


OnClipboardChange:
Filename := "Empty"
Name := ""
Rarity := ""
HasSockets := False
LinkSetup := 0
BaseItem := ""
Affixes := ""
Quality := 0

ParseClipboardItem(Name, Rarity, Affixes, SocketCount, LinkSetup, Itemlevel, Quality)

If (Rarity == "")
	return


If (FileMode == "AUTO")
{
	; Complex logic D:
	
}
Else
	Mode := FileMode

If (Mode == "FUSE")
{
	If (LastLinkSetup == LinkSetup)
	{
	; This is not foolproof, but I have no itentions to make it so.
		If (LastName == Name and LastItemlevel == Itemlevel and LastQuality == Quality)
		{
			MsgBox, 0, , Warning: Same links as previous result (impossible), not writing to file.
		}
	}
	
	FileName := Name . "_i" . Itemlevel . "_q" . Quality
	If (!FileExist(FileName . ".fus"))
		FileAppend, Fuse/Jewl results: %Name%` (ilvl %Itemlevel%`n, ql %Quality%), %FileName%.fus
	
	FileAppend, %LinkSetup%`n, %FileName%.fus
}
Else If (Mode == "ROLL")
{
	
	FileAppend, %LinkSetup%`n, %FileName%.fus
}


ToolTip %linkSetup%
Sleep 1000
ToolTip  ; Turn off the tip.

;ToolTip %Affixes%
;Sleep 2000
;ToolTip  ; Turn off the tip.

FileAppend, %ClipboardAll%, %LastClipboard_FileName%

LastName := Name
LastRarity := Rarity
LastAffixes := Affixes
LastSocketcount := SocketCount
LastLinkSetup := LinkSetup
LastItemlevel := Itemlevel



return