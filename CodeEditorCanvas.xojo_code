#tag Class
Protected Class CodeEditorCanvas
Inherits TextInputCanvas
	#tag Event
		Function BaselineAtIndex(index as integer) As integer
		  
		  
		  dbglog currentmethodname
		End Function
	#tag EndEvent

	#tag Event
		Function CharacterAtPoint(x as integer, y as integer) As integer
		  //  Triggers the user's FireCharacterAtPoint event. The user should return the
		  //  zero-based character index that exists at the given point in view-local 
		  //  coordinates.
		  // 
		  // Gets: x - the x position
		  //       y - the y position
		  // 
		  // Returns: the zero-based character index closest to the point
		  
		  dbglog currentmethodname
		  
		  
		End Function
	#tag EndEvent

	#tag Event
		Sub DiscardIncompleteText()
		  //  Triggers the user's DiscardIncompleteText event. This is called when the
		  //  system wishes to discard the incomplete text.
		  // 
		  // Gets: nothing
		  // 
		  // Returns: nothing
		  
		  // EditLog CurrentMethodName
		  
		  dbglog currentmethodname
		End Sub
	#tag EndEvent

	#tag Event
		Function DoCommand(command as string) As boolean
		  // text system default binding are in /System/Library/Frameworks/AppKit.framework/Resources/StandardKeyBinding.dict.
		  // to look at these grab a copy of https://en.freedownloadmanager.org/Mac-OS/KeyBindingsEditor-FREE.html
		  //                      since its not posted to https://github.com/gknops?tab=repositories
		  //
		  // most of these map to a method in NSResponder.h
		  
		  
		  // note we equate "forward" with "right"
		  // and "back" with "left" which assumes
		  // left to right writing systems
		  
		  Dim handled As Boolean 
		  Dim requiresRedraw As Boolean = False
		  
		  Select Case command
		    // 
		    // // NSResponder: Selection movement and scrolling
		  Case CmdMoveForward, CmdMoveRight // assumes left to right writing so "forward" is "to the right"
		    
		    If HasSelection Then
		      ResetSelStart
		    Else
		      mInsertionPosition = Min(mInsertionPosition + 1, Len(mTextBuffer))
		    End If
		    
		    dbglog " insertion pos = " + Str(mInsertionPosition)
		    requiresRedraw = True
		    handled = True
		    
		  Case CmdMoveForwardAndModifySelection, CmdMoveRightAndModifySelection
		    
		    // on macOS this will set which one gets altered !
		    // if the FIRST press after setting the selection is a left then this moves "the lower bounds" - generally the selStart
		    // if the FIRST press after setting the selection is a right then this moves "the upper bounds" - generally the insertion point
		    If mWhichToAlter = Selections.None Then
		      mWhichToAlter = Selections.UpperBound
		    End If
		    
		    SetSelStart
		    
		    If mWhichToAlter = selections.UpperBound Then
		      mInsertionPosition = Min(mInsertionPosition + 1, Len(mTextBuffer))
		      dbglog " insertion pos = " + Str(mInsertionPosition)
		    Else
		      mSelStartPosition = Min(mSelStartPosition + 1, Len(mTextBuffer))
		      dbglog " sel start pos = " + Str(mSelStartPosition)
		    End If
		    
		    requiresRedraw = True
		    handled = True
		    
		  Case CmdMoveLeft, CmdMoveBackward // assumes left to right writing
		    If HasSelection Then
		      mInsertionPosition = mSelStartPosition
		      ResetSelStart
		    Else
		      mInsertionPosition = Max(mInsertionPosition - 1, 0)
		    End If
		    
		    dbglog " insertion pos = " + Str(mInsertionPosition)
		    requiresRedraw = True
		    handled = True
		    
		  Case CmdMoveLeftAndModifySelection, CmdMoveBackwardAndModifySelection
		    
		    // on macOS this will set which one gets altered !
		    // if the FIRST press after setting the selection is a left then this moves "the lower bounds" - generally the selStart
		    // if the FIRST press after setting the selection is a right then this moves "the upper bounds" - generally the insertion point
		    If mWhichToAlter = selections.none Then
		      mWhichToAlter = Selections.LowerBound
		    End If
		    
		    SetSelStart
		    
		    If mWhichToAlter = selections.UpperBound Then
		      mInsertionPosition = Min(mInsertionPosition - 1, Len(mTextBuffer))
		      dbglog " insertion pos = " + Str(mInsertionPosition)
		    Else
		      mSelStartPosition = Max(mSelStartPosition - 1, 0)
		      dbglog " sel start pos = " + Str(mSelStartPosition)
		    End If
		    
		    
		    dbglog " sel start pos = " + Str(mSelStartPosition)
		    requiresRedraw = True
		    handled = True
		    
		  Case CmdMoveUp, CmdMoveUpAndModifySelection
		    If Keyboard.ShiftKey Then
		      
		      If mWhichToAlter = selections.none Then
		        mWhichToAlter = Selections.LowerBound
		      End If
		      
		      SetSelStart
		      
		    Else
		      
		      If HasSelection Then
		        mInsertionPosition = mSelStartPosition
		        ResetSelStart
		      Else
		        ResetSelStart
		      End If
		    End If
		    
		    Dim line, column As Integer
		    PositionToLineAndColumn(mInsertionPosition, line, column)
		    #If targetmacOS
		      If line = 0 And column > 0 Then
		        column = 0
		      End If
		    #EndIf
		    
		    line = Max(line - 1, 0)
		    If column > Len(mLines(line)) Then
		      column =  Len( mlines(line) ) 
		    End If
		    mInsertionPosition = LineColumnToPosition(line, column )
		    
		    dbglog " insertion pos = " + Str(mInsertionPosition)
		    requiresRedraw = True
		    handled = True
		    
		    
		  Case CmdMoveDown, CmdMoveDownAndModifySelection
		    If Keyboard.ShiftKey Then
		      
		      If mWhichToAlter = selections.none Then
		        mWhichToAlter = Selections.UpperBound
		      End If
		      
		      SetSelStart
		      
		    Else
		      If HasSelection Then
		        mInsertionPosition = mSelStartPosition
		        ResetSelStart
		      Else
		        ResetSelStart
		      End If
		    End If
		    
		    Dim line, column As Integer
		    PositionToLineAndColumn(mInsertionPosition, line, column)
		    #If targetmacOS
		      If line + 1 > mLines.ubound Then
		        column = Len(mLines(mLines.ubound))
		      End If
		    #EndIf
		    line = Min(line + 1, mLines.ubound)
		    If column > Len(mLines(line)) Then
		      column =  Len( mlines(line) ) 
		    End If
		    mInsertionPosition = LineColumnToPosition(line, column)
		    dbglog " insertion pos = " + Str(mInsertionPosition)
		    
		    requiresRedraw = True
		    handled = True
		    
		  case CmdMoveWordForward
		  case CmdMoveWordBackward
		    
		  Case CmdMoveToBeginningOfLine, CmdMoveToBeginningOfLineAndModifySelection
		    If Keyboard.ShiftKey Then
		      SetSelStart
		    Else
		      ResetSelStart
		    End If
		    
		    MoveToBeginningOfLine
		    
		    requiresRedraw = True
		    handled = True
		    
		  Case CmdMoveToEndOfLine, CmdMoveToEndOfLineAndModifySelection
		    If Keyboard.ShiftKey Then
		      SetSelStart
		    Else
		      ResetSelStart
		    End If
		    
		    MoveToEndOfLine
		    
		    requiresRedraw = True
		    handled = True
		    
		  case CmdMoveToBeginningOfParagraph
		  case CmdMoveToEndOfParagraph
		  case CmdMoveToEndOfDocument
		  case CmdMoveToBeginningOfDocument
		  case CmdPageDown
		  case CmdPageUp
		  case CmdCenterSelectionInVisibleArea
		    // 
		    // // NSResponder: Selection movement and scrolling
		  case CmdMoveBackwardAndModifySelection
		  case CmdMoveForwardAndModifySelection
		  case CmdMoveWordForwardAndModifySelection
		  case CmdMoveWordBackwardAndModifySelection
		    
		    // // NSResponder: Selection movement and scrolling
		  case CmdMoveToBeginningOfLineAndModifySelection
		  case CmdMoveToEndOfLineAndModifySelection
		  case CmdMoveToBeginningOfParagraphAndModifySelection
		  case CmdMoveToEndOfParagraphAndModifySelection
		  case CmdMoveToEndOfDocumentAndModifySelection
		  case CmdMoveToBeginningOfDocumentAndModifySelection
		  case CmdPageDownAndModifySelection
		  case CmdPageUpAndModifySelection
		  case CmdMoveParagraphForwardAndModifySelection
		  case CmdMoveParagraphBackwardAndModifySelection
		    // 
		    // // NSResponder: Selection movement and scrolling (added in 10.3)
		  case CmdMoveWordRight
		  case CmdMoveWordLeft
		    
		  case CmdMoveWordRightAndModifySelection
		  case CmdMoveWordLeftAndModifySelection
		    // 
		    // // NSResponder: Selection movement and scrolling (added in 10.6)
		  Case CmdMoveToLeftEndOfLine, CmdMoveToLeftEndOfLineAndModifySelection
		    If Keyboard.ShiftKey Then
		      SetSelStart
		    Else
		      ResetSelStart
		    End If
		    
		    MoveToBeginningOfLine
		    
		    requiresRedraw = True
		    handled = True
		    
		  Case CmdMoveToRightEndOfLine, CmdMoveToRightEndOfLineAndModifySelection
		    If Keyboard.ShiftKey Then
		      SetSelStart
		    Else
		      ResetSelStart
		    End If
		    
		    MoveToEndOfLine
		    
		    requiresRedraw = True
		    handled = True
		    
		  case CmdMoveToLeftEndOfLineAndModifySelection
		  case CmdMoveToRightEndOfLineAndModifySelection
		    // 
		    // // NSResponder: Selection movement and scrolling
		  case CmdScrollPageUp
		  case CmdScrollPageDown
		  case CmdScrollLineUp
		  case CmdScrollLineDown
		    // 
		    // // NSResponder: Selection movement and scrolling
		  case CmdScrollToBeginningOfDocument
		  case CmdScrollToEndOfDocument
		    // 
		    // // NSResponder: Graphical Element transposition
		  case CmdTranspose
		  case CmdTransposeWords
		    // 
		    // // NSResponder: Selections
		  case CmdSelectAll
		  case CmdSelectParagraph
		  case CmdSelectLine
		  case CmdSelectWord
		    // 
		    // // NSResponder: Insertions and Indentations
		  case CmdIndent
		  case CmdInsertTab
		  case CmdInsertBacktab
		  Case CmdInsertNewline
		    ResetSelStart
		    InsertText(EndOfLine)
		    requiresRedraw = True
		    handled = True
		    
		  Case CmdInsertNewlineIgnoringFieldEditor
		    ResetSelStart
		    InsertText(EndOfLine)
		    requiresRedraw = True
		    handled = True
		    
		  Case CmdInsertLineBreak
		    ResetSelStart
		    InsertText(EndOfLine)
		    requiresRedraw = True
		    handled = True
		    
		  case CmdInsertParagraphSeparator
		  case CmdInsertTabIgnoringFieldEditor
		  case CmdInsertContainerBreak
		  case CmdInsertSingleQuoteIgnoringSubstitution
		  case CmdInsertDoubleQuoteIgnoringSubstitution
		    // 
		    // // NSResponder: Case changes
		  case CmdChangeCaseOfLetter
		  case CmdUppercaseWord
		  case CmdLowercaseWord
		  case CmdCapitalizeWord
		    // 
		    // // NSResponder: Deletions
		  case CmdDeleteForward
		  Case CmdDeleteBackward
		    ResetSelStart
		    If mInsertionPosition > 0 Then
		      mTextBuffer = Left(mTextBuffer, mInsertionPosition - 1) + Mid(mTextBuffer, mInsertionPosition + 1)
		      
		      mInsertionPosition = mInsertionPosition - 1
		      
		      requiresRedraw = True
		    End If
		    handled = True
		    
		  case CmdDeleteBackwardByDecomposingPreviousCharacter
		  case CmdDeleteWordForward
		  case CmdDeleteWordBackward
		  case CmdDeleteToBeginningOfLine
		  case CmdDeleteToEndOfLine
		  case CmdDeleteToBeginningOfParagraph
		  case CmdDeleteToEndOfParagraph
		  case CmdYank
		    // 
		    // // NSResponder: Completion
		  case CmdComplete
		    // 
		    // // NSResponder: Mark/Point manipulation
		  case CmdSetMark
		  case CmdDeleteToMark
		  case CmdSelectToMark
		  case CmdSwapWithMark
		    // 
		    // // NSResponder: Cancellation
		  case CmdCancelOperation
		    // 
		    // // NSResponder: Writing Direction
		  case CmdMakeBaseWritingDirectionNatural
		  case CmdMakeBaseWritingDirectionLeftToRight
		  case CmdMakeBaseWritingDirectionRightToLeft
		  case CmdMakeTextWritingDirectionNatural
		  case CmdMakeTextWritingDirectionLeftToRight
		  case CmdMakeTextWritingDirectionRightToLeft
		    // 
		    // // Not part of NSResponder, something custom we need for Windows
		  case CmdToggleOverwriteMode
		  case CmdCopy
		  case CmdCut
		  case CmdPaste
		  case CmdUndo
		    
		  End Select
		  
		  If handled = False Then
		    dbglog currentmethodname, " unhandled ", command
		  End If
		  
		  If requiresRedraw = True Then
		    Self.invalidate
		  End If
		  
		End Function
	#tag EndEvent

	#tag Event
		Function FontNameAtLocation(location as integer) As string
		  //  Triggers the user's FontNameAtLocation event. The implementor should return
		  //  the font used for rendering the specified character.
		  // 
		  // Gets: location - the zero-based character index
		  // Returns: the font name
		  
		  Dim retVal As String = Self.TextFont
		  
		  dbglog currentmethodname, " ", retVal
		  
		  Return Self.TextFont
		End Function
	#tag EndEvent

	#tag Event
		Function FontSizeAtLocation(location as integer) As integer
		  // FireFontSizeAtLocation
		  // 
		  //  Triggers the user's FontNameAtLocation event. The implementor should return
		  //  the font size used for rendering the specified character.
		  // 
		  // Gets: location - the zero-based character index
		  // Returns: the font size
		  
		  Dim retVal As Double = Self.TextSize
		  
		  dbglog currentmethodname, " ", retVal
		  
		  Return retVal
		  
		End Function
	#tag EndEvent

	#tag Event
		Sub GotFocus()
		  // dbglog currentmethodname
		  
		  mBlinkTimer.Mode = Timer.ModeMultiple
		End Sub
	#tag EndEvent

	#tag Event
		Function IncompleteTextRange() As TextRange
		  //  Triggers the user's FireIncompleteTextRange event. The implementor should return
		  //  the range of the current incomplete text, or nil if there is no incomplete text.
		  // 
		  // Gets: nothing
		  // Returns: the range of incomplete text (as a TextRange)
		  
		  // this gets called frequently when text is being input
		  // this is the "marked text" in cocoa terms
		  // see https://developer.apple.com/documentation/appkit/nstextinputclient?language=objc
		  
		  // we can return NIL if there is no "marked range"
		  // usually this is when you deal with international input
		  
		  dbglog currentmethodname
		  
		  Return Nil // mIncompleteRange
		  
		  
		End Function
	#tag EndEvent

	#tag Event
		Sub InsertText(text as string, range as TextRange)
		  //  Triggers the user's InsertText event. The implementor should replace the content
		  //  in its document at `range` with the given text. If `range` is nil, the 
		  //  implementor should insert the text at its current selection.
		  // 
		  // Gets: text - the text to insert
		  //       range - the content range to replace (may be NULL)
		  // Returns: nothing
		  
		  // dbglog currentmethodname 
		  
		  InsertText(Text, range)
		  
		  Me.Invalidate
		End Sub
	#tag EndEvent

	#tag Event
		Function IsEditable() As boolean
		  //  Triggers the user's IsEditable event. The implementor should return whether
		  //  or not its content can be edited.
		  // 
		  // Gets: nothing
		  // Returns: whether or not the content is editable
		  
		  // can return TRUE and the canvas will then be "editable"
		  // return false and its not
		  
		  // DbgLog CurrentMethodName + " = " + If(ReadOnly, "read only", "editable" )
		  
		  Return mEditable
		  
		  
		End Function
	#tag EndEvent

	#tag Event
		Function KeyFallsThrough(key as string) As boolean
		  //  Triggers the user's KeyFallsThrough event. The implementor should return whether
		  //  or not this key should be passed along to other Xojo code
		  // 
		  // Gets: key - the string containing the keystroke
		  // Returns: whether or not the key should be passed along to the rest of the Xojo runtime
		  
		  // The enter key should fall through so that the
		  // default button is pressed when enter is pressed
		  
		  dbglog currentmethodname
		End Function
	#tag EndEvent

	#tag Event
		Sub LostFocus()
		  // dbglog currentmethodname
		  
		  mBlinkTimer.Mode = Timer.ModeOff
		End Sub
	#tag EndEvent

	#tag Event
		Function MouseDown(x as Integer, y as Integer) As Boolean
		  
		  DoMouseDown(X, Y)
		  
		  Return True
		End Function
	#tag EndEvent

	#tag Event
		Sub MouseDrag(x as Integer, y as Integer)
		  
		  DoMouseDrag(X, y)
		End Sub
	#tag EndEvent

	#tag Event
		Sub MouseMove(X As Integer, Y As Integer)
		  
		  // dbglog currentmethodname
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub MouseUp(x as Integer, y as Integer)
		  
		  // dbglog currentmethodname
		  // 
		End Sub
	#tag EndEvent

	#tag Event
		Function MouseWheel(X As Integer, Y As Integer, deltaX as Integer, deltaY as Integer) As Boolean
		  Dim isNatural As Boolean = True
		  
		  #If targetMacOS
		    
		    Try
		      Declare Function SharedApplication_ Lib "AppKit" Selector "sharedApplication" (class_id As Ptr) As Ptr
		      Declare Function NSClassFromString Lib "AppKit" (aClassName As CFStringRef) As Ptr
		      Declare Function getCurrentEvent Lib "AppKit" Selector "currentEvent" (obj_id As Ptr) As Ptr
		      Declare Function isInverted Lib "AppKit" Selector "isDirectionInvertedFromDevice" (id As Ptr) As Boolean
		      
		      Dim nsclass As ptr = NSClassFromString("NSApplication")
		      Dim nsapp As ptr = SharedApplication_(nsclass)
		      Dim currentevent As ptr = getCurrentEvent(nsapp)
		      
		      isNatural = isInverted(currentevent)
		      
		    Catch objx As ObjCException
		      Break // ONLY call this IN a mousewheel event !
		    End Try
		    
		    If isNatural Then
		      deltaX = -1 * deltaX
		      deltaY = -1 * deltaY
		    End If
		  #EndIf
		  
		  // clamp values so we dont scroll "the top" way down, but it can move up out of view
		  // clamp values so we dont scroll "the left" way right, but it can move left out of view
		  mHScrollValue = Min(0, mHScrollValue + deltaX)
		  mVScrollValue = Min(0, mVScrollValue + deltaY)
		  
		  // clamp values so we dont scroll "the bottom" way up out of view
		  Dim p As picture = GetMeasuringPicture()
		  
		  // dbglog currentmethodname, " deltaX:" , deltaX, " deltaY:" , deltaY, " natural:", isNatural, " scrollX:" , mHScrollValue , " scrollY:" , mVScrollValue
		  
		  Return True
		  
		End Function
	#tag EndEvent

	#tag Event
		Sub Paint(g as Graphics, areas() as object)
		  #Pragma unused g
		  #Pragma unused areas
		  
		  DoDraw(G, areas)
		  
		End Sub
	#tag EndEvent

	#tag Event
		Function RectForRange(byref range as TextRange) As REALbasic.Rect
		  //  Triggers the user's RectForRange event. The implementor should return the
		  //  rectangle occupied by the given range, relative to the control. If needed,
		  //  the implementor can adjust the range to represent the text that was actually
		  //  represented in the range (to account for word wrapping or other client-side
		  //  features).
		  
		  // 
		  // Gets: range - the requested text range
		  // Returns: the rect the text takes in the control
		  
		  return GetRectForRange(range)
		End Function
	#tag EndEvent

	#tag Event
		Function SelectedRange() As TextRange
		  //  Triggers the user's SelectedRange event. The implementor should return a valid
		  //  range specifying which portion of the content is selected.
		  // 
		  // Gets: nothing
		  // Returns: the range of the selection
		  
		  return GetSelectedRange()
		End Function
	#tag EndEvent

	#tag Event
		Sub SetIncompleteText(text as string, replacementRange as TextRange, relativeSelection as TextRange)
		  //  Triggers the user's SetIncompleteText event. This is fired when the system
		  //  has started (or is continuing) international text input and wishes to display
		  //  'incomplete text'. Incomplete text (marked text, in Cocoa terms) is a temporary
		  //  string displayed in the text during composition of the final input and is
		  //  not actually part of the content until it has been committed (via InsertText).
		  //  
		  // Gets: text - the marked text (replaces any previous marked text)
		  //       replacementRange - the range of text to replace
		  //       relativeSelection - the new selection, relative to the start of the marked
		  //                           text
		  // Returns: nothing
		  
		  dbglog currentmethodname
		End Sub
	#tag EndEvent

	#tag Event
		Function TextForRange(range as TextRange) As string
		  //  Triggers the user's TextForRange event. The implementor should return the substring
		  //  of its content at the given range.
		  // 
		  // Gets: range - the range of text to return
		  // Returns: the substring of the content
		  
		  return GetTextForRange(range)
		  
		End Function
	#tag EndEvent

	#tag Event
		Function TextLength() As integer
		  //  Triggers the user's TextLength event. The implementor should return the length
		  //  of its content (in characters).
		  //
		  // Gets: nothing
		  // Returns: the content length
		  
		  return GetTextLength()
		End Function
	#tag EndEvent


	#tag MenuHandler
		Function EditClear() As Boolean Handles EditClear.Action
		  // the Edit > Delete menu item
		  dbglog currentmethodname
		  
		  InsertText("")
		  
		  Return True
		  
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function EditCopy() As Boolean Handles EditCopy.Action
		  dbglog currentmethodname
		  
		  Dim c As New Clipboard
		  
		  c.Text = SelectedText()
		  
		  Return True
		  
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function EditCut() As Boolean Handles EditCut.Action
		  dbglog currentmethodname
		  
		  Dim c As New Clipboard
		  
		  c.Text = SelectedText()
		  
		  InsertText("")
		  
		  Return True
		  
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function EditPaste() As Boolean Handles EditPaste.Action
		  dbglog currentmethodname
		  
		  dbglog currentmethodname
		  
		  Dim c As New Clipboard
		  
		  InsertText( c.Text )
		  
		  Return True
		  
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function EditSelectAll() As Boolean Handles EditSelectAll.Action
		  dbglog currentmethodname
		  
		  mSelStartPosition = 0
		  mInsertionPosition = mTextBuffer.Length
		  
		  Me.Invalidate
		  
		  Return True
		  
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function EditUndoX() As Boolean Handles EditUndoX.Action
		  dbglog currentmethodname
		  
		  Return True
		  
		End Function
	#tag EndMenuHandler


	#tag Method, Flags = &h0
		Sub AppendText(toAppend as string)
		  
		  ResetSelStart
		  
		  mTextBuffer = mTextBuffer + toAppend
		  
		  mInsertionPosition = mTextBuffer.Len + 1
		  
		  Me.Invalidate
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub blinkTimerAction(instance as Timer)
		  mCursorVisible = Not mCursorVisible
		  
		  Self.invalidate
		  
		  // dbglog CurrentMethodName + " cursor visible = " + Str(mCursorVisible)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CharPosAtXY(x as integer, y as integer) As integer
		  Dim line, col As Integer
		  
		  XYToLineColumn( mMeasuringPic.Graphics, x, y, line, col)
		  
		  Return LineColumnToPosition(line, col)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  // Calling the overridden superclass constructor.
		  Super.Constructor
		  
		  mBlinkTimer = New Timer
		  mBlinkTimer.Mode = Timer.ModeOff
		  mBlinkTimer.Period = 500
		  AddHandler mBlinkTimer.Action, AddressOf blinkTimerAction
		  
		  mVScrollbar = New ScrollBar
		  mVScrollbar.Visible = False
		  mVScrollbar.Width = 15
		  mVScrollbar.Height = 15
		  mVScrollbar.LineStep = 1
		  mVScrollbar.PageStep = 20
		  AddHandler mVScrollbar.ValueChanged, AddressOf vScrollerChanged
		  
		  mHScrollbar = New ScrollBar
		  mHScrollbar.Visible = False
		  mHScrollbar.Width = 15
		  mHScrollbar.Height = 15
		  mHScrollbar.LineStep = 1
		  mHScrollbar.PageStep = 20
		  AddHandler mHScrollbar.ValueChanged, AddressOf hScrollerChanged
		  
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DbgLog(paramarray msgbits as variant)
		  #If DebugBuild Then
		    
		    If Self.debugMe Then
		      
		      Dim bits() As String
		      For Each bit As Variant In msgbits
		        bits.append bit.StringValue
		      Next
		      
		      System.debuglog Join(bits,"")
		      
		    End If
		    
		  #EndIf
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DoDraw(G as graphics, areas() as object)
		  #Pragma unused g
		  #Pragma unused areas
		  
		  #If DebugBuild = False
		    #Pragma BackgroundTasks False
		    #Pragma BoundsChecking False
		    #Pragma BreakOnExceptions False
		    #Pragma NilObjectChecking False
		    #Pragma StackOverflowChecking False
		  #EndIf
		  
		  g.forecolor = &cFF000000
		  g.FillRect 0, 0, g.Height, g.width
		  
		  // our text buffer MAY have multiple lines in it so lets 
		  // do the blindingly lazy and ReplaceLineEndings 
		  // and split on line endings and just draw each line
		  
		  mlines = Split( ReplaceLineEndings(mTextBuffer, EndOfLine), EndOfLine )
		  
		  // do we need vertical scrollbar ??????????
		  If (mLines.ubound+1)*g.TextSize > Me.height Then
		    // DbgLog CurrentMethodName, " needs vertical scroller"
		  End If
		  // DbgLog CurrentMethodName, " needs horizontal scroller"
		  
		  g.ClearRect 0, 0, g.Height, g.width
		  
		  // ok now ... draw away !
		  
		  g.ForeColor = Self.TextColor
		  g.TextFont = Self.TextFont
		  g.TextUnit = CType(Self.TextUnit, REALbasic.FontUnits)
		  g.TextSize = Self.TextSize
		  g.Underline = Self.Underline
		  g.Bold = Self.Bold
		  g.Italic = Self.Italic
		  
		  mCachedTextAscent = g.TextAscent
		  mCachedTextHeight = g.TextHeight
		  
		  Dim drawAtX As Double
		  Dim drawAtY As Double
		  
		  drawAtY = g.TextAscent + mVScrollValue
		  
		  Dim drawnCount As Integer
		  
		  Dim startSelection As Integer = -1
		  Dim endSelection As Integer = -1
		  
		  If mSelStartPosition >= 0 Then
		    startSelection = Min(mSelStartPosition, mInsertionPosition)
		    endSelection = Max(mSelStartPosition, mInsertionPosition)
		  End If
		  
		  For i As Integer = 0 To mlines.ubound
		    
		    If drawAtY + g.TextHeight < 0 Then
		      // do nothing
		    Else
		      drawAtX = 0 + mHScrollValue
		      
		      Dim lineContainsSelection As Integer
		      lineContainsSelection = 0
		      If drawnCount <= startSelection And startselection <= drawnCount + Len(mlines(i)) + Len(EndOfLine) Then
		        // line contains the start of the selection
		        lineContainsSelection = 1
		      ElseIf drawnCount <= endSelection And endSelection <= drawnCount + Len(mlines(i)) + Len(EndOfLine) Then
		        // line contains the end of the selection
		        lineContainsSelection = 2
		      ElseIf startSelection <= drawnCount And drawnCount + Len(mlines(i)) + Len(EndOfLine) <= endSelection Then
		        // line is fully selected from start to finish
		        lineContainsSelection = 3
		      End If
		      
		      If startSelection >= 0 And lineContainsSelection > 0 Then
		        
		        Dim beforetext As String
		        Dim middletext As String
		        Dim endText As String
		        Dim selCount As Integer = endSelection - startSelection
		        
		        beforeText = Left( mlines(i), startSelection - drawnCount)
		        middleText = Mid( mlines(i), startSelection - drawnCount + 1, selCount )
		        endtext = Mid( mlines(i), startSelection - drawnCount + 1 + selcount )
		        
		        g.DrawString beforeText, drawAtX, drawAtY
		        drawAtX = drawAtX + g.StringWidth(beforeText)
		        
		        // the highlight rect
		        Dim tmpColor As Color = g.DrawingColor
		        g.DrawingColor = SelectedTextBackgroundColor
		        g.FillRectangle drawAtX, drawAty - g.TextAscent, g.StringWidth(middleText), g.TextHeight
		        g.DrawingColor = tmpColor
		        
		        g.DrawString middleText, drawAtX, drawAtY
		        drawAtX = drawAtX + g.StringWidth(middleText)
		        
		        g.DrawString endtext, drawAtX, drawAtY
		        drawAtX = drawAtX + g.StringWidth(endtext)
		        
		      Else
		        
		        g.DrawString mlines(i), drawAtX, drawAtY
		        
		      End If
		      
		      drawAtX = g.StringWidth(mlines(i))
		      
		    End If
		    
		    drawnCount = drawnCount + Len(mlines(i)) + Len(EndOfLine)
		    
		    // if we're drawing the last line then we probably do not want to advance the Y position 
		    If i < mlines.Ubound Then
		      drawAtY = drawAtY + g.TextHeight
		    End If
		    
		  Next
		  
		  // IF the cursor should be visible then draw it - otherwise dont and the clear above will have done the right thing
		  If mCursorVisible and HasSelection = false Then
		    
		    Dim line, column As Integer
		    
		    PositionToLineAndColumn(mInsertionPosition, line, column)
		    
		    // line col to XY already adjusts for scrolled values
		    Dim drawPosition As REAlbasic.point = LineColumnToXY(g, line, column)
		    
		    Dim blinkertop As Double = drawPosition.Y - g.TextAscent
		    Dim blinkerbottom As Double = drawPosition.Y - g.TextAscent + g.TextHeight
		    Dim blinkerH As Double = drawPosition.X
		    
		    g.DrawLine blinkerH, blinkertop, blinkerH, blinkerbottom
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DoMouseDown(X as integer, Y as integer)
		  // dbglog currentmethodname
		  
		  // double and triple clicks are both TIME & SPACE
		  // if you click move a long way click this should not be a double or triple click
		  
		  // triple click ?
		  If (mClickType = ClickTypes.Double) _
		    And (Ticks - mLastClickTime < DoubleClickInterval) _
		    And ( Abs(x - mLastClickX) < 5) _
		    And ( Abs(y - mLastClickY) < 5)  Then
		    
		    mClickType  = ClickTypes.triple
		    dbglog currentmethodname + " triple click"
		    // double click ?
		  ElseIf (mClickType = ClickTypes.Single) _
		    And (Ticks - mLastClickTime < DoubleClickInterval) _
		    And ( Abs(x - mLastClickX) < 5) _
		    And ( Abs(y - mLastClickY) < 5)  Then
		    
		    mClickType = ClickTypes.Double
		    dbglog currentmethodname + " double click"
		  Else
		    mClickType = ClickTypes.Single
		    // dbglog currentmethodname + " single click"
		  End If
		  
		  mLastClickX = x + Abs(mHScrollValue)
		  mLastClickY = y + Abs(mVScrollValue)
		  
		  mLastClickTime = Ticks
		  
		  Dim p As Picture = GetMeasuringPicture
		  
		  Dim line, col As Integer
		  
		  XYToLineColumn(p.Graphics, x, y, line, col)
		  
		  Select Case mClickType
		    
		  Case ClickTypes.Single
		    
		    Dim tmpPosition As Integer = LineColumnToPosition( line, col )
		    
		    If Keyboard.ShiftKey Then
		      // extend the selection ?
		      If mSelStartPosition < 0 Then
		        dbglog currentmethodname , " single click set sel start "
		        SetSelStart
		      ElseIf tmpPosition < mSelStartPosition Then
		        dbglog currentmethodname , " single click before existing "
		      Else
		        dbglog currentmethodname , " single click extends selection"
		      End If
		      
		    Else
		      
		      ResetSelStart
		      
		      mInsertionPosition = tmpPosition // LineColumnToPosition( line, col )
		      
		    End If
		    
		    
		    dbglog " insert = " , Str(mInsertionPosition) , " sel start = ", Str(mSelStartPosition)
		    
		    Me.invalidate
		  End Select
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DoMouseDrag(X as integer, y as integer)
		  Dim p As Picture = GetMeasuringPicture
		  
		  Dim line, col As Integer
		  
		  XYToLineColumn(p.Graphics, x, y, line, col)
		  
		  // if the selection wasnt started it will be now !
		  // and if it was already we dont alter it
		  SetSelStart
		  
		  mInsertionPosition = LineColumnToPosition(line, col)
		  
		  Me.invalidate
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoubleClickInterval() As Double
		  // returns as double that is the # of TICKS
		  
		  #If TargetMacOS
		    
		    Const CocoaLib As String = "Cocoa.framework"
		    Declare Function NSClassFromString Lib CocoaLib(aClassName As CFStringRef) As ptr
		    Declare Function doubleClickInterval Lib CocoaLib selector "doubleClickInterval" (aClass As ptr) As Double
		    
		    Try
		      Dim RefToClass As Ptr = NSClassFromString("NSEvent")
		      Return doubleClickInterval(RefToClass) * 60
		    Catch err As ObjCException
		      Break
		      #If debugbuild
		        MsgBox err.message
		      #EndIf
		    End
		  #EndIf
		  
		  #If TargetWin32
		    Declare Function GetDoubleClickTime Lib "User32.DLL" () As Integer
		    Try
		      Return GetDoubleClickTime
		    Catch err As ObjCException
		      Break
		      #If debugbuild
		        MsgBox err.message
		      #EndIf
		    End
		  #EndIf
		  
		  Break
		  #If debugbuild
		    MsgBox CurrentMethodName + " Unhandled case"
		  #EndIf
		  Return 0
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetMeasuringPicture() As Picture
		  
		  If mMeasuringPic Is Nil Then
		    
		    mMeasuringPic = Self.TrueWindow.BitmapForCaching(10, 10)
		    
		    mMeasuringPic.Graphics.ForeColor = Self.TextColor
		    mMeasuringPic.Graphics.TextFont = Self.TextFont
		    mMeasuringPic.Graphics.TextUnit = CType(Self.TextUnit, REALbasic.FontUnits)
		    mMeasuringPic.Graphics.TextSize = Self.TextSize
		    mMeasuringPic.Graphics.Underline = Self.Underline
		    mMeasuringPic.Graphics.Bold = Self.Bold
		    mMeasuringPic.Graphics.Italic = Self.Italic
		    
		  End If
		  
		  Return mMeasuringPic
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetRectForRange(range as TextRange) As REALbasic.Rect
		  
		  dbglog currentmethodname + " requested range =[" + Str(range.Location) + ", " + Str(range.Length) + "]"
		  
		  // get the position as a line & column #
		  Dim line, column As Integer
		  PositionToLineAndColumn( range.Location, line, column )
		  
		  Dim p As picture = GetMeasuringPicture
		  
		  // get the x (left) edge and (y) baseline for the position
		  Dim position As REAlbasic.point = LineColumnToXY(p.Graphics, line, column)
		  
		  // now compute the rectangle
		  Dim selectedText As String = Mid(mTextBuffer, range.Location, range.Length)
		  Dim width As Double = p.Graphics.StringWidth( selectedText )
		  Dim top As Double = position.Y - p.Graphics.TextAscent
		  
		  Dim windowBounds As Rect = Self.Window.Bounds
		  
		  Dim rangeRect As New REALbasic.Rect(position.x, top, width, p.Graphics.TextHeight)
		  
		  Return rangeRect
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetSelectedRange() As TextRange
		  
		  Dim startPos As Integer = mInsertionPosition
		  Dim endPos As Integer = mInsertionPosition
		  If mSelStartPosition >= 0 Then
		    startPos = Min(mInsertionPosition, mSelStartPosition)
		    endPos = Max(mInsertionPosition, mSelStartPosition)
		  End If
		  
		  Dim retVal As New TextRange( startPos, endPos - startPos )
		  
		  dbglog currentmethodname , " location :" , retval.Location, " length :" , retval.Length.ToString
		  
		  Return retval
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetTextForRange(range as TextRange) As string
		  
		  Dim retVal As String = mTextBuffer.Mid(range.Location+1, range.Length)
		  
		  dbglog currentmethodname , " [" , retVal , "]"
		  
		  return retVal
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetTextLength() As Integer
		  
		  Dim retVal As Integer = mTextBuffer.Len
		  
		  dbglog currentmethodname, " ", retVal
		  
		  Return retVal
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub hScrollerChanged(instance as ScrollBar)
		  break
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InsertText(theText as string, range as textRange = nil)
		  theText = ReplaceLineEndings(theText, EndOfLine)
		  
		  Dim selectedLength As Integer = 0
		  Dim startPos As Integer = mInsertionPosition
		  Dim endPos As Integer = mInsertionPosition
		  If mSelStartPosition >= 0 Then
		    startPos = Min(mInsertionPosition, mSelStartPosition)
		    endPos = Max(mInsertionPosition, mSelStartPosition)
		    selectedLength = endPos - startPos
		  End If
		  
		  If range Is Nil Then
		    dbglog currentmethodname + "[" + If(theText=EndOfLine,"<EOL>",theText) + "] nil range"
		  Else
		    dbglog currentmethodname + "[" + If(theText=EndOfLine,"<EOL>",theText) + "] range (location, length, end) = [" + Str(range.Location) + " ," + Str(range.Length) + ", " + Str(range.EndLocation) + "]"
		  End If
		  
		  Dim leftText As String = Left(mTextBuffer, startPos)
		  Dim rightText As String = Mid(mTextBuffer, endpos + 1 )
		  
		  dbglog CurrentMethodName + " [" + leftText + "] " + If(theText=EndOfLine,"<EOL>",theText) + "[" + rightText + "]"
		  
		  mTextBuffer = leftText + theText + rightText
		  
		  ResetSelStart
		  
		  mInsertionPosition = startPos + Len(theText)
		  
		  dbglog CurrentMethodName + " insertion position = " + Str(mInsertionPosition)
		  
		  Me.invalidate
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LineColumnToPosition(line as integer, column as integer) As integer
		  // NOTE this is NOT EFFICIENT !!!!!!
		  // since we split things into lines in PAINT and again here
		  // if we really need lines we should figure out how to do this as few times as possible
		  
		  // if line , col exceeds the n entire text buffer then the position should be the end of the buffer
		  
		  mlines = Split( ReplaceLineEndings(mTextBuffer, EndOfLine), EndOfLine )
		  
		  Dim tmpPosition As Integer
		  
		  // count up the lengths of whole lines
		  For i As Integer = 0 To Min(line - 1, mlines.Ubound)
		    tmpPosition = tmpPosition + mlines(i).Len + Len(EndOfLine)
		  Next
		  
		  // plus hte last line we add in just the columns since it may not be the wbole line
		  tmpPosition = tmpPosition + column
		  
		  Return Min(tmpPosition, mTextBuffer.Len)
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LineColumnToXY(g as Graphics, lineNumber as integer, column as Integer) As REALbasic.Point
		  Dim xPos As Double
		  Dim yPos As Double
		  
		  // not this is not EFFICIENT
		  // since we split things into lines in PAINT and again here
		  // if we really need lines we should figure out how to do this as few times as possible
		  
		  mlines = Split( ReplaceLineEndings(mTextBuffer, EndOfLine), EndOfLine )
		  
		  Dim X As Double 
		  Dim Y As Double 
		  
		  Y = y + g.TextAscent 
		  y = y + (g.TextHeight * lineNumber)
		  
		  If lineNumber >= 0 And lineNumber <= mlines.ubound Then
		    Dim lineSeg As String = Left( mlines(lineNumber), column ) 
		    
		    X = g.StringWidth( lineseg )
		  End If
		  
		  x = x + mHScrollValue
		  y = y + mVScrollValue
		  
		  // dbglog CurrentMethodName, " line:" , lineNumber, " column:", column, " x:", Format(x,"-###0.00"), " y:", Format(y,"-###0.00"), " hscroll:" , mHScrollValue, " yScroll:" , mVScrollValue 
		  
		  Return New REALbasic.Point(x, y)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub MoveToBeginningOfLine()
		  Dim line, column As Integer
		  PositionToLineAndColumn(mInsertionPosition, line, column)
		  column = 0
		  mInsertionPosition = LineColumnToPosition(line, column)
		  dbglog " insertion pos = " + Str(mInsertionPosition)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub MoveToEndOfLine()
		  Dim line, column As Integer
		  PositionToLineAndColumn(mInsertionPosition, line, column)
		  
		  column = len( mLines(line) )
		  
		  mInsertionPosition = LineColumnToPosition(line, column)
		  
		  dbglog " insertion pos = " + Str(mInsertionPosition)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub PositionToLineAndColumn(position as integer, byref line as integer, byref column as integer)
		  Dim currPos As Integer = 1
		  line = 0
		  column = 0
		  
		  While currPos < position + 1
		    
		    If mTextBuffer.Mid(currPos,Len(EndOfLine)) = EndOfLine Then
		      line = line + 1
		      column = 0
		      currPos = currPos + Len(EndOfLine)
		    Else
		      column = column + 1
		      currPos = currPos + 1
		    End If
		    
		  Wend
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ResetSelStart()
		  mSelStartPosition = -1
		  mWhichToAlter = Selections.None
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SelectedText() As string
		  
		  
		  Dim selectedRange As TextRange = GetSelectedRange
		  
		  Return GetTextForRange(selectedRange)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetSelStart()
		  // if selStart is already >= 0 then we wont overwrite it
		  If mSelStartPosition < 0 Then
		    // DbgLog CurrentMethodName + " same as insert"
		    mSelStartPosition = mInsertionPosition
		  Else
		    // DbgLog CurrentMethodName + " untouched"
		  End If
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub vScrollerChanged(instance as ScrollBar)
		  break
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub XYToLineColumn(g as Graphics, x as double, y as double, byref lineNumber as integer, byref column as Integer)
		  // Dim xPos As Double
		  // Dim yPos As Double
		  
		  x = x + Abs(mHScrollValue)
		  y = y + Abs(mVScrollValue)
		  
		  // NOTE this is NOT EFFICIENT !!!!!!
		  // since we split things into lines in PAINT and again here
		  // if we really need lines we should figure out how to do this as few times as possible
		  
		  Dim lines() As String = Split( ReplaceLineEndings(mTextBuffer, EndOfLine), EndOfLine )
		  
		  // no lines then ANY click inside our bounds is line 0 column 0 
		  If lines.ubound < 0 Then
		    lineNumber = 0
		    column = 0
		    Return
		  End If
		  
		  Dim lineTopY As Double
		  
		  lineNumber = 0
		  column = 0
		  
		  lineTopY = 0 
		  
		  // so a person may not click right on the baseline and we need to see if the 
		  // click is anywhere from the top of the line to the bottom
		  While lineTopY < Y And lineTopY + g.TextHeight <= Y
		    lineNumber = lineNumber + 1
		    
		    lineTopY = lineTopY + g.TextHeight
		  Wend
		  
		  If lineNumber >= 0 And lineNumber <= lines.ubound Then
		    // ok wo what column does this X represent ?
		    
		    column = 0
		    Dim lineSeg As String = lines(lineNumber).Left(column)
		    While column <= lines(lineNumber).Len And g.StringWidth( lineseg ) < x 
		      column = column + 1
		      lineSeg = lines(lineNumber).Left(column)
		    Wend
		    // column has been incremented once too many times
		    column = column - 1
		    
		  End If
		  
		  
		End Sub
	#tag EndMethod


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  // #pragma todo "implement this !"
			  
			  Return mBackgroundColor
			  
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  // #pragma todo "implement this !"
			  
			  mBackgroundColor = value
			  
			  me.Invalidate
			End Set
		#tag EndSetter
		BackgroundColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mBold
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mBold = value
			  
			  mMeasuringPic = Nil
			  
			  me.Invalidate
			End Set
		#tag EndSetter
		Bold As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return SelLength > 0
			End Get
		#tag EndGetter
		HasSelection As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mItalic
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mItalic = value
			  
			  mMeasuringPic = Nil
			  
			  me.Invalidate
			End Set
		#tag EndSetter
		Italic As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mBackgroundColor As Color
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBlinkTimer As Timer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBold As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCachedTextAscent As double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCachedTextHeight As double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mClickType As ClickTypes
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCursorVisible As boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mEditable As boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHScrollbar As ScrollBar
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHScrollValue As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mInsertionPosition As integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mItalic As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLastClickTime As double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLastClickX As Double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLastClickY As double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLines() As string
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMeasuringPic As Picture
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mmTextBuffer As string
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSelectedTextBackgroundColor As Color
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSelStartPosition As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mShiftClick As boolean
	#tag EndProperty

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  Return mmTextBuffer
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mmTextBuffer = value
			  
			  me.invalidate
			End Set
		#tag EndSetter
		Private mTextBuffer As string
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mTextColor As Color
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTextFont As string
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTextSize As double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTextUnit As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mUnderline As boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mVScrollbar As ScrollBar
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mVScrollValue As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mWhichToAlter As Selections
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return not mEditable
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mEditable = Not Value
			  
			  
			End Set
		#tag EndSetter
		ReadOnly As boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mSelectedTextBackgroundColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mSelectedTextBackgroundColor = value
			  
			  me.Invalidate
			End Set
		#tag EndSetter
		SelectedTextBackgroundColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  // #pragma todo "implement this !"
			  
			  If mSelStartPosition < 0 Then
			    Return 0
			  Else
			    Dim high, low As Integer
			    
			    high = Max(Abs(mInsertionPosition), Abs(mSelStartPosition))
			    low = Min(Abs(mInsertionPosition), Abs(mSelStartPosition))
			    
			    Return high - low
			    
			  End If
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #Pragma todo "implement this !"
			  
			  // set the mSelStart to be ?????????
			  If value <= 0 Then
			    ResetSelStart
			  Else
			    SetSelStart
			    mInsertionPosition = mSelStartPosition + value
			  End If
			  
			End Set
		#tag EndSetter
		SelLength As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  // #pragma todo "implement this !"
			  
			  return mSelStartPosition
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #Pragma todo "implement this !"
			  
			  ResetSelStart
			  
			  mInsertionPosition = Min(Max(0, value), mTextBuffer.Length)
			  
			  SetSelStart
			  
			End Set
		#tag EndSetter
		SelStart As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  // #pragma todo "implement this !"
			  return TextColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  // #pragma todo "implement this !"
			  
			  TextColor = value
			  
			  me.Invalidate
			End Set
		#tag EndSetter
		SelTextColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  #Pragma todo "implement this !"
			  
			  // for now we'll leave the prgam as its a warning but do NOTHING !
			  
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #Pragma todo "implement this !"
			  
			  // for now we'll leave the prgam as its a warning but do NOTHING !
			  // styled text is not supported
			  
			End Set
		#tag EndSetter
		Styled As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return ReplaceLineEndings( mTextBuffer, EndOfLine )
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mTextBuffer = ReplaceLineEndings( value, EndOfLine )
			  
			  me.invalidate
			End Set
		#tag EndSetter
		Text As String
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return TextAlignments.Left
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  // #Pragma todo "implement this !"
			  
			  // we're actually going to ignore this here :)
			  
			End Set
		#tag EndSetter
		TextAlignment As TextAlignments
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mTextColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mTextColor = value
			  
			  me.Invalidate
			End Set
		#tag EndSetter
		TextColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mTextFont
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  
			  mMeasuringPic = Nil
			  
			  mTextFont = value
			  
			  me.Invalidate
			End Set
		#tag EndSetter
		TextFont As string
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mTextSize
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mMeasuringPic = Nil
			  
			  mTextSize = value
			  
			  me.Invalidate
			End Set
		#tag EndSetter
		TextSize As double
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mTextUnit
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mTextUnit = value
			  
			  mMeasuringPic = Nil
			  
			  me.Invalidate
			End Set
		#tag EndSetter
		TextUnit As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mUnderline
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mUnderline = value
			  
			  mMeasuringPic = Nil
			  
			  me.Invalidate
			End Set
		#tag EndSetter
		Underline As boolean
	#tag EndComputedProperty


	#tag Constant, Name = debugMe, Type = Boolean, Dynamic = False, Default = \"true", Scope = Private
	#tag EndConstant


	#tag Enum, Name = ClickTypes, Type = Integer, Flags = &h1
		none=0
		  single=1
		  double=2
		triple=3
	#tag EndEnum

	#tag Enum, Name = Selections, Type = Integer, Flags = &h0
		None
		  UpperBound
		LowerBound
	#tag EndEnum


	#tag ViewBehavior
		#tag ViewProperty
			Name="Tooltip"
			Visible=true
			Group="Appearance"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="Integer"
			EditorType="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue=""
			Type="Integer"
			EditorType="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue=""
			Type="Integer"
			EditorType="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Width"
			Visible=true
			Group="Position"
			InitialValue="100"
			Type="Integer"
			EditorType="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Height"
			Visible=true
			Group="Position"
			InitialValue="100"
			Type="Integer"
			EditorType="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockLeft"
			Visible=true
			Group="Position"
			InitialValue=""
			Type="Boolean"
			EditorType="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockTop"
			Visible=true
			Group="Position"
			InitialValue=""
			Type="Boolean"
			EditorType="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockRight"
			Visible=true
			Group="Position"
			InitialValue=""
			Type="Boolean"
			EditorType="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockBottom"
			Visible=true
			Group="Position"
			InitialValue=""
			Type="Boolean"
			EditorType="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabPanelIndex"
			Visible=false
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabIndex"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabStop"
			Visible=true
			Group="Position"
			InitialValue="True"
			Type="Boolean"
			EditorType="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="InitialParent"
			Visible=false
			Group="Position"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Visible"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			EditorType="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AutoDeactivate"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			EditorType="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Enabled"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			EditorType="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ReadOnly"
			Visible=true
			Group="Behavior"
			InitialValue=""
			Type="boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Text"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TextFont"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="string"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TextSize"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="double"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TextUnit"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Bold"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Italic"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Underline"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TextAlignment"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="TextAlignments"
			EditorType="Enum"
			#tag EnumValues
				"0 - Default"
				"1 - Left"
				"2 - Center"
				"3 - Right"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="BackgroundColor"
			Visible=false
			Group="Behavior"
			InitialValue="&c000000"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SelLength"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SelStart"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SelTextColor"
			Visible=false
			Group="Behavior"
			InitialValue="&c000000"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Styled"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TextColor"
			Visible=false
			Group="Behavior"
			InitialValue="&c000000"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SelectedTextBackgroundColor"
			Visible=false
			Group="Behavior"
			InitialValue="&c000000"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="HasSelection"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
