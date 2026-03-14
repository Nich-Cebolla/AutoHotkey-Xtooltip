
#SingleInstance force
#include ..\src\Xtooltip.ahk

/**
    This demonstrates the use of {@link XttPool}. {@link XttPool} is intended to be a convenient
    tool for displaying a tooltip at a specific location. It has
*/

test()

class test {
    static Call() {
        this.count := 0
        this.theme := XttTheme('light-blue', {
            BackColor: XttRgb(255, 255, 255)
          , FaceName: 'Segoe Ui'
          , FontSize: 12
          , Quality: 5
          , Margin: XttRect.Margin(3)
          , MaxWidth: 250
          , TextColor: XttRgb(0, 255, 255)
          , Weight: 700
        })
        this.group := XttThemeGroup('pool', this.theme)
        this.group.ThemeActivate('light-blue')
        global pool := XttPool(this.group)

        g := this.g := gui('+resize', , this)
        g.SetFont('s11 q5', 'Segoe Ui')
        this.lv := g.Add('ListView', 'w100 r4 -Hdr -Multi Section', [ '' ])
        this.lv.GetPos(&x, &y, &w, &h)
=
        controls := this.controls := MakeInputControlGroup(
            g,
            [ 'Text', 'Target', 'Duration', 'Dimension', 'Prefer', 'Padding', 'InsufficientSpaceAction' ],
            { getButton: false, setButton: false, startX: x + w + g.MarginX + 20, startY: y })
        this.available := g.Add('Text', 'x' x ' y' (y + h + g.MarginY) ' Section', 'Available: 0')
        this.available.GetPos(, , &w)
        this.available.Move(, , w + 50)
        (this.btnShowByMouse := g.Add('Button', 'xs', 'Show by mouse')).OnEvent('Click', 'HClickButtonShowByMouse')
        (this.btnShowByRect := g.Add('Button', 'xs', 'Show by rect')).OnEvent('Click', 'HClickButtonShowByRect')
        (this.btnRecallSelected := g.Add('Button', 'xs', 'Recall selected')).OnEvent('Click', 'HClickButtonRecallSelected')
        controls.Get('Text').Edit.Text := 'Hello, world!'
        controls.Get('Duration').Edit.Text := 0
        controls.Get('Prefer').Edit.Text := 'T'
        controls.Get('Dimension').Edit.Text := 'Y'
        controls.Get('Target').Edit.Text := 'A'
        g.Show()
        this.map := Map()


        this.theme2 := XttTheme('info', {
            BackColor: XttRgb(255, 255, 255)
          , FaceName: 'Segoe Ui'
          , FontSize: 12
          , Quality: 5
          , Margin: XttRect.Margin(3)
          , MaxWidth: 400
          , TextColor: XttRgb(255, 0, 235)
          , Weight: 400
        })
        infotip := this.infotip := Xtooltip({ theme: this.theme2, AddStyle: TTS_ALWAYSTIP })
        infotip.SetDelayTime(10000, 2)
        infotip.AddControl('Text', 'Input the text to display on the demo tooltip.', controls.Get('Text').Edit)
        infotip.AddControl('Target', 'Input a window handle (hwnd) or title to use the "Show by rect" button.', controls.Get('Target').Edit)
        infotip.AddControl('Duration', 'Input the duration to display the tooltip (milliseconds). A value of "0" causes the tooltip to display indefinitely until you click "Recall selected". You can spawn multiple, concurrent windows by leaving this "0", or try out the timer by inputting a number.', controls.Get('Duration').Edit)
        infotip.AddControl('Dimension', 'Input "X" or "Y" (see parameter "Dimension" of ``XttPool.Prototype.ShowByMouse`` / ``XttPool.Prototype.ShowByRect``).', controls.Get('Dimension').Edit)
        infotip.AddControl('Prefer', 'Input "L", "T", "R", or "B" (see parameter "Prefer" of ``XttPool.Prototype.ShowByMouse`` / ``XttPool.Prototype.ShowByRect``).', controls.Get('Prefer').Edit)
        infotip.AddControl('Padding', 'Input an integer (pixels) (see parameter "Padding" of ``XttPool.Prototype.ShowByMouse`` / ``XttPool.Prototype.ShowByRect``).', controls.Get('Padding').Edit)
        infotip.AddControl('InsufficientSpaceAction', 'See parameter "InsufficientSpaceAction" of ``XttPool.Prototype.ShowByMouse`` / ``XttPool.Prototype.ShowByRect``.', controls.Get('InsufficientSpaceAction').Edit)
        infotip.AddControl('ShowByMouse', 'Click to call ``XttPool.Prototype.ShowByMouse``.', this.btnShowByMouse)
        infotip.AddControl('ShowByRect', 'Click to call ``XttPool.Prototype.ShowByRect``.', this.btnShowByRect)
        infotip.AddControl('RecallSelected', 'Click to call ``XttPool.Item.Prototype.Call`` for the ``XttPool.Item`` object associated with the highlighted row in the list-view.', this.btnRecallSelected)

    }
    static HClickButtonShowByMouse(*) {
        controls := this.controls
        duration := controls.Get('Duration').Edit.Text
        item := pool.ShowByMouse(
            StrLen(controls.Get('Text').Edit.Text) ? controls.Get('Text').Edit.Text : unset,
            duration || 0,
            StrLen(controls.Get('Dimension').Edit.Text) ? controls.Get('Dimension').Edit.Text : unset,
            StrLen(controls.Get('Prefer').Edit.Text) ? controls.Get('Prefer').Edit.Text : unset,
            StrLen(controls.Get('Padding').Edit.Text) ? controls.Get('Padding').Edit.Text : unset)
        if duration {
            SetTimer(_AddCount, -Abs(duration) - 50)
        } else {
            this.map.Set(++this.count, item)
            this.lv.Add(, this.count)
        }
        this.available.Text := 'Available: ' pool.Length

        return

        _AddCount() {
            test.available.Text := 'Available: ' pool.Length
        }
    }
    static HClickButtonShowByRect(*) {
        controls := this.controls
        if target := controls.Get('Target').Edit.Text {
            if IsNumber(target) {
                target := Number(target)
            } else if WinExist(target) {
                target := WinExist(target)
            } else {
                pool.ShowByMouse('Window not found.', 2000)
                SetTimer(_AddCount, -2050)
                return
            }
        } else {
            pool.ShowByMouse('Enter a window title or hwnd in the "Target" box.', 2000)
            SetTimer(_AddCount, -2050)
            return
        }
        duration := controls.Get('Duration').Edit.Text
        item := pool.ShowByRect(
            StrLen(controls.Get('Text').Edit.Text) ? controls.Get('Text').Edit.Text : unset,
            target,
            duration || 0,
            unset,
            StrLen(controls.Get('Dimension').Edit.Text) ? controls.Get('Dimension').Edit.Text : unset,
            StrLen(controls.Get('Prefer').Edit.Text) ? controls.Get('Prefer').Edit.Text : unset,
            StrLen(controls.Get('Padding').Edit.Text) ? controls.Get('Padding').Edit.Text : unset,
            StrLen(controls.Get('InsufficientSpaceAction').Edit.Text) ? controls.Get('InsufficientSpaceAction').Edit.Text : unset)
        if duration {
            SetTimer(_AddCount, -Abs(duration) - 50)
        } else {
            this.map.Set(++this.count, item)
            this.lv.Add(, this.count)
        }
        this.available.Text := 'Available: ' pool.Length

        return

        _AddCount() {
            test.available.Text := 'Available: ' pool.Length
        }
    }
    static HClickButtonRecallSelected(*) {
        if row := this.lv.GetNext() {
            n := Number(this.lv.GetText(row, 1))
            test.map.Get(n).Call()
            test.map.Delete(n)
            this.lv.Delete(row)
            this.available.Text := 'Available: ' pool.Length
        } else {
            pool.ShowByMouse('A row in the list-view must be selected.', 2000)
            SetTimer(_AddCount, -2050)
        }

        return

        _AddCount() {
            test.available.Text := 'Available: ' pool.Length
        }
    }
}


