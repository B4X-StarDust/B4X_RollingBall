B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.85
@EndOfDesignText@
#Event: MovementCompleted
#Event: ResizeCopmpleted
#Event: ReboundCopmpleted

#DesignerProperty: Key: Number, DisplayName: Ball Text, FieldType: String, DefaultValue: 15
#DesignerProperty: Key: Color, DisplayName: Color, FieldType: Color, DefaultValue: 0xFF7979FF, Description: Color
#DesignerProperty: Key: Start, DisplayName: Start rolling, FieldType: Boolean, DefaultValue: True, Description: Start rolling
'#DesignerProperty: Key: IntExample, DisplayName: Int Example, FieldType: Int, DefaultValue: 10, MinRange: 0, MaxRange: 100, Description: Note that MinRange and MaxRange are optional.
'#DesignerProperty: Key: StringWithListExample, DisplayName: String With List, FieldType: String, DefaultValue: Sunday, List: Sunday|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday
'#DesignerProperty: Key: DefaultColorExample, DisplayName: Default Color Example, FieldType: Color, DefaultValue: Null, Description: Setting the default value to Null means that a nullable field will be displayed.

Sub Class_Globals
	Private mEventName As String 'ignore
	Private mCallBack As Object 'ignore
	Public mBase As B4XView
	Private xui As XUI 'ignore
	Public Tag As Object
	
	Private clr As Int
	Private Can As B4XCanvas
	Private Progress As Int = 0
	Private Velocity As Int
	Private FramePause As Int = 80
	Private Deg As Int = 45
	
	Private Live As Boolean = False
	
	Public BallText As String ="15"
	Public Effect3d As Boolean = True
	Public EffectLight As Boolean = True
End Sub

Public Sub Initialize (Callback As Object, EventName As String)
	mEventName = EventName
	mCallBack = Callback
	
	#IF B4I
	FramePause=55
	#End If
End Sub

'Base type must be Object
Public Sub DesignerCreateView (Base As Object, Lbl As Label, Props As Map)
	mBase = Base
	Tag = mBase.Tag
	mBase.Tag = Me
	clr = xui.PaintOrColorToColor(Props.Get("Color")) 'Example of getting a color value from Props
	BallText=Props.Get("Number")
	
	Can.Initialize(mBase)
	Draw(32)
	If Props.Get("Start") Then Start
End Sub

Private Sub Base_Resize (Width As Double, Height As Double)
 	
End Sub

Public Sub GetBase As B4XView
	Return mBase
End Sub

Public Sub Start
	Live=True
	Progress=Rnd(0,Min(mBase.Width,mBase.Height))
	Rotate
End Sub

Public Sub Stop
	Live=False
	Progress=Min(mBase.Width,mBase.Height)/2
	Sleep(0)
	Draw(32)
End Sub

Public Sub Move(Duration As Int, DeltaX As Int, DeltaY As Int)
	mBase.SetLayoutAnimated(Duration,mBase.Left + DeltaX,mBase.Top + DeltaY,mBase.Width,mBase.Height)
	Sleep(Duration)
	If xui.SubExists(mCallBack,mEventName & "_MovementCompleted",0) Then 
		CallSub(mCallBack,mEventName & "_MovementCompleted")
	End If
End Sub

Public Sub MoveTo(Duration As Int, Left As Int, Top As Int)
	mBase.SetLayoutAnimated(Duration,Left,Top ,mBase.Width,mBase.Height)
	Sleep(Duration)
	If xui.SubExists(mCallBack,mEventName & "_MovementCompleted",0) Then CallSub(mCallBack,mEventName & "_MovementCompleted")
End Sub

Public Sub Resize(Duration As Int, Width As Int, Height As Int)
	mBase.SetLayoutAnimated(Duration,mBase.Left,mBase.Top ,Width,Height)
	Sleep(Duration)
	If xui.SubExists(mCallBack,mEventName & "_ResizeCopmpleted",0) Then CallSub(mCallBack,mEventName & "_ResizeCopmpleted")
End Sub

' Animation 600 mills
Public Sub Rebound(magnification As Float)
	Dim Width As Int = mBase.Width
	Dim height As Int = mBase.Height
	
	mBase.SetLayoutAnimated(300,mBase.Left,mBase.Top,Width*magnification,height*magnification)
	Sleep(300)
	mBase.SetLayoutAnimated(300,mBase.Left,mBase.Top,Width,height)
	Sleep(300)
	If xui.SubExists(mCallBack,mEventName & "_ReboundCopmpleted",0) Then CallSub(mCallBack,mEventName & "_ReboundCopmpleted")
End Sub

Private Sub Rotate
	Do While Live
		Draw(32)
		Sleep(FramePause)
		Draw(40)
		Sleep(FramePause)
	Loop
End Sub

Private Sub Draw(LightDepth As Int)
	Dim Large As Int = Min(mBase.Width,mBase.Height)
	
	Can.Resize(mBase.Width,mBase.Height)
	Can.ClearRect(Can.TargetRect)
	
	Velocity=Min(mBase.Width,mBase.Height)/5
		
	Dim Path As B4XPath
	Path.InitializeOval(Can.TargetRect)
	Can.ClipPath(Path)
	Can.DrawRect(Can.TargetRect,clr,True,1dip)
	
	Dim FontSize As Int = (Large/(50dip/10))
	Dim BallSize As Int =Large/3
	
	Dim LightStep As Int = 3dip
	Dim CountFraction As Int = Large/LightStep
	Dim LightEffectStep As Float = 90/CountFraction
	
	If Effect3d Then
		For i=0 To CountFraction
			'light depth with aliasing
			Dim Trasp As Int = Power(SinD(LightEffectStep*i),2)*LightDepth
			Can.DrawCircle(Can.TargetRect.CenterX-Large*i/CountFraction,Can.TargetRect.CenterY-Large*i/CountFraction,LightStep*(CountFraction-i),xui.Color_ARGB(Trasp,255,255,255),True,1dip)
		Next
	End If

	' roll Number
	If Deg>0 Then 
		Can.DrawCircle(Progress,Large-Progress,BallSize,xui.Color_White,True,1dip)
		Can.DrawTextRotated(BallText,Progress,Large-Progress,xui.CreateDefaultBoldFont(FontSize),xui.Color_Black,"CENTER",Deg)
	Else
		Can.DrawCircle(Progress,Progress,BallSize,xui.Color_White,True,1dip)
		Can.DrawTextRotated(BallText,Progress,Progress,xui.CreateDefaultBoldFont(FontSize),xui.Color_Black,"CENTER",Deg)
	End If
	
	' Pattern Light
	If EffectLight Then Can.DrawBitmap(xui.LoadBitmap(File.DirAssets,"shadowlight.png"),Can.TargetRect)
	Can.Invalidate
	Can.RemoveClip
	
	Progress=(Progress+Velocity)
	If Progress>Large Then 
		Deg=-Deg
		Progress=Progress Mod Large
	End If
End Sub