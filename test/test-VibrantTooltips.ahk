; #include C:\Users\Shared\001_Repos\temp2\temp1.ahk
#include <RGB>
test.GetText()

!t::HClickButtonHide()
!y::HClickButtonShow()
; !g::test.sendmsg()
HClickButtonHide() {
    SendMessage(1041, 0, test.tiTracking.Ptr, test.hwndTracking) ; TTM_TRACKACTIVATE
}
HClickButtonShow() {
    SendMessage(1041, 1, test.tiTracking.Ptr, test.hwndTracking) ; TTM_TRACKACTIVATE
}



class test {

    static __New() {
        var := 'tooltips_class32'
        this.ClassName := Buffer(StrPut(var, 'UTF-16'))
        StrPut(var, this.ClassName, 'UTF-16')
        test_DeclareGlobalVars()
    }
    static Call() {
        className := Buffer(StrPut('tooltips_class32', 'UTF-16'))
        StrPut('tooltips_class32', className, 'UTF-16')
        g := this.g := Gui()
        btn := this.btn := g.Add('Button', 'w100 r1 vBtn', 'Button')
        hwnd := this.hwnd := DllCall(
            'CreateWindowExW'
          , 'uint', 0                       ; dwExStyle
          , 'ptr', className                ; lpClassName
          , 'ptr', 0                        ; lpWindowName
          , 'uint', 0x01                    ; dwStyle - TTS_ALWAYSTIP
          , 'int', 0x80000000               ; X - CW_USEDEFAULT
          , 'int', 0x80000000               ; Y - CW_USEDEFAULT
          , 'int', 0x80000000               ; nWidth - CW_USEDEFAULT
          , 'int', 0x80000000               ; nHeight - CW_USEDEFAULT
          , 'ptr', g.hwnd                   ; hWndParent
          , 'ptr', 0                        ; hMenu
          , 'ptr', 0                        ; hInstance
          , 'ptr', 0                        ; lpParam
        )
        outputdebug(A_LineNumber ' :: getparent: ' DllCall('GetParent', 'ptr', test.hwnd, 'ptr') '`n')
        WinSetAlwaysOnTop(true, hwnd)
        if hresult := DllCall('UxTheme.dll\SetWindowTheme', 'ptr', hwnd, 'ptr', 0, 'str', '', 'uint') {
            throw OSError('``SetWindowTheme`` failed.', -1, hresult)
        }
        ti := ToolInfo(hwnd, g.Hwnd, btn.Hwnd)
        ti.Text := 'Hello, world!'
        ti.Flags := 0x0001 | 0x0010 ; TTF_IDISHWND | TTF_SUBCLASS
        SendMessage(1044, RGB(255, 0, 0), 0, this.Hwnd) ; TTM_SETTIPTEXTCOLOR
        SendMessage(1043, RGB(0, 0, 0), , , this.Hwnd) ; TTM_SETTIPBKCOLOR
        SendMessage(1074, 0, ti.Ptr, hwnd) ; TTM_ADDTOOLW
        SendMessage(1025, true, 0, hwnd) ; TTM_ACTIVATE
        ; SendMessage(1081, 0, ti.Ptr, hwnd) ; TTM_UPDATETIPTEXTW
        btn.getpos(&btnx, &btny, , &btnh)
        y := btny + btnh + g.marginy
        g.add('edit', 'x' (btnx + 100) ' y' y ' w10 h100')
        g.add('edit', 'x' btnx ' y' (y + 100) ' w100 h10 Section')
        g.Add('Button', 'xs Section vBtnShow', 'Show').OnEvent('Click', HClickButtonShow)
        g.Add('Button', 'xs Section vBtnHide', 'Hide').OnEvent('Click', HClickButtonHide)
        g.Add('Button', 'xs Section vBtnMove', 'Move').OnEvent('Click', HClickButtonMove)
        g.add('Edit', 'ys w70 vEdtX')
        g.Add('edit', 'ys w70 vEdtY')
        g.Add('Button', 'xs Section vBtnMove2', 'Move2').OnEvent('Click', HClickButtonMove2)
        g.add('Edit', 'ys w50 vEdtX2')
        g.Add('edit', 'ys w50 vEdtY2')
        g.add('Edit', 'ys w50 vEdtW2')
        g.Add('edit', 'ys w50 vEdtH2')
        g.Add('button', 'xs Section vBtnMakeRect', 'Make XttRect tt').OnEvent('Click', HClickButtonMakeRect)
        g.Add('button', 'xs Section vBtnMakeTracking', 'Make tracking tt').OnEvent('Click', HClickButtonMakeTracking)
        y := 15
        x := 130
        _MakeList(['R', 'G', 'B'], &_x, &_y, &_w, &_h)
        x := _x
        y := _y + _h + g.marginy
        g.Add('Button', 'x' x ' y' y ' Section vBtnSetTextColor', 'Set text color').OnEvent('Click', HClickSetTextColor)
        g.Add('Button', 'xs vBtnSetBackColor', 'Set back color').OnEvent('Click', HClickSetBackColor)
        x := _x + _w + g.marginx
        y := 15
        _MakeList(['L', 'T', 'R2', 'B2'], &_x, &_y, &_w, &_h)
        x := _x
        y := _y + _h + g.marginy
        g.Add('Button', 'x' x ' y' y ' vBtnSetMargin', 'Set margin').OnEvent('Click', HClickButtonSetMargin)
        x := _x + _w + g.marginx
        y := 15
        _MakeList2(['FaceName', 'ClipPrecision', 'Escapement', 'Italic', 'Orientation'
        , 'OutPrecision', 'Pitch', 'Family', 'Quality', 'FontSize', 'Strikeout', 'Underline'
        , 'Weight'], HClickButtonFontGeneral, &_x, &_y, &_w, &_h)

        lf := this.lf := g.lf := XttFont(hwnd)
        lf()

        g.Show('x20 y20 NoActivate')

        return
        _MakeList(list, &outx?, &outy?, &outw?, &outh?) {
            width := 0
            for s in list {
                txt := g.Add('Text', 'x' x ' y' y ' vTxt' s, s ':')
                txt.GetPos(, , &txtw, &txth)
                txt.x := x
                txt.y := y
                if txtw > width {
                    width := txtw
                }
                y += g.marginy * 2 + txth
            }
            x += width + g.marginx
            for s in list {
                txt := g['Txt' s]
                txt.Move(, , width)
                g.add('Edit', 'x' x ' y' txt.y ' w100 vEdt' s)
            }
            g['Edt' list[-1]].GetPos(&outx, &outy, &outw, &outh)
        }
        _MakeList2(list, Callback, &outx?, &outy?, &outw?, &outh?) {
            width := 0
            for s in list {
                txt := g.Add('Text', 'x' x ' y' y ' vTxt' s, s ':')
                txt.GetPos(, , &txtw, &txth)
                txt.x := x
                txt.y := y
                if txtw > width {
                    width := txtw
                }
                y += g.marginy * 2 + txth
            }
            x += width + g.marginx
            for s in list {
                txt := g['Txt' s]
                txt.Move(, , width)
                g.add('Edit', 'x' x ' y' txt.y ' w100 vEdt' s)
                g.add('button', 'x' (x + 100 + g.marginx) ' y' txt.y ' vBtn' s, s).OnEvent('Click', Callback)
            }
            g['Edt' list[-1]].GetPos(&outx, &outy, &outw, &outh)
        }
        HClickButtonMakeRect(Ctrl, *) {
            g := Ctrl.GUi
            g['Btn'].GetPos(&btnx, &btny, , &btnh)
            ti2 := ToolInfo(hwnd, g.Hwnd, 1)
            ti2.Text := 'Goodbye, world!'
            ti2.Flags := 0x0010 ; TTF_SUBCLASS
            y := btny + btnh + g.marginy
            ti2.L := btnx
            ti2.T := y
            ti2.R := btnx + 100
            ti2.B := y + 100
            SendMessage(1074, 0, ti2.Ptr, hwnd) ; TTM_ADDTOOLW
        }
        HClickButtonFontGeneral(Ctrl, *) {
            g := Ctrl.Gui
            name := SubStr(ctrl.Name, 4)
            lf := g.lf
            lf.%name% := g['Edt' name].Text || 0
            lf.Apply()
        }
        HClickButtonMakeTracking(Ctrl, *) {
            thwnd := this.thwnd := this.hwnd
            ; thwnd := this.thwnd := DllCall(
            ;     'CreateWindowExW'
            ;   , 'uint', 0x00000008              ; dwExStyle - WS_EX_TOPMOST
            ;   , 'ptr', className                ; lpClassName
            ;   , 'ptr', 0                        ; lpWindowName
            ;   , 'uint', 0x01                    ; dwStyle - TTS_ALWAYSTIP
            ;   , 'int', 0x80000000               ; X - CW_USEDEFAULT
            ;   , 'int', 0x80000000               ; Y - CW_USEDEFAULT
            ;   , 'int', 0x80000000               ; nWidth - CW_USEDEFAULT
            ;   , 'int', 0x80000000               ; nHeight - CW_USEDEFAULT
            ;   , 'ptr', A_ScriptHwnd             ; hWndParent
            ;   , 'ptr', 0                        ; hMenu
            ;   , 'ptr', 0                        ; hInstance
            ;   , 'ptr', 0                        ; lpParam
            ; )
            tit := this.tit := ToolInfo(thwnd, A_ScriptHwnd, 1)
            tit.Flags := 0x0080 | 0x0020
            tit.Text := 'Big money'
            SendMessage(1074, 0, tit.Ptr, thwnd) ; TTM_ADDTOOLW
            SendMessage(1025, true, 0, thwnd) ; TTM_ACTIVATE
        }
        HClickButtonHide(Ctrl, *) {
            SendMessage(1041, 0, this.tit.Ptr, this.thwnd) ; TTM_TRACKACTIVATE
        }
        HClickButtonShow(Ctrl, *) {
            SendMessage(1041, 1, this.tit.Ptr, this.thwnd) ; TTM_TRACKACTIVATE
        }
        HClickButtonMove(Ctrl, *) {
            g := ctrl.gui
            SendMessage(1042, 0, (Number(g['EdtY'].text) << 16) | (Number(g['EdtX'].text) & 0xFFFF), this.thwnd) ; TTM_TRACKPOSITION
        }
        HClickButtonMove2(Ctrl, *) {
            g := ctrl.gui
            WinMove(
                g['EdtX2'].Text || unset
              , g['EdtY2'].Text || unset
              , g['EdtW2'].Text || unset
              , g['EdtH2'].Text || unset
              , this.thwnd
            )
        }
        HClickButtonSetMargin(Ctrl, *) {
            g := ctrl.Gui
            SetMargin(
                g['EdtL'].Text || 0
              , g['EdtT'].Text || 0
              , g['EdtR2'].Text || 0
              , g['EdtB2'].Text || 0
            )
        }
        HClickSetBackColor(Ctrl, *) {
            g := ctrl.Gui
            SendMessage(
                1043
              , RGB(
                    g['EdtR'].Text || 0
                  , g['EdtG'].Text || 0
                  , g['EdtB'].Text || 0
                )
              , 0
              , this.Hwnd
            ) ; TTM_SETTIPBKCOLOR
        }

        HClickSetTextColor(Ctrl, *) {
            g := ctrl.Gui
            SendMessage(
                1044
              , RGB(
                    g['EdtR'].Text || 0
                  , g['EdtG'].Text || 0
                  , g['EdtB'].Text || 0
                )
              , 0
              , this.Hwnd
            ) ; TTM_SETTIPTEXTCOLOR
        }
        GetMargin() {
            rc := XttRect()
            SendMessage(1051, 0, rc.Ptr, this.Hwnd) ; TTM_GETMARGIN
            return rc
        }
        SetMargin(Left?, Top?, Right?, Bottom?) {
            rc := GetMargin()
            if IsSet(Left) {
                rc.L := Left
            }
            if IsSet(Top) {
                rc.T := Top
            }
            if IsSet(Right) {
                rc.R := Right
            }
            if IsSet(Bottom) {
                rc.B := Bottom
            }
            SendMessage(0x041A, 0, rc.Ptr, this.Hwnd)         ; TTM_SETMARGIN
            return rc
        }
    }

