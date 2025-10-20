
#SingleInstance force
#include ..\src\Xtooltip.ahk

!t::ExitDemo()


ExitDemo(*) {
    Demo.WindowsHook.Unhook()
    for name, xtt in Xtooltip.XttCollection {
        xtt.Dispose()
    }
    ExitApp()
}

Demo()

class Demo {
    static MakeButtonXtooltip(controls) {
        ; create a theme for the Xtooltip
        theme := XttTheme(,
            {
                BackColor: 0x000000
              , FontSize: 11
              , MarginL: 2
              , MarginT: 2
              , MarginR: 2
              , MarginB: 2
              , Name: 'Buttons'
              , Quality: 5
              , TextColor: XttRgb(255, 0, 0)
              , FaceName: this.FaceName
            }
        )
        ; create the Xtooltip. Notice how there is only one Xtooltip for all three buttons
        ; we pass the theme to the fourth parameter
        xtt := Xtooltip({ Name: 'Buttons', Theme: theme, AddStyle: TTS_ALWAYSTIP })
        ; add the tools
        xtt.AddControl(
            'Button1'                           ; Name for the tool
          , 'This is the text for Button 1!'    ; Text that will be displayed
          , controls[1]                         ; The control it is associated with
        )
        xtt.AddControl('Button2', 'This is the text for Button 2!', controls[2])
        xtt.AddControl('Button3', 'This is the text for Button 3!', controls[3])
        ; that's it, the "Tools" are now functional and will appear when the mouse moves over the button
        return xtt
    }
    static MakeEditXtooltip(controls) {
        ; create a theme for the Xtooltip
        theme := XttTheme(,
            {
                BackColor: 0x000000
              , FontSize: 11
              , MarginL: 2
              , MarginT: 2
              , MarginR: 2
              , MarginB: 2
              , Name: 'Edits'
              , Quality: 5
              , TextColor: XttRgb(0, 255, 255)
              , FaceName: this.FaceName
            }
        )
        ; create the Xtooltip. Notice how there is only one Xtooltip for all three edit controls
        ; we pass the theme to the fourth parameter
        xtt := Xtooltip({ Name: 'Edits', Theme: theme, AddStyle: TTS_ALWAYSTIP })
        ; add the tools. We'll add them in a loop this time
        for ctrl in controls {
            xtt.AddControl('Edit' A_Index, DemoStrings.Edits[A_Index], ctrl)
        }
        return xtt
    }
    static __New() {
        this.DeleteProp('__New')
        global ObjGetOwnPropDesc := Object.Prototype.GetOwnPropDesc
    }
    static Call() {
        ; static data
        txtInfoRows := 6
        DemoControlsOffsetX := 25
        faceName := this.FaceName := 'Segoe Ui'
        fontOpt := 's11 q5'
        DemoButtonWidth := 100
        DemoEditWidth := 200
        paddingY := 15
        paddingX := 10
        tabs := this.Tabs := ['Modify', 'Create']
        EdtInputTextWidth := lbToolsWidth := lbXtooltipWidth := 200
        lbXtooltipRows := 6
        lbToolsRows := 10
        EdtInputTextRows := 3
        rgbEditWidth := 50
        previewDisplayHeight := 100
        edtErrorRows := 4
        inputControlGroup := {
            EditWidth: 150
          , ButtonWidth: 70
          , PaddingX: 5
          , PaddingY: 5
        }
        uiTheme := XttTheme(, {
            BackColor: 0x000000
          , FontSize: 11
          , MarginL: 2
          , MarginT: 2
          , MarginR: 2
          , MarginB: 2
          , MaxWidth: 300
          , Name: 'Demo.Ui'
          , Quality: 5
          , TextColor: XttRgb(230, 150, 0)
          , FaceName: faceName
        })
        demoButtonTheme := XttTheme(, {
            BackColor: 0xFFFFFF
          , FontSize: 11
          , MarginL: 2
          , MarginT: 2
          , MarginR: 2
          , MarginB: 2
          , Name: 'Demo button'
          , Quality: 5
          , TextColor: XttRgb(255, 0, 255)
          , FaceName: faceName
        })
        previewTheme := XttTheme(, {
            BackColor: 0xFFFFFF
          , FontSize: 11
          , MarginL: 30
          , MarginT: 30
          , MarginR: 30
          , MarginB: 30
          , Name: 'Preview'
          , Quality: 5
          , TextColor: XttRgb(0, 0, 0)
          , FaceName: faceName
        })
        previewTheme.MaxWidth := lbToolsWidth * 2 - previewTheme.Margin.L - previewTheme.Margin.R
        showOptions := 'x20 y20 NoActivate'

        ; register collections
        Xtooltip.RegisterAllCollections()

        ; prepare gui
        eventHandler := this.EventHandler := DemoEventHandler()
        DllCall('SetThreadDpiAwarenessContext', 'ptr', -3, 'ptr')
        g := this.Ui := Gui('+Resize -DPIScale', 'Xtooltip sandbox', eventHandler)
        DllCall('SetThreadDpiAwarenessContext', 'ptr', -4, 'ptr')
        g.SetFont(fontOpt, faceName)
        txtInfoDummy := g.Add('Text', 'r' txtInfoRows ' vTxtInfoDummy')
        txtInfoDummy.GetPos(, &txty, , &txth)

        ; make Xtooltip for the gui
        xttUi := Xtooltip({ ParentHwnd: g.Hwnd, Name: 'Main', Theme: uiTheme, AddStyle: TTS_ALWAYSTIP })

        ; make three Demo buttons
        buttons := this.Buttons := []
        y := txty + txth + paddingY
        x :=  g.MarginX + DemoControlsOffsetX
        loop 3 {
            buttons.Push(g.Add('Button', 'x' x ' y' y ' w' DemoButtonWidth ' vBtnDemo' A_Index, 'Button ' A_Index))
            buttons[-1].GetPos(, , , &btnh)
            y += btnh + paddingY
        }

        ; make three Demo edits
        edits := this.Edits := []
        loop 3 {
            edits.Push(g.Add('Edit', 'x' x ' y' y ' r3 w' DemoEditWidth ' vEdtDemo' A_Index, DemoStrings.Edits[A_Index]))
            edits[-1].GetPos(, , , &edth)
            y += edth + paddingY
        }

        this.MakeButtonXtooltip(buttons)

        this.MakeEditXtooltip(edits)

        ; make exit button
        edits[-1].GetPos(, &edty, , &edth)
        g.Add('Button', 'x' (g.MarginX + DemoControlsOffsetX) ' y' (edty + edth + paddingY * 3) ' w' DemoButtonWidth ' vBtnExit', 'Exit').OnEvent('Click', ExitDemo)
        g['BtnExit'].GetPos(, , , &btnh)

        buttons[1].GetPos(, &btny)
        edits[1].GetPos(&edtx, , &edtw)

        txt := g.Add('Text', 'x' (edtx + edtw + paddingX) ' y' btny ' w' lbXtooltipWidth ' Center vTxtLabelXtooltips', 'Xtooltips')
        lf := txt.Font := XttLogFont(txt.Hwnd)
        lf.Underline := 1
        lf.Weight := 700
        lf.Apply()
        txt.GetPos(&tabClientLeft, &tabClientTop, &txtw, &txth)

        ; add listbox for Xtooltips
        lbXtooltipsY := tabClientTop + txth + paddingY
        lb := this.LbXtooltips := g.Add('ListBox', 'x' tabClientLeft ' y' lbXtooltipsY ' w' lbXtooltipWidth ' r' lbXtooltipRows ' vLbXtooltips', [])
        lb.OnEvent('Change', 'HChangeListBoxXtooltips')

        ; add Xtooltip for listbox
        xttUi.AddControl('LbXtooltips', 'Select an Xtooltip to modify', lb)

        ; add listbox for tools
        lbToolsX := tabClientLeft + txtw + paddingX
        txt := g.Add('Text', 'x' lbToolsX ' y' tabClientTop ' w' lbToolsWidth ' Center vTxtTools', 'Tools')
        lf.Hwnd := txt.Hwnd
        lf.Apply()
        lbTools := this.LbTools := g.Add('ListBox', 'x' lbToolsX ' y' lbXtooltipsY ' w' lbToolsWidth ' r' lbToolsRows ' vLbTools', [])
        lbTools.OnEvent('Change', 'HChangeListBoxTools')

        ; add Xtooltip for listbox
        xttUi.AddControl('LbTools', 'Select a tool to modify its text', lbTools)

        ; add edit to input new Xtooltip text
        lb.GetPos(&lbx, , , &lbh)
        edtInputText := g.Add('Edit', 'x' lbx ' y' (lbXtooltipsY + lbh + paddingY) ' w' EdtInputTextWidth ' r' EdtInputTextRows ' vEdtInputText')
        edtInputText.OnEvent('Change', 'HChangeEditInputText')

        ; add Xtooltip for edit
        xttUi.AddControl('EdtInputText', 'Input new text for the selected tool', edtInputText)

        ; get list of properties
        props := []
        for prop in XttTheme {
            if InStr(',CharSet,ClipPrecision,Family,OutPrecision,Pitch,Height,', ',' prop ',') {
                continue
            } else if InStr(',L,T,R,B,', ',' prop ',') {
                props.Push('Margin' prop)
            } else {
                props.Push(prop)
            }
        }

        ; make input section
        inputControlGroup.StartX := lbToolsX + lbToolsWidth + paddingX
        inputControlGroup.StartY := tabClientTop
        controls := this.Controls := MakeInputControlGroup(g, props, inputControlGroup)
        bottom := 0
        for prop, group in controls {
            xttUi.AddControlRect('Txt' prop, prop, group.Label)
            xttUi.AddControl('BtnGet' prop, 'Click to get the current value', group.Get)
            xttUi.AddControl('BtnSet' prop, 'Click to set the Xtooltip`'s property with the value in the edit control', group.Set)
            xttUi.AddControl('Edt' prop, DemoStrings.InputEdits.Get(prop), group.Edit)
            group.Get.OnEvent('Click', 'HClickButtonGet')
            group.Set.OnEvent('Click', 'HClickButtonSet')
            group.Set.GetPos(, &btny)
            if btny > bottom {
                bottom := btny
            }
        }

        controls.Get(props[1]).Set.GetPos(&btnx, , &btnw, &btnh)
        bottom += btnh + paddingY
        right := btnx + btnw + paddingX

        ; add the info to the top
        txtInfoDummy.GetPos(&txtx, &txty, , &txth)
        g.Add('Text', 'x' txtx ' y' txty ' w' (right - g.MarginX) ' h' txth ' vTxtInfo', DemoStrings.Welcome)
        ; add the Xtooltip
        xttUi.AddControlRect('TxtInfo', 'Helpful information', g['TxtInfo'])
        txtInfoDummy.Visible := txtInfoDummy.Enabled := 0

        ; add color sliders
        lbTools.GetPos(&lbx, &lby, &lbw, &lbh)
        lb.GetPos(&lbx2)
        totalW := lbx + lbw - lbx2
        y := lby + lbh + paddingY * 3 + previewDisplayHeight

        ; text color sliders
        g.Add('Text', 'x' lbx2 ' y' y ' w' totalW ' Section Center vTxtLabelTextColor', 'Text color')
        lf.Hwnd := g['TxtLabelTextColor'].Hwnd
        lf.Apply()
        g.Add('Text', 'xs Section Right vTxtLabelTextR', 'R:').GetPos(, , &txtw)
        sliderW := lbx + lbw - lbx2 - txtw - g.MarginX * 2 - rgbEditWidth
        g.Add('Slider',  'ys w' sliderW ' NoTicks AltSubmit Range0-255 ToolTip vSliderTextR', 0).OnEvent('Change', 'HChangeSlider')
        g['SliderTextR'].Edit := g.Add('Edit', 'ys w' rgbEditWidth ' vEdtTextR', '0')
        g.Add('Text', 'xs Section Right vTxtLabelTextG', 'G:')
        g.Add('Slider',  'ys w' sliderW ' NoTicks AltSubmit Range0-255 ToolTip vSliderTextG', 0).OnEvent('Change', 'HChangeSlider')
        g['SliderTextG'].Edit := g.Add('Edit', 'ys w' rgbEditWidth ' vEdtTextG', '0')
        g.Add('Text', 'xs Section Right vTxtLabelTextB', 'B:')
        g.Add('Slider',  'ys w' sliderW ' NoTicks AltSubmit Range0-255 ToolTip vSliderTextB', 0).OnEvent('Change', 'HChangeSlider')
        g['SliderTextB'].Edit := g.Add('Edit', 'ys w' rgbEditWidth ' vEdtTextB', '0')

        ; background color sliders
        g.Add('Text', 'xs w' totalW ' Section Center vTxtLabelBackColor', 'Background color')
        lf.Hwnd := g['TxtLabelBackColor'].Hwnd
        lf.Apply()
        g.Add('Text', 'xs Section Right vTxtLabelBackR', 'R:').GetPos(, , &txtw)
        g.Add('Slider',  'ys w' sliderW ' NoTicks AltSubmit Range0-255 ToolTip vSliderBackR', 255).OnEvent('Change', 'HChangeSlider')
        g['SliderBackR'].Edit := g.Add('Edit', 'ys w' rgbEditWidth ' vEdtBackR', '255')
        g.Add('Text', 'xs Section Right vTxtLabelBackG', 'G:')
        g.Add('Slider',  'ys w' sliderW ' NoTicks AltSubmit Range0-255 ToolTip vSliderBackG', 2550).OnEvent('Change', 'HChangeSlider')
        g['SliderBackG'].Edit := g.Add('Edit', 'ys w' rgbEditWidth ' vEdtBackG', '255')
        g.Add('Text', 'xs Section Right vTxtLabelBackB', 'B:')
        g.Add('Slider',  'ys w' sliderW ' NoTicks AltSubmit Range0-255 ToolTip vSliderBackB', 255).OnEvent('Change', 'HChangeSlider')
        g['SliderBackB'].Edit := g.Add('Edit', 'ys w' rgbEditWidth ' vEdtBackB', '255')

        ; add buttons
        g['BtnGetBackColor'].GetPos(&edtx, &edty, &edtw, &edth)
        y := edty - edth - inputControlGroup.PaddingY
        g.Add('Button', 'x' edtx ' y' y ' w' inputControlGroup.ButtonWidth ' vBtnGetAll', 'Get all')
        g.Add('Button', 'x' (edtx + inputControlGroup.ButtonWidth + inputControlGroup.PaddingX) ' y' y ' w' inputControlGroup.ButtonWidth ' vBtnSetAll', 'Set all')
        g.Add('Button', 'x' (edtx - inputControlGroup.ButtonWidth - inputControlGroup.PaddingX) ' y' y ' w' inputControlGroup.ButtonWidth ' vBtnClearAll', 'Clear all')
        g['BtnGetAll'].OnEvent('Click', 'HClickButtonGetAll')
        g['BtnSetAll'].OnEvent('Click', 'HClickButtonSetAll')
        g['BtnClearAll'].OnEvent('Click', 'HClickButtonClearAll')

        ; add error display
        controls.Get('Weight').Set.GetPos(&btnx, &btny, &btnw, &btnh)
        controls.Get('Weight').Label.GetPos(&txtx)
        g.Add('Edit', 'x' txtx ' y' (btny + btnh + paddingY) ' w' (btnx + btnw - txtx) ' r' edtErrorRows ' vEdtError')

        ; add preview Xtooltip
        lb.GetPos(&lbx)
        lbTools.GetPos(, &lby, , &lbh)
        g['EdtBackG'].GetPos(&edtx, , &edtw)
        xttPreview := this.XttPreview := Xtooltip({ HwndParent: g.Hwnd, Name: 'Preview', Theme: previewTheme, AddStyle: TTS_ALWAYSTIP })
        xttPreview.AddTracking(0, 'Preview', , , false)
        xttPreview.TrackActivate(0, 1)
        xttPreview.BoundL := lbx
        xttPreview.BoundT := lby + lbh + PaddingY * 1.5
        xttPreview.BoundR := edtx + edtw
        xttPreview.BoundB := xttPreview.BoundT + previewDisplayHeight + paddingY * 1.5
        xttPreview.BoundW := xttPreview.BoundR - xttPreview.BoundL
        xttPreview.BoundH := xttPreview.BoundB - xttPreview.BoundT

        ; get a list of Xtooltips
        list := ['No selection']
        for name in Xtooltip.XttCollection {
            if name = 'Preview' {
                continue
            }
            list.Push(name)
        }
        lb.Add(list)

        this.WindowsHook := WindowsHook(12, HOOKPROC, , , true)
        global g_windowHookHandle := this.WindowsHook.Handle

        g['EdtError'].GetPos(, &sliy, , &slih)
        gwidth := right + g.MarginX
        gheight := sliy + slih + paddingY
        g.show('w' gwidth ' h' gheight ' ' showOptions)
        MoveXttPreview()
    }
}

class DemoEventHandler {
    static __New() {
        this.DeleteProp('__New')
        this.ListFont := [ 'Escapement', 'Italic', 'FaceName', 'Quality', 'FontSize', 'Strikeout', 'Underline', 'Weight']
    }
    GetFont(xtt) {
        lf := xtt.Font
        controls := Demo.Controls
        for prop in DemoEventHandler.ListFont {
            controls.Get(prop).Edit.Text := lf.%prop%
        }
    }
    GetGeneral(xtt) {
        for prop in XttTheme.ListGeneral {
            Demo.Controls.Get(prop).Edit.Text := xtt.%prop%
        }
    }
    GetMargin(xtt) {
        margin := xtt.GetMargin()
        for char in ['L', 'T', 'R', 'B'] {
            Demo.Controls.Get('Margin' char).Edit.Text := margin.%char%
        }
    }
    GetTitle(xtt) {
        Demo.Controls.Get('Title').Edit.Text := xtt.GetTitle(, &icon)
        Demo.Controls.Get('Icon').Edit.Text := icon
    }
    HChangeListBoxXtooltips_(lb, *) {
        if lb.Text {
            if lb.Text = 'No selection' {
                lb.Gui['LbTools'].Delete()
            } else {
                xtt := Xtooltip.XttCollection.Get(lb.Text)
                lb.Gui['LbTools'].Delete()
                lb.Gui['LbTools'].Add(['No selection', xtt.Tools.ToListKey()*])
            }
        }
    }
    HChangeListBoxTools_(lb, *) {
        g := lb.Gui
        if g['LbXtooltips'].Text && g['LbXtooltips'].Text != 'No selection' && lb.Text && lb.Text != 'No selection' {
            xttPreview := Demo.XttPreview
            xtt := Xtooltip.XttCollection.Get(g['LbXtooltips'].Text)
            g['EdtInputText'].Text := xtt.GetText(lb.Text)
            xttPreview.UpdateTipText(g['EdtInputText'].Text, 0)
            xttPreview.BackColor := xtt.BackColor
            xttPreview.TextColor := xtt.TextColor
            xtt.Font.Clone(xttPreview.Font, , false)
            xttPreview.Font.Apply()
            if title := xtt.GetTitle(, &icon) {
                xttPreview.SetTitle(icon, title)
            }
            xttPreview.SetMargin2(xtt.GetMargin())
            xttPreview.SetMaxWidth(xtt.GetMaxWidth())
            xttPreview.Update()
            MoveXttPreview()
            xttPreview.Update()
            this.SetSlider(xtt)
        }
    }
    HChangeEditInputText_(edt, *) {
        if edt.Text {
            Demo.XttPreview.UpdateTipText(edt.Text, 0)
        } else {
            Demo.XttPreview.UpdateTipText(' ', 0)
        }
        if edt.Gui['LbTools'].Text && edt.Gui['LbTools'].Text != 'No selection' {
            if edt.Text {
                Xtooltip.XttCollection.Get(edt.Gui['LbXtooltips'].Text).UpdateTipText(edt.Text, edt.Gui['LbTools'].Text)
            } else {
                Xtooltip.XttCollection.Get(edt.Gui['LbXtooltips'].Text).UpdateTipText(' ', edt.Gui['LbTools'].Text)
            }
        }
    }
    HClickButtonClearAll(btn, *) {
        for prop, group in Demo.Controls {
            group.Edit.Text := ''
        }
    }
    HClickButtonGet_(btn, *) {
        g := btn.Gui
        if g['LbXtooltips'].Text && g['LbXtooltips'].Text != 'No selection' {
            prop := StrReplace(btn.Name, 'BtnGet', '')
            edt := Demo.Controls.Get(prop).Edit
            xttPreview := Demo.XttPreview
            xtt := Xtooltip.XttCollection.Get(g['LbXtooltips'].Text)
            if InStr(',Escapement,Italic,FaceName,Quality,FontSize,Strikeout,Underline,Weight,', ',' prop ',') {
                edt.Text := xtt.Font.%prop%
            } else if InStr(',BackColor,MaxWidth,TextColor,', ',' prop ',') {
                edt.Text := xtt.%prop%
            } else if InStr(prop, 'Margin') {
                edt.Text := xtt.GetMargin().%SubStr(prop, -1, 1)%
            } else {
                title := xtt.GetTitle(, &icon)
                if prop = 'Title' {
                    Demo.Controls.Get('Title').Edit.Text := title
                } else {
                    Demo.Controls.Get('Icon').Edit.Text := icon
                }
            }
        }
    }
    HClickButtonGetAll_(btn, *) {
        g := btn.Gui
        if g['LbXtooltips'].Text && g['LbXtooltips'].Text != 'No selection' {
            xtt := Xtooltip.XttCollection.Get(g['LbXtooltips'].Text)
        } else {
            xtt := Demo.XttPreview
        }
        this.GetFont(xtt)
        this.GetTitle(xtt)
        this.GetGeneral(xtt)
        this.GetMargin(xtt)
    }
    HClickButtonSet_(btn, *) {
        prop := StrReplace(btn.Name, 'BtnSet', '')
        edt := Demo.Controls.Get(prop).Edit
        xttPreview := Demo.XttPreview
        g := btn.Gui
        if g['LbXtooltips'].Text && g['LbXtooltips'].Text != 'No selection' {
            xtt := Xtooltip.XttCollection.Get(g['LbXtooltips'].Text)
        }
        if InStr(',Escapement,Italic,FaceName,Quality,FontSize,Strikeout,Underline,Weight,', ',' prop ',') {
            xttPreview.Font.%prop% := edt.Text
            xttPreview.Font.Apply()
            if IsSet(xtt) {
                xtt.Font.%prop% := edt.Text
                xtt.Font.Apply()
            }
        } else if InStr(',BackColor,MaxWidth,TextColor,', ',' prop ',') {
            xttPreview.%prop% := edt.Text
            if IsSet(xtt) {
                xtt.%prop% := edt.Text
            }
        } else if InStr(prop, 'Margin') {
            if IsSet(xtt) {
                margin := xtt.GetMargin()
                margin.%SubStr(prop, -1, 1)% := g['EdtMargin' SubStr(prop, -1, 1)].Text
                xttPreview.SetMargin2(margin)
                xtt.SetMargin2(margin)
            } else {
                margin := xttPreview.GetMargin()
                margin.%SubStr(prop, -1, 1)% := g['EdtMargin' SubStr(prop, -1, 1)].Text
                xttPreview.SetMargin2(margin)
            }
        } else if prop = 'Icon' {
            xttPreview.SetTitle(Demo.Controls.Get('Icon').Edit.Text)
            if IsSet(xtt) {
                xtt.SetTitle(Demo.Controls.Get('Icon').Edit.Text)
            }
        } else if prop = 'Title' {
            xttPreview.SetTitle(0, Demo.Controls.Get('Title').Edit.Text)
            if IsSet(xtt) {
                xtt.SetTitle(0, Demo.Controls.Get('Title').Edit.Text)
            }
        }
        xttPreview.Update()
        if IsSet(xtt) {
            xtt.Update()
        }
    }
    HClickButtonSetAll_(btn, *) {
        g := btn.Gui
        if g['LbXtooltips'].Text && g['LbXtooltips'].Text != 'No selection' {
            xtt := Xtooltip.XttCollection.Get(g['LbXtooltips'].Text)
            this.SetFont(xtt)
            this.SetTitle(xtt)
            this.SetGeneral(xtt)
            this.SetMargin(xtt)
        }
        this.SetFont(Demo.XttPreview)
        this.SetTitle(Demo.XttPreview)
        this.SetGeneral(Demo.XttPreview)
        this.SetMargin(Demo.XttPreview)
    }
    HChangeSlider_(slider, *) {
        static xttPreview := Demo.XttPreview
        , g := slider.Gui
        , editTextR := g['EdtTextR']
        , editTextG := g['EdtTextG']
        , editTextB := g['EdtTextB']
        , editBackR := g['EdtBackR']
        , editBackG := g['EdtBackG']
        , editBackB := g['EdtBackB']
        , editTextColor := g['EdtTextColor']
        , edtBackColor := g['EdtBackColor']
        , lbXtooltips := g['LbXtooltips']
        , lastValue := 0, lastName := 0
        if slider.Name !== lastName || slider.Value !== lastValue {
            slider.Edit.Text := slider.Value
            lastValue := slider.Value
            lastName := slider.Name
            if InStr(slider.Name, 'Text') {
                xttPreview.SetTextColorRGB(editTextR.Text, editTextG.Text, editTextB.Text)
                if lbXtooltips.Text && lbXtooltips.Text != 'No selection' {
                    Xtooltip.XttCollection.Get(lbXtooltips.Text).SetTextColorRGB(editTextR.Text, editTextG.Text, editTextB.Text)
                }
                Demo.Controls.Get('TextColor').Edit.Text := xttPreview.GetTextColor()
            } else {
                xttPreview.SetBackColorRGB(editBackR.Text, editBackG.Text, editBackB.Text)
                if lbXtooltips.Text && lbXtooltips.Text != 'No selection' {
                    Xtooltip.XttCollection.Get(lbXtooltips.Text).SetBackColorRGB(editBackR.Text, editBackG.Text, editBackB.Text)
                }
                Demo.Controls.Get('BackColor').Edit.Text := xttPreview.GetBackColor()
            }
        }
    }
    SetSlider(xtt) {
        static g := Demo.Ui
        , editTextR := g['EdtTextR']
        , editTextG := g['EdtTextG']
        , editTextB := g['EdtTextB']
        , editBackR := g['EdtBackR']
        , editBackG := g['EdtBackG']
        , editBackB := g['EdtBackB']
        , sliderTextR := g['SliderTextR']
        , sliderTextG := g['SliderTextG']
        , sliderTextB := g['SliderTextB']
        , sliderBackR := g['SliderBackR']
        , sliderBackG := g['SliderBackG']
        , sliderBackB := g['SliderBackB']
        ParseColorRef(xtt.TextColor, &r, &g, &b)
        sliderTextR.Value := editTextR.Text := r
        sliderTextG.Value := editTextG.Text := g
        sliderTextB.Value := editTextB.Text := b
        ParseColorRef(xtt.BackColor, &r, &g, &b)
        sliderBackR.Value := editBackR.Text := r
        sliderBackG.Value := editBackG.Text := g
        sliderBackB.Value := editBackB.Text := b
    }
    SetFont(xtt) {
        lf := xtt.Font
        controls := Demo.Controls
        for prop in DemoEventHandler.ListFont {
            lf.%prop% := controls.Get(prop).Edit.Text
        }
        lf.Apply()
    }
    SetGeneral(xtt) {
        for prop in XttTheme.ListGeneral {
            xtt.%prop% := Demo.Controls.Get(prop).Edit.Text
        }
        xtt.Update()
    }
    SetMargin(xtt) {
        controls := Demo.Controls
        margin := xtt.GetMargin()
        if controls.Get('MarginL').Edit.Text {
            margin.L := controls.Get('MarginL').Edit.Text
        }
        if controls.Get('MarginT').Edit.Text {
            margin.T := controls.Get('MarginT').Edit.Text
        }
        if controls.Get('MarginR').Edit.Text {
            margin.R := controls.Get('MarginR').Edit.Text
        }
        if controls.Get('MarginB').Edit.Text {
            margin.B := controls.Get('MarginB').Edit.Text
        }
        xtt.SetMargin2(margin)
        xtt.Update()
    }
    SetTitle(xtt) {
        xtt.SetTitle(
            Demo.Controls.Get('Icon').Edit.Text
          , Demo.Controls.Get('Title').Edit.Text
        )
        xtt.Update()
    }
    __Call(Name, Params) {
        this.%Name '_'%(Params*)
        ; try {
        ;     this.%Name '_'%(Params*)
        ; } catch Error as err {
        ;     Demo.Ui['EdtError'].Text := (
        ;         'Message: ' err.Message '`r`n'
        ;         'Extra: ' err.Extra '`r`n'
        ;         'What: ' err.What '`r`n'
        ;         'Line: ' err.Line '`r`n'
        ;         'Stack:`r`n'
        ;         err.Stack
        ;         '`r`n===================`r`n'
        ;         Demo.Ui['EdtError'].Text
        ;     )
        ; }
    }
}

class DemoStrings {
    static Welcome := (
        'Welcome to the Xtooltip sandbox. Try hovering your mouse over the edit controls or buttons below on the left.'
        '`r`nTo modify an Xtooltip, select the Xtooltip in the list box. Change any of the'
        ' properties by typing new values into the edit controls and clicking "Set". To change an'
        ' Xtooltip`'s text, select a tool then modify the text in the edit control beneath "Xtooltips".'
        '`r`nThe color sliders are dynamic and update automatically as you slide the slider.'
        '`r`nIf you are running this in a debugger, there is a chance the preview tooltip persists'
        ' if you stop the script from the debugger.'
        '`r`nTo prevent this, always stop the script using the Exit button.'
    )
    static Edits := [
        'Demo edit control 1'
      , 'Demo edit control 2'
      , 'Demo edit control 3'
    ]
    static InputEdits := Map(
        'BackColor', 'Input as COLORREF or type "RGB(n, n, n)"'
      , 'Escapement', 'Tenths of degrees'
      , 'FaceName', 'Font name, e.g. "Roboto", "Consolas"'
      , 'FontSize', 'Points'
      , 'Icon', 'An integer between 1 and 6, inclusive. The "Title" property also must be set.'
      , 'Italic', '0 or 1'
      , 'MarginB', 'Positive integer'
      , 'MarginL', 'Positive integer'
      , 'MarginT', 'Positive integer'
      , 'MarginR', 'Positive integer'
      , 'MaxWidth', 'Positive integer'
      , 'Quality', 'An integer between 1 and 5, inclusive'
      , 'Strikeout', '0 or 1'
      , 'TextColor', 'Input as COLORREF or type "RGB(n, n, n)"'
      , 'Title', 'String'
      , 'Underline', '0 or 1'
      , 'Weight', 'An integer between 0 and 1000, inclusive'
    )
}

MoveXttPreview() {
    xttPreview := Demo.XttPreview
    g := Demo.Ui
    buf := Buffer(8)
    NumPut('int', xttPreview.BoundL, 'int', xttPreview.BoundT, buf)
    DllCall('ClientToScreen', 'ptr', g.Hwnd, 'ptr', buf, 'int')
    preRc := XttRect.Window(xttPreview.Hwnd)
    xttPreview.TrackPosition(
        Round(NumGet(buf, 0, 'int') + xttPreview.BoundW * 0.5 - 0.5 * preRc.W, 0)
      , Round(NumGet(buf, 4, 'int') + xttPreview.BoundH * 0.5 - 0.5 * preRc.H, 0) - 5
    )
}

/**
 * @param {Gui} G - The Gui object.
 * @param {String[]} - The list of properties to make controls for.
 * @param {Object} Options - Property:value pairs
 *
 * @param {Integer} Options.StartX - The start X coordinate.
 * @param {Integer} Options.StartY - The start Y coordinate.
 * @param {Integer} [Options.MaxY] - A threshold at which a new column will be started.
 * @param {Boolean} [Options.GetButton = true] - If true, a button to the right of the edit control
 * with the text "Get" is included.
 * @param {Boolean} [Options.SetButton = true] - If true, a button to the right of the edit control
 * with the text "Set" is included.
 * @param {Integer} [Options.EditWidth = 250] - The width of the edit controls.
 * @param {Integer} [Options.ButtonWidth = 80] - The width of the button controls.
 * StartX, StartY, MaxX?, MaxY?, GetBtn := true, SetBtn := true
 * @param {Integer} [Options.PaddingX = 5] - The padding to add between controls along the X axis.
 * @param {Integer} [Options.PaddingY = 5] - The padding to add between rows.
 * @param {Boolean} [Options.LabelAlignment = "Right"] - The alignment option to include with the
 * label controls.
 */
MakeInputControlGroup(G, PropList, Options) {
    local maxY := getButton := setButton := editWidth := buttonWidth := paddingX := paddingY := labelAlignment := 0
    x := Options.StartX
    y := startY := Options.StartY
    for prop, val in Map('maxY', '', 'getButton', true, 'setButton', true, 'editWidth', 250
    , 'buttonWidth', 80, 'paddingX', 5, 'paddingY', 5, 'labelAlignment', 'Right') {
        if HasProp(Options, prop) {
            %prop% := Options.%prop%
        } else {
            %prop% := val
        }
    }
    controls := Map()
    width := 0
    for prop in PropList {
        controls.Set(
            prop, group := {
                Label: G.Add('Text', 'x' x ' y' y ' ' labelAlignment ' vTxt' prop, prop ':')
              , Edit: G.Add('Edit', 'x' x ' y' y ' w' editWidth ' vEdt' prop)
            }
        )
        if getButton {
            group.Get := G.Add('Button', 'x' x ' y' y ' w' buttonWidth ' vBtnGet' prop, 'Get')
        }
        if setButton {
            group.Set := G.Add('Button', 'x' x ' y' y ' w' buttonWidth ' vBtnSet' prop, 'Set')
        }
        group.Label.GetPos(, , &txtw)
        if txtw > width {
            width := txtw
        }
    }
    x2 := x + width + paddingX
    x3 := x2 + editWidth + paddingX
    x4 := x3 + buttonWidth + paddingX
    if getButton {
        controls.Get(PropList[1]).Get.GetPos(, , , &rowh)
    } else if setButton {
        controls.Get(PropList[1]).Set.GetPos(, , , &rowh)
    } else {
        controls.Get(PropList[1]).Edit.GetPos(, , , &rowh)
    }
    controls.Get(PropList[1]).Edit.GetPos(, , , &edth)
    controls.Get(PropList[1]).Label.GetPos(, , , &txth)
    txtYOffset := (rowh - txth) / 2
    edtYOffset := (rowh - edth) / 2
    for prop, group in controls {
        group.Label.Move(x, y + txtYOffset, width)
        group.Edit.Move(x2, y + edtYOffset)
        if getButton {
            group.Get.Move(x3, y)
            if setButton {
                group.Set.Move(x4, y)
            }
        } else if setButton {
            group.Set.Move(x3, y)
        }
        y += edth + paddingY
        if maxY && y + edth > maxY {
            y := startY
            if getButton {
                if setButton {
                    x := x4 + buttonWidth + paddingX
                } else {
                    x := x3 + buttonWidth + paddingX
                }
            } else if setButton {
                x := x3 + buttonWidth + paddingX
            } else {
                x := x2 + editWidth + paddingX
            }
            x2 := x + width + paddingX
            x3 := x2 + editWidth + paddingX
            x4 := x3 + buttonWidth + paddingX
        }
    }
    return controls
}


HOOKPROC(code, wParam, lParam) {
    try {
        cwpret := CWPRETSTRUCT(lParam)
        switch cwpret.Message {
            case 71:
                MoveXttPreview()
        }
    } catch {
        DllCall('UnhookWindowsHookEx', 'ptr', g_windowHookHandle, 'int')
        return 0
    }
    return DllCall(
        'CallNextHookEx'
      , 'ptr', 0
      , 'int', code
      , 'uptr', wParam
      , 'ptr', lParam
      , 'ptr'
    )
}

ParseColorRef(colorref, &OutR?, &OutG?, &OutB?) {
    OutR := colorref & 0xFF
    OutG := (colorref >> 8) & 0xFF
    OutB := (colorref >> 16) & 0xFF
}

class CWPRETSTRUCT {
    static __New() {
        this.DeleteProp('__New')
        this.Prototype.Size :=
        A_PtrSize +         ; LRESULT (LONG_PTR)    lResult       0
        A_PtrSize +         ; LPARAM (LONG_PTR)     lParam        4
        A_PtrSize +         ; WPARAM (UINT_PTR)     wParam        8
        4 +                 ; UINT                  message       12
        A_PtrSize           ; HWND                  hwnd          16
    }
    __New(Ptr) {
        this.Ptr := Ptr
    }
    Result => NumGet(this, 0, 'ptr')
    lParam => NumGet(this, A_PtrSize, 'ptr')
    wParam => NumGet(this, A_PtrSize * 2, 'uptr')
    Message => NumGet(this, A_PtrSize * 3, 'uint')
    Hwnd => NumGet(this, A_PtrSize * 3 + 4, 'ptr')
}


class WindowPos {
    static __New() {
        this.DeleteProp('__New')
        this.Prototype.Size :=
        A_PtrSize +     ; HWND     hwnd
        A_PtrSize +     ; HWND     hwndInsertAfter
        4 +             ; int      x
        4 +             ; int      y
        4 +             ; int      cx
        4 +             ; int      cy
        4               ; UINT     flags
    }
    __New(Ptr) {
        this.Ptr := Ptr
    }
    Hwnd => NumGet(this, 0, 'ptr')
    HwndInsertAfter => NumGet(this, A_PtrSize, 'ptr')
    X => NumGet(this, A_PtrSize * 2, 'int')
    Y => NumGet(this, A_PtrSize * 2 + 4, 'int')
    W => NumGet(this, A_PtrSize * 2 + 8, 'int')
    H => NumGet(this, A_PtrSize * 2 + 12, 'int')
    Flags => NumGet(this, A_PtrSize * 2 + 16, 'uint')
    Drawframe => this.Flags & 0x0020
    Framechanged => this.Flags & 0x0020
    Hidewindow => this.Flags & 0x0080
    Noactivate => this.Flags & 0x0010
    Nocopybits => this.Flags & 0x0100
    Nomove => this.Flags & 0x0002
    Noownerzorder => this.Flags & 0x0200
    Noredraw => this.Flags & 0x0008
    Noreposition => this.Flags & 0x0200
    Nosendchanging => this.Flags & 0x0400
    Nosize => this.Flags & 0x0001
    Nozorder => this.Flags & 0x0004
    Showwindow => this.Flags & 0x0040
}

/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Win32/WindowsHook.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * Calls `SetWindowsHookExW`.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowshookexw}
 */
