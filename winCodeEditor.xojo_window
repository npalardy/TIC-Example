#tag Window
Begin Window winCodeEditor
   BackColor       =   &cFFFFFF00
   Backdrop        =   0
   CloseButton     =   True
   Composite       =   False
   Frame           =   0
   FullScreen      =   False
   FullScreenButton=   False
   HasBackColor    =   False
   Height          =   400
   ImplicitInstance=   True
   LiveResize      =   "True"
   MacProcID       =   0
   MaxHeight       =   32000
   MaximizeButton  =   True
   MaxWidth        =   32000
   MenuBar         =   0
   MenuBarVisible  =   True
   MinHeight       =   64
   MinimizeButton  =   True
   MinWidth        =   64
   Placement       =   0
   Resizeable      =   True
   Title           =   "Untitled"
   Visible         =   True
   Width           =   600
   Begin CodeEditorCanvas CodeEditorCanvas1
      AutoDeactivate  =   True
      BackgroundColor =   &c00000000
      Bold            =   False
      Enabled         =   True
      Height          =   360
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   False
      Left            =   0
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      ReadOnly        =   False
      Scope           =   0
      SelectedTextBackgroundColor=   &c00000000
      SelLength       =   0
      SelStart        =   0
      SelTextColor    =   &c00000000
      Styled          =   False
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      Text            =   ""
      TextAlignment   =   0
      TextColor       =   &c00000000
      TextFont        =   ""
      TextSize        =   0.0
      TextUnit        =   0
      Tooltip         =   ""
      Top             =   40
      Underline       =   False
      Visible         =   True
      Width           =   600
   End
   Begin Toolbar1 Toolbar11
      Enabled         =   True
      Index           =   -2147483648
      InitialParent   =   ""
      LockedInPosition=   False
      Scope           =   0
      TabPanelIndex   =   0
      Visible         =   True
   End
End
#tag EndWindow

#tag WindowCode
	#tag Method, Flags = &h0
		Sub DoDebugHack()
		  #If DebugBuild
		    
		    
		    // CodeEditorCanvas1.AppendText " abcdefghijklmnopqrstuvwxyz"
		    
		    CodeEditorCanvas1.SelStart = 32
		    CodeEditorCanvas1.SelLength = 3
		  #EndIf
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UpdateToolbar()
		  
		  For i As Integer = 0 To Toolbar11.Count
		    
		    Dim thisitem As toolitem = Toolbar11.item(i)
		    
		    If thisItem IsA ToolbarButton Then
		      
		      Select Case ToolbarButton(thisItem).Caption
		        
		      Case "Color"
		        Dim p As New picture(20,20)
		        p.Graphics.DrawingColor = CodeEditorCanvas1.TextColor
		        p.Graphics.TextSize = 14
		        p.Graphics.FillOval p.width/4, p.height/4, p.width/2, p.height/2
		        
		        ToolbarButton(thisItem).Icon = p
		        
		      End Select
		      
		    End If
		    
		  Next
		End Sub
	#tag EndMethod


#tag EndWindowCode