    /**
     * This test is to test the VTooltip constructor
     */
    static Constructor() {
        g := this.g := Gui()
        btn := this.btn := g.Add('Button', 'w100 r1', 'button')
        g.show('x100 y20')
        ; vtt := VTooltip('Hello, world!', 20, 20)
        ; tiParams := vtt.GetParamsControl(btn)
    }

    static MakeTrackingTooltip(text) {
        hwndTracking := this.hwndTracking := DllCall(
            'CreateWindowExW'
          , 'uint', WS_EX_TOPMOST           ; dwExStyle - WS_EX_TOPMOST
          , 'ptr', this.ClassName           ; lpClassName
          , 'ptr', 0                        ; lpWindowName
          , 'uint', TTS_ALWAYSTIP           ; dwStyle - TTS_ALWAYSTIP
          , 'int', 0x80000000               ; X - CW_USEDEFAULT
          , 'int', 0x80000000               ; Y - CW_USEDEFAULT
          , 'int', 0x80000000               ; nWidth - CW_USEDEFAULT
          , 'int', 0x80000000               ; nHeight - CW_USEDEFAULT
          , 'ptr', A_ScriptHwnd             ; hWndParent
          , 'ptr', 0                        ; hMenu
          , 'ptr', 0                        ; hInstance
          , 'ptr', 0                        ; lpParam
        )
        WinSetAlwaysOnTop(true, hwndTracking)
        if hresult := DllCall('UxTheme.dll\SetWindowTheme', 'ptr', hwndTracking, 'ptr', 0, 'str', '', 'uint') {
            throw OSError('``SetWindowTheme`` failed.', -1, hresult)
        }
        tiParams := { hwndTracking: hwndTracking, Hwnd: A_ScriptHwnd, Id: 1, Flags: TTF_ABSOLUTE | TTF_TRACK, Text: text }
        ti := ToolInfo(hwndTracking, A_ScriptHwnd, 1)
        ti.Flags := TTF_ABSOLUTE | TTF_TRACK
        ti.Text := text
        SendMessage(TTM_SETMAXTIPWIDTH, 0, 200, hwndTracking)
        SendMessage(TTM_ADDTOOLW, 0, ti.Ptr, hwndTracking)
        SendMessage(TTM_ACTIVATE, true, 0, hwndTracking)
        return tiParams
    }

    /**
     * This is to test if TTM_GETCURRENTTOOL also gets the text.
     *
     * Conclusion: If the character count exceeds a threshold, probably 160, then TTM_GETCURRENTTOOL
     * does not get the text. Beneath that threshold, it does.
     *
     * Also, setting the max width seems to be a prerequisite for multi-line tooltip.
     */
    static GetCurrentTool_text() {
        ; make original tooltip
        str := '1234567890'
        s := ''
        loop 10 {
            s .= str '`n'
        }
        outputdebug(A_LineNumber ' :: ' strlen(s) '`n')
        this.tiParamsTracking := tiParams := this.MakeTrackingTooltip(s)
        ti := ToolInfo(tiParams.hwndTracking, tiParams.hwnd, tiParams.Id, StrPut(s, 'UTF-16'))
        this.bufTracking := ti.TextBuffer
        this.tiTracking := ti
        SendMessage(TTM_GETCURRENTTOOLW, 0, this.tiTracking.Ptr, this.tiParamsTracking.hwndTracking)
        outputdebug(A_LineNumber ' :: ' strlen(strget(this.bufTracking, 'UTF-16')) '`n')
    }

