;SetAspectRatio.pbi
;09.05.2023, Jac de Lad
;Keeps a windows aspect ratio
;Usage: SetAspectRatio(#Window,#True/#False) to enable/disable keeping the current aspect ratio
;also works with WindowBounds
Structure _AR
  Window.i
  Ratio.f
  dx.l
  dy.l
EndStructure
Global NewMap AspectRatioMap._AR()
Procedure AspectRatioCallBack(hwnd,msg,wparam,lparam);
  Protected *rc.rect,w,h  
  Select msg 
    Case #WM_SIZING  
      If FindMapElement(AspectRatioMap(),Str(hwnd))
        *rc = lparam 
        w = *rc\right - *rc\left - AspectRatioMap(Str(hwnd))\dx
        h = *rc\bottom - *rc\top - AspectRatioMap(Str(hwnd))\dy
        Select wparam 
          Case 1;Left
            *rc\bottom = *rc\top + w/AspectRatioMap(Str(hwnd))\Ratio + AspectRatioMap(Str(hwnd))\dy
          Case 2;Right
            *rc\bottom = *rc\top + w/AspectRatioMap(Str(hwnd))\Ratio + AspectRatioMap(Str(hwnd))\dy
          Case 3;Top
            *rc\right = *rc\left + h*AspectRatioMap(Str(hwnd))\Ratio + AspectRatioMap(Str(hwnd))\dx
          Case 6;Bottom
            *rc\right = *rc\left + h*AspectRatioMap(Str(hwnd))\Ratio + AspectRatioMap(Str(hwnd))\dx
          Case 4;Top Left
            If w/AspectRatioMap(Str(hwnd))\Ratio<h
              *rc\top = *rc\bottom - w/AspectRatioMap(Str(hwnd))\Ratio - AspectRatioMap(Str(hwnd))\dy
            Else
              *rc\left = *rc\right - h*AspectRatioMap(Str(hwnd))\Ratio - AspectRatioMap(Str(hwnd))\dx
            EndIf
          Case 7;Bottom Left 
            If w/AspectRatioMap(Str(hwnd))\Ratio<h
              *rc\bottom = *rc\top + w/AspectRatioMap(Str(hwnd))\Ratio + AspectRatioMap(Str(hwnd))\dy
            Else
              *rc\left = *rc\right - h*AspectRatioMap(Str(hwnd))\Ratio - AspectRatioMap(Str(hwnd))\dx
            EndIf
          Case 5;Top Right
            If w/AspectRatioMap(Str(hwnd))\Ratio<h
              *rc\top = *rc\bottom - w/AspectRatioMap(Str(hwnd))\Ratio - AspectRatioMap(Str(hwnd))\dy
            Else
              *rc\right = *rc\left + h*AspectRatioMap(Str(hwnd))\Ratio + AspectRatioMap(Str(hwnd))\dx
            EndIf
          Case 8;Bottom Right  
            If w/AspectRatioMap(Str(hwnd))\Ratio<h
              *rc\bottom = *rc\top + w/AspectRatioMap(Str(hwnd))\Ratio + AspectRatioMap(Str(hwnd))\dy
            Else
              *rc\right = *rc\left + h*AspectRatioMap(Str(hwnd))\Ratio + AspectRatioMap(Str(hwnd))\dx
            EndIf
        EndSelect
      EndIf
  EndSelect 
  ProcedureReturn #PB_ProcessPureBasicEvents
EndProcedure
Procedure SetWindowAspectRatio(Window,Enable=#True)
  Protected rect.rect,WindowID=WindowID(Window)
  If Enable
    GetWindowRect_(WindowID(Window),rect)
    AspectRatioMap(Str(WindowID))\Window=Window
    AspectRatioMap(Str(WindowID))\Ratio=WindowWidth(Window,#PB_Window_InnerCoordinate)/WindowHeight(Window,#PB_Window_InnerCoordinate)
    AspectRatioMap(Str(WindowID))\dy=rect\bottom-rect\top-WindowHeight(Window,#PB_Window_InnerCoordinate)
    AspectRatioMap(Str(WindowID))\dx=rect\right-rect\left-WindowWidth(Window,#PB_Window_InnerCoordinate)
    SetWindowCallback(@AspectRatioCallBack(),Window)
  Else
    If FindMapElement(AspectRatioMap(),Str(WindowID))
      SetWindowCallback(0,AspectRatioMap(Str(WindowID))\Window)
      DeleteMapElement(AspectRatioMap(),Str(WindowID))
    EndIf
  EndIf
EndProcedure
Procedure WindowBoundsEx(Window,minx,miny,maxx,maxy)
  Protected WindowID=WindowID(Window)
  If FindMapElement(AspectRatioMap(),Str(WindowID))
    If minx<>#PB_Ignore Or miny<>#PB_Ignore
      If minx<>#PB_Ignore And miny<>#PB_Ignore
        If miny*AspectRatioMap(Str(WindowID))\Ratio>minx:minx=miny*AspectRatioMap(Str(WindowID))\Ratio:EndIf
        If minx/AspectRatioMap(Str(WindowID))\Ratio>miny:miny=minx/AspectRatioMap(Str(WindowID))\Ratio:EndIf
      ElseIf minx=#PB_Ignore
        minx=miny/AspectRatioMap(Str(WindowID))\Ratio
      ElseIf miny=#PB_Ignore
        miny=minx*AspectRatioMap(Str(WindowID))\Ratio
      EndIf
    EndIf
    If maxx<>#PB_Ignore Or maxy<>#PB_Ignore
      If maxx<>#PB_Ignore And maxy<>#PB_Ignore
        If maxy*AspectRatioMap(Str(WindowID))\Ratio<maxx:maxx=maxy*AspectRatioMap(Str(WindowID))\Ratio:EndIf
        If maxx/AspectRatioMap(Str(WindowID))\Ratio<maxy:maxy=maxx/AspectRatioMap(Str(WindowID))\Ratio:EndIf
      ElseIf maxx=#PB_Ignore
        maxx=maxy/AspectRatioMap(Str(WindowID))\Ratio
      ElseIf maxy=#PB_Ignore
        maxy=maxx*AspectRatioMap(Str(WindowID))\Ratio
      EndIf
    EndIf
  EndIf
  WindowBounds(Window,minx,miny,maxx,maxy)
EndProcedure
Macro WindowBounds(window,minx,miny,maxx,maxy)
  WindowBoundsEx(window,minx,miny,maxx,maxy)
EndMacro

CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit 
  OpenWindow(0,0,0,250,250,"Test",#PB_Window_ScreenCentered|#PB_Window_SystemMenu|#PB_Window_SizeGadget)
  SetWindowAspectRatio(0,#True)
  WindowBounds(0,#PB_Ignore,200,1200,900)
  Repeat
  Until WaitWindowEvent()=#PB_Event_CloseWindow
CompilerEndIf
; IDE Options = PureBasic 6.01 LTS (Windows - x64)
; CursorPosition = 4
; Folding = M7
; Optimizer
; EnableAsm
; EnableThread
; EnableXP
; EnableUser
; DPIAware
; EnableOnError
; CPU = 1
; CompileSourceDirectory
; Compiler = PureBasic 6.01 LTS (Windows - x64)
; EnablePurifier
; EnableCompileCount = 54
; EnableBuildCount = 0