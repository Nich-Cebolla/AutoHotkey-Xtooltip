
#include ..\src\Xtooltip.ahk
#SingleInstance force

demo()

class demo {
    static Call() {
        ; Create a theme
        theme := XttTheme("MyTheme", {
            BackColor: 0
          , Bold: true
          , FaceName: "Segoe Ui"
          , FontSize: 12
          , Italic: true
          , Quality: 5
          , Margin: XttRect.Margin(3)
          , MaxWidth: 250
          , TextColor: XttRgb(0, 255, 255)
        })
        ; Create an Xtooltip, passing the theme as an option
        ; TTS_ALWAYSTIP makes it so the tooltips will appear whether or not the window is the active window.
        xtt := this.xtt := Xtooltip({ Theme: theme, AddStyle: TTS_ALWAYSTIP })

        ; Make a gui
        g := this.g := Gui()
        g.SetFont("s11 q5")

        btn := g.Add("Button", "w125", "Click me")
        ; Associate a control with the tooltip
        xtt.AddControl("Name1", "Click the button!", btn)

        edt := g.Add("Edit", "w400 r5")
        ; Associate a control's client area with the tooltip. Similar to AddControl but notice that
        ; the tooltip does not display when the mouse is over the scrollbar.
        xtt.AddControlRect("Name2", "Input the information!", edt)

        edt.GetPos(&x, &y, &w, &h)
        ; Associate a rectangular area within the window's client area
        l := x
        t := y + h + g.MarginY
        r := w
        b := y + h + g.MarginY + 400
        xtt.AddRect("Name3", "Blank area", g.Hwnd, l, t, r, b)

        ; Show our window
        g.Show("h" (y + h + g.MarginY + 440))

        ; Create a tracking tooltip. Since only one tooltip window can be visible at a time, we
        ; should create another Xtooltip object so the tracking tooltip can be displayed at the same
        ; time as the others.
        ; Let's create a similar theme but use red text
        themeRed := theme.Clone()
        themeRed.TextColor := XttRgb(255, 0, 0)
        xttTracking := this.xttTracking := Xtooltip({ Theme: themeRed })
        g.GetPos(&gx, &gy, &gw, &gh)
        gx += gw - 40
        gy += gh - 50
        xttTracking.AddTracking("Name4", "Tracking tooltip information", , , true, gx, gy)

        ; Create some extra controls to move the tooltip around
        g.Add("Button", "x" x " y" (y + h + g.MarginY + 400) " section", "Move tooltip").OnEvent("Click", MoveTooltip)
        g.Add("Edit", "ys w60 vX")
        g.Add("Edit", "ys w60 vY")
        xtt.AddControl("X", "Enter the X coordinate", g["X"])
        xtt.AddControl("Y", "Enter the Y coordinate", g["Y"])

        ; Creating a theme group

        ; Register a collection
        Xtooltip.RegisterAllCollections()
        ; We need to give `themeRed` a name first
        themeRed.SetName("red dark")
        themeGroup := XttThemeGroup("Red", themeRed)
        ; Create a light mode version
        themeRedLight := XttTheme("red light", {
            BackColor: XttRgb(255, 255, 255)
          , Bold: true
          , FaceName: "Segoe Ui"
          , FontSize: 12
          , Italic: true
          , Quality: 5
          , Margin: XttRect.Margin(3)
          , MaxWidth: 250
          , TextColor: XttRgb(255, 0, 0)
        })
        ; Add the light mode to the group
        themeGroup.ThemeAdd(themeRedLight, true)
        ; Set the light mode / dark mode theme names
        themeGroup.SetLightMode("red light", "red dark")
        ; Add the Xtooltip object to the theme group
        themeGroup.XttAdd(xttTracking)
        ; Create a button to swap themes
        g.Add("Button", "ys", "Swap themes").OnEvent("Click", SwapTheme)
    }
}

MoveTooltip(ctrl, *) {
    g := ctrl.Gui
    x := g["X"].Text || 0
    y := g["Y"].Text || 0
    demo.xttTracking.TrackPosition(x, y)
}

SwapTheme(ctrl, *) {
    demo.xttTracking.ThemeGroup.ToggleLightMode()
}