    /**
     * This is to test TTM_GETTEXT to see if there are any quirks with very long strings.
     * Conclusion: No quirks. The below code behaved as expected; first buffer received full string,
     * second buffer received half string, third buffer received full string.
     */
    static GetText() {
        ; make original tooltip
        str := '123456789012345678901234567890'
        s := ''
        loop 50 {
            s .= str '`n'
        }
        outputdebug(A_LineNumber ' :: ' strlen(s) '`n')
        tiParams := this.MakeTrackingTooltip(s)

        ; Get the whole string
        ti := ToolInfo(tiParams.hwndTracking, tiParams.hwnd, tiParams.Id, StrPut(s, 'UTF-16'))
        SendMessage(TTM_GETTEXTW, Round(ti.TextBuffer.Size / 2, 0), ti.Ptr, tiParams.hwndTracking)
        outputdebug(A_LineNumber ' :: ' strlen(strget(ti.TextBuffer, 'UTF-16')) '`n')

        ; Get part of the string
        ti := ToolInfo(tiParams.hwndTracking, tiParams.hwnd, tiParams.Id, StrPut(s, 'UTF-16'))
        SendMessage(TTM_GETTEXTW, Round(StrLen(s) / 2, 0), ti.Ptr, tiParams.hwndTracking)
        outputdebug(A_LineNumber ' :: ' strlen(strget(ti.TextBuffer, 'UTF-16')) '`n')

        ; Oversize the buffer
        ti := ToolInfo(tiParams.hwndTracking, tiParams.hwnd, tiParams.Id, StrPut(s, 'UTF-16') + 250)
        SendMessage(TTM_GETTEXTW, Round(ti.TextBuffer.Size / 2, 0), ti.Ptr, tiParams.hwndTracking)
        outputdebug(A_LineNumber ' :: ' strlen(strget(ti.TextBuffer, 'UTF-16')) '`n')
    }

    /**
     * This test is to make sure TTM_SETTOOLINFO works the way that I'm understanding it to work.
     */
    static AddToolActivate() {
        ; make original tooltip
        str := '1234567890'
        s := ''
        _GetStr(20)
        hwnd := ToolTip(s, 20, 20, 1)

        sleep 250

        ; make new toolinfo
        ti := ToolInfo(hwnd)
        str := '0987654321'
        s := ''
        _GetStr(5)
        g := this.g := Gui()
        btn := this.btn := g.Add('Button', 'w100 r1', 'button')
        g.show('x100 y20')
        ti.Hwnd := g.hwnd
        ti.Id := btn.hwnd
        ti.flags := 0x0001 | 0x0010
        buf := Buffer(strput(s, 'utf-16'))
        StrPut(s, buf, 'utf-16')
        NumPut('ptr', buf.Ptr, ti, 24 + A_PtrSize * 3) ; lpszText

        ; add the tool
        SendMessage(1074, 0, ti.Ptr, Hwnd) ; TTM_ADDTOOLW

        sleep 250

        ; Get tool count
        OutputDebug('Count: ' SendMessage(1037, 0, 0, hwnd) '`n') ; TTM_GETTOOLCOUNT

        ; Send TTM_SETTOOLINFOW using the same ToolInfo
        SendMessage(1078, 0, ti.Ptr, hwnd)  ; TTM_SETTOOLINFOW

        sleep 250

        ; Update the tooltip
        SendMessage(1053, 0, 0, hwnd) ; TTM_UPDATE

        sleep 250

        ; Send TTM_GETCURRENTTOOLW
        ti2 := ToolInfo(hwnd)
        buf := Buffer(StrPut(s, 'utf-16'))
        NumPut('ptr', buf.Ptr, ti2, 24 + A_PtrSize * 3) ; lpszText
        SendMessage(1083, 0, ti2.Ptr, hwnd)  ; TTM_GETCURRENTTOOLW


        OutputDebug(
            'ti.hwnd == ' ti.Hwnd '`n'
            'ti2.hwnd == ' ti2.hwnd '`n'
            'A_ScriptHwnd == ' A_ScriptHwnd '`n'
            'btn.hwnd == ' btn.hwnd '`n'
            'ti2.text:`n'
            ti2.text
        )

        _GetStr(n) {
            loop n {
                s .= A_Index ' ' str '`n'
            }
        }
    }
}



class ToolInfo {
    static __New() {
        this.DeleteProp('__New')
        this.Size :=
        ;   size          member        type        offset
            4 +         ; cbSize        uint         0
            4 +         ; uFlags        uint         4
            A_PtrSize + ; Hwnd          Hwnd         8
            A_PtrSize + ; uId           UINT_PTR     8 + A_PtrSize
            16 +        ; XttRect          XttRect         8 + A_PtrSize * 2
            A_PtrSize + ; hinst         HINSTANCE   24 + A_PtrSize * 2
            A_PtrSize + ; lpszText      LPTSTR      24 + A_PtrSize * 3
            A_PtrSize + ; lParam        LPARAM      24 + A_PtrSize * 4
            A_PtrSize   ; lpReserved    void        24 + A_PtrSize * 5
        this.Index := 0
    }
    static GetUid() {
        return ++this.Index
    }
    __New(ttHwnd, Text?, toolHwnd?, uId?) {
        this.ttHwnd := ttHwnd
        this.Buffer := Buffer(ToolInfo.Size, 0)
        NumPut('uint', ToolInfo.Size, this) ; cbSize
        if IsSet(Text) {
            this.SetText(Text)
        }
        if IsSet(toolHwnd) {
            this.Hwnd := toolHwnd
        }
        if IsSet(uId) {
            this.Id := uId
        }
    }
    GetBubbleSize(&OutWidth?, &OutHeight?) {
        if sz := SendMessage(TTM_GETBUBBLESIZE, 0, this.Ptr, this.ttHwnd) {
            OutWidth := sz & 0xFFFF
            OutHeight := (sz >> 16) & 0xFFFF
            return sz
        } else {
            return 0
        }
    }
    GetTitle() {
        buf := Buffer(A_PtrSize + 12)
        NumPut('uint', buf.Size, buf)
        SendMessage(TTM_GETTITLE, 0, buf.Ptr, this.Hwnd)
        return StrGet(NumGet(buf, 12, 'ptr'), NumGet(buf, 8, 'uint'))
    }
    /**
     * @description - Sets the `lpszText` member.
     *
     * @param {String|Buffer} [Value] - The text to display on the tooltip, or a buffer containing
     * the text.
     */
    SetText(Value) {
        if Value is Buffer {
            this.TextBuffer := Value
        } else {
            this.TextBuffer := Buffer(StrPut(Value, 'UTF-16'))
            StrPut(Value, this.TextBuffer, 'UTF-16')
        }
        NumPut('ptr', this.TextBuffer.Ptr, this, 24 + A_PtrSize * 3) ; lpszText
    }
    SetTextPtr(Buf) {
        if Buf is Buffer {
            NumPut('ptr', Buf.Ptr, this, 24 + A_PtrSize * 3)
            this.TextBuffer := Buf
        } else {
            throw TypeError('Expected an integer or a Buffer.', -1)
        }
    }
    /**
     * @description - Sets the `lpszText` member then sends TTM_UPDATETIPTEXTW.
     *
     * @param {String|Buffer} [Value] - The text to display on the tooltip, or a buffer containing
     * the text.
     */
    UpdateText(Value) {
        this.SetText(Value)
        SendMessage(TTM_UPDATETIPTEXTW, 0, this.Ptr, this.ttHwnd)
    }
    SetToolInfo() {
        if !this.TextPtr {
            this.__ThrowLpszTextError()
        }
        return SendMessage(TTM_SETTOOLINFOW, 0, this.Ptr, this.ttHwnd)
    }
    __ThrowLpszTextError() {
        ; If you get this error, you must assign something to the lpszText member before sending
        ; the TTM message. The lpszText member is a pointer to a buffer that will receive the
        ; tooltip's text contents. If your code only uses methods provided by this library to
        ; manipulate the tooltip, then the length of the string should be the same
        ; as the value of the property "TextLen" on the `Xtooltip` object. If your code cannot
        ; guarantee that only the methods provided by this library have been used to manipulate
        ; the tooltip, then you should set the size of the buffer to 160, which is the maximum
        ; that will be returned by TTM_GETTOOLINFO (80 TCHARS = 160 bytes). In terms of character
        ; length, 160 bytes is 79 characters (leaving 1 byte for the null terminator).
        throw Error('A value has not been assigned to the lpszText member.', -1)
    }
    B {
        Get => NumGet(this, 20 + A_PtrSize * 2, 'uint')
        Set {
            NumPut('uint', Value, this, 20 + A_PtrSize * 2)
        }
    }
    Flags {
        Get => NumGet(this, 4, 'uint')
        Set {
            NumPut('uint', Value, this, 4)
        }
    }
    Hwnd {
        Get => NumGet(this, 8, 'ptr')
        Set {
            NumPut('ptr', Value, this, 8)
        }
    }
    hInstance {
        get => NumGet(this, 24 + A_PtrSize * 2, 'ptr')
        set {
            NumPut('ptr', Value, 24 + A_PtrSize * 2)
        }
    }
    Id {
        Get => NumGet(this, 8 + A_PtrSize, 'ptr')
        Set {
            NumPut('ptr', Value, this, 8 + A_PtrSize)
        }
    }
    L {
        Get => NumGet(this, 8 + A_PtrSize * 2, 'uint')
        Set {
            NumPut('uint', Value, this, 8 + A_PtrSize * 2)
        }
    }
    lParam {
        Get => NumGet(this, 24 + A_PtrSize * 4, 'uint')
        Set {
            NumPut('ptr', Value, this, 24 + A_PtrSize * 4)
        }
    }
    Ptr => this.Buffer.Ptr
    R {
        Get => NumGet(this, 16 + A_PtrSize * 2, 'uint')
        Set {
            NumPut('uint', Value, this, 16 + A_PtrSize * 2)
        }
    }
    Size => this.Buffer.Size
    Text {
        Get => this.TextPtr ? StrGet(this.TextPtr, 'UTF-16') : ''
        Set {
            this.SetText(Value)
        }
    }
    TextPtr {
        Get => NumGet(this, 24 + A_PtrSize * 3, 'ptr')
        Set => this.SetTextPtr(Value)
    }
    T {
        Get => NumGet(this, 12 + A_PtrSize * 2, 'uint')
        Set {
            NumPut('uint', Value, this, 12 + A_PtrSize * 2)
        }
    }