/**
 * `MakeInputControlGroup` is a function that creates a group of controls in a series of rows and
 * columns, where each row is associated with a particular input item from the parameter `LabelList`.
 * The types of controls that can be created are:
 * 1. Text control - a label indicating what value to input.
 * 2. Edit control - the edit that accepts input from the user.
 * 3. Button control - a button that says "Get".
 * 4. Button control - a button that says "Set".
 *
 * The buttons "Get" and "Set" are optional; that is, you can choose to have zero, one, or both
 * of each in each row. This function does not currently allow customizing the controls on an
 * individual-row basis; each row must have the same controls.
 *
 * You can customize how the controls are named to a degree, but ultimately the format for the
 * names is: `prefix RegExReplace(label, "\W", "")`. The `RegExReplace` expression removes all
 * non-word characters. For example, if the prefix for a control is "BtnGet", and the label for
 * the group is "Option 1", then that control's name is "BtnGetOption1".
 *
 * For a demo, see "test-files\demo-MakeInputControlGroup.ahk".
 *
 * @param {Gui} G - The Gui object.
 *
 * @param {String[]} LabelList - The list of labels for each control group.
 *
 * @param {Object} Options - Property:value pairs
 * @param {Integer} [Options.StartX] - The start X coordinate. If unset, `G.MarginX` is used.
 * @param {Integer} [Options.StartY] - The start Y coordinate. If unset, `G.MarginY` is used.
 * @param {Integer} [Options.MaxY] - A threshold at which a new column will be started.
 * @param {Boolean} [Options.GetButton = true] - If true, a button to the right of the edit control
 * with the text "Get" is included.
 * @param {Boolean} [Options.SetButton = true] - If true, a button to the right of the edit control
 * with the text "Set" is included.
 * @param {Integer} [Options.EditWidth = 250] - The width of the edit controls.
 * @param {Integer} [Options.ButtonWidth = 80] - The width of the button controls.
 * @param {Integer} [Options.PaddingX = 5] - The padding to add between controls along the X axis.
 * @param {Integer} [Options.PaddingY = 5] - The padding to add between rows.
 * @param {Boolean} [Options.LabelAlignment = "Right"] - The alignment option to include with the
 * label controls.
 * @param {String} [Options.LabelPrefix = "Txt"] - The literal string that prefixes the labels.
 * @param {String} [Options.EditPrefix = "Edt"] - The literal string that prefixes the edit controls.
 * @param {String} [Options.GetButtonPrefix = "BtnGet"] - The literal string that prefixes the name
 * of the "Get" buttons.
 * @param {String} [Options.SetButtonPrefix = "BtnSet"] - The literal string that prefixes the name
 * of the "Set" buttons.
 * @param {String} [Options.NameSuffix = ""] - The literal string that will be appended to all
 * control names.
 */