class WindowsHook {
    static __New() {
        this.DeleteProp('__New')
        Proto := this.Prototype
        Proto.Handle := Proto.lpfn := Proto.OnExitCallback := 0
    }
    /**
     * @class
     *
     * @param {Integer} idHook - The type of hook to be installed.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowshookexw}
     *
     * |  Hook Name           |  ID  |  Proc Type             |  lParam Points To       |  Use Case                                         |
     * |  --------------------|------|------------------------|-------------------------|-------------------------------------------------  |
     * |  WH_CALLWNDPROC      |  4   |  CallWndProc           |  CWPSTRUCT              |  Monitor before a message is processed            |
     * |  WH_CALLWNDPROCRET   |  12  |  CallWndRetProc        |  CWPRETSTRUCT           |  Monitor after a message is processed             |
     * |  WH_CBT              |  5   |  CBTProc               |  Varies by nnCode        |  Window activation, creation, move, resize, etc.  |
     * |  WH_DEBUG            |  9   |  DebugProc             |  DEBUGHOOKINFO          |  Debugging other hook procedures                  |
     * |  WH_FOREGROUNDIDLE   |  11  |  ForegroundIdleProc    |  lParam unused          |  Detect idle foreground thread                    |
     * |  WH_GETMESSAGE       |  3   |  GetMsgProc            |  MSG                    |  Intercept message queue on removal               |
     * |  WH_JOURNALPLAYBACK  |  1   |  JournalPlaybackProc   |  EVENTMSG               |  Replay input events (obsolete)                   |
     * |  WH_JOURNALRECORD    |  0   |  JournalRecordProc     |  EVENTMSG               |  Record input events (obsolete)                   |
     * |  WH_KEYBOARD         |  2   |  KeyboardProc          |  lParam = packed flags  |  Keyboard input (per-thread)                      |
     * |  WH_KEYBOARD_LL      |  13  |  LowLevelKeyboardProc  |  KBDLLHOOKSTRUCT        |  Global keyboard input                            |
     * |  WH_MOUSE            |  7   |  MouseProc             |  MOUSEHOOKSTRUCT        |  Mouse events (per-thread)                        |
     * |  WH_MOUSE_LL         |  14  |  LowLevelMouseProc     |  MSLLHOOKSTRUCT         |  Global mouse input                               |
     * |  WH_MSGFILTER        |  -1  |  MessageProc           |  MSG                    |  Pre-translate messages in modal loops            |
     * |  WH_SHELL            |  10  |  ShellProc             |  Varies by nnCode        |  Shell events (task switch, window create, etc.)  |
     * |  WH_SYSMSGFILTER     |  6   |  MessageProc           |  MSG                    |  Like WH_MSGFILTER, but system-wide               |
     *
     * @param {Func|BoundFunc} HookProc - The function that will be registered as the hook procedure.
     * You should read {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-HookProc}
     * before proceeding. Below is an example that uses the helper class `MouseHookStruct`. You can
     * run this example in the file "test-files\demo-MouseHookStruct.ahk".
     * @example
     *  #include <WindowsHook>
     *  #include <MouseHookStruct>
     *
     *  MouseProc(nCode, wParam, lParam) {
     *      if nCode == 0 {
     *          _mouseHookStruct := MouseHookStruct(lParam)
     *          OutputDebug('The mouse moved to ( ' _mouseHookStruct.X ', ' _mouseHookStruct.Y ' )`n')
     *      }
     *      return DllCall(
     *          'CallNextHookEx'
     *        , 'ptr', 0
     *        , 'int', nCode
     *        , 'uptr', wParam
     *        , 'ptr', lParam
     *        , 'ptr'
     *      )
     *  }
     *
     * @param {Integer} [Hmod = 0] - The handle to the module that contains the dll. Leave 0 unless
     * you are specifically using this with an external dll.
     *
     * @param {Integer} [dwThreadId] - The identifier of the thread with which the hook procedure is to
     * be associated. You cannot set this to zero when calling `SetWindowsHookExW` from AHK.
     * If unset, the return value from `GetWindowThreadProcessId` for `A_ScriptHwnd` is used. Leave
     * unset unless you are calling this function for a different process.
     *
     * @param {Boolean} [SetOnExit = true] - If true, sets an `OnExit` callback to call
     * `UnhookWindowsHookEx`. This is recommended by Microsoft:
     * "Before terminating, an application must call the UnhookWindowsHookEx function function to
     * free system resources associated with the hook."
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowshookexw}.
     *
     * If `DeferActivation` is true, `SetOnExit` is ignored.
     *
     * @param {Boolean} [DeferActivation = false] - If true, `SetWindowsHookExW` is not called, your
     * nCode must call `WindowsHook.Prototype.Hook`.
     */
    __New(idHook, HookProc, Hmod := 0, dwThreadId?, SetOnExit := true, DeferActivation := false) {
        this.idHook := idHook
        this.HookProc := HookProc
        this.Hmod := Hmod
        this.dwThreadId := dwThreadId ?? DllCall('GetWindowThreadProcessId', 'ptr', A_ScriptHwnd, 'ptr', 0, 'uint')
        if !DeferActivation {
            this.Hook(SetOnExit)
        }
    }