    /**
     * @classdesc - The purpose of `ToolInfo.Params` is to simplify the process of activating
     * a tool with its needed values. Tooltips have several general behavior patterns available
     * from the Windows API, each requiring a particular configuration. To activate a tool using
     * `TTM_SETTOOLINFO` or `TTM_ADDTOOL`, Microsoft recommends getting the tooltip's current
     * `TTTOOLINFO` struct and modifying the needed members, instead of creating a new `TTTOOLINFO`
     * struct.
     * {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-settoolinfo}.
     *
     * `Xtooltip` instances have a number of methods intended to help facilitate this process.
     * The general concept is:
     * - The `Xtooltip` object has a property "Tools" set with a `ToolInfoParamsCollection`
     *   object. This is used to store and retrieve references to `ToolInfo.Params` objects.
     * - The method `Xtooltip.Prototype.AddTool` has parameters `Key` and `tiParams`. `Key` is the
     *   key used to access the item from the collection. `tiParams` is an object with property:value
     *   pairs representing the members that must be updated when activating the tool associated with
     *   those parameters.
     * - The `ToolInfo.Params` objects can also include an array of callback functions that
     *   will be called before `ToolInfo.Prototype.Call` returns.
     * - To activate a tool, pass the key to `Xtooltip.Prototype.SetToolInfo`. This will get the
     *   current `ToolInfo` struct and copy the values from the `ToolInfo.Params` object to the
     *   `ToolInfo` properties, which are mapped to `TTTOOLINFO` members.
     *   - If you set the parameter `DeferActivation` to a nonzero value, the `ToolInfo` object
     *     is returned without sending TTM_SETTOOLINFO to give your code an opportunity to make
     *     any adjustments. When your code is ready to send `TTM_SETTOOLINFO`, you can send it by
     *     calling `ToolInfo.Prototype.SetToolInfo`.
     *   - If `DeferActivation` is falsy (the default is `0`) then `TTM_SETTOOLINFO` is sent
     *     before `Xtooltip.Pototype.SetToolInfo` returns.
     */
    class Params {
        static __New() {
            this.DeleteProp('__New')
            this.Prototype.Props := ['Flags', 'Hwnd', 'Id', 'L', 'T', 'R', 'B', 'hInstance', 'lParam']
        }
        /**
         * @description - Sets the base of the object to `ToolInfo.Params.Prototype` and validates
         * the object to ensure the needed information is present and to ensue there are not conflicting
         * values.
         *
         * This webpage contains the members of the `TTTOOLINFO` structure:
         * {@link https://learn.microsoft.com/en-us/windows/win32/api/commctrl/ns-commctrl-tttoolinfoa}.
         *
         * These webpages contain instructions and guidance for creating a tooltip:
         * - How to create a tooltip for a gui control:
         * {@link https://learn.microsoft.com/en-us/windows/win32/controls/create-a-tooltip-for-a-control}.
         * - How to create a tooltip for a rectangular area:
         * {@link https://learn.microsoft.com/en-us/windows/win32/controls/create-a-tooltip-for-a-rectangular-area}.
         * - How to implement tracking tooltips (note this library does not implement TTM_TRACKACTIVATE
         *   nor TTM_TRACKPOSITION):
         * {@link https://learn.microsoft.com/en-us/windows/win32/controls/implement-tracking-tooltips}.
         * - How to implement multiline tooltips:
         * {@link https://learn.microsoft.com/en-us/windows/win32/controls/implement-multiline-tooltips}.
         * - How to implement balloon tooltips:
         * {@link https://learn.microsoft.com/en-us/windows/win32/controls/implement-balloon-tooltips}.
         * - How to implement tooltips for status bar icons:
         * {@link https://learn.microsoft.com/en-us/windows/win32/controls/implement-tooltips-for-status-bar-icons}.
         * - How to implement in-place tooltips:
         * {@link https://learn.microsoft.com/en-us/windows/win32/controls/implement-in-place-tooltips}.
         *
         * @param {Xtooltip} XtooltipObj - The `Xtooltip` object.
         *
         * @param {Object} Params - An object with property:value pairs.
         *
         * @param {Integer} [Params.Flags] - One or more flags to assign to the member `uFlags`.
         * To combine values, use the bitwise "or" (e.g. `Params.Flags := 0x0020 | 0x0080`).
         * For descriptions of these flags see
         * {@link https://learn.microsoft.com/en-us/windows/win32/api/commctrl/ns-commctrl-tttoolinfoa}.
         * - TTF_IDISHWND            0x0001
         * - TTF_CENTERTIP           0x0002
         * - TTF_RTLREADING          0x0004
         * - TTF_SUBCLASS            0x0010
         * - TTF_TRACK               0x0020
         * - TTF_ABSOLUTE            0x0080
         * - TTF_TRANSPARENT         0x0100
         * - TTF_PARSELINKS          0x1000
         * - TTF_DI_SETITEM          0x8000       // valid only on the TTN_NEEDTEXT callback
         *
         * @param {Integer} Params.Hwnd - The handle to the window that contains the tool. This is
         * required.
         *
         * @param {Integer} [Params.Id] - The Windows API requires the member "uId" member when
         * activating a tool. "uId" is either a control's window handle, or an application-defined
         * unique identifier. To learn more about this member, read seaction "Supporting Tools"
         * here: {@link https://learn.microsoft.com/en-us/windows/win32/controls/tooltip-controls}.
         *
         * @param {Integer} [Params.L] -
         * @param {Integer} [Params.T] -
         * @param {Integer} [Params.R] -
         * @param {Integer} [Params.B] - For tooltips that support tools implemented as rectangular
         * areas within a window's client area, the "XttRect" member defines the client coordinates of
         * the area's bounding rectangle. For tooltips that support tools implemented as windows or
         * as in-place tooltips, the "XttRect" member is not used.
         *
         * @param {String|Buffer} [Params.Text] - If the text will be updated when the tool is activated,
         * set "Text" with either the string, or a `Buffer` object containing the string. If
         * `Params.Text` is a string, `ToolInfo.Params.Call` will create a buffer object containing
         * the string and assign it to the "Text" property, overwriting the string with the buffer.
         *
         * @param {Integer} [Params.hInstance] - You can leave this unset. Microsoft's
         * description states: Handle to the instance that contains the string resource for the tool.
         * If lpszText specifies the identifier of a string resource, this member is used.
         *
         * @param {Integer} [Params.lParam] - You can leave this unset. Microsoft's
         * description states: A 32-bit application-defined value that is associated with the tool.
         *
         * @param {Array} [Params.Callbacks] - An array of `Func` or callable objects that will be
         * called when activating the tool. The functions will receive:
         * 1. The `Xtooltip` object.
         * 2. The `ToolInfo` object.
         * 3. The `ToolInfo.Params` object.
         *
         * If a function returns a nonzero value, no further callbacks in the array will be called.
         *
         * @returns {ToolInfo.Params}
         *
         * @throws {TypeError|PropertyError} - See {@link ToolInfo.Params.Validate} for error details.
         */
        static Call(XtooltipObj, Params) {
            ObjSetBase(Params, this.Prototype)
            params.ttHwnd := XtooltipObj.Hwnd
            this.Validate(Params)
            return Params
        }
        /**
         * @description - Creates a generic `ToolInfo.Params` object for general use.
         * @param {Xtooltip} XtooltipObj - The `Xtooltip` object.
         * @param {Integer} [ParentHwnd] - If set, the handle to the tooltip's parent window. If
         * unset, `A_ScriptHwnd` is used.
         * @param {Integer} [Id] - The value to assign to the "uId" member of `TTTOOLINFO`. If unset,
         * `ToolInfo.Params.GetTracking` will assign the value.
         * @param {String|Buffer} [Text] - If set, the string that the tooltip will display or a buffer
         * containing the string.
         * @returns {ToolInfo.Params}
         */
        static GetTracking(XtooltipObj, ParentHwnd?, Id?, Text?) {
            tiParams := { ttHwnd: XtooltipObj.Hwnd, Hwnd: ParentHwnd ?? A_ScriptHwnd, Id: uId ?? ToolInfo.GetUid(), Flags: TTF_ABSOLUTE | TTF_TRACK }
            if IsSet(Text) {
                if IsObject(Text) {
                    tiParams.Text := Text
                } else {
                    tiParams.Text := Buffer(StrPut(Text, 'UTF-16'))
                    StrPut(Text, tiParams.Text, 'UTF-16')
                }
            }
            ObjSetBase(tiParams, this.Prototype)
            return tiParams
        }
        /**
         * @description - Creates a `ToolInfo.Params` object with the needed values to associate
         * a tooltip with a `Gui.Control`.
         * @param {Xtooltip} XtooltipObj - The `Xtooltip` object.
         * @param {Gui.Control} Ctrl - The `Gui.Control` object.
         * @param {String|Buffer} [Text] - If set, the string that the tooltip will display or a buffer
         * containing the string.
         * @returns {ToolInfo.Params}
         */
        static GetControl(XtooltipObj, Ctrl, Text?) {
            tiParams := { ttHwnd: XtooltipObj.Hwnd, Hwnd: Ctrl.Gui.Hwnd, Id: Ctrl.Hwnd, Flags: TTF_IDISHWND | TTF_SUBCLASS }
            if IsSet(Text) {
                if IsObject(Text) {
                    tiParams.Text := Text
                } else {
                    tiParams.Text := Buffer(StrPut(Text, 'UTF-16'))
                    StrPut(Text, tiParams.Text, 'UTF-16')
                }
            }
            ObjSetBase(tiParams, this.Prototype)
            return tiParams
        }
        /**
         * @description - Gets a `ToolInfo.Params` object. If any of `L`, `T`, `R`, or `B` are
         * unset, `ToolInfo.Params.GetRect` will assign that property with the relevant value
         * from the window itself.
         * @param {Xtooltip} XtooltipObj - The `Xtooltip` object.
         * @param {Integer} parentHwnd - The handle to the window containing the rectangle.
         * @param {Integer} [L] - The left client coordinate position.
         * @param {Integer} [T] - The top client coordinate position.
         * @param {Integer} [R] - The right client coordinate position.
         * @param {Integer} [B] - The bottom client coordinate position.
         * @param {Integer} [Id] - The value to assign to the "uId" member of `TTTOOLINFO`. If unset,
         * `ToolInfo.Params.GetTracking` will assign the value.
         * @param {String|Buffer} [Text] - If set, the string that the tooltip will display or a buffer
         * containing the string.
         * @returns {ToolInfo.Params}
         */
        static GetRect(XtooltipObj, parentHwnd, L?, T?, R?, B?, Id?, Text?) {
            tiParams := { ttHwnd: XtooltipObj.Hwnd, Hwnd: parentHwnd, Id: Id ?? ToolInfo.GetUid(), Flags: TTF_SUBCLASS }
            if IsSet(Text) {
                if IsObject(Text) {
                    tiParams.Text := Text
                } else {
                    tiParams.Text := Buffer(StrPut(Text, 'UTF-16'))
                    StrPut(Text, tiParams.Text, 'UTF-16')
                }
            }
            rc := XttRect.Window(parentHwnd)
            tiParams.L := L ?? rc.L
            tiParams.T := T ?? rc.T
            tiParams.R := R ?? rc.R
            tiParams.B := B ?? rc.B
            ObjSetBase(tiParams, this.Prototype)
            return tiParams
        }
        /**
         * @description - Creates a `ToolInfo.Params` object with the needed values to associate
         * a tooltip with a window.
         * @param {Xtooltip} XtooltipObj - The `Xtooltip` object.
         * @param {Integer} ToolHwnd - The handle to the window to which the tooltip will be
         * associated.
         * @param {Integer} [ParentHwnd] - If the window represented by `toolHwnd` has a parent window,
         * set `parentHwnd` with the handle to the parent window. Else, leave `parentHwnd` unset
         * and `ToolInfo.Params.GetWindow` will assign the "hwnd" member of `TTTOOLINFO` with
         * the same value as `toolHwnd`.
         * @param {String|Buffer} [Text] - If set, the string that the tooltip will display or a buffer
         * containing the string.
         * @returns {ToolInfo.Params}
         */
        static GetWindow(XtooltipObj, ToolHwnd, ParentHwnd?, Text?) {
            if !IsSet(parentHwnd) {
                ParentHwnd := DllCall('GetAncestor', 'ptr', toolHwnd, 'uint', 1, 'ptr')
                if !ParentHwnd {
                    OutputDebug(A_LineNumber ' :: ' A_ThisFunc ' :: Failed to get parent window :: ' OSError().Message '`n')
                    ParentHwnd := ToolHwnd
                }
            }
            tiParams := { ttHwnd: XtooltipObj.Hwnd, Hwnd: ParentHwnd, Id: ToolHwnd, Flags: TTF_IDISHWND | TTF_SUBCLASS }
            if IsSet(Text) {
                if IsObject(Text) {
                    tiParams.Text := Text
                } else {
                    tiParams.Text := Buffer(StrPut(Text, 'UTF-16'))
                    StrPut(Text, tiParams.Text, 'UTF-16')
                }
            }
            ObjSetBase(tiParams, this.Prototype)
            return tiParams
        }
        /**
         * @param {ToolInfo.Params|Object} tiParams - The `ToolInfo.Params` object. If the value does not
         * inherit from `ToolInfo.Params`, the base of the object is changed to `ToolInfo.Params.Prototype`.
         * @returns {ToolInfo.Params} - If the value passed to `tiParams` inherits from `ToolInfo.Params`,
         * then the return value is the same object. Else, the return value is result of changing
         * the base of the input value to `ToolInfo.Params.`
         * @throws {TypeError} - The property "<prop>" must be a <type>.
         * @throws {PropertyError} - The property "ttHwnd" is required.
         * @throws {PropertyError} - The flag `TTF_IDISHWND` in use, but the property "Hwnd" is unset.
         * @throws {PropertyError} - The flag `TTF_IDISHWND` is in use, but the property "Id" is unset.
         * @throws {PropertyError} - If at least one of properties "L", "T", "R", or "B", is set, then all four must be set.
         */
        static Validate(tiParams) {
            if not tiParams is ToolInfo.Params {
                ObjSetBase(tiParams, this.Prototype)
            }
            if !HasProp(tiParams, 'ttHwnd') {
                ; If you get this error, "ttHwnd" should be the tooltip's handle, i.e. `XtooltipObj.Hwnd`.
                throw PropertyError('The property "ttHwnd" is required.', -1)
            }
            if HasProp(tiParams, 'Flags') {
                if !IsNumber(tiParams.Flags) {
                    throw _TypeError('Flags')
                }
                if tiParams.Flags & 0x0001 {
                    if !HasProp(tiParams, 'Hwnd') {
                        ; If you get this error, you must set "Hwnd" with the handle to the parent
                        ; of "Id". If "Id" does not have a parent window, then set "Hwnd" to the same
                        ; value as "Id".
                        throw PropertyError('The flag ``TTF_IDISHWND`` in use, but the property "Hwnd" is unset.', -1)
                    }
                    if !HasProp(tiParams, 'Id') {
                        ; If you get this error, you must set "Id" with the handle to the window that
                        ; is the tool that this `ToolInfo` object represents. For example, by passing
                        ; a `Gui.Control` object to `Xtooltip.Prototype.GetToolControl` or to
                        ; `Xtooltip.Prototype.GetToolWindow`.
                        throw PropertyError('The flag ``TTF_IDISHWND`` in use, but the property "Id" is unset.', -1)
                    }
                }
            }
            if !HasProp(tiParams, 'Hwnd') {
                tiParams.DefineProp('Hwnd', { Value: A_ScriptHwnd })
            }
            if !IsNumber(tiParams.Hwnd) {
                throw _TypeError('Hwnd')
            }
            if HasProp(tiParams, 'Text') && !IsObject(tiParams.Text) {
                buf := Buffer(StrPut(tiParams.Text, 'UTF-16'))
                StrPut(tiParams.Text, buf, 'UTF-16')
                tiParams.Text := buf
            }
            ct := 0
            for prop in ['L', 'T', 'R', 'B'] {
                if HasProp(tiParams, prop) {
                    if !IsNumber(tiParams.%prop%) {
                        throw _TypeError(prop)
                    }
                    ct++
                }
            }
            switch ct {
                case 0,  4: ; do nothing
                default: throw PropertyError('If at least one of properties "L", "T", "R", or "B", is set, then all four must be set.', -1)
            }
            if HasProp(tiParams, 'hInstance') && !IsNumber(tiParams.hInstance) {
                throw _TypeError('hInstance')
            }
            if HasProp(tiParams, 'lParam') && !IsNumber(tiParams.lParam) {
                throw _TypeError('lParam')
            }
            if HasProp(tiParams, 'Callbacks') && not tiParams.Callbacks is Array {
                throw _TypeError('Callbacks', 'Array')
            }
            if HasProp(tiParams, 'Id') {
                if !IsNumber(tiParams.Id) {
                    throw _TypeError('Id')
                }
            } else {
                tiParams.Id := ToolInfo.GetUid()
            }

            return tiParams

            _TypeError(prop, _type := 'number') {
                return TypeError('The property "' prop '" must be a ' _type '.', -2)
            }
        }
        /**
         * @description - The purpose of `ToolInfo.Params.Prototype.Call` is to prepare a
         * `TTTOOLINFO` structure with new values before sending TTM_SETTOOLINFO.
         *
         * `ToolInfo.Params.Prototype.Call` validates the property values on this object, gets the
         * current `TTTOOLINFO` structure from the `Xtooltip` object by sending TTM_GETCURRENTTOOLW,
         * updates the members using the values of the properties on this object, then returns the
         * updated `ToolInfo` object.
         */
        Call(XtooltipObj) {
            ToolInfo.Params.Validate(this)
            if !XtooltipObj.GetCurrentTool(&ti) {
                ti.Hwnd := this.Hwnd
                ti.Id := this.Id
            }
            for prop in this.Props {
                if HasProp(this, prop) {
                    ti.%prop% := this.%prop%
                }
            }
            if HasProp(this, 'Text') {
                if not this.Text is Buffer {
                    buf := Buffer(StrPut(this.Text, 'UTF-16'))
                    StrPut(this.Text, buf, 'UTF-16')
                    this.Text := buf
                }
                this.TextSize := this.Text.Size
                ti.SetTextPtr(this.Text)
                this.DeleteProp('Text')
            }
            if HasProp(this, 'Callbacks') {
                for cb in this.Callbacks {
                    if cb(XtooltipObj, ti, this) {
                        break
                    }
                }
            }
            return ti
        }
    }
}

