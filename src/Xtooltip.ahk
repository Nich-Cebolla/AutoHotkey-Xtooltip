
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/structs/LOGFONT.ahk
#include <Logfont>

; Test if a tool can be activated without text
; Test if adding a tool also activates it
; Check how it works if a tooltip has multiple tracking tools

/**
 * # Quick start guide
 *
 * The following is a brief introduction intended to share enough information for you to make use
 * of this library.
 *
 * ## The tooltip window
 *
 * A tooltip is a window with the following basic components:
 * - Theme (Text color, background color, window styles)
 * - Display text
 * - Parent window
 *
 * A single tooltip can be associated with any number of "tools". For example, say I have
 * three buttons in a gui window. I can prepare one tooltip window that displays different text
 * when the user hovers the mouse cursor over each button. To accomplish this, we add three
 * "tools" to the tooltip.
 *
 * ## Tools and `ToolInfo` objects
 *
 * A "tool" is an application-defined group of configuration options organized into a `TTTOOLINFO`
 * structure. In this library, the `ToolInfo` class has properties mapped to each of the members
 * of the `TTTOOLINFO` structure, so you will be interacting with the Windows API through familiar
 * object properties instead of byte offsets.
 *
 * The `TTTOOLINFO` structure is used heavily by the tooltip-related functions offered by the Windows
 * API. Whenever we need to get information about a tool, or update a value associated with a tool,
 * we supply a `ToolInfo` object which mediates this exchange.
 *
 * Because a tooltip can be associated with multiple tools, we cannot cache one `ToolInfo` object
 * and use it repeatedly with the Windows API functions. We must fill the structure's members
 * with updated values when we call a function that requires it. In order to fill the members, our
 * code must set two poperties: "Hwnd" and "Id". These identify the tool with which the upcoming function
 * call will be interacting.
 *
 * This is the pattern for sending many of the TTM window messages WITHOUT using this library:
 * @example
 *  ; Assume the `xtt` is an `XTooltip` object
 *  ti :== ToolInfo(xtt.Hwnd) ; get a `ToolInfo` object (mapped to a TTTOOLINFO structure)
 *  ti.Hwnd := parentHwnd ; Set the "hwnd" property
 *  ti.Id := uniqueId ; set the "id" property
 *  ; For this example, we want to update the tooltip's text
 *  str := "Hello, world!"
 *  buf := Buffer(StrPut(str, "UTF-16"))
 *  StrPut(str, buf, "UTF-16")
 *  NumPut("ptr", buf.Ptr, ti, 24 + A_PtrSize * 3)
 *  SendMessage(TTM_UPDATETIPTEXTW, ti.Ptr, 0, xtt.Hwnd)
 * @
 *
 * ## ToolInfo.Params objects
 *
 * As you explore the library, you will see that many methods require a `ToolInfo` object. In order to do this, our code must set two
 * properties: "hwnd" and "uId".
 *
 * To simplify and systematize this pattern that will be repeated in our code, the `Xtt` object
 * has a property "Tools" which is a map object that stores references to `ToolInfo.Params` objects.
 * A `ToolInfo.Params` object contains the static data that defines a particular tool. Instead of
 * caching a `ToolInfo` object, which has values that will change as time goes on, this library
 * will have you cache one `ToolInfo.Params` object for every tool added to a tooltip.
 *
 *
 *
 *
 *
 * The "tool" is represented in our AHK code by a `ToolInfo` object. The `ToolInfo` object is a buffer
 * object with its properties mapped to the members of the `TTTOOLINFO` structure.
 * This library handles the details of the API, but if you are interested the relevant information
 * is here: https://learn.microsoft.com/en-us/windows/win32/api/commctrl/ns-commctrl-tttoolinfoa
 *
 * This is your process when writing the code that will create the tooltip:
 *
 * 1. Decide which tooltip mode is appropriate for your project
 *
 * ## Tooltip modes
 *
 * There are three configurations predefined by this library:
 *
 * 1. If you want your code to have full control over the tooltip's display and position, see
 * "Setting up a tracking tooltip.
 * 2. If you want the tooltip to be visible when the user moves the mouse over a window or control,
 * see "Setting up a tooltip for a window".
 * 3. If you want the tooltip to be visible when the user moves the mouse over a rectangular area
 * defined by you, see "Setting up a tooltip with a trigger area".
 *
 * ### Setting up a tracking tooltip
 *
 *
 *
 * If your intent is to have the tooltip display when the user moves the mouse cursor over
 * a window or control, the relevant section below is "Setting up a tooltip for a window".
 *
 * - If your intent is to have the tooltip display when the user moves the mouse cursor over
 * a rectangular area within a window's client area, the relevant section below is "Setting
 * up a tooltip for a rectangular area".
 *
 *
 *
 * Minimally the `TTTOOLINFO` structure must have members "hwnd" and "uId". What this means
 * for us in our AHK code is that the `ToolInfo` object (from this library) must be associated
 * with a parent window, and must have an ID.
 *
 * Understand that neither the "hwnd" nor "uId" members of `TTTOOLINFO` are the same thing
 * as the tooltip's window handle.
 *
 * Depending on your use case, you may be able to leave one or both of "Hwnd" and "Id" unset.
 * The following sections can help you decide how to proceed.
 *
 * This library assists with the preparation and usage of three behavior patterns:
 *
 *
 * ### Setting up a tracking tooltip
 *
 * This information is for preparing a tooltip that your code will maintain full control of.
 * If you want the system to display / hide a tooltip when the user's mouse cursor enters
 * or leaves an area, read the other sections.
 *
 *
 *
 * This information is to help you set the correct values when your code will control the
 * activation, deactivation, and position of the tooltip. If your intent is to manipulate
 * the tooltip as-needed in your AHK code (as opposed to relying on the Windows API to display
 * and hide the tooltip when the user's mouse enters a certain area), then this is the sectionMany of the TTM window messages
 * require a `TTTOOLINFO` structure, and so even if you don't plan on associating a tooltip
 * with a particular tool, you may find that you still need to get a `ToolInfo` object to
 * use one of the methods.
 *
 * When you call the constructor `Xtooltip.Prototype.__New`, a generic `ToolInfo.Params` object
 * is created using the text passed to the constructor. It is safe to use this object for
 * any method that does not involve associating it with a new tool. To get a reference to
 * the object, access it from the "Tools" property, passing numeric zero (0) to the method
 * "Get":
 *
 * @example
 *  ; Get a `Xtooltip` object.
 *  xtt := Xtooltip("Hello, world!")
 *  ; Get a reference to the generic `ToolInfo.Params` object.
 *  TiParams := xtt.Tools.Get(0)
 *  ; Convert the `ToolInfo.Params` object to a `ToolInfo` object.
 *  ti := TiParams(xtt)
 * @
 *
 * Or to save a line of code, pass numeric zero (0) to the method "GetToolInfo" of the
 * `Xtooltip` object:
 *
 * @example
 *  ; Get a `Xtooltip` object.
 *  xtt := Xtooltip("Hello, world!")
 *  ; Get a reference to the generic `ToolInfo` object.
 *  ti := xtt.GetToolInfo(0)
 * @
 *
 * If you need a new generic `ToolInfo.Params` object, follow these steps:
 *
 * @example
 *  ; Assume we already have a `Xtooltip` object referenced by the symbol `xtt`.
 *  ; Get a new `ToolInfo.Params` object.
 *  TiParams := xtt.GetParamsGeneric()
 *  ; Make changes to the object.
 *  TiParams.Text := "Goodbye, world!"
 *  ; Validate the object. Errors should be handled during the development of the application.
 *  ; During development, I would just allow any errors to be thrown.
 *  TiParams.Validate()
 * @
 *
 * ### If the tool is a window
 *
 * This information is to help you set the correct values when the tool is a window (for
 * example, a gui control). The behavior we want is: When the user's mouse moves over the
 * window, the tooltip should display after a short delay. When the mouse leaves the window's
 * area, the tooltip should automatically hide after a short delay. To achieve this behavior,
 * follow these guidelines:
 *
 * - Set Params.Flags with TTF_IDISHWND. Unless you plan on enabling tracking behavior,
 *   you'll likely also want to include TTF_SUBCLASS. You'll know if you **don't** need
 *   TTF_SUBCLASS, so you should default to setting "Flags" with both TTF_IDISHWND and
 *   TTF_SUBCLASS, plus any other flags. Example: `Params.Flags := 0x0001 | 0x0010`
 * - Set `Params.Id` with the handle to the window (e.g. the handle to a gui control).
 * - If the window has a parent window, set `Params.Hwnd` with the handle to the parent window.
 *   If the window does not have a parent window, set `Params.Hwnd` with the same handle as "Id".
 *
 * You can use `ToolInfo.Params.GetWindow` or `ToolInfo.Params.GetToolControl` to get an
 * object with the minimum required properties. If you make changes to the properties, I
 * recommend calling `ToolInfo.Params.Prototype.Validate` within the same scope that your
 * code makes the changes to catch any problems immediately.
 *
 * ### If the tool is a rectangular area within a window's client area
 *
 * This information is to help you set the correct values when the tool is a rectangular
 * area within a window's client area. The behavior we want is: When the user's mouse moves
 * into the area, the tooltip should display after a short delay. When the mouse leaves
 * the window's area, the tooltip should automatically hide after a short delay. To
 * achieve this behavior, follow these guidelines:
 *
 * - Set `Params.Flags := TTF_SUBCLASS`.
 * - Set `Params.Hwnd` with the handle to the window whose client area contains the area
 *   that will be associated with the tooltip.
 * - Set properties "L", "T", "R", "B", with the left, top, right, and bottom client coordinates
 *   (that is, coordinates relative to the top-left corner of the window's client area).
 *
 * You can use `ToolInfo.Params.GetRect` to get an object with the minimum required
 * properties. If you make changes to the properties, I recommend  calling
 * `ToolInfo.Params.Prototype.Validate` within the same scope that your code makes the changes
 * to catch any problems immediately.
 *
 * ### Enable tracking
 *
 * This information is to help you set the correct values to enable tracking behavior. This
 * library does not implement TTM_TRACKACTIVATE or TTM_TRACKPOSITION messages. The Windows
 * API provides functions for associating a tooltip with a window and for using the window's
 * procedure for sending TTM_TRACKACTIVATE or TTM_TRACKPOSITION messages to the tooltip.
 * However, in our AHK code, we don't typically interact directly with a window procedure,
 * and writing that kind of code into this library is unnecessary because a tooltip is
 * a window and can be manipulated like any other window. To enable tracking behavior, all
 * we need is:
 * - An event that activates the tooltip by using `Xtooltip.Prototype.Show`.
 * - One or more events that adjusts the position of the tooltip by using
 *   `Xtooltip.Prototype.MoveWindow` or `Xtooltip.Prototype.MoveDisplay`.
 * - An event that deactivates the tooltip by using `Xtooltip.Prototype.Hide`.
 *
 * To this end, the needed properties for the `ToolInfo.Params` object are the same as
 * described in the section "If your code will control the tooltip's activation, deactivation,
 * and position".
 *
 * For further reading, these webpages contain instructions and guidance for creating a tooltip:
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
 */