    Dispose(*) {
        if this.lpfn {
            CallbackFree(this.lpfn)
            this.lpfn := 0
        }
        this.HookProc := 0
        if this.Handle {
            return this.__UnhookWindowsEx()
        }
    }

    /**
     * @param {Boolean} [SetOnExit = true] - If true, sets an `OnExit` callback to call
     * `UnhookWindowsHookEx`. This is recommended by Microsoft:
     * "Before terminating, an application must call the UnhookWindowsHookEx function function to
     * free system resources associated with the hook."
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowshookexw}.
     */
    Hook(SetOnExit := true) {
        if this.Handle {
            throw Error('The hook is already active.', -1)
        }
        if !this.lpfn {
            this.lpfn := CallbackCreate(this.HookProc)
        }
        if this.Handle := DllCall(
            'SetWindowsHookExW'
          , 'int', this.idHook
          , 'ptr', this.lpfn
          , 'ptr', this.Hmod
          , 'uint', this.dwThreadId
          , 'int'
        ) {
            if SetOnExit {
                if !this.OnExitCallback {
                    this.OnExitCallback := ObjBindMethod(this, 'Unhook')
                }
                OnExit(this.OnExitCallback, 1)
            }
        } else {
            CallbackFree(this.lpfn)
            throw OSError()
        }
    }

    /**
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-unhookwindowshookex}
     * @returns {Boolean} - If the function succeeds, the return value is nonzero.
     * If the function fails, the return value is zero. To get extended error information, call `OSError`.
     * @throws {Error} - The hook is not currently active.
     */
    Unhook(*) {
        if this.Handle {
            return this.__UnhookWindowsEx()
        } else {
            throw Error('The hook is not currently active.', -1)
        }
    }
    __UnhookWindowsEx() {
        handle := this.Handle
        this.Handle := 0
        if this.OnExitCallback {
            OnExit(this.OnExitCallback, 0)
            this.OnExitCallback := 0
        }
        return DllCall('UnhookWindowsHookEx', 'ptr', Handle, 'int')
    }

    __Delete() {
        this.Dispose()
    }
}