class XttRect {
    static Window(Hwnd) {
        rc := this()
        DllCall('GetWindowRect', 'ptr', Hwnd, 'ptr', rc, 'int')
    }
    static Client(Hwnd) {
        rc := this()
        DllCall('GetClientRect', 'ptr', Hwnd, 'ptr', rc, 'int')
    }
    static Dwma(Hwnd) {
        rc := this()
        if hresult := DllCall(
            'Dwmapi.dll\DwmGetWindowAttribute'
          , 'ptr', Hwnd
          , 'uint', 9       ; DWMWA_EXTENDED_FRAME_BOUNDS
          , 'ptr', rc
          , 'uint', rc.Size
          , 'uint'
        ) {
            throw OsError('DwmGetWindowAttribute failed.', -1, hresult)
        }
    }

    __New(L?, T?, R?, B?) {
        this.Buffer := Buffer(16)
        for prop in ['L', 'T', 'R', 'B'] {
            if IsSet(%prop%) {
                this.%prop% := %prop%
            }
        }
    }
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
    L {
        Get => NumGet(this, 0, 'int')
        Set {
            NumPut('int', Value, this, 0)
        }
    }
    T {
        Get => NumGet(this, 4, 'int')
        Set {
            NumPut('int', Value, this, 4)
        }
    }
    R {
        Get => NumGet(this, 8, 'int')
        Set {
            NumPut('int', Value, this, 8)
        }
    }
    B {
        Get => NumGet(this, 12, 'int')
        Set {
            NumPut('int', Value, this, 12)
        }
    }
    W {
        Get => this.R - this.L
        Set {
            NumPut('int', this.L + Value, this, 8)
        }
    }
    H {
        Get => this.B - this.T
        Set {
            NumPut('int', this.T + Value, this, 12)
        }
    }
}