class Xtooltip {
    static __New() {
        this.DeleteProp('__New')
        XttDeclareConstants()
        ; Store the tooltip system class name as a buffer
        className := 'tooltips_class32'
        this.ClassName := Buffer(StrPut(className, XTT_DEFAULT_ENCODING))
        StrPut(className, this.ClassName, XTT_DEFAULT_ENCODING)
        ; Add instance methods for each of the static `ToolInfo.Params` constructors
        tip := ToolInfo.Params
        proto := this.Prototype
        proto.DefineProp('GetParams', { Call: ObjBindMethod(tip, 'Call') })
        proto.DefineProp('GetParamsTracking', { Call: ObjBindMethod(tip, 'GetTracking') })
        proto.DefineProp('GetParamsControl', { Call: ObjBindMethod(tip, 'GetControl') })
        proto.DefineProp('GetParamsRect', { Call: ObjBindMethod(tip, 'GetRect') }) ; kek
        proto.DefineProp('GetParamsWindow', { Call: ObjBindMethod(tip, 'GetWindow') })

        this.ThemeGroups := XttThemeGroupCollection()
        this.Themes := XttThemeCollection()
        Proto.DefineProp('__Call', { Call: XttSetThreadDpiAwareness__Call })
    }
    /**
     * @param {ToolInfo.Params|Object} TiParams - Either a `ToolInfo.Params` object, or an object
     * that will be pass to `ToolInfo.Params`.
     */
    __New(
        hwndParent := A_ScriptHwnd
      , styleFlags := TTS_ALWAYSTIP
      , exStyleFlags := WS_EX_TOPMOST
      , Theme?
      , CreateWindowOptions?
    ) {
        this.Tools := ToolInfoParamsCollection()
        if IsSet(CreateWindowOptions) {
            hwnd := this.Hwnd := DllCall(
                'CreateWindowExW'
              , 'uint', exStyleFlags            ; dwExStyle
              , 'ptr', Xtooltip.ClassName   ; lpClassName
              , 'ptr', HasProp(CreateWindowOptions, 'lpWindowName') ? CreateWindowOptions.lpWindowName : 0
              , 'uint', styleFlags              ; dwStyle
              , 'int', CW_USEDEFAULT            ; X
              , 'int', CW_USEDEFAULT            ; Y
              , 'int', CW_USEDEFAULT            ; nWidth
              , 'int', CW_USEDEFAULT            ; nHeight
              , 'ptr', hwndParent               ; hWndParent
              , 'ptr', HasProp(CreateWindowOptions, 'hMenu') ? CreateWindowOptions.hMenu : 0
              , 'ptr', HasProp(CreateWindowOptions, 'hInstance') ? CreateWindowOptions.hInstance : 0
              , 'ptr', HasProp(CreateWindowOptions, 'lpParam') ? CreateWindowOptions.lpParam : 0
            )
        } else {
            hwnd := this.Hwnd := DllCall(
                'CreateWindowExW'
              , 'uint', exStyleFlags            ; dwExStyle
              , 'ptr', Xtooltip.ClassName   ; lpClassName
              , 'ptr', 0                        ; lpWindowName
              , 'uint', styleFlags              ; dwStyle
              , 'int', CW_USEDEFAULT            ; X
              , 'int', CW_USEDEFAULT            ; Y
              , 'int', CW_USEDEFAULT            ; nWidth
              , 'int', CW_USEDEFAULT            ; nHeight
              , 'ptr', hwndParent               ; hWndParent
              , 'ptr', 0                        ; hMenu
              , 'ptr', 0                        ; hInstance
              , 'ptr', 0                        ; lpParam
            )
        }
        WinSetAlwaysOnTop(true, hwnd)
        if hresult := DllCall('UxTheme.dll\SetWindowTheme', 'ptr', hwnd, 'ptr', 0, 'str', '', 'uint') {
            throw OSError('``SetWindowTheme`` failed.', -1, hresult)
        }
        this.Font := Logfont(hwnd)
        if IsSet(Theme) {
            Theme.Apply(this)
        }
    }
    Activate(Value := true) {
        this.__Active := Value
        return SendMessage(TTM_ACTIVATE, Value, 0, this.Hwnd)
    }
    /**
     * @description - Adds a `ToolInfo.Params` object to the collection set on property "Tools".
     * Sends the TTM_ADDTOOLW message to the tooltip.
     *
     * @param {ToolInfo.Params|Object} TiParams - Either a `ToolInfo.Params` object, or an object
     * with property:value pairs specifying the values of the members of the `TTTOOLINFO` structure
     * to which the object will be associated. See {@link ToolInfo.Params} and {@link ToolInfo.Params#__New}
     * for more information. If `TiParams` is not a `ToolInfo.Params` object, it will be passed to
     * `ToolInfo.Params.Prototype.__New`.
     * @param {String|Buffer} Text - The string that the tooltip will display, or a buffer containing
     * the string.
     * @param {String} Key - The "key" to associate with the `ToolInfo.Params` object.
     */
    AddTool(TiParams, Text, Key, Activate := true) {
        if not TiParams is ToolInfo.Params {
            TiParams := ToolInfo.Params(this, TiParams)
        }
        this.Tools.Set(Key, TiParams)
        ti := TiParams(this)
        ti.Text := Text
        SendMessage(TTM_ADDTOOLW, 0, ti.Ptr, this.Hwnd)
        SendMessage(TTM_ACTIVATE, true, 0, this.hwnd)
    }
    /**
     * @description - Creates a `ToolInfo.Params` object with the needed values to associate
     * a tooltip with a `Gui.Control` object. Whenever the user's mouse cursor hovers over the
     * control, the tooltip will display after a short delay. When the cursor leaves the control's
     * area, the tooltip will hide after a short delay.
     * @param {String} Key - The "key" to associate with the `ToolInfo.Params` object.
     * @param {String|Buffer} Text - The string that the tooltip will display, or a buffer containing
     * the string.
     * @param {Gui.Control} Ctrl - The `Gui.Control` object.
     * @returns {ToolInfo}
     */
    AddControl(Key, Text, Ctrl) {
        return this.__AddTool(
            Key
          , {
                ttHwnd: this.Hwnd
              , Hwnd: Ctrl.Gui.Hwnd
              , Id: Ctrl.Hwnd
              , Flags: TTF_IDISHWND | TTF_SUBCLASS
            }
          , Text
        )
    }
    /**
     * @description - Creates a `ToolInfo.Params` object with the needed values to associate
     * a tooltip with a rectangular area within a window's client area. Whenever the user's mouse
     * cursor enters into the area, the tooltip will display after a short delay. When the cursor
     * leaves the area, the tooltip will hide after a short delay.
     * @param {String} Key - The "key" to associate with the `ToolInfo.Params` object.
     * @param {String|Buffer} Text - The string that the tooltip will display, or a buffer containing
     * the string.
     * @param {Integer} ParentHwnd - The handle to the window containing the rectangle.
     * @param {Integer} [L] - The left client coordinate position.
     * @param {Integer} [T] - The top client coordinate position.
     * @param {Integer} [R] - The right client coordinate position.
     * @param {Integer} [B] - The bottom client coordinate position.
     * @param {Integer} [Id] - The value to assign to the "uId" member of `TTTOOLINFO`. If unset,
     * `ToolInfo.Params.GetTracking` will assign the value.
     * @returns {ToolInfo.Params}
     */
    AddRect(Key, Text, ParentHwnd, L?, T?, R?, B?, Id?) {
        rc := XttRect.Window(ParentHwnd)
        return this.__AddTool(
            Key
          , {
                ttHwnd: this.Hwnd
              , Hwnd: ParentHwnd
              , Id: Id ?? ToolInfo.GetUid()
              , Flags: TTF_SUBCLASS
              , L: L ?? rc.L
              , T: T ?? rc.T
              , R: R ?? rc.R
              , B: B ?? rc.B
            }
          , Text
        )
    }
    /**
     * @description - Creates a `ToolInfo.Params` with the needed values to create a tracking tooltip
     * (a tooltip which your code has full control over its visibility and position).
     * @param {String} Key - The "key" to associate with the `ToolInfo.Params` object.
     * @param {String|Buffer} Text - The string that the tooltip will display or a buffer
     * containing the string.
     * @param {Integer} [ParentHwnd] - If set, the handle to the tooltip's parent window. If
     * unset, `A_ScriptHwnd` is used.
     * @param {Integer} [Id] - The value to assign to the "uId" member of `TTTOOLINFO`. If unset,
     * `Xtooltip.Prototype.AddTracking` will assign the value.
     * @param {Boolean} [Show = XTT_DEFAULT_SHOW] - If true, the tool is shown immediately by the mouse
     * cursor.
     * @returns {ToolInfo}
     */
    AddTracking(Key, Text, ParentHwnd?, Id?, Show := XTT_DEFAULT_SHOW) {
        ti := this.__AddTool(
            Key
          , {
                ttHwnd: this.Hwnd
              , Hwnd: ParentHwnd ?? A_ScriptHwnd
              , Id: uId ?? ToolInfo.GetUid()
              , Flags: TTF_ABSOLUTE | TTF_TRACK
            }
          , Text
        )
        if Show {
            this.TrackPositionByMouse(Key)
            SendMessage(TTM_TRACKACTIVATE, 1, ti.Ptr, this.Hwnd)
        }
        return ti
    }
    /**
     * @description - Creates a `ToolInfo.Params` object with the needed values to associate
     * a tooltip with a window. Whenever the user's mouse cursor hovers over the window's client
     * area, the tooltip will display after a short delay. When the cursor leaves the window's
     * client area, the tooltip will hide after a short delay.
     * @param {String} Key - The "key" to associate with the `ToolInfo.Params` object.
     * @param {String|Buffer} Text - If set, the string that the tooltip will display or a buffer
     * containing the string.
     * @param {Integer} ToolHwnd - The handle to the window to associate with the tool.
     * @returns {ToolInfo.Params}
     */
    AddWindow(Key, Text, ToolHwnd) {
        return this.__AddTool(
            Key
          , {
                ttHwnd: this.Hwnd
              , Hwnd: DllCall('GetAncestor', 'ptr', ToolHwnd, 'uint', 1, 'ptr') || ToolHwnd
              , Id: ToolHwnd
              , Flags: TTF_IDISHWND | TTF_SUBCLASS
            }
          , Text
        )
    }
    DelTool(Key) {
        TiParams := this.Tools.Get(Key)
        this.Tools.Delete(Key)
        ti := TiParams(this)
        SendMessage(TTM_DELTOOLW, 0, ti.Ptr, this.Hwnd)
    }
    DisplayToWindowRect(L, T, R, B, Move := true) {
        rc := XttRect(L, T, R, B)
        SendMessage(TTM_ADJUSTRECT, true, rc.Ptr, this.Hwnd)
        if Move {
            WinMove(rc.L, rc.T, rc.W, rc.H, this.Hwnd)
        }
        return rc
    }
    Dispose() {
        if this.HasOwnProp('Font') {
            this.Font.DisposeFont()
            this.DeleteProp('Font')
        }
        if WinExist(this.Hwnd) {
            WinClose(this.Hwnd)
            this.Hwnd := 0
        }
    }
    FindToolInfoParams(toolHwnd, toolId) {
        for key, TiParams in this.Tools {
            if TiParams.Hwnd = toolHwnd && TiParams.Id = toolId {
                return TiParams
            }
        }
    }
    GetBackColor() {
        return SendMessage(TTM_GETTIPBKCOLOR, 0, 0, this.Hwnd)
    }
    GetBubbleSize(Key?, &OutWidth?, &OutHeight?) {
        ti := this.GetToolInfoObj(Key ?? unset)
        if sz := SendMessage(TTM_GETBUBBLESIZE, 0, ti.Ptr, this.Hwnd) {
            OutWidth := sz & 0xFFFF
            OutHeight := (sz >> 16) & 0xFFFF
            return sz
        } else {
            return 0
        }
    }
    /**
     * @description - Attempts to get the current tool by sending TTM_GETCURRENTTOOLW. TTM_GETCURRENTTOOLW
     * will only retrieve the tooltip's text if the character count of the string is 79 or less
     */
    GetCurrentTool(&OutToolInfo?) {
        OutToolInfo := ToolInfo(this.Hwnd, , , 160)
        return SendMessage(TTM_GETCURRENTTOOLW, 0, OutToolInfo.Ptr, this.Hwnd)
    }
    /**
     * @param {Integer} [Flag = 0] - One of the following:
     * TTDT_AUTOMATIC          0
     * TTDT_RESHOW             1
     * TTDT_AUTOPOP            2
     * TTDT_INITIAL            3
     * @returns {Integer} - The duration in milliseconds.
     */
    GetDelayTime(Flag := 0) {
        return SendMessage(TTM_GETDELAYTIME, Flag, 0, this.Hwnd)
    }
    GetDisplayRect() {
        rc := XttRect.Window(this.Hwnd)
        SendMessage(TTM_ADJUSTRECT, false, rc.Ptr, this.Hwnd)
        return rc
    }
    GetLargestTextSize(&OutBytes) {
        OutBytes := 0
        for key, TiParams in this.Tools {
            if HasProp(TiParams, 'Text') {
                if IsObject(TiParams.Text) {
                    if TiParams.Text.Size > OutBytes {
                        OutBytes := TiParams.Text.Size
                    }
                } else if StrPut(TiParams.Text, XTT_DEFAULT_ENCODING) > OutBytes {
                    OutBytes := StrPut(TiParams.Text, XTT_DEFAULT_ENCODING)
                }
            } else if HasProp(TiParams, 'TextSize') {
                if TiParams.TextSize > OutBytes {
                    OutBytes := TiParams.TextSize
                }
            }
        }
    }
    GetMargin() {
        rc := XttRect()
        SendMessage(TTM_GETMARGIN, 0, rc.Ptr, this.Hwnd)
        return rc
    }
    GetMaxTipWidth() {
        return SendMessage(TTM_GETMAXTIPWIDTH, 0, 0, this.Hwnd)
    }
    /**
     * @borrows ToolInfo.Params.Call as Xtooltip#GetParams
     */
    GetParams(Params) {
        ; This is ovverriden
    }
    /**
     * @borrows ToolInfo.Params.GetTracking as Xtooltip#GetParamsTracking
     */
    GetParamsTracking(ParentHwnd?, Id?, Text?) {
        ; This is ovverriden
    }
    /**
     * @borrows ToolInfo.Params.GetParamsControl as Xtooltip#GetControl
     */
    GetParamsControl(Ctrl, Text?) {
        ; This is ovverriden
    }
    /**
     * @borrows ToolInfo.Params.GetParamsRect as Xtooltip#GetRect
     */
    GetParamsRect(parentHwnd, L?, T?, R?, B?, Id?, Text?) {
        ; This is ovverriden
    }
    /**
     * @borrows ToolInfo.Params.GetParamsWindow as Xtooltip#GetWindow
     */
    GetParamsWindow(ToolHwnd, ParentHwnd?, Text?) {
        ; This is ovverriden
    }
    GetText(MaxChars) {
        ti := this.GetToolInfoObj(Key ?? unset)
        ti.SetTextBuffer(, MaxChars)
        SendMessage(TTM_GETTEXTW, MaxChars, ti.Ptr, this.Hwnd)
    }
    GetTextColor() {
        return SendMessage(TTM_GETTIPTEXTCOLOR, 0, 0, this.Hwnd)
    }
    GetTitle() {
        buf := Buffer(A_PtrSize + 12)
        NumPut('uint', buf.Size, buf)
        SendMessage(TTM_GETTITLE, 0, buf.Ptr, this.Hwnd)
        return StrGet(NumGet(buf, 12, 'ptr'), NumGet(buf, 8, 'uint'))
    }
    GetToolCount() {
        return SendMessage(TTM_GETTOOLCOUNT, 0, 0, this.Hwnd)
    }
    GetToolInfo(toolHwnd, toolId) {
        ti := ToolInfo(this.Hwnd, toolHwnd, toolId)
        SendMessage(TTM_GETTOOLINFOW, 0, ti.Ptr, this.Hwnd)
        return ti
    }
    GetToolInfoObj(Key?) {
        if IsSet(Key) {
            tiParams := this.Tools.Get(Key)
            ti := ToolInfo(this.Hwnd, tiParams.Hwnd, tiParams.Id)
            SendMessage(TTM_GETTOOLINFOW, 0, ti.Ptr, this.Hwnd)
            return ti
        } else if this.GetToolCount() {
            this.GetCurrentTool(&ti)
            return ti
        } else {
            throw Error('The tooltip does not have an active tool.', -1)
        }
    }
    NewToolRect(Key, RectObj) {
        TiParams := this.Tools.Get(Key)
        ti := ToolInfo(this.Hwnd, TiParams.Hwnd, TiParams.Id)
        ti.L := RectObj.L
        ti.T := RectObj.T
        ti.R := RectObj.R
        ti.B := RectObj.B
        SendMessage(TTM_NEWTOOLRECTW, 0, ti.Ptr, this.Hwnd)
    }
    Pop() {
        SendMessage(TTM_POP, 0, 0, this.Hwnd)
    }
    Popup() {
        SendMessage(TTM_POPUP, 0, 0, this.Hwnd)
    }
    Redraw() {
        WinRedraw(this.Hwnd)
    }
    SetBackColor(Color) {
        return SendMessage(TTM_SETTIPBKCOLOR, Color, 0, this.Hwnd)
    }
    SetBackColorRGB(R, G, B) {
        return SendMessage(TTM_SETTIPBKCOLOR, XttRGB(R, G, B), 0, this.Hwnd)
    }
    /**
     * @param {Integer} Delay - The new delay in milliseconds.
     * @param {Integer} [Flag = 0] - One of the following:
     * - 0 : TTDT_AUTOMATIC
     * - 1 : TTDT_RESHOW
     * - 2 : TTDT_AUTOPOP
     * - 3 : TTDT_INITIAL
     * Descriptions of these are available here:
     * {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-setdelaytime}.
     */
    SetDelayTime(Delay, Flag := 0) {
        SendMessage(TTM_SETDELAYTIME, Flag, Delay & 0xFFFF, this.Hwnd)
    }
    SetMargin(Left?, Top?, Right?, Bottom?) {
        rc := this.GetMargin()
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
        SendMessage(TTM_SETMARGIN, 0, rc.Ptr, this.Hwnd)
    }
    SetMargin2(RectObj) {
        SendMessage(TTM_SETMARGIN, 0, RectObj.Ptr, this.Hwnd)
    }
    /**
     * @param {Integer} Width - The maximum width for the tooltip's display area. If the text extends
     * beyond this width, the lines will wrap. Set to -1 to allow any width.
     * @returns {Integer} - The previous maximum width.
     */
    SetMaxWidth(Width) {
        return SendMessage(TTM_SETMAXTIPWIDTH, 0, Width, this.Hwnd)
    }
    SetTextColor(Color) {
        return SendMessage(TTM_SETTIPTEXTCOLOR, Color, 0, this.Hwnd)
    }
    SetTextColorRGB(R, G, B) {
        return SendMessage(TTM_SETTIPTEXTCOLOR, XttRGB(R, G, B), 0, this.Hwnd)
    }
    /**
     * @param {Integer} [Icon = 0] - Either a handle to an icon, or one of the following:
     * - 0 : TTI_NONE
     * - 1 : TTI_INFO
     * - 2 : TTI_WARNING
     * - 3 : TTI_ERROR
     *
     * #if (NTDDI_VERSION >= NTDDI_VISTA)
     * - 4 : TTI_INFO_LARGE
     * - 5 : TTI_WARNING_LARGE
     * - 6 : TTI_ERROR_LARGE
     *
     * @param {String} [Title] - The title string. This cannot exceed 99 characters.
     */
    SetTitle(Icon := 0, Title?) {
        if IsSet(Title) {
            bytes := StrPut(Title, XTT_DEFAULT_ENCODING)
            if bytes > 200 {
                throw Error('The title length exceeds the maximum (198 bytes).', -1, Title)
            }
            buf := Buffer(bytes)
            StrPut(Title, buf, XTT_DEFAULT_ENCODING)
        } else {
            buf := Buffer(2, 0)
        }
        return SendMessage(TTM_SETTITLEW, Icon, buf.Ptr, this.Hwnd)
    }
    /**
     * @description - Sends TTM_SETTOOLINFO to update a tool with new values. In your code, you should
     * follow these steps:
     * @example
     *  ; Assume `xtt` is an `Xtooltip` object.
     *  ; Get the relevant `ToolInfo.Params` object.
     *  TiParams := xtt.Tools.Get('MyKey')
     *  ; Get the current `ToolInfo` object for the tool
     *  ti := xtt.GetToolInfo(TiParams.Hwnd, TiParams.Id)
     *  ; Update the values.
     *  ; Maybe I want to store some information in the lParam member.
     *  ti.lParam := Buffer(StrPut(SomeMessage, XTT_DEFAULT_ENCODING))
     *  StrPut(SomeMessage, ti.lParam, XTT_DEFAULT_ENCODING)
     *  ; Also let's update the tooltip text.
     *  ti.Text := 'Goodby, world!'
     *  ; Since we updated the text outside of one of this library's functions,
     *  ; we are responsible for updating the value of "TextSize" on the
     *  ; `ToolInfo.Params` object. It's important this stays accurate.
     *  TiParams.TextSize := StrPut(ti.Text, XTT_DEFAULT_ENCODING)
     *  ; Send TTM_SETTOOLINFO
     *  xtt.SetToolInfo(ti)
     * @
     *
     * The only property on the `ToolInfo.Params` object that must be updated along with the tooltip
     * is "TextSize". The properties "Hwnd" and "Id" don't change, and the values of the remaining
     * properties can be acquied as needed.
     *
     * If you update the tooltip's text, it must be 79 characters or less. If you need to update
     * the text with a longer string, use TTM_UPDATETIPTEXT instead.
     *
     * @param {ToolInfo} NewToolInfo - The updated `ToolInfo` object.
     */
    SetToolInfo(NewToolInfo) {
        SendMessage(TTM_SETTOOLINFOW, 0, NewToolInfo.Ptr, this.Hwnd)
    }
    SetWindowTheme(TooltipVisualStyleName) {
        buf := Buffer(StrPut(TooltipVisualStyleName, XTT_DEFAULT_ENCODING))
        StrPut(TooltipVisualStyleName, buf, XTT_DEFAULT_ENCODING)
        SendMessage(TTM_SETWINDOWTHEME, 0, buf.Ptr, this.Hwnd)
    }
    TrackActivate(Key, Value) {
        SendMessage(TTM_TRACKACTIVATE, Value, this.Tools.Get(Key).Ptr, this.Hwnd)
    }
    TrackPosition(X, Y) {
        SendMessage(TTM_TRACKPOSITION, 0, (Y << 16) | (X & 0xFFFF), this.Hwnd)
    }
    TrackPositionByMouse(OffsetX := 0, OffsetY := 0) {
        pt := Buffer(8)
        DllCall('GetCursorPos', 'ptr', pt, 'int')
        SendMessage(TTM_TRACKPOSITION, 0, ((NumGet(pt, 'int', 4) + OffsetY) << 16) | ((NumGet(pt, 'int', 0) + OffsetX) & 0xFFFF), this.Hwnd)
    }
    Update() {
        return SendMessage(TTM_UPDATE, 0, 0, this.Hwnd)
    }
    /**
     * @description - Sets the `lpszText` member then sends TTM_UPDATETIPTEXTW.
     *
     * @param {String|Buffer} [Value] - The text to display on the tooltip, or a buffer containing
     * the text.
     */
    UpdateText(Str, Key) {
        TiParams := this.Tools.Get(Key)
        ti := this.GetToolInfo(TiParams.Hwnd, TiParams.Id)
        ti.Text := Str
        TiParams.TextSize := StrPut(Str, XTT_DEFAULT_ENCODING)
        SendMessage(TTM_UPDATETIPTEXTW, 0, ti.Ptr, this.Hwnd)
    }
    __AddTool(Key, TiParams, Text) {
        if IsObject(Text) {
            buf := Text
        } else {
            buf := Buffer(StrPut(Text, XTT_DEFAULT_ENCODING))
            StrPut(Text, buf, XTT_DEFAULT_ENCODING)
        }
        ObjSetBase(TiParams, ToolInfo.Params.Prototype)
        this.Tools.Set(Key, TiParams)
        ti := TiParams(this)
        ti.SetText(buf)
        SendMessage(TTM_ADDTOOLW, 0, ti.Ptr, this.Hwnd)
        SendMessage(TTM_ACTIVATE, true, 0, this.hwnd)
        return ti
    }
    __Delete() {
        this.Dispose()
    }