MakeInputControlGroup(G, LabelList, Options?) {
    local maxY := getButton := setButton := editWidth := buttonWidth := paddingX := paddingY :=
    labelAlignment := labelPrefix := editPrefix := getButtonPrefix := setButtonPrefix := nameSuffix := 0
    if !IsSet(Options) {
        Options := {}
    }
    x := HasProp(Options, 'StartX') ? Options.StartX : G.MarginX
    y := startY := HasProp(Options, 'StartY') ? Options.StartY : G.MarginY
    for prop, val in Map('maxY', '', 'getButton', true, 'setButton', true, 'editWidth', 250
    , 'buttonWidth', 80, 'paddingX', 5, 'paddingY', 5, 'labelAlignment', 'Right'
    , 'labelPrefix', 'Txt', 'editPrefix', 'Edt', 'getButtonPrefix', 'BtnGet', 'setButtonPrefix', 'BtnSet'
    , 'nameSuffix', ''
    ) {
        if HasProp(Options, prop) {
            %prop% := Options.%prop%
        } else {
            %prop% := val
        }
    }
    controls := Map()
    controls.NameSuffix := nameSuffix
    width := 0
    for label in LabelList {
        _label := RegExReplace(label, '\W', '')
        controls.Set(
            label, group := {
                Label: G.Add('Text', 'x' x ' y' y ' ' labelAlignment ' v' labelPrefix _label nameSuffix, label ':')
              , Edit: G.Add('Edit', 'x' x ' y' y ' w' editWidth ' v' editPrefix _label nameSuffix)
            }
        )
        if getButton {
            group.Get := G.Add('Button', 'x' x ' y' y ' w' buttonWidth ' v' getButtonPrefix _label nameSuffix, 'Get')
        }
        if setButton {
            group.Set := G.Add('Button', 'x' x ' y' y ' w' buttonWidth ' v' setButtonPrefix _label nameSuffix, 'Set')
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
        controls.Get(LabelList[1]).Get.GetPos(, , , &rowh)
    } else if setButton {
        controls.Get(LabelList[1]).Set.GetPos(, , , &rowh)
    } else {
        controls.Get(LabelList[1]).Edit.GetPos(, , , &rowh)
    }
    controls.Get(LabelList[1]).Edit.GetPos(, , , &edth)
    controls.Get(LabelList[1]).Label.GetPos(, , , &txth)
    txtYOffset := (rowh - txth) / 2
    edtYOffset := (rowh - edth) / 2
    for label in LabelList {
        group := controls.Get(label)
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
