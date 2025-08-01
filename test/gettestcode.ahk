
#include ..\src\VibrantTooltips.ahk
#include <TestInterfaceConfig>


vt := VTooltip('Hello, world!')


Subjects := TestInterface.SubjectCollection(false)
Subjects.Add('VTooltip', GetPropsInfo(vt, '-Object', , false))
Subjects.Add('LOGFONT', GetPropsInfo(vt.Font, '-Buffer', , false))
Subjects.Add('TTINFO', GetPropsInfo(vt.Info, '-Buffer', , false))


A_Clipboard := Subjects.ToInitialValuesCode()