test_DeclareGlobalVars() {
    global

    ; TTM - tooltip messages

    TTM_ACTIVATE := 1025
    TTM_ADDTOOLW := 1074
    TTM_ADJUSTRECT := 1055
    TTM_DELTOOLW := 1075
    TTM_ENUMTOOLSW := 1082
    TTM_GETBUBBLESIZE := 1054
    TTM_GETCURRENTTOOLW := 1083
    TTM_GETDELAYTIME := 1045
    TTM_GETMARGIN := 1051
    TTM_GETMAXTIPWIDTH := 1049
    TTM_GETTEXTW := 1080
    TTM_GETTIPBKCOLOR := 1046
    TTM_GETTIPTEXTCOLOR := 1047
    TTM_GETTITLE := 1059
    TTM_GETTOOLCOUNT := 1037
    TTM_GETTOOLINFOW := 1077
    TTM_HITTESTW := 1079
    TTM_NEWTOOLRECTW := 1076
    TTM_POP := 1052
    TTM_POPUP := 1058
    TTM_RELAYEVENT := 1031
    TTM_SETDELAYTIME := 1027
    TTM_SETMARGIN := 1050
    TTM_SETMAXTIPWIDTH := 1048
    TTM_SETTIPBKCOLOR := 1043
    TTM_SETTIPTEXTCOLOR := 1044
    TTM_SETTITLEW := 1057
    TTM_SETTOOLINFOW := 1078
    TTM_TRACKACTIVATE := 1041
    TTM_TRACKPOSITION := 1042
    TTM_UPDATE := 1053
    TTM_UPDATETIPTEXTW := 1081
    TTM_WINDOWFROMPOINT := 1040

    ; TTF - tooltip flags

    TTF_ABSOLUTE := 0x0080
    TTF_CENTERTIP := 0x0002
    TTF_DI_SETITEM := 0x8000
    TTF_IDISHWND := 0x0001
    TTF_PARSELINKS := 0x1000
    TTF_RTLREADING := 0x0004
    TTF_SUBCLASS := 0x0010
    TTF_TRACK := 0x0020
    TTF_TRANSPARENT := 0x0100

    ; TTS - tooltip styles

    TTS_ALWAYSTIP := 0x01
    TTS_BALLOON := 0x40
    TTS_CLOSE := 0x80
    TTS_NOANIMATE := 0x10
    TTS_NOFADE := 0x20
    TTS_NOPREFIX := 0x02
    TTS_USEVISUALSTYLE := 0x100 ; #if (NTDDI_VERSION >= NTDDI_VISTA)

    ; WS - window styles

    WS_BORDER := 0x00800000
    WS_CAPTION := 0x00C00000
    WS_CHILD := 0x40000000
    WS_CHILDWINDOW := 0x40000000
    WS_CLIPCHILDREN := 0x02000000
    WS_CLIPSIBLINGS := 0x04000000
    WS_DISABLED := 0x08000000
    WS_DLGFRAME := 0x00400000
    WS_GROUP := 0x00020000
    WS_HSCROLL := 0x00100000
    WS_ICONIC := 0x20000000
    WS_MAXIMIZE := 0x01000000
    WS_MAXIMIZEBOX := 0x00010000
    WS_MINIMIZE := 0x20000000
    WS_MINIMIZEBOX := 0x00020000
    WS_OVERLAPPED := 0x00000000
    WS_POPUP := 0x80000000
    WS_SIZEBOX := 0x00040000
    WS_SYSMENU := 0x00080000
    WS_TABSTOP := 0x00010000
    WS_THICKFRAME := 0x00040000
    WS_TILED := 0x00000000
    WS_VISIBLE := 0x10000000
    WS_VSCROLL := 0x00200000
    WS_POPUPWINDOW := WS_POPUP | WS_BORDER | WS_SYSMENU
    WS_TILEDWINDOW := WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX
    WS_OVERLAPPEDWINDOW := WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX

    ; WS_EX - window extended styles

    WS_EX_ACCEPTFILES := 0x00000010
    WS_EX_APPWINDOW := 0x00040000
    WS_EX_CLIENTEDGE := 0x00000200
    WS_EX_COMPOSITED := 0x02000000
    WS_EX_CONTEXTHELP := 0x00000400
    WS_EX_CONTROLPARENT := 0x00010000
    WS_EX_DLGMODALFRAME := 0x00000001
    WS_EX_LAYERED := 0x00080000
    WS_EX_LAYOUTRTL := 0x00400000
    WS_EX_LEFT := 0x00000000
    WS_EX_LEFTSCROLLBAR := 0x00004000
    WS_EX_LTRREADING := 0x00000000
    WS_EX_MDICHILD := 0x00000040
    WS_EX_NOACTIVATE := 0x08000000
    WS_EX_NOINHERITLAYOUT := 0x00100000
    WS_EX_NOPARENTNOTIFY := 0x00000004
    WS_EX_NOREDIRECTIONBITMAP := 0x00200000
    WS_EX_RIGHT := 0x00001000
    WS_EX_RIGHTSCROLLBAR := 0x00000000
    WS_EX_RTLREADING := 0x00002000
    WS_EX_STATICEDGE := 0x00020000
    WS_EX_TOOLWINDOW := 0x00000080
    WS_EX_TOPMOST := 0x00000008
    WS_EX_TRANSPARENT := 0x00000020
    WS_EX_WINDOWEDGE := 0x00000100
    WS_EX_OVERLAPPEDWINDOW := WS_EX_WINDOWEDGE | WS_EX_CLIENTEDGE
    WS_EX_PALETTEWINDOW := WS_EX_WINDOWEDGE | WS_EX_TOOLWINDOW | WS_EX_TOPMOST

    CW_USEDEFAULT := 0x80000000
    WM_SETFONT := 0x0030
    WM_USER := 1024
}


