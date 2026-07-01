-- ============================================================
-- Tab Finder  (native AppleScriptObjC, no dependencies)
-- A floating search window over all open Safari + Chrome tabs.
--   * type any text -> filters live (matches title, url, browser)
--   * up/down arrows -> move selection
--   * Return -> jump to highlighted tab
--   * Esc -> cancel
--   * double-click a row -> jump
-- Bind it to a hotkey with a Shortcut: see README.md.
-- MIT licensed.
-- ============================================================

use framework "Foundation"
use framework "AppKit"
use scripting additions

property theApp : missing value
property theWindow : missing value
property theSearch : missing value
property theTable : missing value

property allRows : {} -- records {ttl, ur, w, t}
property shownIdx : {} -- 1-based indices into allRows currently visible
property resultIndex : 0 -- 1-based index into allRows of choice; 0 = cancelled
property finishing : false

on run
	set my allRows to {}
	set my shownIdx to {}
	set my resultIndex to 0
	set my finishing to false

	gatherTabs()
	if (count of allRows) is 0 then
		display notification "No open browser tabs." with title "Tab Finder"
		return
	end if

	buildAndShow()

	if resultIndex > 0 then
		set r to item resultIndex of allRows
		jumpTo(br of r, w of r, t of r)
	end if
end run

-- ---- gather every tab -------------------------------------------------
on gatherTabs()
	set collected to {}
	-- Safari (only if running, so we never launch it)
	if application "Safari" is running then
		tell application "Safari"
			repeat with wi from 1 to (count of windows)
				try
					set tc to count of tabs of window wi
					repeat with ti from 1 to tc
						set tb to tab ti of window wi
						set nm to name of tb
						if nm is missing value then set nm to "(untitled)"
						set u to ""
						try
							set u to (URL of tb) as text
						end try
						set end of collected to {br:"Safari", ttl:nm, ur:u, w:wi, t:ti}
					end repeat
				end try
			end repeat
		end tell
	end if
	-- Google Chrome (only if running)
	if application "Google Chrome" is running then
		tell application "Google Chrome"
			repeat with wi from 1 to (count of windows)
				try
					set tc to count of tabs of window wi
					repeat with ti from 1 to tc
						set tb to tab ti of window wi
						set nm to title of tb
						if nm is missing value then set nm to "(untitled)"
						set u to ""
						try
							set u to (URL of tb) as text
						end try
						set end of collected to {br:"Chrome", ttl:nm, ur:u, w:wi, t:ti}
					end repeat
				end try
			end repeat
		end tell
	end if
	set my allRows to collected
	-- show all initially
	set idxs to {}
	repeat with i from 1 to count of allRows
		set end of idxs to i
	end repeat
	set my shownIdx to idxs
end gatherTabs