    Active {
        Get => this.__Active
        Set => this.Activate(Value)
    }
    BackColor {
        Get => this.GetBackColor()
        Set => this.SetBackColor(Value)
    }
    Dpi => this.Font.Dpi

    MaxWidth {
        Get => SendMessage(TTM_GETMAXTIPWIDTH, , , , this.Hwnd)
        Set {
            SendMessage(TTM_SETMAXTIPWIDTH, , Value, , this.Hwnd)
        }
    }
    TextColor {
        Get => this.GetTextColor()
        Set => this.SetTextColor(Value)
    }
    Title {
        Get => this.GetTitle()
        Set => this.SetTitle(, Value)
    }
    Visible {
        Get => DllCall('IsWindowVisible', 'Ptr', this.Hwnd, 'int')
        Set {
            if Value {
                SendMessage(TTM_POPUP, 0, 0,  , this.Hwnd)
            } else {
                SendMessage(TTM_POP, 0, 0,  , this.Hwnd)
            }
        }
    }

    class Theme {
        static __New() {
            this.DeleteProp('__New')
            this.ListFont := [
                'CharSet', 'ClipPrecision', 'Escapement', 'Family'
              , 'Italic', 'FaceName', 'Orientation', 'OutPrecision', 'Pitch'
              , 'Quality', 'FontSize', 'Strikeout', 'Underline', 'Weight'
            ]
            this.ListGeneral := ['BackColor', 'MaxWidth', 'TextColor']
            this.ListMargin := ['MarginL', 'MarginT', 'MarginR', 'MarginB']
            this.ListTitle := ['Icon', 'Title']
            this.Prototype.Default := ''
        }
        static __Enum(VarCount) {
            i := n := 0
            k := 1
            list := [this.ListFont, this.ListGeneral, this.ListMargin, this.ListTitle]
            if VarCount == 1 {
                return enum1
            } else {
                return enum2
            }

            enum1(&item) {
                if ++i > list[k].Length {
                    if ++k > list.Length {
                        return 0
                    }
                    i := 1
                }
                item := list[k][i]
                return 1
            }
            enum2(&index, &item) {
                ++n
                if ++i > list[k].Length {
                    if ++k > list.Length {
                        return 0
                    }
                    i := 1
                }
                index := n
                item := list[k][i]
                return 1
            }
        }
        static RegisterDefault(DefaultOptions) {
            this.Prototype.Default := DefaultOptions
        }
        static DeregisterDefault() {
            this.Prototype.Default := ''
        }
        __New(Options?) {
            this.SetOptions(Options ?? {})
        }
        Apply(XttObj) {
            this.ApplyFont(XttObj)
            this.ApplyGeneral(XttObj)
            this.ApplyMargin(XttObj)
            this.ApplyTitle(XttObj)
        }
        ApplyFont(XttObj) {
            lf := XttObj.Font
            for prop in Xtooltip.Theme.ListFont {
                if HasProp(this, prop) {
                    lf.%prop% := this.%prop%
                }
            }
            lf.Apply()
        }
        ApplyGeneral(XttObj) {
            for prop in Xtooltip.Theme.ListGeneral {
                if HasProp(this, prop) {
                    XttObj.Set%prop%(this.%prop%)
                }
            }
        }
        ApplyMargin(XttObj) {
            XttObj.SetMargin(
                HasProp(this, 'MarginL') ? this.MarginL : unset
              , HasProp(this, 'MarginT') ? this.MarginT : unset
              , HasProp(this, 'MarginR') ? this.MarginR : unset
              , HasProp(this, 'MarginB') ? this.MarginB : unset
            )
        }
        ApplySelect(XttObj, Font := false, General := false, Margin := false, Title := false) {
            if Font {
                this.ApplyFont(XttObj)
            }
            if General {
                this.ApplyGeneral(XttObj)
            }
            if Margin {
                this.ApplyMargin(XttObj)
            }
            if Title {
                this.ApplyTitle(XttObj)
            }
        }
        ApplyTitle(XttObj) {
            XttObj.SetTitle(
                HasProp(this, 'Icon') ? this.Icon : unset
              , HasProp(this, 'Title') ? this.Title : unset
            )
        }
        SetOptions(Options) {
            if this.Default {
                default := this.Default
                for prop in Xtooltip.Theme {
                    if HasProp(Options, prop) {
                        this.%prop% := Options.%prop%
                    } else if HasProp(default, prop) {
                        this.%prop% := default.%prop%
                    }
                }
            } else {
                for prop in Xtooltip.Theme {
                    if HasProp(Options, prop) {
                        this.%prop% := Options.%prop%
                    }
                }
            }
        }
    }

