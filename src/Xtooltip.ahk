
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
class Xtooltip extends Xtooltip.Base {
    static __New() {
        this.DeleteProp('__New')
        XttDeclareConstants()
        ; Store the tooltip system class name as a buffer
        className := 'tooltips_class32'
        this.ClassName := Buffer(StrPut(className, XTT_DEFAULT_ENCODING))
        StrPut(className, this.ClassName, XTT_DEFAULT_ENCODING)
        this.ThemeCollection := this.ThemeGroupCollection := this.XtooltipCollection := ''
        proto := this.Prototype
        Proto.DefineProp('__Call', { Call: XttSetThreadDpiAwareness__Call })
        Proto.__ThemeGroupName := Proto.__Theme := Proto.__Name := Proto.Hwnd := Proto.Font := ''
        Proto.TitleSize := 0
    }
    static RegisterAllCollections() {
        this.RegisterThemeCollection()
        this.RegisterThemeGroupCollection()
        this.RegisterXtooltipCollection()
    }
    /**
     *
     */
    static RegisterThemeCollection(ThemeCollection?, CaseSense := false) {
        return this.ThemeCollection := ThemeCollection ?? XttThemeCollection(CaseSense)
    }
    static RegisterThemeGroupCollection(ThemeGroupCollection?, CaseSense := false) {
        return this.ThemeGroupCollection := ThemeGroupCollection ?? XttThemeGroupCollection(CaseSense)
    }
    static RegisterXtooltipCollection(XtooltipCollectionObj?, CaseSense := false) {
        return this.XtooltipCollection := XtooltipCollectionObj ?? XtooltipCollection(CaseSense)
    }
    static DeregisterAllCollections(ClearCollection := false) {
        this.DeregisterThemeCollection(ClearCollection)
        this.DeregisterThemeGroupCollection(ClearCollection)
        this.DeregisterXtooltipCollection(ClearCollection)
    }
    static DeregisterThemeCollection(ClearCollection := false) {
        if ClearCollection {
            this.ThemeCollection.Clear()
        }
        this.ThemeCollection := ''
    }
    static DeregisterThemeGroupCollection(ClearCollection := false) {
        if ClearCollection {
            this.ThemeGroupCollection.Clear()
        }
        this.ThemeGroupCollection := ''
    }
    static DeregisterXtooltipCollection(ClearCollection := false) {
        if ClearCollection {
            this.XtooltipCollection.Clear()
        }
        this.XtooltipCollection := ''
    }
    /**
     * @param {ToolInfo.Params|Object} TiParams - Either a `ToolInfo.Params` object, or an object
     * that will be pass to `ToolInfo.Params`.
     */
    __New(
        hwndParent := A_ScriptHwnd
      , Name := ''
      , Theme?
      , styleFlags := TTS_ALWAYSTIP
      , exStyleFlags := WS_EX_TOPMOST
      , CreateWindowOptions?
    ) {
        this.Tools := ToolInfoParamsCollection()
        if IsSet(CreateWindowOptions) {
            hwnd := this.Hwnd := DllCall(
                'CreateWindowExW'
              , 'uint', exStyleFlags            ; dwExStyle
              , 'ptr', Xtooltip.ClassName       ; lpClassName
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
              , 'ptr', Xtooltip.ClassName       ; lpClassName
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
        } else {
            this.__Theme := ''
        }
        this.__Name := Name
        if this.XtooltipCollection {
            this.XtooltipCollection.Set(Name || hwnd, this)
        }
        this.HasTrackingTool := 0
        ; I found this to be necessary to avoid an invalid memory read/write error when using a debugger.
        ; If I used a local scoped variable in the function `Xtooltip.Prototype.GetTitle` to reference
        ; the buffer, even though function would be valid and not present any issues during a normal
        ; call to the function, if the debugger called the function when using the Get accessor for
        ; the property "Title", I would get the error. I presumed this was due to how the buffer
        ; variable was being handled. Reusing a buffer set on an object property fixed the issue.
        this.TtGetTitle := TtGetTitle(this, , false)
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
        if HasProp(TiParams, 'Flags') && TiParams.Flags & TTF_TRACK {
            if this.HasTrackingTool {
                XttErrors.ThrowTrackingError()
            } else {
                this.HasTrackingTool := 1
            }
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
     * a tooltip with a `Gui.Control`'s client area. Whenever the user's mouse cursor enters into
     * the area, the tooltip will display after a short delay. When the cursor leaves the area, the
     * tooltip will hide after a short delay.
     * @param {String} Key - The "key" to associate with the `ToolInfo.Params` object.
     * @param {String|Buffer} Text - The string that the tooltip will display, or a buffer containing
     * the string.
     * @param {Gui.Control} Ctrl - The `Gui.Control` object.
     * @returns {ToolInfo}
     */
    AddControlRect(Key, Text, Ctrl) {
        rc := XttRect.Window(Ctrl.Hwnd)
        DllCall('ScreenToClient', 'ptr', Ctrl.Gui.Hwnd, 'ptr', rc.Ptr, 'int')
        DllCall('ScreenToClient', 'ptr', Ctrl.Gui.Hwnd, 'ptr', rc.Ptr + 8, 'int')
        return this.__AddTool(
            Key
          , {
                ttHwnd: this.Hwnd
              , Hwnd: Ctrl.Gui.Hwnd
              , Id: Id ?? ToolInfo.GetUid()
              , Flags: TTF_SUBCLASS
              , L: rc.L
              , T: rc.T
              , R: rc.R
              , B: rc.B
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
        rc := XttRect.Client(ParentHwnd)
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
     *
     * Note that only one tracking tool can be added to a single Xtooltip.
     *
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
        if this.HasTrackingTool {
            XttErrors.ThrowTrackingError()
        }
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
        this.HasTrackingTool := 1
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
        ti := ToolInfo(this.Hwnd, tiParams.Hwnd, tiParams.Id)
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
        hwnd := this.Hwnd
        if _name := this.__Name || hwnd {
            if themeGroup := this.ThemeGroup {
                if themeGroup.Has(_name) {
                    themeGroup.Delete(_name)
                }
            }
            if this.XtooltipCollection && this.XtooltipCollection.Has(_name) {
                this.XtooltipCollection.Delete(_name)
            }
            if this.HasOwnProp('__Name') {
                this.DeleteProp('__Name')
            }
        }
        if this.HasOwnProp('Font') {
            this.Font.DisposeFont()
            this.DeleteProp('Font')
        }
        if hwnd {
            for key, tiParams in this.Tools {
                ti := ToolInfo(hwnd, tiParams.Hwnd, tiParams.Id)
                SendMessage(TTM_DELTOOLW, 0, ti.Ptr, hwnd)
            }
            if this.GetToolCount() {
                list := []
                loop this.GetToolCount() {
                    list.Push(ToolInfo(hwnd, , , 160))
                    SendMessage(TTM_ENUMTOOLSW, A_Index - 1, list[-1].Ptr, hwnd)
                }
                for ti in list {
                    SendMessage(TTM_DELTOOLW, 0, ti.Ptr, hwnd)
                }
            }
            if WinExist(hwnd) {
                DllCall('DestroyWindow', 'ptr', hwnd, 'int')
            }
            this.DeleteProp('Hwnd')
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
    GetMargin() {
        rc := XttRect()
        SendMessage(TTM_GETMARGIN, 0, rc.Ptr, this.Hwnd)
        return rc
    }
    GetMaxTipWidth() {
        return SendMessage(TTM_GETMAXTIPWIDTH, 0, 0, this.Hwnd)
    }
    GetText(Key?, MaxChars?) {
        if IsSet(Key) {
            tiParams := this.Tools.Get(Key)
            ti := ToolInfo(this.Hwnd, tiParams.Hwnd, tiParams.Id)
            if !IsSet(MaxChars) {
                MaxChars := tiParams.TextSize
            }
        } else if this.GetToolCount() {
            this.GetCurrentTool(&ti)
            if !IsSet(MaxChars) {
                hwnd := ti.Hwnd
                id := ti.Id
                for key, _tiParams in this.Tools {
                    if _tiParams.Hwnd = hwnd && _tiParams.Id = id {
                        tiParams := _tiParams
                        break
                    }
                }
                if IsSet(tiParams) {
                    MaxChars := tiParams.TextSize
                } else {
                    throw Error('Unable to retrieve the ``ToolInfo.Params`` object associated with the current tool.', -1)
                }
            }
        } else {
            throw Error('The tooltip does not have an active tool.', -1)
        }
        ti.SetTextBuffer(, MaxChars)
        SendMessage(TTM_GETTEXTW, MaxChars, ti.Ptr, this.Hwnd)
        return ti.Text
    }
    GetTextColor() {
        return SendMessage(TTM_GETTIPTEXTCOLOR, 0, 0, this.Hwnd)
    }
    GetTitle(MaxChars?) {
        return TtGetTitle(this, MaxChars ?? this.TitleSize)
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
    IsTracking(Key?) {
        return this.GetToolInfoObj(Key ?? unset).Flags & TTF_TRACK
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
    SetBackColor(Color) {
        SendMessage(TTM_SETTIPBKCOLOR, Color, 0, this.Hwnd)
    }
    SetBackColorRGB(R, G, B) {
        SendMessage(TTM_SETTIPBKCOLOR, XttRGB(R, G, B), 0, this.Hwnd)
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
        this.Update()
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
        this.Update()
    }
    SetMargin2(RectObj) {
        SendMessage(TTM_SETMARGIN, 0, RectObj.Ptr, this.Hwnd)
        this.Update()
    }
    /**
     * @param {Integer} Width - The maximum width for the tooltip's display area. If the text extends
     * beyond this width, the lines will wrap. Set to -1 to allow any width.
     * @returns {Integer} - The previous maximum width.
     */
    SetMaxWidth(Width) {
        result := SendMessage(TTM_SETMAXTIPWIDTH, 0, Width, this.Hwnd)
        this.Update()
        return result
    }
    SetName(Name) {
        _name := this.__Name || this.Hwnd
        if this.XtooltipCollection {
            if this.XtooltipCollection.Has(_name) {
                this.XtooltipCollection.Delete(_name)
            }
            this.XtooltipCollection.Set(Name, this)
        }
        if themeGroup := this.ThemeGroup {
            if themeGroup.Has(_name) {
                themeGroup.Delete(_name)
            }
            themeGroup.Set(Name, this)
        }
        this.__Name := Name
    }
    SetTextColor(Color) {
        SendMessage(TTM_SETTIPTEXTCOLOR, Color, 0, this.Hwnd)
    }
    SetTextColorRGB(R, G, B) {
        SendMessage(TTM_SETTIPTEXTCOLOR, XttRGB(R, G, B), 0, this.Hwnd)
    }
    SetTheme(Theme) {
        if !IsObject(Theme) {
            if this.ThemeCollection {
                Theme := this.ThemeCollection.Get(Theme)
            } else {
                ; If you get this, you need to call the static method `Xtooltip.RegisterThemeCollection`
                ; before you can refer to a theme by name
                throw Error('An Xtooltip theme collection has not been registered.', -1)
            }
        }
        Theme.Apply(this)
        this.Update()
    }
    SetThemeGroup(ThemeGroup, ApplyTheme := true) {
        if !IsObject(ThemeGroup) {
            if collection := this.ThemeGroupCollection {
                ThemeGroup := collection.Get(ThemeGroup)
            } else {
                ; If you get this error, call the static method `Xtooltip.RegisterThemeGroupCollection`.
                throw Error('You must register a theme group collection before being able to reference a group by name.', -1)
            }
        }
        this.__ThemeGroupName := ThemeGroup.Name
        if ApplyTheme && ThemeGroup.__ActiveTheme {
            ThemeGroup.__ActiveTheme.Apply(this)
        }
        this.Update()
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
            this.TitleSize := StrLen(Title)
        } else {
            if this.TitleSize {
                _ttGetTitle := this.GetTitle()
                if _ttGetTitle.Chars {
                    buf := { Ptr: _ttGetTitle.TitlePtr, Size: _ttGetTitle.Chars * 2 + 2 }
                } else {
                    buf := Buffer(2, 0)
                }
            } else {
                buf := Buffer(2, 0)
            }
        }
        result := SendMessage(TTM_SETTITLEW, Icon, buf.Ptr, this.Hwnd)
        this.Update()
        return result
    }
    /**
     * @description - Sends TTM_SETTOOLINFO to update a tool with new values. Before sending the
     * message, `Xtooltip.Prototype.SetToolInfo` performs some pre-processing and validation to
     * ensure there are no issues. Specifically:
     * - If you do not set `Key` with a valid key, `Xtooltip.Prototype.SetToolInfo` iterates the
     * objects in the ToolInfoParams collection to find a matching one. If a matching `ToolInfo.Params`
     * object is not found, an error is thrown.
     * - If TTF_TRACK is included in `NewToolInfo.Flags`, and if the current `ToolInfo.Params` object
     * associated with `NewToolInfo` does not have the flag TTF_TRACK, and if the property
     * "HasTrackingTool" is 1, an error is thrown because only one tracking tool can be active
     * at a time on an Xtooltip.
     * - If TTF_TRACK is included in `NewToolInfo.Flags` and the value of "HasTrackingTool" is 0,
     * the value is set to 1.
     * - If `NewToolInfo.Text` returns text, and if the length of the text is greater than 79 characters,
     * `Xtooltip.Prototype.SetToolInfo` will proceed with a warning sent to `OutputDebug` explaining
     * that the maximum characters is 79. If you encounte this, you should use method "UpdateTipText"
     * instead.
     * - If `NewToolInfo.Text` returns text, the value of the property "TextSize" is updated on the
     * current `ToolInfo.Params` object with the correct number of bytes.
     *
     * If you update the tooltip's text, it must be 79 characters or less. If you need to update
     * the text with a longer string, use TTM_UPDATETIPTEXT instead.
     *
     * @param {ToolInfo} NewToolInfo - The updated `ToolInfo` object.
     * @param {String} [Key] - The key associated with the `ToolInfo.Params` object associated with
     * the tool that is being updated. If you need to add a new tool, use `Xtooltip.Prototype.AddTool`
     * or any of the other "Add" methods.
     *
     * @throws {Error} - Unable to find the `ToolInfo.Params` object associated with the new `ToolInfo`
     * object. Use `Xtooltip.Prototype.AddTool` instead.
     */
    SetToolInfo(NewToolInfo, Key?) {
        if IsSet(Key) {
            if this.Tools.Has(Key) {
                currentTiParams := this.Tools.Get(Key)
            }
        } else {
            ; find the existing `ToolInfo.Params` object associated with the new `ToolInfo` object.
            hwnd := NewToolInfo.Hwnd
            id := NewToolInfo.Id
            for key, tiParams in this.Tools {
                if hwnd = tiParams.Hwnd && id = tiParams.Id {
                    currentTiParams := tiParams
                    break
                }
            }
        }
        if IsSet(currentTiParams) {
            if NewToolInfo.Flags & TTF_TRACK {
                if this.HasTrackingTool {
                    ; Only one tracking tool can be active on an Xtooltip at a time
                    if !HasProp(currentTiParams, 'Flags') || !(currentTiParams.Flags & TTF_TRACK) {
                        XttErrors.ThrowTrackingError()
                    }
                } else {
                    this.HasTrackingTool := 1
                }
            }
            if len := StrLen(NewToolInfo.Text) {
                if len > 79 {
                    OutputDebug('A maximum of 79 characters can be added to a tool using TTM_SETTOOLINFO. To add a longer string, use TTM_UPDATETIPTEXT`n')
                }
                currentTiParams.TextSize := StrPut(NewToolInfo.Text, XTT_DEFAULT_ENCODING)
            }
        } else {
            throw Error('Unable to find the ``ToolInfo.Params`` object associated with the new'
            ' ``ToolInfo`` object. Use ``Xtooltip.Prototype.AddTool`` instead.', -1)
        }
        SendMessage(TTM_SETTOOLINFOW, 0, NewToolInfo.Ptr, this.Hwnd)
        this.Update()
    }
    SetWindowTheme(TooltipVisualStyleName) {
        buf := Buffer(StrPut(TooltipVisualStyleName, XTT_DEFAULT_ENCODING))
        StrPut(TooltipVisualStyleName, buf, XTT_DEFAULT_ENCODING)
        SendMessage(TTM_SETWINDOWTHEME, 0, buf.Ptr, this.Hwnd)
        this.Update()
    }
    TrackActivate(Key, Value) {
        tiParams := this.Tools.Get(Key)
        ti := ToolInfo(this.Hwnd, tiParams.Hwnd, tiParams.Id)
        SendMessage(TTM_TRACKACTIVATE, Value, ti.Ptr, this.Hwnd)
    }
    TrackPosition(X, Y) {
        SendMessage(TTM_TRACKPOSITION, 0, (Y << 16) | (X & 0xFFFF), this.Hwnd)
    }
    TrackPositionByMouse(OffsetX := 0, OffsetY := 0) {
        pt := Buffer(8)
        DllCall('GetCursorPos', 'ptr', pt, 'int')
        SendMessage(TTM_TRACKPOSITION, 0, ((NumGet(pt, 4, 'int') + OffsetY) << 16) | ((NumGet(pt, 0, 'int') + OffsetX) & 0xFFFF), this.Hwnd)
        this.Update()
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
    UpdateTipText(Str, Key) {
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
        TiParams.TextSize := buf.Size
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
    Name {
        Get => this.__Name
        Set => this.SetName(Value)
    }
    TextColor {
        Get => this.GetTextColor()
        Set => this.SetTextColor(Value)
    }
    Theme {
        Get => this.__Theme
        Set => this.SetTheme(Value)
    }
    ThemeGroup {
        Get => this.ThemeGroupCollection && this.ThemeGroupCollection.Has(this.__ThemeGroupName) ? this.ThemeGroupCollection.Get(this.__ThemeGroupName) : ''
        Set => this.SetThemeGroup(Value)
    }
    Title {
        Get => this.TtGetTitle.Call(this.TitleSize)
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

    class Theme extends Xtooltip.Base {
        static __New() {
            this.DeleteProp('__New')
            this.ListFont := [
                'CharSet', 'ClipPrecision', 'Escapement', 'Family'
              , 'Italic', 'FaceName', 'OutPrecision', 'Pitch', 'Height'
              , 'Quality', 'FontSize', 'Strikeout', 'Underline', 'Weight'
            ]
            this.ListGeneral := ['BackColor', 'MaxWidth', 'TextColor']
            this.ListMargin := ['MarginL', 'MarginT', 'MarginR', 'MarginB']
            this.ListTitle := ['Icon', 'Title']
            Proto := this.Prototype
            Proto.Default := Proto.__Name := ''
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
        static DeregisterDefault() {
            this.Prototype.Default := ''
        }
        static RegisterDefault(DefaultOptions) {
            this.Prototype.Default := DefaultOptions
        }
        static GetOptionCategory(OptionName) {
            if RegExMatcH(OptionName, 'i)^Margin[ltrb]$') {
                return 'Margin'
            }
            OptionName := ',' OptionName ','
            if InStr(',Icon,Title,', OptionName) {
                return 'Title'
            }
            if InStr(',BackColor,MaxWidth,TextColor,', OptionName) {
                return 'General'
            }
            if InStr(',CharSet,ClipPrecision,Escapement,Family,Italic,FaceName,Orientation'
            ',OutPrecision,Pitch,Quality,FontSize,Strikeout,Underline,Weight,', ',' OptionName ',') {
                return 'Font'
            }
            throw ValueError('The option name is invalid.', -1, Trim(OptionName, ','))
        }
        __New(Options?) {
            this.SetOptions(Options ?? {})
            if this.ThemeCollection && this.HasOwnProp('__Name') {
                this.ThemeCollection.Set(this.__Name, this)
            }
        }
        /**
         * @param {Xtooltip} XttObj - The `Xtooltip` object.
         * @param {Boolean} [UpdateThemeProperty = false] - If true, the property "Theme" on
         * `XttObj` will be updated to this `Xtooltip.Theme` object.
         */
        Apply(XttObj) {
            this.ApplyFont(XttObj)
            this.ApplyGeneral(XttObj)
            this.ApplyMargin(XttObj)
            this.ApplyTitle(XttObj)
            XttObj.__Theme := this
        }
        /**
         * @param {Xtooltip} XttObj - The `Xtooltip` object.
         * @param {Boolean} [UpdateThemeProperty = false] - If true, the property "Theme" on
         * `XttObj` will be updated to this `Xtooltip.Theme` object.
         */
        ApplyFont(XttObj) {
            lf := XttObj.Font
            for prop in Xtooltip.Theme.ListFont {
                if HasProp(this, prop) {
                    lf.%prop% := this.%prop%
                }
            }
            lf.Apply()
        }
        /**
         * @param {Xtooltip} XttObj - The `Xtooltip` object.
         * @param {Boolean} [UpdateThemeProperty = false] - If true, the property "Theme" on
         * `XttObj` will be updated to this `Xtooltip.Theme` object.
         */
        ApplyGeneral(XttObj) {
            for prop in Xtooltip.Theme.ListGeneral {
                if HasProp(this, prop) {
                    XttObj.%prop% := this.%prop%
                }
            }
        }
        /**
         * @param {Xtooltip} XttObj - The `Xtooltip` object.
         * @param {Boolean} [UpdateThemeProperty = false] - If true, the property "Theme" on
         * `XttObj` will be updated to this `Xtooltip.Theme` object.
         */
        ApplyMargin(XttObj) {
            XttObj.SetMargin(
                HasProp(this, 'MarginL') ? this.MarginL : unset
              , HasProp(this, 'MarginT') ? this.MarginT : unset
              , HasProp(this, 'MarginR') ? this.MarginR : unset
              , HasProp(this, 'MarginB') ? this.MarginB : unset
            )
        }
        /**
         * @param {Xtooltip} XttObj - The `Xtooltip` object.
         * @param {Boolean} [Font = false] - If true, `Xtooltip.Theme.Prototype.ApplyFont` will be called.
         * @param {Boolean} [General = false] - If true, `Xtooltip.Theme.Prototype.ApplyGeneral` will be called.
         * @param {Boolean} [Margin = false] - If true, `Xtooltip.Theme.Prototype.ApplyMargin` will be called.
         * @param {Boolean} [Title = false] - If true, `Xtooltip.Theme.Prototype.ApplyTitle` will be called.
         * @param {Boolean} [UpdateThemeProperty = false] - If true, the property "Theme" on
         * `XttObj` will be updated to this `Xtooltip.Theme` object.
         */
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
        /**
         * @param {Xtooltip} XttObj - The `Xtooltip` object.
         * @param {Boolean} [UpdateThemeProperty = false] - If true, the property "Theme" on
         * `XttObj` will be updated to this `Xtooltip.Theme` object.
         */
        ApplyTitle(XttObj) {
            XttObj.SetTitle(
                HasProp(this, 'Icon') ? this.Icon : unset
              , HasProp(this, 'Title') ? this.Title : unset
            )
        }
        DisownChildren(CopyInheritedProperties := false) {
            for child in this.__Children {
                child.DisownParent(CopyInheritedProperties)
            }
        }
        DisownParent(CopyInheritedProperties := false) {
            if CopyInheritedProperties {
                parent := this.__Parent
                for prop in Xtooltip.Theme {
                    if HasProp(parent, prop) {
                        this.DefineProp(prop, { Value: parent.%prop% })
                    }
                }
            }
            ObjSetBase(this, Xtooltip.Theme.Prototype)
            this.DeleteProp('__Parent')
        }
        MakeChildTheme(ChildOptions) {
            if !this.HasOwnProp('__Children') {
                this.__Children := XttChildThemeCollection()
            }
            this.DefineProp('MakeChildTheme', { Call: _MakeChildTheme })
            _MakeChildTheme.DefineProp('Name', { Value: A_ThisFunc })

            return this.MakeChildTheme(ChildOptions)

            _MakeChildTheme(Self, ChildOptions) {
                if !HasProp(ChildOptions, 'Name') {
                    ; If you get this error, call `ThemeObj.SetName("SomeName")`.
                    XttErrors.ThrowChildThemeNoName()
                }
                Child := {}
                ObjSetBase(Child, this)
                Child.SetOptions(ChildOptions)
                this.__Children.Set(Child.Name, Child)
                if this.ThemeCollection {
                    this.ThemeCollection.Set(Child.__Name, Child)
                }
                return Child
            }
        }
        SetName(ThemeName) {
            if this.ThemeCollection {
                if this.ThemeCollection.Has(this.__Name) {
                    this.ThemeCollection.Delete(this.__Name)
                }
                this.ThemeCollection.Set(ThemeName, this)
            }
            if parent := this.Parent {
                if parent.__Children.Has(this.__Name) {
                    parent.__Children.Delete(this.__Name)
                }
                parent.__Children.Set(ThemeName, this)
            }
            this.__Name := ThemeName
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
            if HasProp(Options, 'Name') {
                this.SetName(Options.Name)
            }
        }
        SetParent(ParentTheme) {
            if !this.HasOwnProp('__Name') {
                throw Error('A theme must have a name to be made a child theme.', -1)
            }
            if !IsObject(ParentTheme) {
                ParentTheme := this.ThemeCollection.Get(ParentTheme)
            }
            if this.HasOwnProp('__Parent') {
                this.__Parent.__Children.Delete(this.__Name)
            }
            this.__Parent := ParentTheme
            if !ParentTheme.HasOwnProp('__Children') {
                ParentTheme.__Children := XttChildThemeCollection()
            }
            ParentTheme.__Children.Set(this.Name, this)
        }

        Children {
            Get => this.HasOwnProp('__Children') ? this.__Children : ''
            Set {
                if this.HasOwnProp('__Children') {
                    if Value {
                        throw Error('The theme already has an ``XttChildThemeCollection``.', -1)
                    } else {
                        this.DisownChildren()
                    }
                } else {
                    if Value {
                        if Value is XttChildThemeCollection {
                            this.__Children := Value
                        } else {
                            this.__Children := XttChildThemeCollection()
                        }
                    } else {
                        throw Error('The theme does not have an ``XttChildThemeCollection``.', -1)
                    }
                }
            }
        }
        Name {
            Get => this.HasOwnProp('__Name') ? this.__Name : ''
            Set => this.SetName(Value)
        }
        Parent {
            Get => this.HasOwnProp('__Parent') ? this.__Parent : ''
            Set => this.SetParent(Value)
        }
    }

    class ThemeGroup extends Xtooltip.Base {
        __New(GroupName) {
            this.__ActiveTheme := ''
            this.Themes := XttThemeCollection()
            this.Xtooltips := XtooltipCollection()
            this.__Name := GroupName
            if this.ThemeGroupCollection {
                this.ThemeGroupCollection.Set(GroupName, this)
            }
        }
        Apply(Theme?) {
            if IsSet(Theme) {
                if !IsObject(Theme) {
                    Theme := this.Themes.Get(Theme)
                }
            } else {
                Theme := this.__ActiveTheme
            }
            for key, xtt in this.Xtooltips {
                _lf := xtt.Font.Clone()
                for prop in Xtooltip.Theme.ListFont {
                    if HasProp(Theme, prop) {
                        _lf.%prop% := Theme.%prop%
                    }
                }
                break
            }
            if HasProp(Theme, 'Title') {
                flag_title := 1
                bytes := StrPut(Theme.Title, XTT_DEFAULT_ENCODING)
                if bytes > 200 {
                    throw Error('The title length exceeds the maximum (198 bytes).', -1, Theme.Title)
                }
                title := Buffer(bytes)
                StrPut(Theme.Title, title, XTT_DEFAULT_ENCODING)
                if HasProp(Theme, 'Icon') {
                    icon := Theme.Icon
                } else {
                    icon := 0
                }
            } else if HasProp(Theme, 'Icon') {
                flag_title := 1
                icon := Theme.Icon
                title := Buffer(2, 0)
            } else {
                flag_title := 0
            }
            margins := []
            margins.Length := 4
            flag_margins := 0
            for char in ['L', 'T', 'R', 'B'] {
                if HasProp(Theme, 'Margins' char) {
                    margins[A_Index] := Theme.Margins%char%
                    flag_margins := 1
                }
            }
            list := Map()
            for prop in Xtooltip.Theme.ListGeneral {
                if HasProp(Theme, prop) {
                    list.Set(prop, Theme.%prop%)
                }
            }
            flag_general := list.Count
            for hwnd, xtt in this.Xtooltips {
                _lf.Clone(xtt.Font.Buffer, , false)
                xtt.Font.Apply()
                if flag_title {
                    SendMessage(TTM_SETTITLEW, icon, title.Ptr, hwnd)
                }
                if flag_margins {
                    xtt.SetMargin(margins*)
                }
                if flag_general {
                    for prop, val in list {
                        xtt.%prop% := val
                    }
                }
                xtt.__Theme := Theme
            }
        }
        ApplyFont(Theme?) {
            if IsSet(Theme) {
                if !IsObject(Theme) {
                    Theme := this.Themes.Get(Theme)
                }
            } else {
                Theme := this.__ActiveTheme
            }
            for hwnd, xtt in this.Xtooltips {
                _lf := xtt.Font.Clone()
                for prop in Xtooltip.Theme.ListFont {
                    if HasProp(Theme, prop) {
                        _lf.%prop% := Theme.%prop%
                    }
                }
                break
            }
            for key, xtt in this.Xtooltips {
                _lf.Clone(xtt.Font.Buffer, , false)
                xtt.Font.Apply()
            }
        }
        ApplyGeneral(Theme?) {
            if IsSet(Theme) {
                if !IsObject(Theme) {
                    Theme := this.Themes.Get(Theme)
                }
            } else {
                Theme := this.__ActiveTheme
            }
            xtooltips := this.Xtooltips
            for prop in Xtooltip.Theme.ListGeneral {
                if HasProp(Theme, prop) {
                    val := Theme.%prop%
                    for hwnd, xtt in xtooltips {
                        xtt.%prop% := val
                    }
                }
            }
        }
        ApplyMargin(Theme?) {
            if IsSet(Theme) {
                if !IsObject(Theme) {
                    Theme := this.Themes.Get(Theme)
                }
            } else {
                Theme := this.__ActiveTheme
            }
            margins := []
            margins.Length := 4
            flag_margins := 0
            for char in ['L', 'T', 'R', 'B'] {
                if HasProp(Theme, 'Margins' char) {
                    margins[A_Index] := Theme.Margins%char%
                }
            }
            for hwnd, xtt in this.Xtooltips {
                xtt.SetMargin(margins*)
            }
        }
        ApplySelection(Theme?, Font := false, General := false, Margin := false, Title := false) {
            if IsSet(Theme) {
                if !IsObject(Theme) {
                    Theme := this.Themes.Get(Theme)
                }
            } else {
                Theme := this.__ActiveTheme
            }
            if Font {
                this.ApplyFont(Theme)
            }
            if General {
                this.ApplyGeneral(Theme)
            }
            if Margin {
                this.ApplyMargin(Theme)
            }
            if Title {
                this.ApplyTitle(Theme)
            }
        }
        ApplyTitle(Theme?) {
            if IsSet(Theme) {
                if !IsObject(Theme) {
                    Theme := this.Themes.Get(Theme)
                }
            } else {
                Theme := this.__ActiveTheme
            }
            icon := HasProp(Theme, 'Icon') ? Theme.Icon : 0
            if HasProp(Theme, 'Title') {
                flag_title := 1
                bytes := StrPut(Theme.Title, XTT_DEFAULT_ENCODING)
                if bytes > 200 {
                    throw Error('The title length exceeds the maximum (198 bytes).', -1, Theme.Title)
                }
                title := Buffer(bytes)
                StrPut(Theme.Title, title, XTT_DEFAULT_ENCODING)
                if HasProp(Theme, 'Icon') {
                    icon := Theme.Icon
                } else {
                    icon := 0
                }
            } else {
                title := Buffer(2, 0)
            }
            for hwnd in this.Xtooltips {
                SendMessage(TTM_SETTITLEW, icon, title.Ptr, hwnd)
            }
        }
        GetActiveTheme() {
            return this.__ActiveTheme
        }
        SetName(GroupName) {
            for hwnd, xtt in this.Xtooltips {
                xtt.__ThemeGroupName := this.__Name
            }
            if collection := this.ThemeGroupCollection {
                if collection.Has(this.__Name) {
                    collection.Delete(this.__Name)
                }
                collection.Set(GroupName, this)
            }
            this.__Name := GroupName
        }
        ThemeActivate(Theme) {
            if IsObject(Theme) {
                if !Theme.HasOwnProp('__Name') {
                    ; If you get this error, call `ThemeObj.SetName("SomeName")`.
                    XttErrors.ThrowThemeGroupNoThemeName()
                }
                this.Themes.Set(Theme.__Name, Theme)
            } else {
                if this.Themes.Has(Theme) {
                    Theme := this.Themes.Get(Theme)
                } else if this.ThemeCollection && this.ThemeCollection.Has(Theme) {
                    Theme := this.ThemeCollection.Get(Theme)
                    this.Themes.Set(Theme.__Name, Theme)
                } else {
                    throw Error('Unable to find a theme with the input name.', -1, Theme)
                }
            }
            if this.Xtooltips.Count {
                this.Apply(Theme)
            }
            this.__ActiveTheme := Theme
        }
        ThemeAdd(Theme, Activate := true) {
            if IsObject(Theme) {
                if !Theme.HasOwnProp('__Name') {
                    ; If you get this error, call `ThemeObj.SetName("SomeName")`.
                    XttErrors.ThrowThemeGroupNoThemeName()
                }
                if not Theme is Xtooltip.Theme {
                    Theme := Xtooltip.Theme(Theme)
                }
            } else {
                Theme := this.ThemeCollection.Get(Theme)
            }
            this.Themes.Set(Theme.__Name, Theme)
            if Activate {
                if this.Xtooltips.Count {
                    this.Apply(Theme)
                }
                this.__ActiveTheme := Theme
            }
            return Theme
        }
        ThemeDelete(Theme) {
            this.Themes.Delete(IsObject(Theme) ? Theme.__Name : Theme)
        }
        ThemeGet(ThemeName) {
            return this.Themes.Get(ThemeName)
        }
        ThemeSet(Theme) {
            if !Theme.HasOwnProp('__Name') {
                ; If you get this error, call `ThemeObj.SetName("SomeName")`.
                XttErrors.ThrowThemeGroupNoThemeName()
            }
            this.Themes.Set(Theme.__Name, Theme)
        }
        ThemeSetValue(OptionName, Value, Apply := true) {
            this.__ActiveTheme.%OptionName% := Value
            if Apply {
                this.Apply%Xtooltip.Theme.GetOptionCategory(OptionName)%()
            }
        }
        XttAdd(XttObj, ApplyActiveTheme := true) {
            this.Xtooltips.Set(XttObj.Hwnd, XttObj)
            if ApplyActiveTheme && this.__ActiveTheme {
                this.__ActiveTheme.Apply(XttObj)
                XttObj.__ThemeGroupName := this.Name
            }
        }
        XttDelete(XttObj) {
            this.Xtooltips.Delete(XttObj.Hwnd)
            XttObj.__ThemeGroupName := ''
        }

        ActiveTheme {
            Get => this.__ActiveTheme
            Set => this.ThemeActivate(Value)
        }
        Name {
            Get => this.__Name
            Set => this.SetName(Value)
        }
    }

    class Base {
        ThemeGroupCollection => Xtooltip.ThemeGroupCollection
        ThemeCollection => Xtooltip.ThemeCollection
        XtooltipCollection => Xtooltip.XtooltipCollection
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
        return rc
    }
    static Client(Hwnd) {
        rc := this()
        DllCall('GetClientRect', 'ptr', Hwnd, 'ptr', rc, 'int')
        return rc
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
        return rc
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

class TtGetTitle {
    static __New() {
        this.DeleteProp('__New')
        this.Size :=
        4 +         ; DWORD         dwSize
        4 +         ; UINT          uTitleBitmap
        A_PtrSize + ; UINT          cch + 4 for alignment on x64
        A_PtrSize   ; WCHAR         *pszTitle

        if A_PtrSize == 8 {
            this.Prototype.PtrOffset := 16
        } else {
            this.Prototype.PtrOffset := 12
        }
    }
    __New(Xtt, MaxChars?, Send := true) {
        this.Hwnd := Xtt.Hwnd
        this.Buffer := Buffer(TtGetTitle.Size, 0)
        NumPut('uint', this.Buffer.Size, this.Buffer.Ptr)
        if Send {
            if IsSet(MaxChars) {
                this.Chars := MaxChars + 1
                this.SetTextBuffer()
            } else {
                throw Error('``MaxChars`` must be set when ``Send`` is nonzero.', -1)
            }
            SendMessage(TTM_GETTITLE, 0, this.Buffer.Ptr, this.Hwnd)
        }
    }
    Call(MaxChars, &OutIcon?) {
        if WinExist(this.Hwnd) {
            this.Chars := MaxChars + 1
            NumPut('uint', 0, this.Buffer, 4)
            this.SetTextBuffer()
            SendMessage(TTM_GETTITLE, 0, this.Buffer.Ptr, this.Hwnd)
        } else {
            throw Error('The window no longer exists.', -1)
        }
        OutIcon := this.Icon
        if this.Chars {
            return this.Title
        }
    }
    SetTextBuffer() {
        this.TextBuffer := Buffer(this.TitleSize)
        NumPut('ptr', this.TextBuffer.Ptr, this.Buffer, this.PtrOffset)
    }
    Chars {
        Get => NumGet(this.Buffer, 8, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, 8)
        }
    }
    Icon => NumGet(this.Buffer, 4, 'uint')
    Title => StrGet(this.TitlePtr) ; XTT_DEFAULT_ENCODING = UTF-16
    TitlePtr => NumGet(this.Buffer, this.PtrOffset, 'ptr')
    TitleSize => this.Chars * 2
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
}

class XtooltipCollection extends XttCollectionBase {

}

class ToolInfoParamsCollection extends XttCollectionBase {
}
class XttThemeCollection extends XttCollectionBase {
}
class XttThemeGroupCollection extends XttCollectionBase {
    Add(ThemeGroupName, Group?) {
        this.Set(ThemeGroupName, Group ?? XTooltip.ThemeGroup())
        return this.Get(ThemeGroupName)
    }
}
class XttChildThemeCollection extends XttCollectionBase {
}
class XttCollectionBase extends Map {
    __New(CaseSense := false, Items*) {
        this.CaseSense := CaseSense
        if Items.Length {
            this.Set(Items*)
        }
    }
    /**
     * @returns {Array} - An array of keys.
     */
    ToListKey() {
        list := []
        list.Capacity := this.Count
        for k in this {
            list.Push(k)
        }
        return list
    }
    /**
     * @returns {Array} - An array of objects contained in the collection.
     */
    ToListValue() {
        list := []
        list.Capacity := this.Count
        for k, v in this {
            list.Push(v)
        }
        return list
    }
}

class XttErrors {
    static ThrowThemeGroupNoThemeName() {
        throw Error('A theme must be set with a name to be added to a theme group.', -2)
    }
    static ThrowChildThemeNoName() {
        throw Error('A theme must be set with a name to be made a child of another theme.', -2)
    }
    static ThrowTrackingError() {
        throw Error('Only one tracking tool can be added to an Xtooltip at a time.', -2)
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

    ; TTI - tooltip icons
    TTI_NONE := 0
    TTI_INFO := 1
    TTI_WARNING := 2
    TTI_ERROR := 3
    ; #if (NTDDI_VERSION >= NTDDI_VISTA)
    TTI_INFO_LARGE := 4
    TTI_WARNING_LARGE := 5
    TTI_ERROR_LARGE := 6

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



/*
 * Window Messages


#define WM_NULL                         0x0000
#define WM_CREATE                       0x0001
#define WM_DESTROY                      0x0002
#define WM_MOVE                         0x0003
#define WM_SIZE                         0x0005

#define WM_ACTIVATE                     0x0006
/*
 * WM_ACTIVATE state values

#define     WA_INACTIVE     0
#define     WA_ACTIVE       1
#define     WA_CLICKACTIVE  2

#define WM_SETFOCUS                     0x0007
#define WM_KILLFOCUS                    0x0008
#define WM_ENABLE                       0x000A
#define WM_SETREDRAW                    0x000B
#define WM_SETTEXT                      0x000C
#define WM_GETTEXT                      0x000D
#define WM_GETTEXTLENGTH                0x000E
#define WM_PAINT                        0x000F
#define WM_CLOSE                        0x0010
#ifndef _WIN32_WCE
#define WM_QUERYENDSESSION              0x0011
#define WM_QUERYOPEN                    0x0013
#define WM_ENDSESSION                   0x0016
#endif
#define WM_QUIT                         0x0012
#define WM_ERASEBKGND                   0x0014
#define WM_SYSCOLORCHANGE               0x0015
#define WM_SHOWWINDOW                   0x0018
#define WM_WININICHANGE                 0x001A
#if(WINVER >= 0x0400)
#define WM_SETTINGCHANGE                WM_WININICHANGE
#endif /* WINVER >= 0x0400

#if (NTDDI_VERSION >= NTDDI_WIN10_19H1)
#endif // NTDDI_VERSION >= NTDDI_WIN10_19H1


#define WM_DEVMODECHANGE                0x001B
#define WM_ACTIVATEAPP                  0x001C
#define WM_FONTCHANGE                   0x001D
#define WM_TIMECHANGE                   0x001E
#define WM_CANCELMODE                   0x001F
#define WM_SETCURSOR                    0x0020
#define WM_MOUSEACTIVATE                0x0021
#define WM_CHILDACTIVATE                0x0022
#define WM_QUEUESYNC                    0x0023

#define WM_GETMINMAXINFO                0x0024

#pragma region Desktop Family
#if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_DESKTOP)

/*
 * Struct pointed to by WM_GETMINMAXINFO lParam

typedef struct tagMINMAXINFO {
    POINT ptReserved;
    POINT ptMaxSize;
    POINT ptMaxPosition;
    POINT ptMinTrackSize;
    POINT ptMaxTrackSize;
} MINMAXINFO, *PMINMAXINFO, *LPMINMAXINFO;

#endif /* WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_DESKTOP)
#pragma endregion

#define WM_PAINTICON                    0x0026
#define WM_ICONERASEBKGND               0x0027
#define WM_NEXTDLGCTL                   0x0028
#define WM_SPOOLERSTATUS                0x002A
#define WM_DRAWITEM                     0x002B
#define WM_MEASUREITEM                  0x002C
#define WM_DELETEITEM                   0x002D
#define WM_VKEYTOITEM                   0x002E
#define WM_CHARTOITEM                   0x002F
#define WM_SETFONT                      0x0030
#define WM_GETFONT                      0x0031
#define WM_SETHOTKEY                    0x0032
#define WM_GETHOTKEY                    0x0033
#define WM_QUERYDRAGICON                0x0037
#define WM_COMPAREITEM                  0x0039
#if(WINVER >= 0x0500)
#ifndef _WIN32_WCE
#define WM_GETOBJECT                    0x003D
#endif
#endif /* WINVER >= 0x0500
#define WM_COMPACTING                   0x0041
#define WM_COMMNOTIFY                   0x0044  /* no longer suported
#define WM_WINDOWPOSCHANGING            0x0046
#define WM_WINDOWPOSCHANGED             0x0047

#define WM_POWER                        0x0048
/*
 * wParam for WM_POWER window message and DRV_POWER driver notification

#define PWR_OK              1
#define PWR_FAIL            (-1)
#define PWR_SUSPENDREQUEST  1
#define PWR_SUSPENDRESUME   2
#define PWR_CRITICALRESUME  3

#define WM_COPYDATA                     0x004A
#define WM_CANCELJOURNAL                0x004B


#pragma region Desktop Family
#if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_DESKTOP)

/*
 * lParam of WM_COPYDATA message points to...

typedef struct tagCOPYDATASTRUCT {
    ULONG_PTR dwData;
    DWORD cbData;
    _Field_size_bytes_(cbData) PVOID lpData;
} COPYDATASTRUCT, *PCOPYDATASTRUCT;

#if(WINVER >= 0x0400)
typedef struct tagMDINEXTMENU
{
    HMENU   hmenuIn;
    HMENU   hmenuNext;
    HWND    hwndNext;
} MDINEXTMENU, * PMDINEXTMENU, FAR * LPMDINEXTMENU;
#endif /* WINVER >= 0x0400

#endif /* WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_DESKTOP)
#pragma endregion


#if(WINVER >= 0x0400)
#define WM_NOTIFY                       0x004E
#define WM_INPUTLANGCHANGEREQUEST       0x0050
#define WM_INPUTLANGCHANGE              0x0051
#define WM_TCARD                        0x0052
#define WM_HELP                         0x0053
#define WM_USERCHANGED                  0x0054
#define WM_NOTIFYFORMAT                 0x0055

#define NFR_ANSI                             1
#define NFR_UNICODE                          2
#define NF_QUERY                             3
#define NF_REQUERY                           4

#define WM_CONTEXTMENU                  0x007B
#define WM_STYLECHANGING                0x007C
#define WM_STYLECHANGED                 0x007D
#define WM_DISPLAYCHANGE                0x007E
#define WM_GETICON                      0x007F
#define WM_SETICON                      0x0080
#endif /* WINVER >= 0x0400

#define WM_NCCREATE                     0x0081
#define WM_NCDESTROY                    0x0082
#define WM_NCCALCSIZE                   0x0083
#define WM_NCHITTEST                    0x0084
#define WM_NCPAINT                      0x0085
#define WM_NCACTIVATE                   0x0086
#define WM_GETDLGCODE                   0x0087
#ifndef _WIN32_WCE
#define WM_SYNCPAINT                    0x0088
#endif
#define WM_NCMOUSEMOVE                  0x00A0
#define WM_NCLBUTTONDOWN                0x00A1
#define WM_NCLBUTTONUP                  0x00A2
#define WM_NCLBUTTONDBLCLK              0x00A3
#define WM_NCRBUTTONDOWN                0x00A4
#define WM_NCRBUTTONUP                  0x00A5
#define WM_NCRBUTTONDBLCLK              0x00A6
#define WM_NCMBUTTONDOWN                0x00A7
#define WM_NCMBUTTONUP                  0x00A8
#define WM_NCMBUTTONDBLCLK              0x00A9



#if(_WIN32_WINNT >= 0x0500)
#define WM_NCXBUTTONDOWN                0x00AB
#define WM_NCXBUTTONUP                  0x00AC
#define WM_NCXBUTTONDBLCLK              0x00AD
#endif /* _WIN32_WINNT >= 0x0500


#if(_WIN32_WINNT >= 0x0501)
#define WM_INPUT_DEVICE_CHANGE          0x00FE
#endif /* _WIN32_WINNT >= 0x0501

#if(_WIN32_WINNT >= 0x0501)
#define WM_INPUT                        0x00FF
#endif /* _WIN32_WINNT >= 0x0501

#define WM_KEYFIRST                     0x0100
#define WM_KEYDOWN                      0x0100
#define WM_KEYUP                        0x0101
#define WM_CHAR                         0x0102
#define WM_DEADCHAR                     0x0103
#define WM_SYSKEYDOWN                   0x0104
#define WM_SYSKEYUP                     0x0105
#define WM_SYSCHAR                      0x0106
#define WM_SYSDEADCHAR                  0x0107
#if(_WIN32_WINNT >= 0x0501)
#define WM_UNICHAR                      0x0109
#define WM_KEYLAST                      0x0109
#define UNICODE_NOCHAR                  0xFFFF
#else
#define WM_KEYLAST                      0x0108
#endif /* _WIN32_WINNT >= 0x0501

#if(WINVER >= 0x0400)
#define WM_IME_STARTCOMPOSITION         0x010D
#define WM_IME_ENDCOMPOSITION           0x010E
#define WM_IME_COMPOSITION              0x010F
#define WM_IME_KEYLAST                  0x010F
#endif /* WINVER >= 0x0400

#define WM_INITDIALOG                   0x0110
#define WM_COMMAND                      0x0111
#define WM_SYSCOMMAND                   0x0112
#define WM_TIMER                        0x0113
#define WM_HSCROLL                      0x0114
#define WM_VSCROLL                      0x0115
#define WM_INITMENU                     0x0116
#define WM_INITMENUPOPUP                0x0117
#if(WINVER >= 0x0601)
#define WM_GESTURE                      0x0119
#define WM_GESTURENOTIFY                0x011A
#endif /* WINVER >= 0x0601
#define WM_MENUSELECT                   0x011F
#define WM_MENUCHAR                     0x0120
#define WM_ENTERIDLE                    0x0121
#if(WINVER >= 0x0500)
#ifndef _WIN32_WCE
#define WM_MENURBUTTONUP                0x0122
#define WM_MENUDRAG                     0x0123
#define WM_MENUGETOBJECT                0x0124
#define WM_UNINITMENUPOPUP              0x0125
#define WM_MENUCOMMAND                  0x0126

#ifndef _WIN32_WCE
#if(_WIN32_WINNT >= 0x0500)
#define WM_CHANGEUISTATE                0x0127
#define WM_UPDATEUISTATE                0x0128
#define WM_QUERYUISTATE                 0x0129

/*
 * LOWORD(wParam) values in WM_*UISTATE*

#define UIS_SET                         1
#define UIS_CLEAR                       2
#define UIS_INITIALIZE                  3

/*
 * HIWORD(wParam) values in WM_*UISTATE*

#define UISF_HIDEFOCUS                  0x1
#define UISF_HIDEACCEL                  0x2
#if(_WIN32_WINNT >= 0x0501)
#define UISF_ACTIVE                     0x4
#endif /* _WIN32_WINNT >= 0x0501
#endif /* _WIN32_WINNT >= 0x0500
#endif

#endif
#endif /* WINVER >= 0x0500

#define WM_CTLCOLORMSGBOX               0x0132
#define WM_CTLCOLOREDIT                 0x0133
#define WM_CTLCOLORLISTBOX              0x0134
#define WM_CTLCOLORBTN                  0x0135
#define WM_CTLCOLORDLG                  0x0136
#define WM_CTLCOLORSCROLLBAR            0x0137
#define WM_CTLCOLORSTATIC               0x0138
#define MN_GETHMENU                     0x01E1

#define WM_MOUSEFIRST                   0x0200
#define WM_MOUSEMOVE                    0x0200
#define WM_LBUTTONDOWN                  0x0201
#define WM_LBUTTONUP                    0x0202
#define WM_LBUTTONDBLCLK                0x0203
#define WM_RBUTTONDOWN                  0x0204
#define WM_RBUTTONUP                    0x0205
#define WM_RBUTTONDBLCLK                0x0206
#define WM_MBUTTONDOWN                  0x0207
#define WM_MBUTTONUP                    0x0208
#define WM_MBUTTONDBLCLK                0x0209
#if (_WIN32_WINNT >= 0x0400) || (_WIN32_WINDOWS > 0x0400)
#define WM_MOUSEWHEEL                   0x020A
#endif
#if (_WIN32_WINNT >= 0x0500)
#define WM_XBUTTONDOWN                  0x020B
#define WM_XBUTTONUP                    0x020C
#define WM_XBUTTONDBLCLK                0x020D
#endif
#if (_WIN32_WINNT >= 0x0600)
#define WM_MOUSEHWHEEL                  0x020E
#endif

#if (_WIN32_WINNT >= 0x0600)
#define WM_MOUSELAST                    0x020E
#elif (_WIN32_WINNT >= 0x0500)
#define WM_MOUSELAST                    0x020D
#elif (_WIN32_WINNT >= 0x0400) || (_WIN32_WINDOWS > 0x0400)
#define WM_MOUSELAST                    0x020A
#else
#define WM_MOUSELAST                    0x0209
#endif /* (_WIN32_WINNT >= 0x0600)


#if(_WIN32_WINNT >= 0x0400)
/* Value for rolling one detent
#define WHEEL_DELTA                     120
#define GET_WHEEL_DELTA_WPARAM(wParam)  ((short)HIWORD(wParam))

/* Setting to scroll one page for SPI_GET/SETWHEELSCROLLLINES
#define WHEEL_PAGESCROLL                (UINT_MAX)
#endif /* _WIN32_WINNT >= 0x0400

#if(_WIN32_WINNT >= 0x0500)
#define GET_KEYSTATE_WPARAM(wParam)     (LOWORD(wParam))
#define GET_NCHITTEST_WPARAM(wParam)    ((short)LOWORD(wParam))
#define GET_XBUTTON_WPARAM(wParam)      (HIWORD(wParam))

/* XButton values are WORD flags
#define XBUTTON1      0x0001
#define XBUTTON2      0x0002
/* Were there to be an XBUTTON3, its value would be 0x0004
#endif /* _WIN32_WINNT >= 0x0500

#define WM_PARENTNOTIFY                 0x0210
#define WM_ENTERMENULOOP                0x0211
#define WM_EXITMENULOOP                 0x0212

#if(WINVER >= 0x0400)
#define WM_NEXTMENU                     0x0213
#define WM_SIZING                       0x0214
#define WM_CAPTURECHANGED               0x0215
#define WM_MOVING                       0x0216
#endif /* WINVER >= 0x0400

#if(WINVER >= 0x0400)


#define WM_POWERBROADCAST               0x0218

#ifndef _WIN32_WCE
#define PBT_APMQUERYSUSPEND             0x0000
#define PBT_APMQUERYSTANDBY             0x0001

#define PBT_APMQUERYSUSPENDFAILED       0x0002
#define PBT_APMQUERYSTANDBYFAILED       0x0003

#define PBT_APMSUSPEND                  0x0004
#define PBT_APMSTANDBY                  0x0005

#define PBT_APMRESUMECRITICAL           0x0006
#define PBT_APMRESUMESUSPEND            0x0007
#define PBT_APMRESUMESTANDBY            0x0008

#define PBTF_APMRESUMEFROMFAILURE       0x00000001

#define PBT_APMBATTERYLOW               0x0009
#define PBT_APMPOWERSTATUSCHANGE        0x000A

#define PBT_APMOEMEVENT                 0x000B


#define PBT_APMRESUMEAUTOMATIC          0x0012
#if (_WIN32_WINNT >= 0x0502)
#ifndef PBT_POWERSETTINGCHANGE
#define PBT_POWERSETTINGCHANGE          0x8013

#pragma region Desktop Family
#if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_DESKTOP)

typedef struct {
    GUID PowerSetting;
    DWORD DataLength;
    UCHAR Data[1];
} POWERBROADCAST_SETTING, *PPOWERBROADCAST_SETTING;


#endif /* WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_DESKTOP)
#pragma endregion

#endif // PBT_POWERSETTINGCHANGE

#endif // (_WIN32_WINNT >= 0x0502)
#endif

#endif /* WINVER >= 0x0400

#if(WINVER >= 0x0400)
#define WM_DEVICECHANGE                 0x0219
#endif /* WINVER >= 0x0400

#define WM_MDICREATE                    0x0220
#define WM_MDIDESTROY                   0x0221
#define WM_MDIACTIVATE                  0x0222
#define WM_MDIRESTORE                   0x0223
#define WM_MDINEXT                      0x0224
#define WM_MDIMAXIMIZE                  0x0225
#define WM_MDITILE                      0x0226
#define WM_MDICASCADE                   0x0227
#define WM_MDIICONARRANGE               0x0228
#define WM_MDIGETACTIVE                 0x0229


#define WM_MDISETMENU                   0x0230
#define WM_ENTERSIZEMOVE                0x0231
#define WM_EXITSIZEMOVE                 0x0232
#define WM_DROPFILES                    0x0233
#define WM_MDIREFRESHMENU               0x0234

#if(WINVER >= 0x0602)
#define WM_POINTERDEVICECHANGE          0x238
#define WM_POINTERDEVICEINRANGE         0x239
#define WM_POINTERDEVICEOUTOFRANGE      0x23A
#endif /* WINVER >= 0x0602

// TODO(47499024): Make public when Feature_TouchpadPublicApis is enabled

#if(WINVER >= 0x0601)
#define WM_TOUCH                        0x0240
#endif /* WINVER >= 0x0601

#if(WINVER >= 0x0602)
#define WM_NCPOINTERUPDATE              0x0241
#define WM_NCPOINTERDOWN                0x0242
#define WM_NCPOINTERUP                  0x0243
#define WM_POINTERUPDATE                0x0245
#define WM_POINTERDOWN                  0x0246
#define WM_POINTERUP                    0x0247
#define WM_POINTERENTER                 0x0249
#define WM_POINTERLEAVE                 0x024A
#define WM_POINTERACTIVATE              0x024B
#define WM_POINTERCAPTURECHANGED        0x024C
#define WM_TOUCHHITTESTING              0x024D
#define WM_POINTERWHEEL                 0x024E
#define WM_POINTERHWHEEL                0x024F
#define DM_POINTERHITTEST               0x0250
#define WM_POINTERROUTEDTO              0x0251
#define WM_POINTERROUTEDAWAY            0x0252
#define WM_POINTERROUTEDRELEASED        0x0253
#endif /* WINVER >= 0x0602


#if(WINVER >= 0x0400)
#define WM_IME_SETCONTEXT               0x0281
#define WM_IME_NOTIFY                   0x0282
#define WM_IME_CONTROL                  0x0283
#define WM_IME_COMPOSITIONFULL          0x0284
#define WM_IME_SELECT                   0x0285
#define WM_IME_CHAR                     0x0286
#endif /* WINVER >= 0x0400
#if(WINVER >= 0x0500)
#define WM_IME_REQUEST                  0x0288
#endif /* WINVER >= 0x0500
#if(WINVER >= 0x0400)
#define WM_IME_KEYDOWN                  0x0290
#define WM_IME_KEYUP                    0x0291
#endif /* WINVER >= 0x0400

#if((_WIN32_WINNT >= 0x0400) || (WINVER >= 0x0500))
#define WM_MOUSEHOVER                   0x02A1
#define WM_MOUSELEAVE                   0x02A3
#endif
#if(WINVER >= 0x0500)
#define WM_NCMOUSEHOVER                 0x02A0
#define WM_NCMOUSELEAVE                 0x02A2
#endif /* WINVER >= 0x0500

#if(_WIN32_WINNT >= 0x0501)
#define WM_WTSSESSION_CHANGE            0x02B1

#define WM_TABLET_FIRST                 0x02c0
#define WM_TABLET_LAST                  0x02df
#endif /* _WIN32_WINNT >= 0x0501

#if(WINVER >= 0x0601)
#define WM_DPICHANGED                   0x02E0
#endif /* WINVER >= 0x0601
#if(WINVER >= 0x0605)
#define WM_DPICHANGED_BEFOREPARENT      0x02E2
#define WM_DPICHANGED_AFTERPARENT       0x02E3
#define WM_GETDPISCALEDSIZE             0x02E4
#endif /* WINVER >= 0x0605

#define WM_CUT                          0x0300
#define WM_COPY                         0x0301
#define WM_PASTE                        0x0302
#define WM_CLEAR                        0x0303
#define WM_UNDO                         0x0304
#define WM_RENDERFORMAT                 0x0305
#define WM_RENDERALLFORMATS             0x0306
#define WM_DESTROYCLIPBOARD             0x0307
#define WM_DRAWCLIPBOARD                0x0308
#define WM_PAINTCLIPBOARD               0x0309
#define WM_VSCROLLCLIPBOARD             0x030A
#define WM_SIZECLIPBOARD                0x030B
#define WM_ASKCBFORMATNAME              0x030C
#define WM_CHANGECBCHAIN                0x030D
#define WM_HSCROLLCLIPBOARD             0x030E
#define WM_QUERYNEWPALETTE              0x030F
#define WM_PALETTEISCHANGING            0x0310
#define WM_PALETTECHANGED               0x0311
#define WM_HOTKEY                       0x0312

#if(WINVER >= 0x0400)
#define WM_PRINT                        0x0317
#define WM_PRINTCLIENT                  0x0318
#endif /* WINVER >= 0x0400

#if(_WIN32_WINNT >= 0x0500)
#define WM_APPCOMMAND                   0x0319
#endif /* _WIN32_WINNT >= 0x0500

#if(_WIN32_WINNT >= 0x0501)
#define WM_THEMECHANGED                 0x031A
#endif /* _WIN32_WINNT >= 0x0501


#if(_WIN32_WINNT >= 0x0501)
#define WM_CLIPBOARDUPDATE              0x031D
#endif /* _WIN32_WINNT >= 0x0501

#if(_WIN32_WINNT >= 0x0600)
#define WM_DWMCOMPOSITIONCHANGED        0x031E
#define WM_DWMNCRENDERINGCHANGED        0x031F
#define WM_DWMCOLORIZATIONCOLORCHANGED  0x0320
#define WM_DWMWINDOWMAXIMIZEDCHANGE     0x0321
#endif /* _WIN32_WINNT >= 0x0600

#if(_WIN32_WINNT >= 0x0601)
#define WM_DWMSENDICONICTHUMBNAIL           0x0323
#define WM_DWMSENDICONICLIVEPREVIEWBITMAP   0x0326
#endif /* _WIN32_WINNT >= 0x0601


#if(WINVER >= 0x0600)
#define WM_GETTITLEBARINFOEX            0x033F
#endif /* WINVER >= 0x0600

#if(WINVER >= 0x0400)
#endif /* WINVER >= 0x0400


#if(WINVER >= 0x0400)
#define WM_HANDHELDFIRST                0x0358
#define WM_HANDHELDLAST                 0x035F

#define WM_AFXFIRST                     0x0360
#define WM_AFXLAST                      0x037F
#endif /* WINVER >= 0x0400

#define WM_PENWINFIRST                  0x0380
#define WM_PENWINLAST                   0x038F


#if(WINVER >= 0x0400)
#define WM_APP                          0x8000
#endif /* WINVER >= 0x0400


/*
 * NOTE: All Message Numbers below 0x0400 are RESERVED.
 *
 * Private Window Messages Start Here:

#define WM_USER                         0x0400

#if(WINVER >= 0x0400)

/*  wParam for WM_SIZING message
#define WMSZ_LEFT           1
#define WMSZ_RIGHT          2
#define WMSZ_TOP            3
#define WMSZ_TOPLEFT        4
#define WMSZ_TOPRIGHT       5
#define WMSZ_BOTTOM         6
#define WMSZ_BOTTOMLEFT     7
#define WMSZ_BOTTOMRIGHT    8
#endif /* WINVER >= 0x0400
