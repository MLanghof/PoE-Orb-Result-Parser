; Auto-execute section
#Persistent

IfExist, Fuse.ico
	Menu, Tray, Icon, Fuse.ico

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setup the mode in which files are written.                   ;;
;;   AUTO: Guesses on a best-effort basis.	                    ;;
;;   FUSE: One file per item with same name + sockets.          ;;
;;   JEWL: One file per item with same name.                    ;;
;;   ALTS: One file per item with same base, sockets and links. ;;
;;   CHRM: One file per item with same base, sockets and links. ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FileMode := "AUTO"

return
; End of auto-execute section


; Only react when PoE has focus.
#IfWinActive, Path of Exile ahk_exe PathOfExile.exe

; Using keyboard hook prevents hotkeys from triggering themselves.
#UseHook 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The keycode should allow it to work for non-latin keyboards. ;;
;; If you want to change it and are using a latin keyboard, you ;;
;; can just use the normal AHK hotkey format (like ^n and ^c).	;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Default hotkey for parsing a new item: Ctrl+N
LControl & SC031::
	CtrlCSource := "NewItem"
	Send, ^c
return
; Default hotkey for continued item parsing: Ctrl+C
LControl & SC02E::
	CtrlCSource := "CopyItem"
	Send, ^c
return

OnClipboardChange:
	If (CtrlCSource == "NewItem")
		OnNewItem()
	If (CtrlCSource == "CopyItem")
		OnCopyItem()
	CtrlCSource := "None"
return