    class ThemeGroup extends XttCollectionBase {
        __New(XttObjs?) {
            this.__ActiveTheme := ''
            this.Themes := XttThemeCollection()
            this.Tooltips := XtooltipCollection()
            if IsSet(XttObjs) {
                if XttObjs is Array {
                    for xtt in XttObjs {
                        this.Tooltips.Set(xtt.Hwnd, xtt)
                    }
                } else {
                    this.Tooltips.Set(XttObjs.Hwnd, XttObjs)
                }
            }
        }
        GetActiveTheme() {
            if this.__ActiveTheme {
                return this.Themes.Get(this.__ActiveTheme)
            }
        }
        ThemeActivate(Theme) {
            if IsObject(Theme) {
                for themeName, themeObj in this.Themes {
                    if ObjPtr(Theme) == ObjPtr(themeObj) {
                        this.__ActiveTheme := themeName
                        flag := 1
                        break
                    }
                }
                if !IsSet(flag) {
                    throw UnsetItemError('The theme must be added to the collection before it can be activated.', -1)
                }
            } else {
                this.__ActiveTheme := Theme
                Theme := this.Themes.Get(Theme)
            }
            this.Update(Theme)
        }
        ThemeAdd(ThemeName, Theme, Activate := true) {
            this.Themes.Set(ThemeName, Theme)
            if Activate {
                if this.Count {
                    this.Update(Theme)
                }
                this.__ActiveTheme := ThemeName
            }
        }
        ThemeDelete(ThemeName) {
            this.Themes.Delete(ThemeName)
        }
        ThemeGet(ThemeName) {
            return this.Themes.Get(ThemeName)
        }
        ThemeSet(ThemeName, ThemeObj) {
            this.Themes.Set(ThemeName, ThemeObj)
        }
        ThemeSetValue(ThemeName, PropName, Value, Activate := true) {
            theme := this.Themes.Get(ThemeName)
            theme.%PropName% := Value
            if Activate {
                this.Update(theme)
            }
        }
        TtAdd(XttObj, ApplyActiveTheme := true) {
            this.Tooltips.Set(XttObj.Hwnd, XttObj)
            if ApplyActiveTheme {
                if theme := this.GetActiveTheme() {
                    theme.Apply(XttObj)
                }
            }
        }
        TtDelete(xttHwnd) {
            this.Tooltips.Delete(xttHwnd)
        }
        Update(Theme) {
            if !IsObject(Theme) {
                Theme := this.Themes.Get(Theme)
            }
            this.UpdateFont(Theme)
            this.UpdateGeneral(Theme)
            this.UpdateMargin(Theme)
            this.UpdateTitle(Theme)
        }
        UpdateFont(Theme) {
            if !IsObject(Theme) {
                Theme := this.Themes.Get(Theme)
            }
            list := Map()
            master := Xtooltip.Theme.ListFont
            list.Capacity := master.Length
            for prop in master {
                if HasProp(Theme, prop) {
                    list.Set(prop, Theme.%prop%)
                }
            }
            for hwnd, xtt in this.Tooltips {
                lf := xtt.Font
                for prop, val in list {
                    lf.%prop% := val
                }
                lf.Apply()
            }
        }
        UpdateGeneral(Theme) {
            if !IsObject(Theme) {
                Theme := this.Themes.Get(Theme)
            }
            for prop in Xtooltip.Theme.ListGeneral {
                if HasProp(Theme, prop) {
                    for hwnd, xtt in this.Tooltips {
                        xtt.Set%prop%(Theme.%prop%)
                    }
                }
            }
        }
        UpdateMargin(Theme) {
            if !IsObject(Theme) {
                Theme := this.Themes.Get(Theme)
            }
            for hwnd, xtt in this.Tooltips {
                xtt.SetMargin(
                    HasProp(Theme, 'MarginL') ? Theme.MarginL : unset
                  , HasProp(Theme, 'MarginT') ? Theme.MarginT : unset
                  , HasProp(Theme, 'MarginR') ? Theme.MarginR : unset
                  , HasProp(Theme, 'MarginB') ? Theme.MarginB : unset
                )
            }
        }
        UpdateSelection(Theme, Font := false, General := false, Margin := false, Title := false) {
            if !IsObject(Theme) {
                Theme := this.Themes.Get(Theme)
            }
            if Font {
                this.UpdateFont(Theme)
            }
            if General {
                this.UpdateGeneral(Theme)
            }
            if Margin {
                this.UpdateMargin(Theme)
            }
            if Title {
                this.UpdateTitle(Theme)
            }
        }
        UpdateTitle(Theme) {
            if !IsObject(Theme) {
                Theme := this.Themes.Get(Theme)
            }
            for hwnd, xtt in this.Tooltips {
                xtt.SetTitle(
                    HasProp(Theme, 'Icon') ? Theme.Icon : unset
                  , HasProp(Theme, 'Title') ? Theme.Title : unset
                )
            }
        }