/**
 * @class
 * @description - A wrapper around the LOGFONT structure.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/dimm/ns-dimm-logfontw}
 */
class XttFont {
    static __New() {
        this.DeleteProp('__New')
        this.Prototype.Encoding := 'UTF-16'
    }
    /**
     * @description - Returns the first font facename that exists on the system from a list
     * of names.
     * @param {String|String[]} FaceNames - If an array, an array of font typeface names. If a string,
     * a comma-separated list of font typeface names.
     * @param {Buffer|TxtFont} [Logfont] - If set, a buffer representing a `LOGFONT` struct, or
     * a `TxtFont` object. Pass a value to `Logfont` if there are other characteristics which you
     * want to include in the search.
     * @returns {String} - Returns the first found name from the list, if one is found. Else, returns
     * an empty string.
     */
    static FontExist(FaceNames, Logfont?, Callback?) {
        static maxLen := 32
        , encoding := 'UTF-16'
        if !IsObject(FaceNames) {
            FaceNames := StrSplit(FaceNames, ',', '`s')
        }
        if !IsSet(Logfont) {
            Logfont := Buffer(92, 0) ; LOGFONTW struct size = 92 bytes
        }
        if IsSet(Callback) {
            cb := CallbackCreate(Callback)
        } else {
            cb := CallbackCreate(EnumFontProc)
        }
        result := ''
        hdc := DllCall('GetDC', 'ptr', 0, 'ptr')
        for faceName in FaceNames {
            if _Proc(&faceName) {
                result := faceName
                break
            }
        }
        DllCall('ReleaseDC', 'ptr', 0, 'ptr', hdc)
        CallbackFree(cb)
        return result

        _Proc(&faceName) {
            StrPut(SubStr(faceName, 1, 31), Logfont.Ptr + 28, maxLen, encoding)
            if !DllCall('gdi32\EnumFontFamiliesExW', 'ptr', hdc, 'ptr', Logfont, 'ptr', cb, 'ptr', Logfont.Ptr + 28, 'uint', 0, 'uint') {
                return 1
            }
        }
        EnumFontProc(lpelfe, lpntme, FontType, lParam) {
            if StrGet(lpelfe + 28, maxLen, encoding) = StrGet(lParam, maxLen, encoding) {
                return 0
            }
            return 1
        }
    }
    /**
     * @description - Creates a new `XttFont` object. This object is a reusable buffer object
     * that is used to get or set font details for a control (or other window).
     * @example
     * G := Gui('+Resize -DPIScale')
     * Txt := G.Add('Text', , 'Some text')
     * G.Show()
     * Font := XttFont(Txt.Hwnd)
     * Font()
     * MsgBox(Font.FaceName) ; Ms Shell Dlg
     * MsgBox(Font.FontSize) ; 11.25
     * Txt.SetFont('s15', 'Roboto')
     * Font()
     * MsgBox(Font.FaceName) ; Roboto
     * MsgBox(Font.FontSize) ; 15.00
     * @
     *
     * @param {Integer} [Hwnd = 0] - The window handle to associate with the font object.
     * @param {String} [Encoding = "UTF-16"] - The encoding to use when handling names.
     * @return {XttFont}
     */
    __New(Hwnd := 0, Encoding := 'UTF-16') {
        this.Buffer := Buffer(92)
        this.Encoding := Encoding
        this.Handle := 0
        if this.Hwnd := Hwnd {
            this()
        }
    }
    /**
     * @description - Attempts to set a window's font object using this object's values.
     */
    Apply(Redraw := true) {
        if !(hFontOld := SendMessage(0x0031,,, this.Hwnd)) {
            throw Error('Failed to get hFont.', -1)
        }
        Flag := this.Handle = hFontOld
        this.Handle := DllCall('CreateFontIndirectW', 'ptr', this, 'ptr')
        SendMessage(0x30, this.Handle, Redraw, this.Hwnd)  ; 0x30 = WM_SETFONT
        if Flag {
            DllCall('DeleteObject', 'ptr', hFontOld, 'int')
        }
    }
    Call(*) {
        if !(hFont := SendMessage(0x0031,,, this.Hwnd)) {
            throw Error('Failed to get hFont.', -1)
        }
        if !DllCall('Gdi32.dll\GetObject', 'ptr', hFont, 'int', 92, 'ptr', this, 'uint') {
            throw Error('Failed to get font object.', -1)
        }
    }
    Clone(lf?, Offset := 0) {
        if IsSet(lf) {
            if lf.Size < 92 + Offset {
                throw Error('The input buffer`'s size is insufficient.', -1, lf.Size)
            }
        } else {
            lf := { Buffer: Buffer(92 + Offset), Encoding: 'UTF-16', Handle: 0 }
            ObjSetBase(lf, XttFont.Prototype)
        }
        DllCall(
            'msvcrt.dll\memmove'
          , 'ptr', lf.Buffer.Ptr + Offset
          , 'ptr', this.Buffer.Ptr
          , 'int', 92
          , 'ptr'
        )
        return lf
    }
    DisposeFont() {
        if this.Handle {
            DllCall('DeleteObject', 'ptr', this.Handle)
            this.Handle := 0
        }
    }
    Set(Name, Value) {
        this.%Name% := Value
        this.Apply()
    }
    __Delete() {
        if this.Handle {
            DllCall('DeleteObject', 'ptr', this.Handle)
            this.Handle := 0
        }
    }

    /**
     * @property {Integer} XttFont.CharSet - The character set of the font.
     */
    CharSet {
        Get => NumGet(this, 23, 'uchar')
        Set => NumPut('uchar', Value, this, 23)
    }
    /**
     * @property {Integer} XttFont.ClipPrecision - The clipping precision of the font.
     */
    ClipPrecision {
        Get => NumGet(this, 25, 'uchar')
        Set => NumPut('uchar', Value, this, 25)
    }
    /**
     * @property {Integer} XttFont.Dpi - The DPI of the window to which `Hwnd` is the handle.
     */
    Dpi => DllCall('User32\GetDpiForWindow', 'Ptr', this.Hwnd, 'UInt')
    /**
     * @property {Integer} XttFont.Escapement - The angle of escapement, in tenths of degrees.
     */
    Escapement {
        Get => NumGet(this, 8, 'int')
        Set => NumPut('int', Value, this, 8)
    }
    /**
     * @property {String} XttFont.FaceName - The name of the font.
     */
    FaceName {
        Get => StrGet(this.ptr + 28, 32, this.Encoding)
        Set => StrPut(SubStr(Value, 1, 31), this.Ptr + 28, 32, 'UTF-16')
    }
    /**
     * @property {Integer} XttFont.Family - The font group to which the font belongs.
     */
    Family {
        Get => NumGet(this, 27, 'uchar') & 0xF0
        Set => NumPut('uchar', (this.Family & 0x0F) | (Value & 0xF0), this, 27)
    }
    /**
     * @property {Integer} XttFont.FontSize - The size of the font in points.
     */
    FontSize {
        Get => Round(this.Height * -72 / this.Dpi, 2)
        Set => this.SetFontSize(Value)
    }
    /**
     * @property {Integer} XttFont.Height - The height of the font in logical units.
     */
    Height {
        Get => NumGet(this, 0, 'int')
        Set => NumPut('int', Value, this, 0)
    }
    /**
     * @property {Boolean} XttFont.Mask - The mask that specifies which members of the structure are
     * valid.
     */
    Italic {
        Get => NumGet(this, 20, 'uchar')
        Set => NumPut('uchar', Value ? 1 : 0, this, 20)
    }
    /**
     * @property {Integer} XttFont.Orientation - The angle of orientation, in tenths of degrees.
     */
    Orientation {
        Get => NumGet(this, 12, 'int')
        Set => NumPut('int', Value, this, 12)
    }
    /**
     * @property {Integer} XttFont.OutPrecision - The output precision of the font.
     */
    OutPrecision {
        Get => NumGet(this, 24, 'uchar')
        Set => NumPut('uchar', Value, this, 24)
    }
    /**
     * @property {Integer} XttFont.Pitch - The pitch of the font.
     */
    Pitch {
        Get => NumGet(this, 27, 'uchar') & 0x0F
        Set => NumPut('uchar', (this.Pitch & 0xF0) | (Value & 0x0F), this, 27)
    }
    Ptr => this.Buffer.Ptr
    /**
     * @property {Integer} XttFont.Quality - The quality of the font.
     */
    Quality {
        Get => NumGet(this, 26, 'uchar')
        Set => NumPut('uchar', Value, this, 26)
    }
    Size => this.Buffer.Size
    /**
     * @property {Boolean} XttFont.StrikeOut - The strikeout flag.
     */
    StrikeOut {
        Get => NumGet(this, 22, 'uchar')
        Set => NumPut('uchar', Value ? 1 : 0, this, 22)
    }
    /**
     * @property {Boolean} XttFont.Underline - The underline flag.
     */
    Underline {
        Get => NumGet(this, 21, 'uchar')
        Set => NumPut('uchar', Value ? 1 : 0, this, 21)
    }
    /**
     * @property {Integer} XttFont.Weight - The weight of the font.
     */
    Weight {
        Get => NumGet(this, 16, 'int')
        Set => NumPut('int', Value, this, 16)
    }
    /**
     * @property {Integer} XttFont.Width - The average width of characters in the font.
     */
    Width {
        Get => NumGet(this, 4, 'int')
        Set => NumPut('int', Value, this, 4)
    }
}