OnNewItem()
{
	; Also makes the rest of the function global
	local NewReferenceItem := ParseClipboardItem()
	If (BasicItemCheck(NewReferenceItem) == False)
	{
		MsgBox, Error: Invalid item.`nCouldn't set reference item.
		return
	}
	
	ReferenceItem := NewReferenceItem
	Mode := "NEW"
	
	LastItem := ObjClone(ReferenceItem)
	
	MakeTooltip("  Reference item registered.", 1000)
}


OnCopyItem()
{
	Global
	If (Mode == "") {
		MsgBox, Error: Reference item not set.`nPlease set a reference item with Ctrl+N before using your orbs and collecting the results!
		return
	}
	
	Item := ParseClipboardItem()
	
	If (BasicItemCheck(Item) == False) {
		MakeTooltip("Couldn't parse item.", 1000)
		return
	}
	
	NewMode := GetNewMode(Item, LastItem)
	
	If (NewMode == "DUNNO") ; This will never happen when Mode is "NEW", so no need to handle that separately.
	{
		; This item happens to be identical to the last item. Compare to reference item instead.
		NewMode := GetNewMode(Item, ReferenceItem)
		If (NewMode == "DUNNO") ; This can happen when rolling with alts.
			NewMode := Mode ; Give up.
		; Otherwise it will be handled properly by the below stuff.
	}
	
	If (NewMode == "ERROR")
		return ; Message should already be shown in GetNewMode().
	
	
	If (FileMode == "AUTO")
	{
		If (Mode == "NEW")
			; First item after resetting
			Mode := NewMode
		Else
			If (Mode != NewMode) {
				MsgBox, Error: Wrong orb used.`nPlease set a new reference item when collecting results for a different project.
				return
			}
			;Otherwise mode doesn't change
	}
	Else
		If (NewMode != FileMode) {
			MsgBox, Error: You used a different orb than you set manually with FileMode.
			return
		}
	
	
	
	Filename := ""

	If (Mode == "FUSE")
	{
		If (Item.LinkSetup == LastItem.LinkSetup)
		{
			MsgBox, Error: Same links as previous result (impossible)`, not writing to file.
			return
		}
		
		FileName := ReferenceItem.Name . "_i" . ReferenceItem.Itemlevel . "_q" . ReferenceItem.Quality . ".fus"
		If (!FileExist(FileName))
			FileAppend, % "Fuse results: " . ReferenceItem.Name . " (ilvl " . ReferenceItem.Itemlevel . ", ql " . ReferenceItem.Quality . ")`n", %FileName%
		
		FileAppend, % Item.LinkSetup . "`n", %FileName%
		
		MakeTooltip("  " . Item.LinkSetup, 1000) ; Spaces so the cursor doesn't overlap
	}
	If (Mode == "JEWL")
	{
		If (Item.SocketCount == LastItem.SocketCount)
		{
			MsgBox, Error: Same sockets as previous result (impossible)`, not writing to file.
			return
		}
		
		FileName := ReferenceItem.Name . "_i" . ReferenceItem.Itemlevel . "_q" . ReferenceItem.Quality . ".jwl"
		If (!FileExist(FileName))
			FileAppend, % "Jewl results: " . ReferenceItem.Name . " (ilvl " . ReferenceItem.Itemlevel . ", ql " . ReferenceItem.Quality . ")`n", %FileName%
		
		FileAppend, % Item.SocketCount . "`n", %FileName%
		
		MakeTooltip("  " . Item.SocketCount, 1000) ; Spaces so the cursor doesn't overlap
	}
	If (Mode == "CHRM")
	{
		If (Item.ColorSetup == LastItem.ColorSetup)
		{
			MsgBox, Error: Same colors as previous result (impossible)`, not writing to file.
			return
		}
		
		FileName := ReferenceItem.Name . "_i" . ReferenceItem.Itemlevel . ".crm"
		If (!FileExist(FileName))
			FileAppend, % "Chrom results: " . ReferenceItem.Name
				. " (ilvl " . ReferenceItem.Itemlevel
				. ", requires str/dex/int "
				. ReferenceItem.RequirementStr . "/"
				. ReferenceItem.RequirementDex . "/"
				. ReferenceItem.RequirementInt
				. ")`n", %FileName%
		
		FileAppend, % Item.ColorSetup . "`n", %FileName%
		
		MakeTooltip("  " . Item.ColorSetup, 2000) ; Spaces so the cursor doesn't overlap
	}
	If (Mode == "ALTS")
	{
		If (Item.Rarity == "Normal")
		{
			MsgBox, Rolling... white items? Uhh, no support for blessed orbs yet, sorry.
			return
		}
		
		If (Item.Rarity == "Magic")
		{
			MsgBox, TODO: Implement affix parsing.
			; Parse affixes from the name here.
			;FileAppend, %Tiers%`n, %FileName%.trs
			
		}
		
		If (Item.Rarity == "Rare")
		{
			MsgBox, Sorry, affix parsing of rare items is not implemented yet.
			return
		}
		
		If (Item.Rarity == "Unique")
		{
			MsgBox, Are you divining? Sorry, not supported yet.
			return
		}
	}

	LastItem := ObjClone(Item)
	
	return
}



ParseClipboardItem()
{
	LINK_CHAR := "-"
	Item := new EmptyItem
	
	Loop, Parse, Clipboard, `n, `r
	{
		Line := A_LoopField
		If A_Index = 1
		{
			If (Line != "Rarity: Rare") and (Line != "Rarity: Unique") and (Line != "Rarity: Magic") and (Line != "Rarity: Normal")
			{
				;MakeTooltip(Not a normal`, magic`, rare or unique item!, 1500)
				return
			}
			Item.Rarity := SubStr(Line, 9)
		}
		If A_Index = 2
			Item.Name := Line
		If A_Index = 3
		{
			; For magic and rare items, include the second line
			If (Line != "--------" and Item.Rarity != "Unique")
				Item.Name := Item.Name . ", " . Line
		}
		
		If InStr(Line, "Quality: ")
		{
			; This will always have " (augmented)", so omit that when parsing.
			Item.Quality := SubStr(Line, 11, -13)
		}
		
		If InStr(Line, "Sockets: ")
		{
			Item.SocketCount := (StrLen(Line) - 9) // 2
			
			CurrentLinkLength := 1
			Loop, Parse, Line
			{
				If (A_Index < 10)
					Continue
					
				If (A_LoopField == LINK_CHAR)
				{
					CurrentLinkLength++
				}
				Else If (A_LoopField == A_Space)
				{
					Item.LinkSetup := Item.LinkSetup * 10 + CurrentLinkLength
					CurrentLinkLength := 1
				}
				Else
					Item.ColorSetup .= A_LoopField
			}
			; Apparently all socket outputs end with a space after the last socket, so no extra line of "finishing" the last link is necessary. Lazy GGG...
		}
		
		If InStr(Line, "Str: ")
			Item.RequirementStr := SubStr(Line, 6)
		If InStr(Line, "Dex: ")
			Item.RequirementDex := SubStr(Line, 6)
		If InStr(Line, "Int: ")
			Item.RequirementInt := SubStr(Line, 6)
		
		If InStr(Line, "Itemlevel:")
		{
			Item.Itemlevel := SubStr(Line, 12)
			AffixStart := A_Index + 2
		}
		
		If (AffixStart and A_Index == AffixStart)
			PotentialImplicit := Line
			
		If (AffixStart and A_Index == AffixStart + 1)
		{
			If (Line != "--------") ; No implicit
				Item.Affixes := PotentialImplicit . "`n" . Line
			Else
				Item.Implicit := PotentialImplicit
		}
		
		If (AffixStart and A_Index > AffixStart + 1)
		{
			If (Line == "--------") ; Something else below (like corrupted or flask info)
				Break
			Item.Affixes .= (Item.Affixes ? "`n" : "") . Line
		}
	}
	Item.Sane := True
	return Item
}


GetNewMode(NewItem, OldItem)
{
	global
	MaybeAlts := 0
	MaybeJewl := 0
	MaybeFuse := 0
	MaybeChrm := 0
	
	If (NewItem.Rarity != OldItem.Rarity)
	{
		MsgBox, Error: Invalid orb used.`nNo transmute/regal/scour(?)/chance support yet.
		return "ERROR"
	}
		
	If (NewItem.Name != OldItem.Name)
		MaybeAlts := 1
	
	If (NewItem.SocketCount != OldItem.SocketCount)
		MaybeJewl := 1
	Else
	{
		; When sockets change, links and colors will always change.
		If (NewItem.LinkSetup != OldItem.LinkSetup) 
			MaybeFuse := 1
		If (NewItem.ColorSetup != OldItem.ColorSetup)
			MaybeChrm := 1
	}
	PossibleModeCount := MaybeAlts + MaybeJewl + MaybeFuse + MaybeChrm
	If (PossibleModeCount == 0)
		If (Mode == "NEW")
		{
			; This is the first item after the reference was set.
			MsgBox, Error: Can't figure out what orb you used (nothing changed?)...
			return "ERROR"
		}
		Else
			; No way to judge in the case where we arrive back at the reference/previous item.
			return "DUNNO"
	Else If (PossibleModeCount > 1)
		If (FileMode == "AUTO")
		{
			MsgBox, Error: Mode matching failed.`nMore than one orb must have been used`, or you tried logging a different item than the reference item.
			return "ERROR"
		}
		Else
			; Even if it's ambiguous, we'll let it slide.
			return "DUNNO" ; TODO: Investigate whether this is a good idea.
	Else ; Precisely one mode active.
	{
		NewMode := ""
		NewMode := (MaybeAlts ? "ALTS" : NewMode)
		NewMode := (MaybeJewl ? "JEWL" : NewMode)
		NewMode := (MaybeFuse ? "FUSE" : NewMode)
		NewMode := (MaybeChrm ? "CHRM" : NewMode)
	}
	return NewMode
}


BasicItemCheck(Item)
{
	If (Item.Sane == False)
		return False
	If (Item.Rarity == "")
		return False
}


IsPoEActive()
{
	IfWinActive, Path of Exile ahk_exe PathOfExile.exe
		return True
	return False
}

class EmptyItem
{
	Name := ""
	Rarity := ""
	Implicit := ""
	Affixes := ""
	SocketCount := 0
	LinkSetup := 0
	ColorSetup := ""
	RequirementStr := 0
	RequirementDex := 0
	RequirementInt := 0
	Itemlevel := 0
	Quality := 0
	Sane := False
}

MakeTooltip(Message, Duration)
{
	ToolTip, %Message%
	SetTimer, TooltipTimer, % -Duration
}

TooltipTimer:
	ToolTip
return