        Active {
            Get => this.__ActiveTheme
            Set => this.ThemeActivate(Value)
        }
    }
}

/**
 * @classdesc - `ToolInfo` maps the members of a `TTTOOLINFO` structure to AHK object properties.
 *
 * This webpage contains the members of the `TTTOOLINFO` structure:
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/commctrl/ns-commctrl-tttoolinfoa}.
 */
class ToolInfo {
    static __New() {
        this.DeleteProp('__New')
        this.Size :=
        ;   size          member        type        offset
            4 +         ; cbSize        uint         0
            4 +         ; uFlags        uint         4
            A_PtrSize + ; Hwnd          Hwnd         8
            A_PtrSize + ; uId           UINT_PTR     8 + A_PtrSize
            16 +        ; rect          RECT         8 + A_PtrSize * 2
            A_PtrSize + ; hinst         HINSTANCE   24 + A_PtrSize * 2
            A_PtrSize + ; lpszText      LPTSTR      24 + A_PtrSize * 3
            A_PtrSize + ; lParam        LPARAM      24 + A_PtrSize * 4
            A_PtrSize   ; lpReserved    void        24 + A_PtrSize * 5
        this.Index := 0
        this.DefineProp('__Call', { Call: XttSetThreadDpiAwareness__Call })
        this.Prototype.DefineProp('__Call', { Call: XttSetThreadDpiAwareness__Call })
    }
    static GetUid() {
        return ++this.Index
    }
    static HitTest(toolHwnd, X, Y) {
        hti := {
            Buffer: Buffer(this.Size + A_PtrSize + 8)
          , ToolInfo: { ttHwnd: toolHwnd, Buffer: { Ptr: hti.Ptr + A_PtrSize + 8, Size: this.Size } }
        }
        hti.Ptr := hti.Buffer.Ptr
        hti.Size := hti.Buffer.Size
        ObjSetBase(hti.ToolInfo, this.Prototype)
        NumPut('ptr', toolHwnd, 'int', X, 'int', Y, hti)
        if SendMessage(TTM_HITTESTW, 0, hti.Ptr, toolHwnd) {
            return hti.ToolInfo
        }
    }
    __New(ttHwnd, toolHwnd?, uId?, TextBufferSize?) {
        this.ttHwnd := ttHwnd
        this.Buffer := Buffer(ToolInfo.Size, 0)
        NumPut('uint', ToolInfo.Size, this) ; cbSize
        if IsSet(toolHwnd) {
            this.Hwnd := toolHwnd
        }
        if IsSet(uId) {
            this.Id := uId
        }
        if IsSet(TextBufferSize) {
            this.TextBuffer := Buffer(TextBufferSize)
        }
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
            this.TextBuffer := Buffer(StrPut(Value, XTT_DEFAULT_ENCODING))
            StrPut(Value, this.TextBuffer, XTT_DEFAULT_ENCODING)
        }
        this.TextSize := this.TextBuffer.Size
        NumPut('ptr', this.TextBuffer.Ptr, this, 24 + A_PtrSize * 3) ; lpszText
    }
    SetTextBuffer(Buf?, BufferSize?) {
        if IsSet(Buf) {
            this.TextBuffer := Buf
        } else if IsSet(BufferSize) {
            this.TextBuffer := Buffer(BufferSize)
        } else {
            throw TypeError('An input value is required.', -1)
        }
        NumPut('ptr', this.TextBuffer.Ptr, this, 24 + A_PtrSize * 3)
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
        Get => this.TextPtr ? StrGet(this.TextPtr, XTT_DEFAULT_ENCODING) : ''
        Set {
            this.SetText(Value)
        }
    }
    TextPtr {
        Get => NumGet(this, 24 + A_PtrSize * 3, 'ptr')
        Set => this.SetTextBuffer(Value)
    }
    T {
        Get => NumGet(this, 12 + A_PtrSize * 2, 'uint')
        Set {
            NumPut('uint', Value, this, 12 + A_PtrSize * 2)
        }
    }

    /**
     * @classdesc - The purpose of `ToolInfo.Params` is to simplify the process of interacting with
     * the `TTTOOLINFO` structure that is needed for many tooltip-related functions / messages.
     *
     * {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-settoolinfo}.
     */
    class Params {
        static __New() {
            this.DeleteProp('__New')
            this.Prototype.Props := ['Flags', 'Hwnd', 'Id', 'L', 'T', 'R', 'B', 'hInstance', 'lParam']
        }
        /**
         * @description - Validates the parameters and copies their values to this instance of
         * `ToolInfo.Params`.
         *
         * @param {Xtooltip} XttObj - The `Xtooltip` object. This object's handle is copied
         * to property "TtHwnd".
         *
         * @param {Object} Params - An object with property:value pairs.
         *
         * @param {Integer} [Params.Flags] - One or more flags to assign to the member `uFlags`.
         * To combine values, use the bitwise "|" (e.g. `Params.Flags := 0x0020 | 0x0080`).
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
         * areas within a window's client area, the "rect" member defines the client coordinates of
         * the area's bounding rectangle. For tooltips that support tools implemented as windows or
         * as in-place tooltips, the "rect" member is not used.
         *
         * @param {Integer} [Params.hInstance] - You can leave this unset. Microsoft's
         * description states: Handle to the instance that contains the string resource for the tool.
         * If lpszText specifies the identifier of a string resource, this member is used.
         *
         * @param {Integer} [Params.lParam] - You can leave this unset. Microsoft's
         * description states: A 32-bit application-defined value that is associated with the tool.
         *
         * @returns {ToolInfo.Params}
         *
         * @throws {TypeError} - The property "<prop>" must be a <type>.
         * @throws {TypeError} - The property "Text" must be set with a `Buffer` object or an object with properties "Size" and "Ptr".
         * @throws {PropertyError} - The property "ttHwnd" is required.
         * @throws {PropertyError} - The flag `TTF_IDISHWND` in use, but the property "Hwnd" is unset.
         * @throws {PropertyError} - The flag `TTF_IDISHWND` is in use, but the property "Id" is unset.
         * @throws {PropertyError} - If at least one of properties "L", "T", "R", or "B", is set, then all four must be set.
         */
        __New(XttObj, Params) {
            if HasProp(Params, 'Flags') {
                if !IsNumber(Params.Flags) {
                    throw _TypeError('Flags')
                }
                if Params.Flags & 0x0001 {
                    if !HasProp(Params, 'Hwnd') {
                        ; If you get this error, you must set "Hwnd" with the handle to the parent
                        ; of "Id". If "Id" does not have a parent window, then set "Hwnd" to the same
                        ; value as "Id".
                        throw PropertyError('The flag ``TTF_IDISHWND`` in use, but the property "Hwnd" is unset.', -1)
                    }
                    if !HasProp(Params, 'Id') {
                        ; If you get this error, you must set "Id" with the handle to the window that
                        ; is the tool that this `ToolInfo` object represents. For example, by passing
                        ; a `Gui.Control` object to `Xtooltip.Prototype.GetToolControl` or to
                        ; `Xtooltip.Prototype.GetToolWindow`.
                        throw PropertyError('The flag ``TTF_IDISHWND`` in use, but the property "Id" is unset.', -1)
                    }
                }
            }
            if !IsNumber(Params.Hwnd) {
                throw _TypeError('Hwnd')
            }
            if HasProp(Params, 'Hwnd') {
                this.Hwnd := Params.Hwnd
            } else {
                this.Hwnd := A_ScriptHwnd
            }
            ct := 0
            for prop in ['L', 'T', 'R', 'B'] {
                if HasProp(Params, prop) {
                    if !IsNumber(Params.%prop%) {
                        throw _TypeError(prop)
                    }
                    ct++
                    this.%prop% := Params.%prop%
                }
            }
            switch ct {
                case 0,  4: ; do nothing
                default: throw PropertyError('If at least one of properties "L", "T", "R", or "B", is set, then all four must be set.', -1)
            }
            for prop in ['hInstance', 'lParam', 'Id'] {
                if HasProp(Params, prop) {
                    if IsNumber(Params.%prop%) {
                        this.%prop% := Params.%prop%
                    } else {
                        throw _TypeError(prop)
                    }
                }
            }
            if !this.HasOwnProp('Id') {
                this.Id := ToolInfo.GetUid()
            }
            this.TtHwnd := XttObj.Hwnd

            return

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
        Call(XttObj) {
            if !XttObj.GetCurrentTool(&ti) {
                ti.Hwnd := this.Hwnd
                ti.Id := this.Id
            }
            for prop in this.Props {
                if HasProp(this, prop) {
                    ti.%prop% := this.%prop%
                }
            }
            return ti
        }
    }
}