#tag Events CodeEditorCanvas1
	#tag Event
		Sub Open()
		  Me.TextColor = &cFFFF
		  Me.TextFont = "Menlo"
		  Me.TextSize = 14
		  
		  Dim lines() As String
		  // 
		  // Dim tmp As String
		  // For j As Integer = 1 To 10
		  // tmp = tmp + "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ "
		  // Next
		  // 
		  // For i As Integer = 1 To 100
		  // lines.append Str(i,"000") + " " + tmp
		  // Next
		  // 
		  // Me.Text = Join(lines, EndOfLine)
		  
		  Me.SelectedTextBackgroundColor = &c007700
		  
		  
		  me.AppendText " abcdefghijklmnopqrstuvwxyz" + endofline + " abcdefghijklmnopqrstuvwxyz" + endofline + " abcdefghijklmnopqrstuvwxyz"
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events Toolbar11
	#tag Event
		Sub Action(item As ToolItem)
		  Select Case item.Caption
		    
		  Case "Bold"
		    CodeEditorCanvas1.Bold = Not CodeEditorCanvas1.Bold
		    
		  Case "Italic"
		    CodeEditorCanvas1.Italic = Not CodeEditorCanvas1.Italic
		    
		  Case "Underline"
		    CodeEditorCanvas1.Underline = not CodeEditorCanvas1.Underline
		    
		  Case "Color"
		    
		    Dim c As Color
		    
		    If SelectColor(c, "Pick the text color") Then
		      CodeEditorCanvas1.TextColor = c
		    End
		    
		    UpdateToolbar
		    
		    #If DebugBuild
		  Case "debug"
		    DoDebugHack()
		    #EndIf
		    
		  Else
		    Break
		  End Select
		  
		  
		End Sub
	#tag EndEvent
	#tag Event
		Sub DropDownMenuAction(item As ToolItem, hitItem As MenuItem)
		  CodeEditorCanvas1.TextFont = hititem.Text
		End Sub
	#tag EndEvent
	#tag Event
		Sub Open()
		  // Create a menu
		  
		  Dim myMenu As New MenuItem
		  
		  Dim maximum As Integer = FontCount - 1
		  
		  For i As Integer = 0 To maximum
		    
		    myMenu.Append ( New menuitem(Font(i)) )
		    
		  Next
		  
		  For i As Integer = 0 To Me.Count
		    Dim thisitem As toolitem = Me.item(i)
		    
		    If thisItem IsA ToolbarButton Then
		      
		      Select Case ToolbarButton(thisItem).Caption
		        
		      Case "Font" 
		        // Assign the new menu to the toolitem..
		        ToolbarButton(thisItem).menu = myMenu
		        
		        Dim p As New picture(20,20)
		        p.Graphics.Italic = True
		        p.Graphics.DrawingColor = &cFFFFFF
		        p.Graphics.TextSize = 14
		        
		        Dim textToDraw As String = "F"
		        
		        Dim padLeft, padTop As Integer
		        padleft = (p.width - p.Graphics.StringWidth(textToDraw)) / 2
		        padtop = (p.height - p.Graphics.TextHeight) / 2
		        
		        p.Graphics.DrawText textToDraw, padLeft, padtop + p.Graphics.TextAscent
		        
		        ToolbarButton(thisItem).Icon = p
		        
		      Case "Bold"
		        
		        Dim p As New picture(20,20)
		        p.Graphics.Bold = True
		        p.Graphics.DrawingColor = &cFFFFFF
		        p.Graphics.TextSize = 14
		        
		        Dim textToDraw As String = "B"
		        
		        Dim padLeft, padTop As Integer
		        padleft = (p.width - p.Graphics.StringWidth(textToDraw)) / 2
		        padtop = (p.height - p.Graphics.TextHeight) / 2
		        
		        p.Graphics.DrawText textToDraw, padLeft, padtop + p.Graphics.TextAscent
		        
		        ToolbarButton(thisItem).Icon = p
		        
		      Case "Italic"
		        
		        Dim p As New picture(20,20)
		        p.Graphics.Italic = True
		        p.Graphics.DrawingColor = &cFFFFFF
		        p.Graphics.TextSize = 14
		        Dim textToDraw As String = "I"
		        
		        Dim padLeft, padTop As Integer
		        padleft = (p.width - p.Graphics.StringWidth(textToDraw)) / 2
		        padtop = (p.height - p.Graphics.TextHeight) / 2
		        
		        p.Graphics.DrawText textToDraw, padLeft, padtop + p.Graphics.TextAscent
		        
		        ToolbarButton(thisItem).Icon = p
		        
		      Case "Underline"
		        
		        Dim p As New picture(20,20)
		        p.Graphics.Underline = True
		        p.Graphics.DrawingColor = &cFFFFFF
		        p.Graphics.TextSize = 14
		        
		        Dim textToDraw As String = "U"
		        
		        Dim padLeft, padTop As Integer
		        padleft = (p.width - p.Graphics.StringWidth(textToDraw)) / 2
		        padtop = (p.height - p.Graphics.TextHeight) / 2
		        
		        p.Graphics.DrawText textToDraw, padLeft, padtop + p.Graphics.TextAscent
		        
		        ToolbarButton(thisItem).Icon = p
		        
		      Case "Color"
		        Dim p As New picture(20,20)
		        p.Graphics.DrawingColor = CodeEditorCanvas1.TextColor
		        p.Graphics.TextSize = 14
		        p.Graphics.FillOval p.width/4, p.height/4, p.width/2, p.height/2
		        
		        ToolbarButton(thisItem).Icon = p
		        
		      End Select
		    End If
		    
		  Next
		  
		  
		  #If DebugBuild Then
		    Dim debugTB As New ToolbarButton
		    
		    debugTB.Caption = "debug"
		    
		    Me.AddButton debugTB
		    
		  #EndIf
		  
		  
		  
		End Sub
	#tag EndEvent