-- ---- filtering --------------------------------------------------------
on applyFilter(queryText)
	set q to (queryText as text)
	set idxs to {}
	if q is "" then
		repeat with i from 1 to count of allRows
			set end of idxs to i
		end repeat
	else
		set nsQ to current application's NSString's stringWithString:q
		repeat with i from 1 to count of allRows
			set r to item i of allRows
			set hay to (br of r) & " " & (ttl of r) & " " & (ur of r)
			set nsHay to current application's NSString's stringWithString:hay
			set rng to nsHay's rangeOfString:nsQ options:1 -- case-insensitive
			if ((rng's |length|) as integer) > 0 then
				set end of idxs to i
			end if
		end repeat
	end if
	set my shownIdx to idxs
	theTable's reloadData()
	if (count of shownIdx) > 0 then
		theTable's selectRowIndexes:(current application's NSIndexSet's indexSetWithIndex:0) byExtendingSelection:false
	end if
end applyFilter

-- ---- table data source / view ----------------------------------------
on numberOfRowsInTableView:aTableView
	return count of shownIdx
end numberOfRowsInTableView:

on tableView:aTableView viewForTableColumn:aColumn row:aRow
	set idx to item ((aRow as integer) + 1) of shownIdx
	set r to item idx of allRows
	set theText to (br of r) & "   ·   " & (ttl of r) & "    —    " & (ur of r)
	set tf to aTableView's makeViewWithIdentifier:"cell" owner:me
	if tf is missing value then
		set tf to current application's NSTextField's alloc()'s initWithFrame:(current application's NSMakeRect(0, 0, 600, 18))
		tf's setIdentifier:"cell"
		tf's setBordered:false
		tf's setDrawsBackground:false
		tf's setEditable:false
		tf's setSelectable:false
		tf's setLineBreakMode:4 -- truncating tail
		tf's setFont:(current application's NSFont's systemFontOfSize:13)
	end if
	tf's setStringValue:theText
	return tf
end tableView:viewForTableColumn:row:

-- ---- live typing + key handling in the search field ------------------
on controlTextDidChange:aNotification
	set fld to aNotification's object()
	applyFilter(fld's stringValue() as text)
end controlTextDidChange:

on control:aControl textView:aTextView doCommandBySelector:aSelector
	set sel to aSelector as text
	if sel is "cancelOperation:" or sel is "cancel:" then
		cancelOut()
		return true
	else if sel is "insertNewline:" then
		confirmSelection()
		return true
	else if sel is "moveDown:" then
		moveSel(1)
		return true
	else if sel is "moveUp:" then
		moveSel(-1)
		return true
	end if
	return false
end control:textView:doCommandBySelector:

on moveSel(delta)
	set n to count of shownIdx
	if n is 0 then return
	set cur to (theTable's selectedRow()) as integer
	set newRow to cur + delta
	if newRow < 0 then set newRow to 0
	if newRow > (n - 1) then set newRow to n - 1
	theTable's selectRowIndexes:(current application's NSIndexSet's indexSetWithIndex:newRow) byExtendingSelection:false
	theTable's scrollRowToVisible:newRow
end moveSel

-- ---- double click ----------------------------------------------------
on tableDoubleClick:sender
	confirmSelection()
end tableDoubleClick:

-- ---- confirm / cancel ------------------------------------------------
on confirmSelection()
	set selRow to (theTable's selectedRow()) as integer
	if selRow < 0 then
		if (count of shownIdx) > 0 then
			set my resultIndex to (item 1 of shownIdx)
		else
			set my resultIndex to 0
		end if
	else
		set my resultIndex to (item (selRow + 1) of shownIdx)
	end if
	set my finishing to true
	theWindow's orderOut:me
	stopApp()
end confirmSelection

on cancelOut()
	set my resultIndex to 0
	set my finishing to true
	theWindow's orderOut:me
	stopApp()
end cancelOut

on windowWillClose:aNotification
	if finishing is false then
		set my resultIndex to 0
		set my finishing to true
		stopApp()
	end if
end windowWillClose:

on stopApp()
	theApp's |stop|:me
	set dummyEvent to current application's NSEvent's otherEventWithType:15 location:(current application's NSMakePoint(0, 0)) modifierFlags:0 timestamp:0 windowNumber:0 context:(missing value) subtype:0 data1:0 data2:0
	theApp's postEvent:dummyEvent atStart:true
end stopApp

-- ---- build + show the window -----------------------------------------
on buildAndShow()
	set my theApp to current application's NSApplication's sharedApplication()
	theApp's setActivationPolicy:1 -- accessory (no dock icon)

	set winW to 720
	set winH to 440
	set styleMask to 11 -- titled(1)+closable(2)+resizable(8)
	set frameRect to current application's NSMakeRect(0, 0, winW, winH)
	set my theWindow to current application's NSWindow's alloc()'s initWithContentRect:frameRect styleMask:styleMask backing:2 defer:false
	theWindow's setTitle:"Tab Finder  —  Safari + Chrome"
	theWindow's setLevel:3 -- floating window level
	theWindow's |center|()
	theWindow's setReleasedWhenClosed:false
	theWindow's setDelegate:me

	set contentView to theWindow's contentView()
	set pad to 14
	set sfH to 28

	set sfRect to current application's NSMakeRect(pad, winH - sfH - pad, winW - 2 * pad, sfH)
	set my theSearch to current application's NSSearchField's alloc()'s initWithFrame:sfRect
	theSearch's setAutoresizingMask:10 -- width-sizable(2)+min-Y-margin(8)
	theSearch's setDelegate:me
	(contentView's addSubview:theSearch)

	set svRect to current application's NSMakeRect(pad, pad, winW - 2 * pad, winH - sfH - 3 * pad)
	set scrollView to current application's NSScrollView's alloc()'s initWithFrame:svRect
	scrollView's setHasVerticalScroller:true
	scrollView's setAutoresizingMask:18 -- width-sizable(2)+height-sizable(16)
	scrollView's setBorderType:2 -- bezel border

	set my theTable to current application's NSTableView's alloc()'s initWithFrame:(scrollView's |bounds|())
	set col to current application's NSTableColumn's alloc()'s initWithIdentifier:"tab"
	col's setEditable:false
	col's setWidth:(winW - 2 * pad - 4)
	(theTable's addTableColumn:col)
	theTable's setHeaderView:(missing value)
	theTable's setRowHeight:22
	theTable's setDataSource:me
	theTable's setDelegate:me
	theTable's setTarget:me
	theTable's setDoubleAction:"tableDoubleClick:"
	theTable's setAllowsEmptySelection:true
	theTable's setAllowsMultipleSelection:false

	scrollView's setDocumentView:theTable
	(contentView's addSubview:scrollView)

	theTable's reloadData()
	if (count of shownIdx) > 0 then
		theTable's selectRowIndexes:(current application's NSIndexSet's indexSetWithIndex:0) byExtendingSelection:false
	end if

	theApp's activateIgnoringOtherApps:true
	theWindow's makeKeyAndOrderFront:me
	theWindow's makeFirstResponder:theSearch

	theApp's |run|()
end buildAndShow

-- ---- jump to the chosen tab ------------------------------------------
on jumpTo(theBrowser, wi, ti)
	if theBrowser is "Chrome" then
		tell application "Google Chrome"
			-- un-minimize the window (Chrome uses 'minimized'); needs only Automation perm
			set minimized of window wi to false
			set active tab index of window wi to ti
			set index of window wi to 1
			activate
		end tell
	else
		tell application "Safari"
			set targetWindow to window wi
			-- un-minimize the window (Safari uses 'miniaturized')
			set miniaturized of targetWindow to false
			set current tab of targetWindow to tab ti of targetWindow
			set index of targetWindow to 1
			activate
		end tell
	end if
end jumpTo