class XttRect {
    static __New() {
        this.DeleteProp('__New')
        this.DefineProp('__Call', { Call: XttSetThreadDpiAwareness__Call })
        this.Prototype.DefineProp('__Call', { Call: XttSetThreadDpiAwareness__Call })
    }
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

class XtooltipCollection extends XttCollectionBase {
    __New(Items*) {
        this.CaseSense := false
        if Items.Length {
            this.Set(Items*)
        }
    }
}

class ToolInfoParamsCollection extends XttCollectionBase {
}
class XttThemeCollection extends XttCollectionBase {
}
class XttThemeGroupCollection extends XttCollectionBase {
    Add(Label, Group?) {
        this.Set(Label, Group ?? XTooltip.ThemeGroup())
        return this.Get(Label)
    }
}
class XttCollectionBase extends Map {
    __New(Items*) {
        this.CaseSense := false
        if Items.Length {
            this.Set(Items*)
        }
    }
}

XttRGB(r := 0, g := 0, b := 0) {
    return (r & 0xFF) | ((g & 0xFF) << 8) | ((b & 0xFF) << 16)
}

XttParseColorRef(colorref, &OutR?, &OutG?, &OutB?) {
    OutR := colorref & 0xFF
    OutG := (colorref >> 8) & 0xFF
    OutB := (colorref >> 16) & 0xFF
}

XttDeclareConstants() {
    global

    ; XTT - constants for this library
    XTT_DEFAULT_ENCODING := 'UTF-16'
    XTT_DEFAULT_SHOW := true

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
    TTM_SETWINDOWTHEME := 0x2000 + 0xb
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
 * @description - Enables the usage of the "_S" suffix when calling `Xtooltip` instance methods,
 * `ToolInfo` static methods, `ToolInfo` instance methods, `XttRect` static methods, and `XttRect`
 * instance methods. By including "_S" at the end of a method call, the function will set the
 * thread dpi awareness context before calling the method.
 */
XttSetThreadDpiAwareness__Call(Obj, Name, Params) {
    Split := StrSplit(Name, '_')
    if Split.Length == 2 && Obj.HasMethod(Split[1]) && SubStr(Split[2], 1, 1) = 'S' {
        if StrLen(Split[2]) == 2 {
            DllCall('SetThreadDpiAwarenessContext', 'ptr', -SubStr(Split[2], 2, 1), 'ptr')
        } else {
            DllCall('SetThreadDpiAwarenessContext', 'ptr', HasProp(Obj, 'DpiAwarenessContext') ? Obj.DpiAwarenessContext : DPI_AWARENESS_CONTEXT_DEFAULT ?? -4, 'ptr')
        }
        if Params.Length {
            return Obj.%Split[1]%(Params*)
        } else {
            return Obj.%Split[1]%()
        }
    } else {
        throw PropertyError('Property not found.', -1, Name)
    }
}


/*

CW_USEDEFAULT := 0x80000000

WM_USER := 1024
WM_SETFONT := 0x0030
TTM_ACTIVATE := 1025
TTM_ADDTOOLA := 1028
TTM_ADDTOOLW := 1074
TTM_ADJUSTRECT := 1055
TTM_DELTOOLA := 1029
TTM_DELTOOLW := 1075
TTM_ENUMTOOLSA := 1038
TTM_ENUMTOOLSW := 1082
TTM_GETBUBBLESIZE := 1054
TTM_GETCURRENTTOOLA := 1039
TTM_GETCURRENTTOOLW := 1083
TTM_GETDELAYTIME := 1045
TTM_GETMARGIN := 1051
TTM_GETMAXTIPWIDTH := 1049
TTM_GETTEXTA := 1035
TTM_GETTEXTW := 1080
TTM_GETTIPBKCOLOR := 1046
TTM_GETTIPTEXTCOLOR := 1047
TTM_GETTITLE := 1059
TTM_GETTOOLCOUNT := 1037
TTM_GETTOOLINFOA := 1032
TTM_GETTOOLINFOW := 1077
TTM_HITTESTA := 1034
TTM_HITTESTW := 1079
TTM_NEWTOOLRECTA := 1030
TTM_NEWTOOLRECTW := 1076
TTM_POP := 1052
TTM_POPUP := 1058
TTM_RELAYEVENT := 1031
TTM_SETDELAYTIME := 1027
TTM_SETMARGIN := 1050
TTM_SETMAXTIPWIDTH := 1048
TTM_SETTIPBKCOLOR := 1043
TTM_SETTIPTEXTCOLOR := 1044
TTM_SETTITLEA := 1056
TTM_SETTITLEW := 1057
TTM_SETTOOLINFOA := 1033
TTM_SETTOOLINFOW := 1078
TTM_TRACKACTIVATE := 1041
TTM_TRACKPOSITION := 1042
TTM_UPDATE := 1053
TTM_UPDATETIPTEXTA := 1036
TTM_UPDATETIPTEXTW := 1081
TTM_WINDOWFROMPOINT := 1040


TTDT_AUTOMATIC          0
TTDT_RESHOW             1
TTDT_AUTOPOP            2
TTDT_INITIAL            3

https://learn.microsoft.com/en-us/windows/win32/api/commctrl/ns-commctrl-tttoolinfoa
TTF_IDISHWND            0x0001
TTF_CENTERTIP           0x0002
TTF_RTLREADING          0x0004
TTF_SUBCLASS            0x0010
TTF_TRACK               0x0020
TTF_ABSOLUTE            0x0080
TTF_TRANSPARENT         0x0100
TTF_PARSELINKS          0x1000
TTF_DI_SETITEM          0x8000       // valid only on the TTN_NEEDTEXT callback


TTDT_AUTOMATIC          0
TTDT_RESHOW             1
TTDT_AUTOPOP            2
TTDT_INITIAL            3

// ToolTip Icons (Set with TTM_SETTITLE)
TTI_NONE                0
TTI_INFO                1
TTI_WARNING             2
TTI_ERROR               3
#if (NTDDI_VERSION >= NTDDI_VISTA)
TTI_INFO_LARGE          4
TTI_WARNING_LARGE       5
TTI_ERROR_LARGE         6
#endif  // (NTDDI_VERSION >= NTDDI_VISTA)

; Indicates that the tooltip control appears when the cursor is on a tool, even if the tooltip control's owner window is inactive. Without this style, the tooltip appears only when the tool's owner window is active.
TTS_ALWAYSTIP := 0x01

; Prevents the system from stripping ampersand characters from a string or terminating a string at a tab character. Without this style, the system automatically strips ampersand characters and terminates a string at the first tab character. This allows an application to use the same string as both a menu item and as text in a tooltip control.
TTS_NOPREFIX            0x02

; Version 5.80. Disables sliding tooltip animation on Windows 98 and Windows 2000 systems. This style is ignored on earlier systems.
TTS_NOANIMATE           0x10

; Version 5.80. Disables fading tooltip animation.
TTS_NOFADE              0x20

; Version 5.80. Indicates that the tooltip control has the appearance of a cartoon "balloon," with rounded corners and a stem pointing to the item.
TTS_BALLOON             0x40

; Displays a Close button on the tooltip. Valid only when the tooltip has the TTS_BALLOON style and a title; see TTM_SETTITLE.
TTS_CLOSE               0x80

#if (NTDDI_VERSION >= NTDDI_VISTA)
; Uses themed hyperlinks. The theme will define the styles for any links in the tooltip. This style always requires TTF_PARSELINKS to be set.
TTS_USEVISUALSTYLE      0x100  // Use themed hyperlinks

TTN_GETDISPINFOA        4294966766
TTN_GETDISPINFOW        4294966766
TTN_SHOW                4294966775
TTN_POP                 4294966774
TTN_LINKCLICK           4294966773

WM_USER := 0x0400
TTM_ACTIVATE := 0x0400 + 1
TTM_ADDTOOLA := 0x0400 + 4
TTM_ADDTOOLW := 0x0400 + 50
TTM_ADJUSTRECT := 0x0400 + 31
TTM_DELTOOLA := 0x0400 + 5
TTM_DELTOOLW := 0x0400 + 51
TTM_ENUMTOOLSA := 0x0400 +14
TTM_ENUMTOOLSW := 0x0400 +58
TTM_GETBUBBLESIZE := 0x0400 + 30
TTM_GETCURRENTTOOLA := 0x0400 + 15
TTM_GETCURRENTTOOLW := 0x0400 + 59
TTM_GETDELAYTIME := 0x0400 + 21
TTM_GETMARGIN := 0x0400 + 27
TTM_GETMAXTIPWIDTH := 0x0400 + 25
TTM_GETTEXTA := 0x0400 +11
TTM_GETTEXTW := 0x0400 +56
TTM_GETTIPBKCOLOR := 0x0400 + 22
TTM_GETTIPTEXTCOLOR := 0x0400 + 23
TTM_GETTITLE := 0x0400 + 35
TTM_GETTOOLCOUNT := 0x0400 +13
TTM_GETTOOLINFOA := 0x0400 + 8
TTM_GETTOOLINFOW := 0x0400 + 53
TTM_HITTESTA := 0x0400 +10
TTM_HITTESTW := 0x0400 +55
TTM_NEWTOOLRECTA := 0x0400 + 6
TTM_NEWTOOLRECTW := 0x0400 + 52
TTM_POP := 0x0400 + 28
TTM_POPUP := 0x0400 + 34
TTM_RELAYEVENT := 0x0400 + 7
TTM_SETDELAYTIME := 0x0400 + 3
TTM_SETMARGIN := 0x0400 + 26
TTM_SETMAXTIPWIDTH := 0x0400 + 24
TTM_SETTIPBKCOLOR := 0x0400 + 19
TTM_SETTIPTEXTCOLOR := 0x0400 + 20
TTM_SETTITLEA := 0x0400 + 32
TTM_SETTITLEW := 0x0400 + 33
TTM_SETTOOLINFOA := 0x0400 + 9
TTM_SETTOOLINFOW := 0x0400 + 54
TTM_TRACKACTIVATE := 0x0400 + 17
TTM_TRACKPOSITION := 0x0400 + 18
TTM_UPDATE := 0x0400 + 29
TTM_UPDATETIPTEXTA := 0x0400 +12
TTM_UPDATETIPTEXTW := 0x0400 +57
TTM_WINDOWFROMPOINT := 0x0400 + 16

TOOLTIPS_CLASSW := "tooltips_class32"

; Places the window at the bottom of the Z order. If the hWnd parameter identifies a topmost window, the window loses its topmost status and is placed at the bottom of all other windows.
HWND_BOTTOM := 1

; Places the window above all non-topmost windows (that is, behind all topmost windows). This flag has no effect if the window is already a non-topmost window.
HWND_NOTOPMOST := -2

; Places the window at the top of the Z order.
HWND_TOP := 0

; Places the window above all non-topmost windows. The window maintains its topmost position even when it is deactivated.
HWND_TOPMOST := -1

; The window has a thin-line border
WS_BORDER := 0x00800000

; The window has a title bar (includes the WS_BORDER style).
WS_CAPTION := 0x00C00000

; The window is a child window. A window with this style cannot have a menu bar. This style cannot
; be used with the WS_POPUP style
WS_CHILD := 0x40000000

; Same as the WS_CHILD style.
WS_CHILDWINDOW := 0x40000000

; Excludes the area occupied by child windows when drawing occurs within the parent window. This
; style is used when creating the parent window
WS_CLIPCHILDREN := 0x02000000

; Clips child windows relative to each other; that is, when a particular child window receives a
; WM_PAINT message, the WS_CLIPSIBLINGS style clips all other overlapping child windows out of the
; region of the child window to be updated. If WS_CLIPSIBLINGS is not specified and child windows
; overlap, it is possible, when drawing within the client area of a child window, to draw within
; the client area of a neighboring child window
WS_CLIPSIBLINGS := 0x04000000

; The window is initially disabled. A disabled window cannot receive input from the user. To change
; this after a window has been created, use the EnableWindow function
WS_DISABLED := 0x08000000

; The window has a border of a style typically used with dialog boxes. A window with this style
; cannot have a title bar
WS_DLGFRAME := 0x00400000

; The window is the first control of a group of controls. The group consists of this first control
; and all controls defined after it, up to the next control with the WS_GROUP style. The first
; control in each group usually has the WS_TABSTOP style so that the user can move from group to
; group. The user can subsequently change the keyboard focus from one control in the group to the
; next control in the group by using the direction keys. You can turn this style on and off to
; change dialog box navigation. To change this style after a window has been created, use the
; SetWindowLong function
WS_GROUP := 0x00020000

; The window has a horizontal scroll bar.
WS_HSCROLL := 0x00100000

; The window is initially minimized. Same as the WS_MINIMIZE style.
WS_ICONIC := 0x20000000

; The window is initially maximized.
WS_MAXIMIZE := 0x01000000

; The window has a maximize button. Cannot be combined with the WS_EX_CONTEXTHELP style. The
; WS_SYSMENU style must also be specified
WS_MAXIMIZEBOX := 0x00010000

; The window is initially minimized. Same as the WS_ICONIC style.
WS_MINIMIZE := 0x20000000

; The window has a minimize button. Cannot be combined with the WS_EX_CONTEXTHELP style. The
; WS_SYSMENU style must also be specified
WS_MINIMIZEBOX := 0x00020000

; The window is an overlapped window. An overlapped window has a title bar and a border. Same as
; the WS_TILED style
WS_OVERLAPPED := 0x00000000

WS_OVERLAPPEDWINDOW
(WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX)
The window is an overlapped window. Same as the WS_TILEDWINDOW style.

; The window is a pop-up window. This style cannot be used with the WS_CHILD style.
WS_POPUP := 0x80000000

WS_POPUPWINDOW
(WS_POPUP | WS_BORDER | WS_SYSMENU)
The window is a pop-up window. The WS_CAPTION and WS_POPUPWINDOW styles must be combined to make the window menu visible.

; The window has a sizing border. Same as the WS_THICKFRAME style.
WS_SIZEBOX := 0x00040000

; The window has a window menu on its title bar. The WS_CAPTION style must also be specified.
WS_SYSMENU := 0x00080000

; The window is a control that can receive the keyboard focus when the user presses the TAB key.
; Pressing the TAB key changes the keyboard focus to the next control with the WS_TABSTOP style.
; You can turn this style on and off to change dialog box navigation. To change this style after a
; window has been created, use the SetWindowLong function. For user-created windows and modeless
; dialogs to work with tab stops, alter the message loop to call the IsDialogMessage
; function
WS_TABSTOP := 0x00010000

; The window has a sizing border. Same as the WS_SIZEBOX style.
WS_THICKFRAME := 0x00040000

; The window is an overlapped window. An overlapped window has a title bar and a border. Same as
; the WS_OVERLAPPED style
WS_TILED := 0x00000000

WS_TILEDWINDOW
(WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX)
The window is an overlapped window. Same as the WS_OVERLAPPEDWINDOW style.

; The window is initially visible. This style can be turned on and off by using the ShowWindow or
; SetWindowPos function
WS_VISIBLE := 0x10000000

; The window has a vertical scroll bar.
WS_VSCROLL := 0x00200000


; The window accepts drag-drop files.
WS_EX_ACCEPTFILES := 0x00000010

; Forces a top-level window onto the taskbar when the window is visible.
WS_EX_APPWINDOW := 0x00040000

; The window has a border with a sunken edge.
WS_EX_CLIENTEDGE := 0x00000200

; Paints all descendants of a window in bottom-to-top painting order using double-buffering.
; Bottom-to-top painting order allows a descendent window to have translucency (alpha) and
; transparency (color-key) effects, but only if the descendent window also has the
; WS_EX_TRANSPARENT bit set. Double-buffering allows the window and its descendents to be painted
; without flicker. This cannot be used if the window has a class style of CS_OWNDC, CS_CLASSDC, or
; CS_PARENTDC.  Windows 2000: This style is not supported
WS_EX_COMPOSITED := 0x02000000

; The title bar of the window includes a question mark. When the user clicks the question mark, the
; cursor changes to a question mark with a pointer. If the user then clicks a child window, the
; child receives a WM_HELP message. The child window should pass the message to the parent window
; procedure, which should call the WinHelp function using the HELP_WM_HELP command. The Help
; application displays a pop-up window that typically contains help for the child window.
; WS_EX_CONTEXTHELP cannot be used with the WS_MAXIMIZEBOX or WS_MINIMIZEBOX styles
WS_EX_CONTEXTHELP := 0x00000400

; The window itself contains child windows that should take part in dialog box navigation. If this
; style is specified, the dialog manager recurses into children of this window when performing
; navigation operations such as handling the TAB key, an arrow key, or a keyboard
; mnemonic
WS_EX_CONTROLPARENT := 0x00010000

; The window has a double border; the window can, optionally, be created with a title bar by
; specifying the WS_CAPTION style in the dwStyle parameter
WS_EX_DLGMODALFRAME := 0x00000001

; The window is a layered window. This style cannot be used if the window has a class style of
; either CS_OWNDC or CS_CLASSDC. Windows 8: The WS_EX_LAYERED style is supported for top-leve
; windows and child windows. Previous Windows versions support WS_EX_LAYERED only for top-leve
; windows
WS_EX_LAYERED := 0x00080000

; If the shell language is Hebrew, Arabic, or another language that supports reading order
; alignment, the horizontal origin of the window is on the right edge. Increasing horizontal values
; advance to the left.
WS_EX_LAYOUTRTL := 0x00400000

; The window has generic left-aligned properties. This is the default.
WS_EX_LEFT := 0x00000000

; If the shell language is Hebrew, Arabic, or another language that supports reading order
; alignment, the vertical scroll bar (if present) is to the left of the client area. For other
; languages, the style is ignored
WS_EX_LEFTSCROLLBAR := 0x00004000

; The window text is displayed using left-to-right reading-order properties. This is the default.
WS_EX_LTRREADING := 0x00000000

; The window is a MDI child window.
WS_EX_MDICHILD := 0x00000040

; A top-level window created with this style does not become the foreground window when the user
; clicks it. The system does not bring this window to the foreground when the user minimizes or
; closes the foreground window. The window should not be activated through programmatic access or
; via keyboard navigation by accessible technology, such as Narrator. To activate the window, use
; the SetActiveWindow or SetForegroundWindow function. The window does not appear on the taskbar by
; default. To force the window to appear on the taskbar, use the WS_EX_APPWINDOW
; style
WS_EX_NOACTIVATE := 0x08000000

; The window does not pass its window layout to its child windows.
WS_EX_NOINHERITLAYOUT := 0x00100000

; The child window created with this style does not send the WM_PARENTNOTIFY message to its parent
; window when it is created or destroyed
WS_EX_NOPARENTNOTIFY := 0x00000004

; The window does not render to a redirection surface. This is for windows that do not have visible
; content or that use mechanisms other than surfaces to provide their visua
WS_EX_NOREDIRECTIONBITMAP := 0x00200000

; The window is an overlapped window.
WS_EX_OVERLAPPEDWINDOW := (WS_EX_WINDOWEDGE | WS_EX_CLIENTEDGE)

; The window is palette window, which is a modeless dialog box that presents an array of commands.
WS_EX_PALETTEWINDOW := (WS_EX_WINDOWEDGE | WS_EX_TOOLWINDOW | WS_EX_TOPMOST)

; The window has generic "right-aligned" properties. This depends on the window class. This style
; has an effect only if the shell language is Hebrew, Arabic, or another language that supports
; reading-order alignment; otherwise, the style is ignored. Using the WS_EX_RIGHT style for static
; or edit controls has the same effect as using the SS_RIGHT or ES_RIGHT style, respectively. Using
; this style with button controls has the same effect as using BS_RIGHT and BS_RIGHTBUTTON styles.
WS_EX_RIGHT := 0x00001000

; The vertical scroll bar (if present) is to the right of the client area. This is the default.
WS_EX_RIGHTSCROLLBAR := 0x00000000

; If the shell language is Hebrew, Arabic, or another language that supports reading-order
; alignment, the window text is displayed using right-to-left reading-order properties. For other
; languages, the style is ignored
WS_EX_RTLREADING := 0x00002000

; The window has a three-dimensional border style intended to be used for items that do not accept
; user input
WS_EX_STATICEDGE := 0x00020000

; The window is intended to be used as a floating toolbar. A tool window has a title bar that is
; shorter than a normal title bar, and the window title is drawn using a smaller font. A too
; window does not appear in the taskbar or in the dialog that appears when the user presses
; ALT+TAB. If a tool window has a system menu, its icon is not displayed on the title bar. However,
; you can display the system menu by right-clicking or by typing ALT+SPACE.
WS_EX_TOOLWINDOW := 0x00000080

; The window should be placed above all non-topmost windows and should stay above them, even when
; the window is deactivated. To add or remove this style, use the SetWindowPos function
WS_EX_TOPMOST := 0x00000008

; The window should not be painted until siblings beneath the window (that were created by the same
; thread) have been painted. The window appears transparent because the bits of underlying sibling
; windows have already been painted. To achieve transparency without these restrictions, use the
; SetWindowRgn function
WS_EX_TRANSPARENT := 0x00000020

; The window has a border with a raised edge.
WS_EX_WINDOWEDGE := 0x00000100