#tag EndEvents
#tag ViewBehavior
	#tag ViewProperty
		Name="MinimumWidth"
		Visible=true
		Group="Size"
		InitialValue="64"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MinimumHeight"
		Visible=true
		Group="Size"
		InitialValue="64"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MaximumWidth"
		Visible=true
		Group="Size"
		InitialValue="32000"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MaximumHeight"
		Visible=true
		Group="Size"
		InitialValue="32000"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Type"
		Visible=true
		Group="Frame"
		InitialValue="0"
		Type="Types"
		EditorType="Enum"
		#tag EnumValues
			"0 - Document"
			"1 - Movable Modal"
			"2 - Modal Dialog"
			"3 - Floating Window"
			"4 - Plain Box"
			"5 - Shadowed Box"
			"6 - Rounded Window"
			"7 - Global Floating Window"
			"8 - Sheet Window"
			"9 - Metal Window"
			"11 - Modeless Dialog"
		#tag EndEnumValues
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasCloseButton"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasMaximizeButton"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasMinimizeButton"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasFullScreenButton"
		Visible=true
		Group="Frame"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="DefaultLocation"
		Visible=true
		Group="Behavior"
		InitialValue="0"
		Type="Locations"
		EditorType="Enum"
		#tag EnumValues
			"0 - Default"
			"1 - Parent Window"
			"2 - Main Screen"
			"3 - Parent Window Screen"
			"4 - Stagger"
		#tag EndEnumValues
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasBackgroundColor"
		Visible=true
		Group="Background"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="BackgroundColor"
		Visible=true
		Group="Background"
		InitialValue="&hFFFFFF"
		Type="Color"
		EditorType="Color"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Name"
		Visible=true
		Group="ID"
		InitialValue=""
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Interfaces"
		Visible=true
		Group="ID"
		InitialValue=""
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Super"
		Visible=true
		Group="ID"
		InitialValue=""
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Width"
		Visible=true
		Group="Size"
		InitialValue="600"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Height"
		Visible=true
		Group="Size"
		InitialValue="400"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Title"
		Visible=true
		Group="Frame"
		InitialValue="Untitled"
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Resizeable"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Composite"
		Visible=false
		Group="OS X (Carbon)"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MacProcID"
		Visible=false
		Group="OS X (Carbon)"
		InitialValue="0"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="FullScreen"
		Visible=false
		Group="Behavior"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="ImplicitInstance"
		Visible=true
		Group="Behavior"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Visible"
		Visible=true
		Group="Behavior"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Backdrop"
		Visible=true
		Group="Background"
		InitialValue=""
		Type="Picture"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MenuBar"
		Visible=true
		Group="Menus"
		InitialValue=""
		Type="MenuBar"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MenuBarVisible"
		Visible=true
		Group="Deprecated"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
#tag EndViewBehavior
