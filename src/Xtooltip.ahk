

/**
 */
class Xtooltip extends Xtooltip.Base {
    static __New() {
        this.DeleteProp('__New')
        ; Store the tooltip system class name as a buffer
        className := 'tooltips_class32'
        this.ClassName := Buffer(StrPut(className, XTT_DEFAULT_ENCODING))
        StrPut(className, this.ClassName, XTT_DEFAULT_ENCODING)
        this.ThemeCollection := this.ThemeGroupCollection := this.XttCollection := ''
        proto := this.Prototype
        Proto.DefineProp('__Call', { Call: XttSetThreadDpiAwareness__Call })
        Proto.ThemeGroupName := Proto.__Theme := Proto.__Name := Proto.Hwnd := Proto.Font := ''
        Proto.TitleSize := 0
    }
    /**
     * Registers each of XttCollection, ThemeCollection, and ThemeGroupCollection. When new
     * {@link Xtooltip}, {@link XttTheme}, and {@link XttThemeGroup} objects are created, they
     * are added to their respective collection. Each collection is available from any instance
     * of {@link Xtooltip}, {@link XttTheme}, or {@link XttThemeGroup} on properties ThemeCollection,
     * ThemeGroupCollection, XttCollection, respectively.
     *
     * {@link Xtooltip} object are added to the collection by name if one is provided, otherwise
     * by hwnd.
     *
     * {@link XttTheme} objects are added to the collection by name if one is provided. If a name
     * is not provided, it is not added to the collection.
     *
     * {@link XttThemeGroup} objects are added to the collection by name.
     *
     * This library does not check for the existence of a name beforehand; if an object has already
     * been added to a collection by a given name, it will be overwritten.
     */
    static RegisterAllCollections() {
        this.RegisterThemeCollection()
        this.RegisterThemeGroupCollection()
        this.RegisterXttCollection()
    }
    /**
     * Registers the ThemeCollection. When new {@link XttTheme} objects are created, they
     * are added to the collection. The collection is available from any instance
     * of {@link Xtooltip}, {@link XttTheme}, or {@link XttThemeGroup} on property ThemeCollection.
     *
     * {@link XttTheme} objects are added to the collection by name if one is provided. If a name
     * is not provided, it is not added to the collection.
     *
     * This library does not check for the existence of a name beforehand; if an object has already
     * been added to a collection by a given name, it will be overwritten.
     */
    static RegisterThemeCollection(ThemeCollection?, CaseSense := false) {
        return this.ThemeCollection := ThemeCollection ?? XttThemeCollection(CaseSense)
    }
    /**
     * Registers the ThemeGroupCollection. When new {@link XttThemeGroup} objects are created, they
     * are added to the collection. The collection is available from any instance
     * of {@link Xtooltip}, {@link XttTheme}, or {@link XttThemeGroup} on property ThemeGroupCollection.
     *
     * {@link XttThemeGroup} objects are added to the collection by name if one is provided.
     *
     * This library does not check for the existence of a name beforehand; if an object has already
     * been added to a collection by a given name, it will be overwritten.
     */
    static RegisterThemeGroupCollection(ThemeGroupCollection?, CaseSense := false) {
        return this.ThemeGroupCollection := ThemeGroupCollection ?? XttThemeGroupCollection(CaseSense)
    }
    /**
     * Registers the XttCollection. When new {@link Xtooltip} objects are created, they
     * are added to the collection. The collection is available from any instance
     * of {@link Xtooltip}, {@link XttTheme}, or {@link XttThemeGroup} on property ThemeGroupCollection.
     *
     * {@link Xtooltip} object are added to the collection by name if one is provided, otherwise
     * by hwnd.
     *
     * This library does not check for the existence of a name beforehand; if an object has already
     * been added to a collection by a given name, it will be overwritten.
     */
    static RegisterXttCollection(XttCollectionObj?, CaseSense := false) {
        return this.XttCollection := XttCollectionObj ?? XttCollection(CaseSense)
    }
    /**
     * Calls {@link Xtooltip.DeregisterThemeCollection}, {@link Xtooltip.DeregisterThemeGroupCollection},
     * and {@link Xtooltip.DeregisterXttCollection}.
     *
     * @param {Boolean} [ClearCollection = false] - If true, calls `Map.Prototype.Clear` before
     * settings the property to an empty string. If false, does not call `Map.Prototype.Clear`.
     */
    static DeregisterAllCollections(ClearCollection := false) {
        this.DeregisterThemeCollection(ClearCollection)
        this.DeregisterThemeGroupCollection(ClearCollection)
        this.DeregisterXttCollection(ClearCollection)
    }
    /**
     * @param {Boolean} [ClearCollection = false] - If true, calls `Map.Prototype.Clear` before
     * settings the property to an empty string. If false, does not call `Map.Prototype.Clear`.
     */
    static DeregisterThemeCollection(ClearCollection := false) {
        if ClearCollection {
            this.ThemeCollection.Clear()
        }
        this.ThemeCollection := ''
    }
    /**
     * @param {Boolean} [ClearCollection = false] - If true, calls `Map.Prototype.Clear` before
     * settings the property to an empty string. If false, does not call `Map.Prototype.Clear`.
     */
    static DeregisterThemeGroupCollection(ClearCollection := false) {
        if ClearCollection {
            this.ThemeGroupCollection.Clear()
        }
        this.ThemeGroupCollection := ''
    }
    /**
     * @param {Boolean} [ClearCollection = false] - If true, calls `Map.Prototype.Clear` before
     * settings the property to an empty string. If false, does not call `Map.Prototype.Clear`.
     */
    static DeregisterXttCollection(ClearCollection := false) {
        if ClearCollection {
            this.XttCollection.Clear()
        }
        this.XttCollection := ''
    }
    /**
     * @param {ToolInfo.Params|Object} tiParams - Either a {@link XttToolInfo.Params} object, or an object
     * that will be pass to {@link XttToolInfo.Params}.
     * If `Options.Theme` or `Options.ThemeGroup` are set, all other customization options are ignored.
     * `Options.Theme` supercedes `Options.ThemeGroup`.
     *
     * @param {Integer} [Options.AddExStyle] - Extended window style flags to use in addition to the default `Options.ExStyle`.
     * @param {Integer} [Options.AddStyle] - Window style flags to use in addition to the default `Options.Style`.
     * @param {Boolean} [Options.AlwaysOnTop = true] - If true, the WS_EX_TOPMOST flag is added to the extended style flags.
     * @param {Integer} [Options.BackColor] - The COLORREF representing the background color. Use `XttRgb(r, g, b)` to
     * convert RGB to COLORREF.
     * @param {Float} [Options.Escapement = 0] - The font escapement.
     * @param {Integer} [Options.ExStyle = WS_EX_NOACTIVATE] - Extended window style flags.
     * @param {String} [Options.FaceName] - The font name to use.
     * @param {Float} [Options.FontSize] - The font size in points (`Round(LogfontObj.Height * -72 / LogfontObj.Dpi, 2)`).
     * @param {Integer} [Options.HwndParent = A_ScriptHwnd] - The parent window's handle.
     * @param {Integer} [Options.Icon = 0] - The icon to display next to the title.
     * @param {Integer} [Options.Instance = 0] - The value to pass to `hInstance` parameter of `CreateWindowExW`. Leave this 0.
     * @param {Integer} [Options.Italic = 0] - Set to 1 to italicize the text.
     * @param {Integer} [Options.MarginB] - The bottom margin padding in pixels.
     * @param {Integer} [Options.MarginL] - The left margin padding in pixels.
     * @param {Integer} [Options.MarginR] - The right margin padding in pixels.
     * @param {Integer} [Options.Margins] - A single integer representing the number of pixels to apply to all four margins.
     * Use this instead of setting each individually. If you include one or more of the individual margin options
     * in addition to this one, the individual option will supervede `Options.Margins` for that attribute.
     * @param {Integer} [Options.MarginT] - The top margin padding in pixels.
     * @param {Integer} [Options.MaxWidth] - The value to set as the tooltip window's maximum width. See
     * [Microsoft's documentation](https://learn.microsoft.com/en-us/windows/win32/controls/ttm-setmaxtipwidth)
     * about the maximum width.
     * @param {Integer} [Options.Menu = 0] - The value to pass to the `hMenu` parameter of `CreateWindowExW`.
     * Leave this 0.
     * @param {String} [Options.Name] - A name to associate with the `Xtooltip` object. See [Collections](#collections).
     * @param {Integer} [Options.Param = 0] - The value to pass to the `lParam` parameter of `CreateWindowExW`.
     * Leave this 0.
     * @param {Integer} [Options.Quality = 5] - The font quality.
     * @param {Integer} [Options.Strikeout = 0] - Set to 1 to strikeout the text.
     * @param {Integer} [Options.Style = WS_BORDER | WS_POPUP | TTS_NOPREFIX] - The window style flags.
     * @param {Integer} [Options.TextColor] - The COLORREF representing the text color. Use `XttRgb(r, g, b)` to
     * convert RGB to COLORREF.
     * @param {XttTheme} [Options.Theme] - The `XttTheme` object to apply to the tooltip. See [Themes](#themes).
     * @param {XttThemeGroup} [Options.ThemeGroup] - The `XttThemeGroup` object to which to add the `Xtooltip` object.
     * See [Theme groups](#theme-groups).
     * @param {String} [Options.Title] - The title to display in the tooltip window.
     * @param {Integer} [Options.Underline = 0] - Set to 1 to underline the text.
     * @param {Integer} [Options.Weight = 400] - The font weight.
     * @param {Integer} [Options.WindowName = 0] - The pointer to a null-terminated string that is
     * passed to `lpWindowName` parameter of `CreateWindowExW`. Leave this 0.
     */
    __New(Options?) {
        if IsSet(Options) {
            if Options.HasOwnProp('__Get') {
                __get := Options.GetOwnPropDesc('__Get')
            }
            Options.DefineProp('__Get', { Call: _Get.Bind(Xtooltip.Options.Default) })
            if Options.AlwaysOnTop {
                exStyle := Options.AddExStyle ? Options.AddExStyle | Options.ExStyle | WS_EX_TOPMOST : Options.ExStyle | WS_EX_TOPMOST
            } else {
                exStyle := Options.AddExStyle ? Options.AddExStyle | Options.ExStyle : Options.ExStyle
            }
            style := Options.AddStyle ? Options.AddStyle | Options.Style : Options.Style
            hwnd := this.Hwnd := DllCall(
                'CreateWindowExW'
              , 'uint', exStyle             ; dwExStyle
              , 'ptr', Xtooltip.ClassName   ; lpClassName
              , 'ptr', Options.WindowName   ; lpWindowName
              , 'uint', style               ; dwStyle
              , 'int', 0                    ; X
              , 'int', 0                    ; Y
              , 'int', 0                    ; nWidth
              , 'int', 0                    ; nHeight
              , 'ptr', Options.HwndParent   ; hWndParent
              , 'ptr', Options.Menu         ; hMenu
              , 'ptr', Options.Instance     ; hInstance
              , 'ptr', Options.Param        ; lpParam
              , 'ptr'
            )
            if hresult := DllCall('UxTheme.dll\SetWindowTheme', 'ptr', hwnd, 'ptr', 0, 'str', '', 'uint') {
                throw OSError('``SetWindowTheme`` failed.', -1, hresult)
            }
            this.__Name := Options.Name
            lf := this.Font := XttLogfont(hwnd)
            if Options.Theme {
                if IsObject(Options.Theme) {
                    Options.Theme.Apply(this)
                } else if this.ThemeCollection {
                    this.ThemeCollection.Get(Options.Theme).Apply(this)
                } else {
                    throw Error('A theme collection has not been registered.')
                }
            } else if Options.ThemeGroup {
                if IsObject(Options.ThemeGroup) {
                    Options.ThemeGroup.XttAdd(this)
                } else if this.ThemeGroupCollection {
                    this.ThemeGroupCollection.Get(Options.ThemeGroup).XttAdd(this)
                } else {
                    throw Error('A theme group collection has not been registered.')
                }
            } else {
                lf.Escapement := Options.Escapement
                if Options.FaceName {
                    lf.FaceName := Options.FaceName
                }
                if Options.FontSize {
                    lf.FontSize := Options.FontSize
                }
                lf.Italic := Options.Italic
                lf.Quality := Options.Quality
                lf.Strikeout := Options.Strikeout
                lf.Underline := Options.Underline
                lf.Weight := Options.Weight
                lf.Apply()
                if Options.BackColor {
                    this.SetBackColor(Options.BackColor)
                }
                if Options.Title {
                    this.SetTitle(Options.Title, Options.Icon)
                } else if Options.Icon {
                    throw ValueError('Tooltips cannot have an icon without a title.')
                }
                if IsNumber(Options.Margins) {
                    rc := XttRect()
                    rc.L := IsNumber(Options.MarginL) ? Options.MarginL : Options.Margins
                    rc.T := IsNumber(Options.MarginT) ? Options.MarginT : Options.Margins
                    rc.R := IsNumber(Options.MarginR) ? Options.MarginR : Options.Margins
                    rc.B := IsNumber(Options.MarginB) ? Options.MarginB : Options.Margins
                    this.SetMargin2(rc)
                } else {
                    rc := XttRect()
                    for char in XttTheme.ListMargin {
                        if Options.Margin%char% {
                            rc.%char% := Options.Margin%char%
                            flag_margin := 1
                        }
                        if IsSet(flag_margin) {
                            this.SetMargin2(rc)
                        }
                    }

                }
                if Options.MaxWidth {
                    this.SetMaxWidth(Options.MaxWidth)
                }
                if Options.TextColor {
                    this.SetTextColor(Options.TextColor)
                }
            }
            if this.XttCollection {
                this.XttCollection.Set(Options.Name || hwnd, this)
            }
            if IsSet(__get) {
                Options.DefineProp('__Get', __get)
            } else {
                Options.DeleteProp('__Get')
            }
            this.Update()
        } else {
            hwnd := this.Hwnd := DllCall(
                'CreateWindowExW'
              , 'uint', 0                       ; dwExStyle
              , 'ptr', Xtooltip.ClassName       ; lpClassName
              , 'ptr', 0                        ; lpWindowName
              , 'uint', 0                       ; dwStyle
              , 'int', 0                        ; X
              , 'int', 0                        ; Y
              , 'int', 0                        ; nWidth
              , 'int', 0                        ; nHeight
              , 'ptr', A_ScriptHwnd             ; hWndParent
              , 'ptr', 0                        ; hMenu
              , 'ptr', 0                        ; hInstance
              , 'ptr', 0                        ; lpParam
            )
            if hresult := DllCall('UxTheme.dll\SetWindowTheme', 'ptr', hwnd, 'ptr', 0, 'str', '', 'uint') {
                throw OSError('``SetWindowTheme`` failed.', -1, hresult)
            }
            lf := this.Font := XttLogfont(hwnd)
            if this.XttCollection {
                this.XttCollection.Set(hwnd, this)
            }
        }
        this.HasTrackingTool := 0
        this.Tools := ToolInfoParamsCollection()
        ; I found this to be necessary to avoid an invalid memory read/write error when using a debugger.
        ; If I used a local scoped variable in the function `Xtooltip.Prototype.GetTitle` to reference
        ; the buffer, even though function would be valid and not present any issues during a normal
        ; call to the function, if the debugger called the function when using the Get accessor for
        ; the property "Title", I would get the error. I presumed this was due to how the buffer
        ; variable was being handled. Reusing a buffer set on an object property fixed the issue.
        this.TtGetTitle := TtGetTitle(this, , false)

        return

        _Get(default, self, name, *) {
            return default.%name%
        }
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-activate TTM_ACTIVATE}.
     * @param {Boolean} [Value = true] - Activation flag. If this parameter is TRUE, the tooltip
     * control is activated. If it is FALSE, the tooltip control is deactivated.
     */
    Activate(Value := true) {
        this.__Active := Value
        return SendMessage(TTM_ACTIVATE, Value, 0, this.Hwnd)
    }
    /**
     * @description - Adds a {@link XttToolInfo.Params} object to the collection set on property
     * {@link Xtooltip#Tools}.
     *
     * Sends the {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-addtool TTM_ADDTOOLW}
     * message to the tooltip.
     *
     * Only one tool with TTF_TRACK can be used with a tooltip. If `tiParams` has the TTF_TRACK flag
     * and property {@link Xtooltip#HasTrackingTool} != 0, an error is thrown.
     *
     * @param {String} Key - The "key" to associate with the {@link XttToolInfo.Params} object.
     *
     * @param {ToolInfo.Params|Object} tiParams - Either a {@link XttToolInfo.Params} object, or an object
     * with property : value pairs specifying the values of the members of the TTTOOLINFO structure
     * to which the object will be associated. See {@link ToolInfo.Params.Prototype.__New}
     * for more information. If `tiParams` is not a {@link XttToolInfo.Params} object, it will be passed to
     * {@link ToolInfo.Params.Prototype.__New}.
     *
     * @param {String|Buffer} Text - The string that the tooltip will display, or a buffer containing
     * the string.
     *
     * @param {Boolean} [Activate = true] - If true, TTM_ACTIVATE is sent.
     *
     * @throws {Error} - "Only one tracking tool can be added to an Xtooltip at a time."
     */
    AddTool(Key, tiParams, Text, Activate := true) {
        if not tiParams is XttToolInfo.Params {
            tiParams.StrLen := StrLen(Text)
            tiParams := XttToolInfo.Params(this.Hwnd, tiParams)
        }
        if HasProp(tiParams, 'uFlags') && tiParams.uFlags & TTF_TRACK {
            if this.HasTrackingTool {
                XttErrors.ThrowTrackingError()
            } else {
                this.HasTrackingTool := 1
            }
        }
        this.Tools.Set(Key, tiParams)
        ti := tiParams()
        ti.lpszText := Text
        SendMessage(TTM_ADDTOOLW, 0, ti.Ptr, this.Hwnd)
        if Activate {
            SendMessage(TTM_ACTIVATE, true, 0, this.hwnd)
        }
    }
    /**
     * @description - Creates a {@link XttToolInfo.Params} object with the needed values to associate
     * a tooltip with a `Gui.Control` object. Whenever the user's mouse cursor hovers over the
     * control, the tooltip will display after a short delay. When the cursor leaves the control's
     * area, the tooltip will hide after a short delay.
     * @param {String} Key - The "key" to associate with the {@link XttToolInfo.Params} object.
     * @param {String|Buffer} Text - The string that the tooltip will display, or a buffer containing
     * the string.
     * @param {Gui.Control} Ctrl - The `Gui.Control` object.
     * @returns {ToolInfo}
     */
    AddControl(Key, Text, Ctrl) {
        return this.__AddTool(
            Key
          , {
                HwndXtt: this.Hwnd
              , hwnd: Ctrl.Gui.Hwnd
              , uId: Ctrl.Hwnd
              , uFlags: TTF_IDISHWND | TTF_SUBCLASS
              , StrLen: StrLen(Text)
            }
          , Text
        )
    }
    /**
     * @description - Creates a {@link XttToolInfo.Params} object with the needed values to associate
     * a tooltip with a `Gui.Control`'s client area. Whenever the user's mouse cursor enters into
     * the area, the tooltip will display after a short delay. When the cursor leaves the area, the
     * tooltip will hide after a short delay.
     * @param {String} Key - The "key" to associate with the {@link XttToolInfo.Params} object.
     * @param {String|Buffer} Text - The string that the tooltip will display, or a buffer containing
     * the string.
     * @param {Gui.Control} Ctrl - The `Gui.Control` object.
     * @param {Integer} [uId] - The value to assign to the "uId" member of TTTOOLINFO. If unset,
     * {@link XttToolInfo.GetUid} will assign the value.
     * @returns {ToolInfo}
     */
    AddControlRect(Key, Text, Ctrl, uId?) {
        rc := XttRect.Client(Ctrl.Hwnd)
        return this.__AddTool(
            Key
          , {
                HwndXtt: this.Hwnd
              , hwnd: Ctrl.Hwnd
              , uId: uId ?? XttToolInfo.GetUid()
              , uFlags: TTF_SUBCLASS
              , L: rc.L
              , T: rc.T
              , R: rc.R
              , B: rc.B
              , StrLen: StrLen(Text)
            }
          , Text
        )
    }
    /**
     * @description - Creates a {@link XttToolInfo.Params} object with the needed values to associate
     * a tooltip with a rectangular area within a window's client area. Whenever the user's mouse
     * cursor enters into the area, the tooltip will display after a short delay. When the cursor
     * leaves the area, the tooltip will hide after a short delay.
     * @param {String} Key - The "key" to associate with the {@link XttToolInfo.Params} object.
     * @param {String|Buffer} Text - The string that the tooltip will display, or a buffer containing
     * the string.
     * @param {Integer} hwnd - The handle to the window containing the rectangle.
     * @param {Integer} [L] - The left client coordinate position.
     * @param {Integer} [T] - The top client coordinate position.
     * @param {Integer} [R] - The right client coordinate position.
     * @param {Integer} [B] - The bottom client coordinate position.
     * @param {Integer} [uId] - The value to assign to the "uId" member of TTTOOLINFO. If unset,
     * {@link XttToolInfo.GetUid} will assign the value.
     * @returns {ToolInfo.Params}
     */
    AddRect(Key, Text, hwnd, L?, T?, R?, B?, uId?) {
        rc := XttRect.Client(Hwnd)
        return this.__AddTool(
            Key
          , {
                HwndXtt: this.Hwnd
              , hwnd: Hwnd
              , uId: uId ?? XttToolInfo.GetUid()
              , uFlags: TTF_SUBCLASS
              , L: L ?? rc.L
              , T: T ?? rc.T
              , R: R ?? rc.R
              , B: B ?? rc.B
              , StrLen: StrLen(Text)
            }
          , Text
        )
    }
    /**
     * @description - Creates a {@link XttToolInfo.Params} object with the needed values to associate
     * a tooltip with a rectangular area within a window's client area. Whenever the user's mouse
     * cursor enters into the area, the tooltip will display after a short delay. When the cursor
     * leaves the area, the tooltip will hide after a short delay.
     * @param {String} Key - The "key" to associate with the {@link XttToolInfo.Params} object.
     * @param {String|Buffer} Text - The string that the tooltip will display, or a buffer containing
     * the string.
     * @param {Integer} Hwnd - The handle to the window containing the rectangle.
     * @param {XttRect|Buffer} RectObj - The rect object with the coordinates to use.
     * @param {Integer} [uId] - The value to assign to the "uId" member of TTTOOLINFO. If unset,
     * {@link XttToolInfo.GetUid} will assign the value.
     * @returns {ToolInfo.Params}
     */
    AddRect2(Key, Text, Hwnd, RectObj, uId?) {
        if not RectObj is XttRect {
            ObjSetBase(RectObj, XttRect.Prototype)
        }
        return this.__AddTool(
            Key
          , {
                HwndXtt: this.Hwnd
              , hwnd: Hwnd
              , uId: uId ?? XttToolInfo.GetUid()
              , uFlags: TTF_SUBCLASS
              , L: RectObj.L
              , T: RectObj.T
              , R: RectObj.R
              , B: RectObj.B
              , StrLen: StrLen(Text)
            }
          , Text
        )
    }
    /**
     * @description - Creates a {@link XttToolInfo.Params} with the needed values to create a tracking tooltip
     * (a tooltip which your code has full control over its visibility and position).
     *
     * Note that only one tracking tool can be added to a single Xtooltip.
     *
     * @param {String} Key - The "key" to associate with the {@link XttToolInfo.Params} object.
     * @param {String|Buffer} Text - The string that the tooltip will display or a buffer
     * containing the string.
     * @param {Integer} [hwnd] - If set, the handle to the tooltip's parent window. If
     * unset, `A_ScriptHwnd` is used.
     * @param {Integer} [uId] - The value to assign to the "uId" member of TTTOOLINFO. If unset,
     * {@link XttToolInfo.GetUid} will assign the value.
     * @param {Boolean} [Activate = false] - If true, the tool is shown immediately by the mouse
     * cursor.
     * @param {Integer} [X] - If `Activate` is true, optionally specify the X and Y coordinates to
     * display the tooltip. If `Activate` is false, `X` and `Y` are ignored. If `Activate` is true
     * and `X` and/or `Y` are unset, the tooltip is shown near the mouse cursor.
     * @param {Integer} [Y] - If `Activate` is true, optionally specify the X and Y coordinates to
     * display the tooltip. If `Activate` is false, `X` and `Y` are ignored. If `Activate` is true
     * and `X` and/or `Y` are unset, the tooltip is shown near the mouse cursor.
     * @returns {ToolInfo}
     */
    AddTracking(Key, Text, hwnd?, uId?, Activate := false, X?, Y?) {
        if this.HasTrackingTool {
            XttErrors.ThrowTrackingError()
        }
        ti := this.__AddTool(
            Key
          , {
                HwndXtt: this.Hwnd
              , hwnd: hwnd ?? A_ScriptHwnd
              , uId: uId ?? XttToolInfo.GetUid()
              , uFlags: TTF_ABSOLUTE | TTF_TRACK
              , StrLen: StrLen(Text)
            }
          , Text
        )
        this.HasTrackingTool := 1
        if Activate {
            if IsSet(X) && IsSet(Y) {
                this.TrackActivate(Key, true, X, Y)
            } else {
                this.TrackActivateByMouse(Key)
            }
        }
        return ti
    }
    /**
     * @description - Creates a {@link XttToolInfo.Params} object with the needed values to associate
     * a tooltip with a window. Whenever the user's mouse cursor hovers over the window's client
     * area, the tooltip will display after a short delay. When the cursor leaves the window's
     * client area, the tooltip will hide after a short delay.
     * @param {String} Key - The "key" to associate with the {@link XttToolInfo.Params} object.
     * @param {String|Buffer} Text - The string that the tooltip will display or a buffer
     * containing the string.
     * @param {Integer} hwnd - The handle to the window to associate with the tool.
     * @returns {ToolInfo.Params}
     */
    AddWindow(Key, Text, hwnd) {
        return this.__AddTool(
            Key
          , {
                HwndXtt: this.Hwnd
              , Hwnd: DllCall('GetAncestor', 'ptr', hwnd, 'uint', 1, 'ptr') || hwnd
              , uId: hwnd
              , uFlags: TTF_IDISHWND | TTF_SUBCLASS
              , StrLen: StrLen(Text)
            }
          , Text
        )
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-adjustrect TTM_ADJUSTRECT}.
     * @param {XttRect|Buffer} RectObj - The {@link XttRect} or similar buffer.
     * @param {Boolean} [Flag = true] - The value to pass to wParam. If TRUE, `RectObj` is used to
     * specify a text-display rectangle and it receives the corresponding window rectangle. If FALSE,
     * `RectObj` is used to specify a window rectangle and it receives the corresponding text
     * display rectangle.
     * @returns {XttRect|Buffer} - The adjusted {@link XttRect} or buffer.
     */
    AdjustRect(RectObj, Flag := true) {
        SendMessage(TTM_ADJUSTRECT, Flag, RectObj.Ptr, this.Hwnd)
        return RectObj
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-deltool TTM_DELTOOL}.
     * @param {String} Key - The key associated with the tool.
     */
    DelTool(Key) {
        tiParams := this.Tools.Get(Key)
        this.Tools.Delete(Key)
        ti := tiParams()
        SendMessage(TTM_DELTOOLW, 0, ti.Ptr, this.Hwnd)
    }
    /**
     * Destroys the tools then the tooltip.
     */
    Dispose() {
        hwnd := this.Hwnd
        if _name := this.__Name || hwnd {
            if themeGroup := this.ThemeGroup {
                if themeGroup.Has(_name) {
                    themeGroup.Delete(_name)
                }
            }
            if this.XttCollection && this.XttCollection.Has(_name) {
                this.XttCollection.Delete(_name)
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
                ti := XttToolInfo(hwnd, tiParams.hwnd, tiParams.uId)
                SendMessage(TTM_DELTOOLW, 0, ti.Ptr, hwnd)
            }
            if this.GetToolCount() {
                list := []
                loop this.GetToolCount() {
                    list.Push(XttToolInfo(hwnd, , , 160))
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
    /**
     * Find a {@link XttToolInfo.Params} object using the hwnd and id.
     *
     * @param {Integer} hwnd - The hwnd passed to {@link XttToolInfo.Prototype.__New~hwnd}.
     * The following are descriptions of what is passed to `toolHwnd` from the indicated methods:
     * - {@link Xtooltip.Prototype.AddControl} - The control's parent gui's hwnd.
     * - {@link Xtooltip.Prototype.AddControlRect} - The control's hwnd.
     * - {@link Xtooltip.Prototype.AddRect} - The value passed to `ParentHwnd`.
     * - {@link Xtooltip.Prototype.AddTracking} - The value passed to `ParentHwnd` or `A_ScriptHwnd`
     *   if unset.
     * - {@link Xtooltip.Prototype.AddWindow} - The value passed to `ToolHwnd` or `ToolHwnd` was
     *   a child window, the return value from `DllCall('GetAncestor', 'ptr', ToolHwnd, 'uint', 1, 'ptr')`.
     *
     * @param {Integer} uId - The id passed to {@link XttToolInfo.Prototype.__New~uId}.
     * The following are descriptions of what is passed to `uId` from the indicated methods:
     * - {@link Xtooltip.Prototype.AddControl} - The control's hwnd.
     * - {@link Xtooltip.Prototype.AddControlRect} - The value passed to `uId`, or if unset,
     *   the return value from {@link Xtooltip.GetUid}.
     * - {@link Xtooltip.Prototype.AddRect} - The value passed to `uId`, or if unset,
     *   the return value from {@link Xtooltip.GetUid}.
     * - {@link Xtooltip.Prototype.AddTracking} - The value passed to `uId`, or if unset,
     *   the return value from {@link Xtooltip.GetUid}.
     * - {@link Xtooltip.Prototype.AddWindow} - The value passed to `hwnd`.
     */
    FindToolInfoParams(hwnd, uId) {
        for key, tiParams in this.Tools {
            if HasProp(tiParams, 'hwnd') && tiParams.hwnd = hwnd && HasProp(tiParams, 'uId') && tiParams.uId = uId {
                return tiParams
            }
        }
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-gettipbkcolor TTM_GETTIPBKCOLOR}.
     */
    GetBackColor() {
        return SendMessage(TTM_GETTIPBKCOLOR, 0, 0, this.Hwnd)
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-getbubblesize TTM_GETBUBBLESIZE}.
     * @param {String} [Key] - The "key" associated with a {@link XttToolInfo.Params} object.
     * @param {VarRef} [OutWidth] - A variable that will receive the width.
     * @param {VarRef} [OutHeight] - A variable that will receive the height.
     * @returns {Integer} - Returns the width of the tooltip in the low word and the height in the
     * high word if successful. Otherwise, it returns FALSE.
     */
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
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-getcurrenttool TTM_GETCURRENTTOOL}.
     * @param {VarRef} [OutToolInfo] - A variable that will receive the {@link XttToolInfo} object.
     * @returns {Integer} - Returns nonzero if successful, or zero otherwise.
     */
    GetCurrentTool(&OutToolInfo?) {
        OutToolInfo := XttToolInfo(this.Hwnd, , , 160)
        return SendMessage(TTM_GETCURRENTTOOLW, 0, OutToolInfo.Ptr, this.Hwnd)
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-getdelaytime TTM_GETDELAYTIME}.
     * @param {Integer} [Flag = 0] - One of the following:
     * - TTDT_AUTOMATIC - 0
     * - TTDT_RESHOW - 1
     * - TTDT_AUTOPOP - 2
     * - TTDT_INITIAL - 3
     * @returns {Integer} - The duration in milliseconds.
     */
    GetDelayTime(Flag := 0) {
        return SendMessage(TTM_GETDELAYTIME, Flag, 0, this.Hwnd)
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-getmargin TTM_GETMARGIN}.
     * @returns {XttRect}
     */
    GetMargin() {
        rc := XttRect()
        SendMessage(TTM_GETMARGIN, 0, rc.Ptr, this.Hwnd)
        return rc
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-getmaxtipwidth TTM_GETMAXTIPWIDTH}.
     * @returns {Integer}
     */
    GetMaxWidth() {
        return SendMessage(TTM_GETMAXTIPWIDTH, 0, 0, this.Hwnd)
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-gettext TTM_GETTEXT}.
     * @param {String} [Key] - The "key" associated with a {@link XttToolInfo.Params} object.
     * @param {Integer} [MaxChars] - The maximum characters to acquire from the tooltip. If unset,
     * the {@link XttToolInfo.Params} object must have a property {@link XttToolInfo.Params#StrLen}
     * @returns {String}
     * @throws {Error} - "Either `MaxChars` must be set, or the `XttToolInfo.Params` object must have a property "StrLen"."
     * @throws {Error} - "Unable to retrieve the ``XttToolInfo.Params`` object associated with the current tool."
     * @throws {Error} - "The tooltip does not have an active tool."
     */
    GetText(Key?, MaxChars?) {
        if IsSet(Key) {
            tiParams := this.Tools.Get(Key)
            ti := tiParams()
            if !IsSet(MaxChars) {
                if HasProp(tiParams, 'StrLen') {
                    MaxChars := tiParams.StrLen
                } else {
                    throw Error('Either ``MaxChars`` must be set, or the ``XttToolInfo.Params`` object must have a property "StrLen".')
                }
            }
        } else if this.GetToolCount() {
            this.GetCurrentTool(&ti)
            if !IsSet(MaxChars) {
                if tiParams := this.FindToolInfoParams(ti.hwnd, ti.uId) {
                    if HasProp(tiParams, 'StrLen') {
                        MaxChars := tiParams.StrLen
                    } else {
                        throw Error('Either ``MaxChars`` must be set, or the ``XttToolInfo.Params`` object must have a property "StrLen".')
                    }
                } else {
                    throw Error('Unable to retrieve the ``XttToolInfo.Params`` object associated with the current tool.')
                }
            }
        } else {
            throw Error('The tooltip does not have an active tool.')
        }
        ti.SetTextBuffer(, MaxChars * 2 + 2)
        SendMessage(TTM_GETTEXTW, MaxChars + 1, ti.Ptr, this.Hwnd)
        return ti.lpszText
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-gettiptextcolor TTM_GETTIPTEXTCOLOR}.
     * @returns {Integer}
     */
    GetTextColor() {
        return SendMessage(TTM_GETTIPTEXTCOLOR, 0, 0, this.Hwnd)
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-gettitle TTM_GETTITLE}.
     * @param {Integer} [MaxChars] - The maximum characters to acquire from the tooltip.
     * @param {VarRef} [OutIcon] - A variable that will receive the tooltip's icon.
     * @returns {String}
     */
    GetTitle(MaxChars?, &OutIcon?) {
        _ttGetTitle := TtGetTitle(this, MaxChars ?? this.TitleSize)
        OutIcon := _ttGetTitle.uTitleBitmap
        return _ttGetTitle.Title
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-gettoolcount TTM_GETTOOLCOUNT}.
     * @returns {Integer}
     */
    GetToolCount() {
        return SendMessage(TTM_GETTOOLCOUNT, 0, 0, this.Hwnd)
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-gettoolinfo TTM_GETTOOLINFO}.
     * @returns {XttToolInfo}
     */
    GetToolInfo(toolHwnd, toolId) {
        ti := XttToolInfo(this.Hwnd, toolHwnd, toolId)
        SendMessage(TTM_GETTOOLINFOW, 0, ti.Ptr, this.Hwnd)
        return ti
    }
    /**
     * Gets a {@link XttToolInfo} object using the {@link XttToolInfo.Params} associated with `Key`, or
     * if `Key` is unset, the current tool.
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-gettoolinfo TTM_GETTOOLINFO}.
     *
     * @param {String} [Key] - The "key" associated with a {@link XttToolInfo.Params} object. If unset,
     * gets information about the current tool.
     *
     * @returns {XttToolInfo}
     */
    GetToolInfoObj(Key?) {
        if IsSet(Key) {
            tiParams := this.Tools.Get(Key)
            ti := XttToolInfo(this.Hwnd, tiParams.Hwnd, tiParams.Id)
            SendMessage(TTM_GETTOOLINFOW, 0, ti.Ptr, this.Hwnd)
            return ti
        } else if this.GetToolCount() {
            this.GetCurrentTool(&ti)
            return ti
        } else {
            throw Error('The tooltip does not have an active tool.', -1)
        }
    }
    /**
     * Returns nonzero if the tool has the TTF_TRACK flag.
     *
     * @param {String} [Key] - The "key" associated with a {@link XttToolInfo.Params} object. If unset,
     * gets information about the current tool.
     *
     * @returns {Integer} - Nonzero if the tool has the TTF_TRACK flag, else zero.
     */
    IsTracking(Key?) {
        return this.GetToolInfoObj(Key ?? unset).Flags & TTF_TRACK
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-newtoolrect TTM_NEWTOOLRECT}.
     *
     * @param {String} [Key] - The "key" associated with a {@link XttToolInfo.Params} object.
     * @param {XttRect|Buffer} RectObj - The {@link XttRect} or similar buffer.
     */
    NewToolRect(Key, RectObj) {
        tiParams := this.Tools.Get(Key)
        tiParams.L := RectObj.L
        tiParams.T := RectObj.T
        tiParams.R := RectObj.R
        tiParams.B := RectObj.B
        ti := tiParams()
        SendMessage(TTM_NEWTOOLRECTW, 0, ti.Ptr, this.Hwnd)
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-pop TTM_POP}.
     */
    Pop() {
        SendMessage(TTM_POP, 0, 0, this.Hwnd)
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-popup TTM_POPUP}.
     */
    Popup() {
        SendMessage(TTM_POPUP, 0, 0, this.Hwnd)
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-settipbkcolor TTM_SETTIPBKCOLOR}.
     * Also see {@link Xtooltip.Prototype.SetBackColorRGB}.
     * @param {Integer} Color - The COLORREF value.
     */
    SetBackColor(Color) {
        SendMessage(TTM_SETTIPBKCOLOR, Color, 0, this.Hwnd)
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-settipbkcolor TTM_SETTIPBKCOLOR}.
     * Also see {@link Xtooltip.Prototype.SetBackColor}.
     * @param {Integer} R - The 0-255 red value.
     * @param {Integer} G - The 0-255 green value.
     * @param {Integer} B - The 0-255 blue value.
     */
    SetBackColorRGB(R, G, B) {
        SendMessage(TTM_SETTIPBKCOLOR, XttRGB(R, G, B), 0, this.Hwnd)
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-setdelaytime TTM_SETDELAYTIME}.
     * @param {Integer} Delay - The new delay in milliseconds.
     * @param {Integer} [Flag = 0] - One of the following:
     * - 0 : TTDT_AUTOMATIC
     * - 1 : TTDT_RESHOW
     * - 2 : TTDT_AUTOPOP
     * - 3 : TTDT_INITIAL
     */
    SetDelayTime(Delay, Flag := 0) {
        SendMessage(TTM_SETDELAYTIME, Flag, Delay & 0xFFFF, this.Hwnd)
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-setmargin TTM_SETMARGIN}.
     *
     * This only updates the margins that are set. Unset margins remain their current value.
     *
     * @param {Integer} [Left] - The left margin.
     * @param {Integer} [Top] - The top margin.
     * @param {Integer} [Right] - The right margin.
     * @param {Integer} [Bottom] - The bottom margin.
     */
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
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-setmargin TTM_SETMARGIN}.
     * @param {XttRect|Buffer} RectObj - The {@link XttRect} or similar buffer.
     */
    SetMargin2(RectObj) {
        SendMessage(TTM_SETMARGIN, 0, RectObj.Ptr, this.Hwnd)
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-setmaxtipwidth TTM_SETMAXTIPWIDTH}.
     * @param {Integer} Width - The maximum width for the tooltip's display area. If the text extends
     * beyond this width, the lines will wrap. Set to -1 to allow any width.
     * @returns {Integer} - The previous maximum width.
     */
    SetMaxWidth(Width) {
        return SendMessage(TTM_SETMAXTIPWIDTH, 0, Width, this.Hwnd)
    }
    /**
     * Assigns a new name to the object. If the object has already been added to the XttCollection,
     * deletes that first then adds it again using the new name. This does the same thing if the
     * object has been added to a theme group.
     * @param {String} Name - The name.
     */
    SetName(Name) {
        _name := this.__Name || this.Hwnd
        if this.XttCollection {
            if this.XttCollection.Has(_name) {
                this.XttCollection.Delete(_name)
            }
            this.XttCollection.Set(Name, this)
        }
        if themeGroup := this.ThemeGroup {
            if themeGroup.Has(_name) {
                themeGroup.Delete(_name)
            }
            themeGroup.Set(Name, this)
        }
        this.__Name := Name
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-settiptextcolor TTM_SETTIPTEXTCOLOR}.
     * Also see {@link Xtooltip.Prototype.SetTextColorRGB}.
     * @param {Integer} Color - The COLORREF value.
     */
    SetTextColor(Color) {
        SendMessage(TTM_SETTIPTEXTCOLOR, Color, 0, this.Hwnd)
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-settiptextcolor TTM_SETTIPTEXTCOLOR}.
     * Also see {@link Xtooltip.Prototype.SetTextColor}.
     * @param {Integer} R - The 0-255 red value.
     * @param {Integer} G - The 0-255 green value.
     * @param {Integer} B - The 0-255 blue value.
     */
    SetTextColorRGB(R, G, B) {
        SendMessage(TTM_SETTIPTEXTCOLOR, XttRGB(R, G, B), 0, this.Hwnd)
    }
    /**
     * Sets a theme.
     * @param {XttTheme|String} - The theme or the name of the theme in the collection.
     */
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
    }
    /**
     * Adds the {@link Xtooltip} to a theme group.
     * @param {XttThemeGroup|String} - The theme group or the name of the theme group in the collection.
     * @param {Boolean} [ApplyTheme = true] - If true, applies the group's active theme to the
     * {@link Xtooltip} object.
     */
    SetThemeGroup(ThemeGroup, ApplyTheme := true) {
        if !IsObject(ThemeGroup) {
            if collection := this.ThemeGroupCollection {
                ThemeGroup := collection.Get(ThemeGroup)
            } else {
                ; If you get this error, call the static method `Xtooltip.RegisterThemeGroupCollection`.
                throw Error('You must register a theme group collection before being able to reference a group by name.', -1)
            }
        }
        this.ThemeGroupName := ThemeGroup.Name
        if ApplyTheme && ThemeGroup.__ActiveTheme {
            ThemeGroup.__ActiveTheme.Apply(this)
        }
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-settitle TTM_SETTITLE}.
     * @param {Integer} [Icon = 0] - Either a handle to an icon (HICON), or one of the following:
     * - 0 : TTI_NONE
     * - 1 : TTI_INFO
     * - 2 : TTI_WARNING
     * - 3 : TTI_ERROR
     * - 4 : TTI_INFO_LARGE
     * - 5 : TTI_WARNING_LARGE
     * - 6 : TTI_ERROR_LARGE
     *
     * @param {String} [Title] - The title string. This cannot exceed 99 characters.
     */
    SetTitle(Title, Icon := 0) {
        bytes := StrPut(Title, XTT_DEFAULT_ENCODING)
        if bytes > 198 {
            throw Error('The title length exceeds the maximum (198 bytes).', , Title)
        }
        buf := Buffer(bytes)
        StrPut(Title, buf, XTT_DEFAULT_ENCODING)
        this.TitleSize := StrLen(Title) + 1
        if !SendMessage(TTM_SETTITLEW, Number(Icon), buf.Ptr, this.Hwnd) {
            throw OSError()
        }
    }
    /**
     * @description - Sends TTM_SETTOOLINFO to update a tool with new values. Before sending the
     * message, {@link Xtooltip.Prototype.SetToolInfo} performs some pre-processing and validation to
     * ensure there are no issues. Specifically:
     *
     * - If you do not set `Key` with a valid key, {@link Xtooltip.Prototype.SetToolInfo} iterates the
     * objects in the ToolInfoParams collection to find a matching one. If a matching {@link XttToolInfo.Params}
     * object is not found, an error is thrown.
     * - If TTF_TRACK is included in `NewToolInfo.uFlags`, and if the current {@link XttToolInfo.Params} object
     * associated with `NewToolInfo` does not have the flag TTF_TRACK, and if the property
     * {@link Xtooltip#HasTrackingTool} is 1, an error is thrown because only one tracking tool can be active
     * at a time on an Xtooltip.
     * - If TTF_TRACK is included in `NewToolInfo.uFlags` and the value of {@link Xtooltip#HasTrackingTool} is 0,
     * the value is set to 1.
     * - If `NewToolInfo.lpszText` returns text, and if the length of the text is greater than 79 characters,
     * {@link Xtooltip.Prototype.SetToolInfo} will proceed with a warning sent to `OutputDebug` explaining
     * that the maximum characters is 79. If you encounter this, you should use method
     * {@link Xtooltip.Prototype.UpdateTipText} instead.
     * - If `NewToolInfo.lpszText` returns text, the value of the property "StrLen" is updated on the
     * current {@link XttToolInfo.Params} object with the correct number of characters.
     *
     * If you update the tooltip's text, it must be 79 characters or less. If you need to update
     * the text with a longer string, use TTM_UPDATETIPTEXT instead.
     *
     * @param {ToolInfo} NewToolInfo - The updated {@link XttToolInfo} object.
     *
     * @param {String} [Key] - The "key" associated with the {@link XttToolInfo.Params} object associated with
     * the tool that is being updated. If you need to add a new tool, use {@link Xtooltip.Prototype.AddTool}
     * or any of the other "Add" methods.
     *
     * @throws {Error} - Unable to find the {@link XttToolInfo.Params} object associated with the new {@link XttToolInfo}
     * object. Use {@link Xtooltip.Prototype.AddTool} instead.
     */
    SetToolInfo(NewToolInfo, Key?) {
        if IsSet(Key) {
            currentTiParams := this.Tools.Get(Key)
        } else {
            ; find the existing XttToolInfo.Params object associated with the new `ToolInfo` object.
            currentTiParams := this.FindToolInfoParams(NewToolInfo.Hwnd, NewToolInfo.uId)
            if !currentTiParams {
                throw Error('Unable to find the ``XttToolInfo.Params`` object associated with the new'
                ' ``ToolInfo`` object. Use ``Xtooltip.Prototype.AddTool`` instead.', -1)
            }
        }
        if NewToolInfo.uFlags & TTF_TRACK {
            if this.HasTrackingTool {
                ; Only one tracking tool can be active on an Xtooltip at a time
                if !HasProp(currentTiParams, 'uFlags') || !(currentTiParams.uFlags & TTF_TRACK) {
                    XttErrors.ThrowTrackingError()
                }
            } else {
                this.HasTrackingTool := 1
            }
        }
        if NewToolInfo.lpszText {
            currentTiParams.StrLen := StrLen(NewToolInfo.lpszText)
            if currentTiParams.StrLen > 79 {
                OutputDebug('A maximum of 79 characters can be added to a tool using TTM_SETTOOLINFO. To add a longer string, use TTM_UPDATETIPTEXT.`n')
            }
        }
        for prop in [ 'uFlags', 'hInst', 'lParam' ] {
            if NewToolInfo.%prop% {
                currentTiParams.%prop% := NewToolInfo.%prop%
            }
        }
        dimensions := [ 'L', 'T', 'R', 'B' ]
        ; If at least one property has a nonzero value, then we know the RECT member was used.
        for prop in dimensions {
            if NewToolInfo.%prop% {
                for prop in dimensions {
                    currentTiParams.%prop% := NewToolInfo.%prop%
                }
                break
            }
        }
        SendMessage(TTM_SETTOOLINFOW, 0, NewToolInfo.Ptr, this.Hwnd)
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-setwindowtheme TTM_SETWINDOWTHEME}.
     * @param {String} TooltipVisualStyleName - The tooltip visual style to set.
     */
    SetWindowTheme(TooltipVisualStyleName) {
        buf := Buffer(StrPut(TooltipVisualStyleName, XTT_DEFAULT_ENCODING))
        StrPut(TooltipVisualStyleName, buf, XTT_DEFAULT_ENCODING)
        SendMessage(TTM_SETWINDOWTHEME, 0, buf.Ptr, this.Hwnd)
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-trackactivate TTM_TRACKACTIVATE}.
     * @param {String} Key - The "key" associated with the {@link XttToolInfo.Params} object.
     * @param {Boolean} Value - true to activate, false to deactivate.
     * @param {Integer} [X] - If `Value` is true, optionally specify the X and Y coordinates to
     * display the tooltip. If `Value` is false, `X` and `Y` are ignored.
     * @param {Integer} [Y] - If `Value` is true, optionally specify the X and Y coordinates to
     * display the tooltip. If `Value` is false, `X` and `Y` are ignored.
     */
    TrackActivate(Key, Value, X?, Y?) {
        ti := this.Tools.Get(Key).Call()
        if Value && IsSet(X) && IsSet(Y) {
            SendMessage(TTM_TRACKPOSITION, 0, (Y << 16) | (X & 0xFFFF), this.Hwnd)
        }
        SendMessage(TTM_TRACKACTIVATE, Value, ti.Ptr, this.Hwnd)
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-trackactivate TTM_TRACKACTIVATE}
     * and {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-trackposition TTM_TRACKPOSITION}
     * to position the tooltip by the mouse.
     * @param {String} Key - The "key" associated with the {@link XttToolInfo.Params} object.
     * @param {Integer} [OffsetX = 0] - A number of pixels to add to the X coordinate.
     * @param {Integer} [OffsetY = 0] - A number of pixels to add to the Y coordinate.
     */
    TrackActivateByMouse(Key, OffsetX := 0, OffsetY := 0) {
        pt := Buffer(8)
        DllCall('GetCursorPos', 'ptr', pt, 'int')
        SendMessage(TTM_TRACKPOSITION, 0, ((NumGet(pt, 4, 'int') + OffsetY) << 16) | ((NumGet(pt, 0, 'int') + OffsetX) & 0xFFFF), this.Hwnd)
        ti := this.Tools.Get(Key).Call()
        SendMessage(TTM_TRACKACTIVATE, true, ti.Ptr, this.Hwnd)
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-trackposition TTM_TRACKPOSITION}.
     * @param {Integer} X - The X screen coordinate position.
     * @param {Integer} Y - The Y screen coordinate position.
     */
    TrackPosition(X, Y) {
        SendMessage(TTM_TRACKPOSITION, 0, (Y << 16) | (X & 0xFFFF), this.Hwnd)
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-trackposition TTM_TRACKPOSITION}.
     * @param {Integer} [OffsetX = 0] - A number of pixels to add to the X coordinate.
     * @param {Integer} [OffsetY = 0] - A number of pixels to add to the Y coordinate.
     */
    TrackPositionByMouse(OffsetX := 0, OffsetY := 0) {
        pt := Buffer(8)
        DllCall('GetCursorPos', 'ptr', pt, 'int')
        SendMessage(TTM_TRACKPOSITION, 0, ((NumGet(pt, 4, 'int') + OffsetY) << 16) | ((NumGet(pt, 0, 'int') + OffsetX) & 0xFFFF), this.Hwnd)
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-update TTM_UPDATE}.
     */
    Update() {
        return SendMessage(TTM_UPDATE, 0, 0, this.Hwnd)
    }
    /**
     * Sends {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-updatetiptext TTM_UPDATETIPTEXT}.
     *
     * @param {String} Text - The text to display on the tooltip.
     * @param {String} Key - The "key" associated with the {@link XttToolInfo.Params} object.
     */
    UpdateTipText(Text, Key) {
        tiParams := this.Tools.Get(Key)
        ti := tiParams()
        ti.lpszText := Text
        tiParams.StrLen := StrLen(Text)
        SendMessage(TTM_UPDATETIPTEXTW, 0, ti.Ptr, this.Hwnd)
    }
    __AddTool(Key, tiParams, Text) {
        if IsObject(Text) {
            buf := Text
        } else {
            buf := Buffer(StrPut(Text, XTT_DEFAULT_ENCODING))
            StrPut(Text, buf, XTT_DEFAULT_ENCODING)
        }
        ObjSetBase(tiParams, XttToolInfo.Params.Prototype)
        tiParams.StrLen := StrLen(Text)
        this.Tools.Set(Key, tiParams)
        ti := tiParams()
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
        Set => SendMessage(TTM_SETMAXTIPWIDTH, , Value, , this.Hwnd)
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
        Get {
            if this.ThemeGroupCollection {
                if this.ThemeGroupCollection.Has(this.ThemeGroupName) {
                    return this.ThemeGroupCollection.Get(this.ThemeGroupName)
                }
            } else {
                throw Error('Your code must call the static method ``Xtooltip.RegisterAllCollections``'
                ' or ``Xtooltip.RegisterThemeGroupCollection`` before accessing the "ThemeGroup" property.')
            }
        }
        Set => this.SetThemeGroup(Value)
    }
    Title {
        Get => this.TitleSize ? this.TtGetTitle.Call(this.TitleSize) : ''
        Set => this.SetTitle(Value)
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

    class Options {
        static __New() {
            this.DeleteProp('__New')
            Xtooltip_SetConstants()
            this.Default := {
                AddExStyle: ''
              , AddStyle: ''
              , AlwaysOnTop: true
              , BackColor: ''
              , Escapement: 0
              , ExStyle: WS_EX_NOACTIVATE
              , FaceName: ''
              , FontSize: ''
              , HwndParent: A_ScriptHwnd
              , Icon: 0
              , Instance: 0
              , Italic: 0
              , MarginB: ''
              , MarginL: ''
              , MarginR: ''
              , Margins: ''
              , MarginT: ''
              , MaxWidth: ''
              , Menu: 0
              , Name: ''
              , Param: 0
              , Quality: 5
              , Strikeout: 0
              , Style: WS_BORDER | WS_POPUP | TTS_NOPREFIX
              , TextColor: ''
              , Theme: ''
              , ThemeGroup: ''
              , Title: ''
              , Underline: 0
              , Weight: 400
              , WindowName: 0
            }
        }
        static Call(Options?) {
            if IsSet(Options) {
                o := {}
                d := this.Default
                for prop in d.OwnProps() {
                    o.%prop% := HasProp(Options, prop) ? Options.%prop% : d.%prop%
                }
                return o
            } else {
                return this.Default.Clone()
            }
        }
    }

    class Base {
        ThemeCollection => Xtooltip.ThemeCollection
        ThemeGroupCollection => Xtooltip.ThemeGroupCollection
        XttCollection => Xtooltip.XttCollection
    }
}

class XttTheme extends Xtooltip.Base {
    static __New() {
        this.DeleteProp('__New')
        this.ListFont := [
            'CharSet', 'ClipPrecision', 'Escapement', 'Family'
          , 'Italic', 'FaceName', 'OutPrecision', 'Pitch', 'Height'
          , 'Quality', 'FontSize', 'Strikeout', 'Underline', 'Weight'
        ]
        this.ListGeneral := [ 'BackColor', 'MaxWidth', 'TextColor' ]
        this.ListMargin := [ 'L', 'T', 'R', 'B' ]
        this.ListTitle := [ 'Icon', 'Title' ]
        proto := this.Prototype
        proto.__Name := proto.__Margin := proto.__Font := ''
        proto.Default := this()
        for list in [ this.ListGeneral, this.ListTitle ] {
            for prop in list {
                proto.__%prop% := ''
            }
        }
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
    static RegisterDefault(DefaultOptions) {
        this.Prototype.Default := DefaultOptions
    }
    /**
     * @param {String} [ThemeName] - If set, the name to associate with the theme. The name is used
     * when retrieving the theme from {@link Xtooltip#ThemeCollection},
     * {@link XttTheme#ThemeCollection}, or {@link XttThemeGroup#ThemeCollection}.
     * It is also used when retrieving the theme from a theme group. If unset, the theme cannot be
     * added to any collections until {@link XttTheme.Prototype.SetName} is called.
     *
     * @param {Object} [Options] - An object with options as property : value pairs. The following
     * are the available options. If a theme is not set with an option, when the theme is applied
     * to an {@link Xtooltip} object, that option is no changed; the current value on the object
     * is maintained.
     *  - BackColor
     *  - Font : `Options.Font` can be an {@link XttLogfont} object, or include any of the following
     *    properties on `Options`. If none of the font options are included, the theme will not include
     *    a font object; whenever the theme is applied, the {@link Xtooltip} object's current font
     *    will be maintained.
     *    - Bold
     *    - Escapement
     *    - FaceName
     *    - FontSize
     *    - Italic
     *    - Quality
     *    - Strikeout
     *    - Underline
     *    - Weight
     *  - Icon
     *  - Margin : `Options.Margin` can be an {@link XttRect} object, a Buffer object, or include
     *    any of the following properties on `Options`. If none of the margin options are included,
     *    the theme will not include a margin object; whenever the theme is applied,
     *    the {@link Xtooltip} object's current margins will be maintained.
     *    - MarginL
     *    - MarginT
     *    - MarginR
     *    - MarginB
     *  - MaxWidth
     *  - Name : The theme name (same as the parameter `ThemeName`)
     *  - TextColor
     *  - Title
     */
    __New(ThemeName?, Options?) {
        if IsSet(ThemeName) {
            this.SetName(ThemeName)
        }
        if IsSet(Options) {
            this.SetOptions(Options)
        }
        if this.ThemeCollection && this.__Name {
            this.ThemeCollection.Set(this.__Name, this)
        }
    }
    /**
     * Applies all of the theme options and sets the {@link XttTheme} object to property
     * {@link Xtooltip#Theme}.
     * @param {Xtooltip} Xtt - The {@link Xtooltip} object.
     */
    Apply(Xtt) {
        if this.Font {
            this.ApplyFont(Xtt)
        }
        this.ApplyGeneral(Xtt)
        if this.Margin {
            this.ApplyMargin(Xtt)
        }
        if this.Title || this.Icon {
            this.ApplyTitle(Xtt)
        }
        Xtt.__Theme := this
    }
    /**
     * @param {Xtooltip} Xtt - The {@link Xtooltip} object.
     */
    ApplyFont(Xtt) {
        this.Font.Clone(Xtt.Font, , false)
        Xtt.Font.Apply()
    }
    /**
     * @param {Xtooltip} Xtt - The {@link Xtooltip} object.
     */
    ApplyGeneral(Xtt) {
        for prop in XttTheme.ListGeneral {
            if StrLen(this.__%prop%) {
                Xtt.%prop% := this.%prop%
            }
        }
    }
    /**
     * @param {Xtooltip} Xtt - The {@link Xtooltip} object.
     */
    ApplyMargin(Xtt) {
        Xtt.SetMargin2(this.Margin)
    }
    /**
     * @param {Xtooltip} Xtt - The {@link Xtooltip} object.
     * @param {Boolean} [Font = false] - If true, {@link XttTheme.Prototype.ApplyFont} will be called.
     * @param {Boolean} [General = false] - If true, {@link XttTheme.Prototype.ApplyGeneral} will be called.
     * @param {Boolean} [Margin = false] - If true, {@link XttTheme.Prototype.ApplyMargin} will be called.
     * @param {Boolean} [Title = false] - If true, {@link XttTheme.Prototype.ApplyTitle} will be called.
     */
    ApplySelect(Xtt, Font := false, General := false, Margin := false, Title := false) {
        if Font && this.Font {
            this.ApplyFont(Xtt)
        }
        if General {
            this.ApplyGeneral(Xtt)
        }
        if Margin && this.Margin {
            this.ApplyMargin(Xtt)
        }
        if Title && (this.Title || this.Icon) {
            this.ApplyTitle(Xtt)
        }
    }
    /**
     * @param {Xtooltip} Xtt - The {@link Xtooltip} object.
     */
    ApplyTitle(Xtt) {
        Xtt.SetTitle(this.Title || unset, IsNumber(this.Icon) ? this.Icon : unset)
    }
    /**
     * Sets an {@link XttLogfont} object to property {@link XttTheme#Font}.
     * @param {Object|XttLogfont} Options - An object with options as property : value pairs,
     * or an {@link XttLogfont} object.
     */
    SetFont(Options) {
        if Options is XttLogfont {
            this.__Font := Options
        } else if HasProp(Options, 'Font') {
            if Options.Font is XttLogfont {
                this.__Font := Options.Font
            } else {
                throw TypeError('``Options.Font`` must be an ``XttLogfont`` object.')
            }
        } else {
            lf := XttLogfont()
            if this.Default && this.Default.Font {
                default := this.Default.Font
                for prop in XttTheme.ListFont {
                    if HasProp(Options, prop) {
                        lf.%prop% := Options.%prop%
                    } else {
                        lf.%prop% := default.%prop%
                    }
                }
                flag := true
            } else {
                for prop in XttTheme.ListFont {
                    if HasProp(Options, prop) {
                        lf.%prop% := Options.%prop%
                        flag := true
                    }
                }
            }
            if IsSet(flag) {
                this.__Font := lf
            }
        }
    }
    /**
     * Sets {@link XttTheme#BackColor}, {@link XttTheme#MaxWidth} and {@link XttTheme#TextColor}.
     * @param {Object} Options - An object with options as property : value pairs.
     */
    SetGeneral(Options) {
        for prop in XttTheme.ListGeneral {
            if HasProp(Options, prop) {
                this.__%prop% := Options.%prop%
            }
        }
    }
    /**
     * Sets an {@link XttRect} object to property {@link XttTheme#Margin}.
     * @param {Object|XttRect} Options - An object with options as property : value pairs, or
     * an {@link XttRect} object.
     */
    SetMargin(Options) {
        if Options is XttRect {
            this.__Margin := Options
        } else if HasProp(Options, 'Margin') {
            if Options.Margin is XttRect || Options.Margin is Buffer {
                this.__Margin := Options.Margin
            } else {
                throw TypeError('``Options.Margin`` must be an ``XttRect`` or ``Buffer`` object.')
            }
        } else {
            rc := XttRect()
            if HasProp(Options, 'Margins') {
                margins := Options.Margins
                flag := true
            } else {
                margins := 0
            }
            for char in XttTheme.ListMargin {
                if HasProp(Options, 'Margin' char) {
                    rc.%char% := Options.Margin%char%
                    flag := true
                } else {
                    rc.%char% := margins
                }
            }
            if IsSet(flag) {
                this.__Margin := rc
            }
        }
    }
    /**
     * Sets property {@link XttTheme#Name}.
     * @param {String} ThemeName - The name.
     */
    SetName(ThemeName) {
        if this.ThemeCollection {
            if this.__Name {
                if this.ThemeCollection.Has(this.__Name) {
                    this.ThemeCollection.Delete(this.__Name)
                }
            }
            this.ThemeCollection.Set(ThemeName, this)
        }
        this.__Name := ThemeName
    }
    /**
     * Updates the theme with new options. This only changes values that are present on the input
     * `Options` object. If an option is absent from `Options`, that option does not get deleted
     * from the theme.
     * @param {Object} Options - An object with options as property : value pairs.
     */
    SetOptions(Options) {
        this.SetFont(Options)
        this.SetMargin(Options)
        if HasProp(Options, 'Name') {
            this.SetName(Options.Name)
        }
        for list in [ XttTheme.ListTitle, XttTheme.ListGeneral ] {
            for prop in list {
                if HasProp(Options, prop) {
                    this.__%prop% := Options.%prop%
                }
            }
        }
    }
    /**
     * Sets {@link XttTheme#Title} and {@link XttTheme#Icon}.
     * @param {Object} Options - An object with options as property : value pairs.
     */
    SetTitle(Options) {
        for prop in XttTheme.ListTitle {
            if HasProp(Options, prop) {
                this.__%prop% := Options.%prop%
            }
        }
    }

    BackColor {
        Get => StrLen(this.__BackColor) ? this.__BackColor : this.Default.__BackColor
        Set => this.__BackColor := Value
    }
    Font {
        Get => this.__Font ? this.__Font : this.Default.__Font
        Set => this.__Font := Value
    }
    Icon {
        Get => StrLen(this.__Icon) ? this.__Icon : this.Default.__Icon
        Set => this.__Icon := Value
    }
    Margin {
        Get => this.__Margin ? this.__Margin : this.Default.__Margin
        Set => this.__Margin := Value
    }
    MaxWidth {
        Get => StrLen(this.__MaxWidth) ? this.__MaxWidth : this.Default.__MaxWidth
        Set => this.__MaxWidth := Value
    }
    Name {
        Get => this.__Name
        Set => this.SetName(Value)
    }
    TextColor {
        Get => StrLen(this.__TextColor) ? this.__TextColor : this.Default.__TextColor
        Set => this.__TextColor := Value
    }
    Title {
        Get => StrLen(this.__Title) ? this.__Title : this.Default.__Title
        Set => this.__Title := Value
    }
}

class XttThemeGroup extends Xtooltip.Base {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.LightModeName := proto.DarkModeName := ''
    }
    /**
     * @param {String} GroupName
     * @param {XttTheme|XttTheme[]} [Themes] - An {@link XttTheme} object or an array of
     * {@link XttTheme} objects.
     */
    __New(GroupName, Themes?) {
        this.__ActiveTheme := ''
        this.Themes := XttThemeCollection()
        this.Xtooltips := XttCollection()
        this.__Name := GroupName
        if this.ThemeGroupCollection {
            this.ThemeGroupCollection.Set(GroupName, this)
        }
        if IsSet(Themes) {
            if Themes is Array {
                this.ThemeAddList(Themes)
            } else {
                this.ThemeAdd(Themes, false)
            }
        }
    }
    /**
     * @param {Boolean} Value - If true, activates the light mode theme. If false, activates the
     * dark mode theme.
     */
    ActivateLight(Value) {
        if Value {
            this.ThemeActivate(this.LightModeName)
        } else {
            this.ThemeActivate(this.DarkModeName)
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
        for hwnd, xtt in this.Xtooltips {
            Theme.Apply(xtt)
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
        for key, xtt in this.Xtooltips {
            Theme.ApplyFont(xtt)
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
        for key, xtt in this.Xtooltips {
            Theme.ApplyGeneral(xtt)
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
        for key, xtt in this.Xtooltips {
            Theme.ApplyMargin(xtt)
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
        for key, xtt in this.Xtooltips {
            Theme.ApplyTitle(xtt)
        }
    }
    GetActiveTheme() {
        return this.__ActiveTheme
    }
    /**
     * Sets light mode and dark mode theme names, allowing your code to call
     * {@link XttThemeGroup.Prototype.ActivateLight} to activate one or the other.
     * @param {String} [LightModeName] - The name of the light mode theme.
     * @param {String} [DarkModeName] - The name of the dark mode theme.
     */
    SetLightMode(LightModeName?, DarkModeName?) {
        if IsSet(LightModeName) {
            this.LightModeName := LightModeName
        }
        if IsSet(DarkModeName) {
            this.DarkModeName := DarkModeName
        }
    }
    SetName(GroupName) {
        if this.ThemeGroupCollection {
            if this.ThemeGroupCollection.Has(this.__Name) {
                this.ThemeGroupCollection.Delete(this.__Name)
            }
            this.ThemeGroupCollection.Set(GroupName, this)
        }
        this.__Name := GroupName
        for hwnd, xtt in this.Xtooltips {
            xtt.ThemeGroupName := GroupName
        }
    }
    ThemeActivate(Theme) {
        if IsObject(Theme) {
            if !Theme.__Name {
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
            if not Theme is XttTheme {
                Theme := XttTheme(Theme)
            }
            if !StrLen(Theme.__Name) {
                ; If you get this error, call `ThemeObj.SetName("SomeName")`.
                XttErrors.ThrowThemeGroupNoThemeName()
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
    ThemeAddList(Themes) {
        for theme in Themes {
            this.ThemeAdd(theme, false)
        }
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
            this.Apply%XttTheme.GetOptionCategory(OptionName)%()
        }
    }
    ToggleLightMode() {
        if this.__ActiveTheme.Name = this.LightModeName {
            this.ActivateLight(0)
        } else {
            this.ActivateLight(1)
        }
    }
    XttAdd(Xtt, ApplyActiveTheme := true) {
        this.Xtooltips.Set(Xtt.Hwnd, Xtt)
        Xtt.ThemeGroupName := this.__Name
        if ApplyActiveTheme && this.__ActiveTheme {
            this.__ActiveTheme.Apply(Xtt)
        }
    }
    XttDelete(Xtt) {
        this.Xtooltips.Delete(Xtt.Hwnd)
        Xtt.ThemeGroupName := ''
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

class XttToolInfo {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.cbSizeInstance :=
        ; Size      Type           Symbol         Offset                Padding
        4 +         ; UINT         cbSize         0
        4 +         ; UINT         uFlags         4
        A_PtrSize + ; HWND         hwnd           8
        A_PtrSize + ; UINT_PTR     uId            8 + A_PtrSize * 1
        4 +         ; INT          L              8 + A_PtrSize * 2
        4 +         ; INT          T              12 + A_PtrSize * 2
        4 +         ; INT          R              16 + A_PtrSize * 2
        4 +         ; INT          B              20 + A_PtrSize * 2
        A_PtrSize + ; HINSTANCE    hinst          24 + A_PtrSize * 2
        A_PtrSize + ; LPWSTR       lpszText       24 + A_PtrSize * 3
        A_PtrSize + ; LPARAM       lParam         24 + A_PtrSize * 4
        A_PtrSize   ; void         *lpReserved    24 + A_PtrSize * 5
        proto.offset_cbSize       := 0
        proto.offset_uFlags       := 4
        proto.offset_hwnd         := 8
        proto.offset_uId          := 8 + A_PtrSize * 1
        proto.offset_L            := 8 + A_PtrSize * 2
        proto.offset_T            := 12 + A_PtrSize * 2
        proto.offset_R            := 16 + A_PtrSize * 2
        proto.offset_B            := 20 + A_PtrSize * 2
        proto.offset_hinst        := 24 + A_PtrSize * 2
        proto.offset_lpszText     := 24 + A_PtrSize * 3
        proto.offset_lParam       := 24 + A_PtrSize * 4
        proto.offset_lpReserved   := 24 + A_PtrSize * 5
        this.Index := 0
    }
    static GetUid() {
        return ++this.Index
    }
    __New(HwndXtt, Hwnd?, uId?, TextBufferSize?) {
        this.HwndXtt := HwndXtt
        this.Buffer := Buffer(this.cbSizeInstance, 0)
        this.cbSize := this.cbSizeInstance
        if IsSet(Hwnd) {
            this.hwnd := Hwnd
        }
        if IsSet(uId) {
            this.uId := uId
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
        NumPut('ptr', this.TextBuffer.Ptr, this, this.offset_lpszText) ; lpszText
    }
    SetTextBuffer(Buf?, BufferSize?) {
        if IsSet(Buf) {
            this.TextBuffer := Buf
        } else if IsSet(BufferSize) {
            this.TextBuffer := Buffer(BufferSize)
        } else {
            throw TypeError('An input value is required.', -1)
        }
        NumPut('ptr', this.TextBuffer.Ptr, this, this.offset_lpszText)
    }
    cbSize {
        Get => NumGet(this.Buffer, this.offset_cbSize, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_cbSize)
        }
    }
    uFlags {
        Get => NumGet(this.Buffer, this.offset_uFlags, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_uFlags)
        }
    }
    hwnd {
        Get => NumGet(this.Buffer, this.offset_hwnd, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_hwnd)
        }
    }
    uId {
        Get => NumGet(this.Buffer, this.offset_uId, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_uId)
        }
    }
    L {
        Get => NumGet(this.Buffer, this.offset_L, 'int')
        Set {
            NumPut('int', Value, this.Buffer, this.offset_L)
        }
    }
    T {
        Get => NumGet(this.Buffer, this.offset_T, 'int')
        Set {
            NumPut('int', Value, this.Buffer, this.offset_T)
        }
    }
    R {
        Get => NumGet(this.Buffer, this.offset_R, 'int')
        Set {
            NumPut('int', Value, this.Buffer, this.offset_R)
        }
    }
    B {
        Get => NumGet(this.Buffer, this.offset_B, 'int')
        Set {
            NumPut('int', Value, this.Buffer, this.offset_B)
        }
    }
    hinst {
        Get => NumGet(this.Buffer, this.offset_hinst, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_hinst)
        }
    }
    lpszText {
        Get {
            Value := NumGet(this.Buffer, this.offset_lpszText, 'ptr')
            if Value > 0 {
                return StrGet(Value, XTT_DEFAULT_ENCODING)
            } else {
                return Value
            }
        }
        Set {
            if Type(Value) = 'String' {
                if !this.HasOwnProp('TextBuffer')
                || (this.TextBuffer is Buffer && this.TextBuffer.Size < StrPut(Value, XTT_DEFAULT_ENCODING)) {
                    this.TextBuffer := Buffer(StrPut(Value, XTT_DEFAULT_ENCODING))
                    NumPut('ptr', this.TextBuffer.Ptr, this.Buffer, this.offset_lpszText)
                }
                StrPut(Value, this.TextBuffer, XTT_DEFAULT_ENCODING)
            } else if Value is Buffer {
                this.TextBuffer := Value
                NumPut('ptr', this.TextBuffer.Ptr, this.Buffer, this.offset_lpszText)
            } else {
                this.TextBuffer := Value
                NumPut('ptr', this.TextBuffer, this.Buffer, this.offset_lpszText)
            }
        }
    }
    lParam {
        Get => NumGet(this.Buffer, this.offset_lParam, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_lParam)
        }
    }
    lpReserved {
        Get => NumGet(this.Buffer, this.offset_lpReserved, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_lpReserved)
        }
    }
    TextPtr {
        Get => NumGet(this, 24 + A_PtrSize * 3, 'ptr')
        Set => this.SetTextBuffer(Value)
    }
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size

    /**
     * @classdesc - The purpose of {@link XttToolInfo.Params} is to simplify the process of interacting with
     * the TTTOOLINFO structure that is needed for many tooltip-related functions / messages.
     *
     * {@link https://learn.microsoft.com/en-us/windows/win32/controls/ttm-settoolinfo}.
     */
    class Params {
        static __New() {
            this.DeleteProp('__New')
            this.Prototype.Props := [ 'uFlags', 'hwnd', 'uId', 'L', 'T', 'R', 'B', 'hInst', 'lParam' ]
        }
        /**
         * @description - Validates the parameters and copies their values to this instance of
         * {@link XttToolInfo.Params}.
         *
         * @param {Xtooltip} HwndXtt - The value of {@link Xtooltip#Hwnd}.
         *
         * @param {Object} Params - An object with property:value pairs.
         *
         * @param {String} [Params.StrLen] - The length of the text displayed by the tooltip.
         *
         * @param {Integer} [Params.uFlags] - One or more flags to assign to the member `uFlags`.
         * To combine values, use the bitwise "|" (e.g. `Params.uFlags := 0x0020 | 0x0080`).
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
         * @param {Integer} Params.hwnd - The handle to the window that contains the tool. This is
         * required.
         *
         * @param {Integer} [Params.uId] - The Windows API requires the member "uId" member when
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
         * @param {Integer} [Params.hInst] - You can leave this unset. Microsoft's
         * description states: Handle to the instance that contains the string resource for the tool.
         * If lpszText specifies the identifier of a string resource, this member is used.
         *
         * @param {Integer} [Params.lParam] - You can leave this unset. Microsoft's
         * description states: A 32-bit application-defined value that is associated with the tool.
         *
         * @returns {ToolInfo.Params}
         *
         * @throws {TypeError} - The property "<prop>" must be a <type>.
         * @throws {PropertyError} - The property "HwndXtt" is required.
         * @throws {PropertyError} - The flag `TTF_IDISHWND` in use, but the property "Hwnd" is unset.
         * @throws {PropertyError} - The flag `TTF_IDISHWND` is in use, but the property "Id" is unset.
         * @throws {PropertyError} - If at least one of properties "L", "T", "R", or "B", is set, then all four must be set.
         */
        __New(HwndXtt, Params) {
            if HasProp(Params, 'uFlags') {
                if !IsNumber(Params.uFlags) {
                    throw _TypeError('uFlags')
                }
                if Params.uFlags & TTF_IDISHWND {
                    if !HasProp(Params, 'hwnd') {
                        ; If you get this error, you must set "hwnd" with the handle to the parent
                        ; of "uId". If "uId" does not have a parent window, then set "hwnd" to the same
                        ; value as "uId".
                        throw PropertyError('The flag ``TTF_IDISHWND`` in use, but the property "hwnd" is unset.', -1)
                    }
                    if !HasProp(Params, 'uId') {
                        ; If you get this error, you must set "uId" with the handle to the window that
                        ; is the tool that this `XttToolInfo` object represents. For example, by passing
                        ; a `Gui.Control` object to `Xtooltip.Prototype.GetToolControl` or to
                        ; `Xtooltip.Prototype.GetToolWindow`.
                        throw PropertyError('The flag ``TTF_IDISHWND`` in use, but the property "uId" is unset.', -1)
                    }
                }
            }
            if !IsNumber(Params.hwnd) {
                throw _TypeError('hwnd')
            }
            if HasProp(Params, 'hwnd') {
                this.hwnd := Params.hwnd
            } else {
                this.hwnd := A_ScriptHwnd
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
            for prop in ['hInst', 'lParam', 'uId'] {
                if HasProp(Params, prop) {
                    if IsNumber(Params.%prop%) {
                        this.%prop% := Params.%prop%
                    } else {
                        throw _TypeError(prop)
                    }
                }
            }
            if !HasProp(this, 'uId') {
                this.uId := XttToolInfo.GetUid()
            }
            if HasProp(Params, 'StrLen') {
                if !IsNumber(Params.StrLen) {
                    throw _TypeError('StrLen')
                }
                this.StrLen := Params.StrLen
            }
            this.HwndXtt := HwndXtt

            return

            _TypeError(prop, _type := 'number') {
                return TypeError('The property "' prop '" must be a ' _type '.', -2)
            }
        }
        /**
         * @description - The purpose of {@link ToolInfo.Params.Prototype.Call} is to prepare a
         * TTTOOLINFO structure with new values before sending TTM_SETTOOLINFO.
         *
         * {@link ToolInfo.Params.Prototype.Call} validates the property values on this object, gets the
         * current TTTOOLINFO structure from the {@link Xtooltip} object by sending TTM_GETCURRENTTOOLW,
         * updates the members using the values of the properties on this object, then returns the
         * updated {@link XttToolInfo} object.
         */
        Call() {
            ti := XttToolInfo(this.HwndXtt)
            for prop in this.props {
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
    static Margin(Margin) {
        rc := this(margin, margin, margin, margin)
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
            NumPut('int', Number(Value), this, 0)
        }
    }
    T {
        Get => NumGet(this, 4, 'int')
        Set {
            NumPut('int', Number(Value), this, 4)
        }
    }
    R {
        Get => NumGet(this, 8, 'int')
        Set {
            NumPut('int', Number(Value), this, 8)
        }
    }
    B {
        Get => NumGet(this, 12, 'int')
        Set {
            NumPut('int', Number(Value), this, 12)
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
        proto := this.Prototype
        proto.cbSizeInstance :=
        ; Size      Type       Symbol          Offset               Padding
        4 +         ; DWORD    dwSize          0
        4 +         ; UINT     uTitleBitmap    4
        A_PtrSize + ; UINT     cch             8                    +4 on x64 only
        A_PtrSize   ; WCHAR    *pszTitle       8 + A_PtrSize * 1
        proto.offset_dwSize        := 0
        proto.offset_uTitleBitmap  := 4
        proto.offset_cch           := 8
        proto.offset_pszTitle      := 8 + A_PtrSize * 1
    }
    __New(Xtt, MaxChars := XTT_DEFAULT_TITLEMAXCHARS, Send := true) {
        this.Hwnd := Xtt.Hwnd
        this.Buffer := Buffer(this.cbSizeInstance, 0)
        NumPut('uint', this.Buffer.Size, this.Buffer)
        if Send {
            this.cch := MaxChars
            this.SetTextBuffer()
            SendMessage(TTM_GETTITLE, 0, this.Buffer.Ptr, this.Hwnd)
        }
    }
    Call(MaxChars := XTT_DEFAULT_TITLEMAXCHARS, &OutIcon?) {
        if !WinExist(this.Hwnd) {
            throw Error('The window no longer exists.', -1)
        }
        if !this.HasOwnProp('TextBuffer') || this.TextBuffer.Size < MaxChars * 2 {
            this.SetTextBuffer(MaxChars)
        }
        SendMessage(TTM_GETTITLE, 0, this.Buffer.Ptr, this.Hwnd)
        OutIcon := this.uTitleBitmap
        return this.Title
    }
    SetTextBuffer(MaxChars?) {
        if IsSet(MaxChars) {
            this.cch := MaxChars
        }
        this.TextBuffer := Buffer(this.cch * 2)
        NumPut('ptr', this.TextBuffer.Ptr, this.Buffer, this.offset_pszTitle)
    }
    dwSize {
        Get => NumGet(this.Buffer, this.offset_dwSize, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_dwSize)
        }
    }
    uTitleBitmap {
        Get => NumGet(this.Buffer, this.offset_uTitleBitmap, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_uTitleBitmap)
        }
    }
    cch {
        Get => NumGet(this.Buffer, this.offset_cch, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_cch)
        }
    }
    pszTitle {
        Get => NumGet(this.Buffer, this.offset_pszTitle, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_pszTitle)
        }
    }
    Title => this.pszTitle ? StrGet(this.pszTitle, XTT_DEFAULT_ENCODING) : ''
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
}

class XttCollection extends XttCollectionBase {

}

class ToolInfoParamsCollection extends XttCollectionBase {
}
class XttThemeCollection extends XttCollectionBase {
}
class XttThemeGroupCollection extends XttCollectionBase {
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
        throw Error('A theme must be set with a name to be added to a theme group.', -1)
    }
    static ThrowChildThemeNoName() {
        throw Error('A theme must be set with a name to be made a child of another theme.', -1)
    }
    static ThrowTrackingError() {
        throw Error('Only one tracking tool can be added to an Xtooltip at a time.', -1)
    }
}

/**
 * See the bottom of the file for static Windows API symbols related to fonts.
 * Note you cannot use an Ahk `Gui` handle with {@link XttLogfont}; it has to be a `Gui.Control` or some
 * other type of window.
 * @classdesc - A wrapper around the LOGFONT structure.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/dimm/ns-dimm-logfontw}
 */
class XttLogfont {
    static __New() {
        this.DeleteProp('__New')
        global WM_GETFONT := 0x0031, WM_SETFONT := 0x0030, LF_DEFAULT_ENCODING := 'UTF-16'
        Proto := this.Prototype
        Proto.Encoding := LF_DEFAULT_ENCODING
        /**
         * The structure's size.
         * @memberof XttLogfont
         * @instance
         */
        Proto.Size :=
        4 + ; LONG  lfHeight                    0
        4 + ; LONG  lfWidth                     4
        4 + ; LONG  lfEscapement                8
        4 + ; LONG  lfOrientation               12
        4 + ; LONG  lfWeight                    16
        1 + ; BYTE  lfItalic                    20
        1 + ; BYTE  lfUnderline                 21
        1 + ; BYTE  lfStrikeOut                 22
        1 + ; BYTE  lfCharSet                   23
        1 + ; BYTE  lfOutPrecision              24
        1 + ; BYTE  lfClipPrecision             25
        1 + ; BYTE  lfQuality                   26
        1 + ; BYTE  lfPitchAndFamily            27
        64  ; WCHAR lfFaceName[LF_FACESIZE]     28
        Proto.Handle := Proto.Hwnd := 0
    }
    /**
     * @description - Creates a {@link XttLogfont} object using a ptr address instead of a buffer. The
     * expected use case for this is when a Windows API function returns a LOGFONT structure. In
     * such cases, the system is managing that memory, and so it should be assumed that the memory
     * will only be available temporarily. When using {@link XttLogfont.FromPtr}, do not cache a reference to
     * the {@link XttLogfont} object; use it then let it go out of scope, or copy its values to an AHK buffer
     * using {@link XttLogfont.Prototype.Clone}.
     * @param {Integer} Ptr - The address of the LOGFONT structure.
     */
    static FromPtr(Ptr) {
        lf := { Buffer: { Ptr: Ptr, Size: this.Prototype.Size }, Handle: 0 }
        ObjSetBase(lf, this.Prototype)
        return lf
    }
    /**
     * Constructs a new {@link XttLogfont} object, optionally associating the object with a window handle.
     * @class
     * @param {Integer} [Hwnd = 0] - The window handle to associate with the {@link XttLogfont} object. If
     * `Hwnd` is set with a nonzero value, {@link XttLogfont.Prototype.Call} is called to initialize this
     * {@link XttLogfont} object's properties with values obtained from the window. If `Hwnd` is zero, this
     * {@link XttLogfont} object's properties will all be zero.
     * @return {XttLogfont}
     */
    __New(Hwnd := 0) {
        /**
         * A reference to the buffer object which is used as the LOGFONT structure.
         * @memberof XttLogfont
         * @instance
         */
        this.Buffer := Buffer(this.Size, 0)
        /**
         * The handle to the font object created by this object. Initially, this object
         * will not have yet created an object, so the handle is `0` until {@link XttLogfont.Prototype.Apply}
         * is called.
         * @memberof XttLogfont
         * @instance
         */
        this.Handle := 0
        /**
         * The handle to the window associated with this object, if any.
         * @memberof XttLogfont
         * @instance
         */
        if this.Hwnd := Hwnd {
            this()
        }
    }
    /**
     * @description - Calls `CreateFontIndirectW` then sends WM_SETFONT to the window associated
     * with this {@link XttLogfont} object.
     * @param {Boolean} [Redraw = true] - The value to pass to the `lParam` parameter when sending
     * WM_SETFONT. If true, the control redraws itself.
     */
    Apply() {
        hFontOld := SendMessage(WM_GETFONT,,, this.Hwnd)
        Flag := this.Handle = hFontOld
        this.Handle := DllCall('CreateFontIndirectW', 'ptr', this, 'ptr')
        SendMessage(WM_SETFONT, this.Handle, false, this.Hwnd)
        if Flag {
            DllCall('DeleteObject', 'ptr', hFontOld, 'int')
        }
    }
    /**
     * @description - Sends WM_GETFONT to the window associated with this {@link XttLogfont} object, updating
     * this object's properties with the values obtained from the window.
     * @throws {OSError} - Failed to get font object.
     */
    Call(*) {
        hFont := SendMessage(WM_GETFONT,,, this.Hwnd)
        if !DllCall('Gdi32.dll\GetObject', 'ptr', hFont, 'int', this.Size, 'ptr', this, 'uint') {
            throw OSError('Failed to get font object.', -1)
        }
    }
    /**
     * @description - Copies the bytes from this {@link XttLogfont} object's buffer to another buffer.
     * @param {XttLogfont|Buffer|Object} [Buf] - If set, one of the following three kinds of objects:
     * - A {@link XttLogfont} object.
     * - A `Buffer` object.
     * - An object with properties { Ptr, Size }.
     *
     * The size of the buffer must be at least `XttLogfont.Prototype.Size + Offset`.
     *
     * If unset, {@link XttLogfont.Prototype.Clone} will create a buffer of adequate size.
     * @param {Integer} [Offset = 0] - The byte offset from the start of `Buf` into which the LOGFONT
     * structure will be copied. If `Buf` is unset, then the LOGFONT structure will begin at
     * byte `Offset` within the buffer created by {@link XttLogfont.Prototype.Clone}.
     * @param {Boolean} [MakeInstance = true] - If true, then an instance of {@link XttLogfont} will be
     * created and returned by the function. If false, then only the buffer object will be returned;
     * the object will not have any of the properties or methods associated with the {@link XttLogfont} class.
     * @returns {Buffer|XttLogfont} - Depending on the value of `MakeInstance`, the `Buffer` object
     * or the {@link XttLogfont} object.
     * @throws {Error} - The input buffer's size is insufficient.
     */
    Clone(Buf?, Offset := 0, MakeInstance := true) {
        if IsSet(Buf) {
            if not Buf is Buffer && not Buf is XttLogFont {
                throw TypeError('Invalid input parameter ``Buf``.', -1)
            }
        } else {
            Buf := Buffer(this.Size + Offset)
        }
        if Buf.Size < this.Size + Offset {
            throw Error('The input buffer`'s size is insufficient.', -1, Buf.Size)
        }
        DllCall(
            'msvcrt.dll\memmove'
          , 'ptr', Buf.Ptr + Offset
          , 'ptr', this.Ptr
          , 'int', this.Size
          , 'ptr'
        )
        if MakeInstance {
            b := this
            loop {
                if b := b.Base {
                    if Type(b) = 'Prototype' {
                        break
                    }
                } else {
                    throw Error('Unable to identify the prototype object.', -1)
                }
            }
            Obj := { Buffer: Buf }
            ObjSetBase(Obj, b)
            return Obj
        }
        return Buf
    }
    /**
     * @description - If a font object has been created by this {@link XttLogfont} object, the font object
     * is deleted.
     */
    DisposeFont() {
        if this.Handle {
            DllCall('DeleteObject', 'ptr', this.Handle)
            this.Handle := 0
        }
    }
    /**
     * @description - Updates a property's value and calls {@link XttLogfont.Prototype.Apply} immediately afterward.
     * @param {String} Name - The name of the property.
     * @param {String|Number} Value - The value.
     */
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
     * Gets or sets the character set.
     * @memberof XttLogfont
     * @instance
     */
    CharSet {
        Get => NumGet(this, 23, 'uchar')
        Set => NumPut('uchar', Value, this, 23)
    }
    /**
     * Gets or sets the behavior when part of a character is clipped.
     * @memberof XttLogfont
     * @instance
     */
    ClipPrecision {
        Get => NumGet(this, 25, 'uchar')
        Set => NumPut('uchar', Value, this, 25)
    }
    /**
     * If this {@link XttLogfont} object is associated with a window, returns the dpi for the window.
     * @memberof XttLogfont
     * @instance
     */
    Dpi => this.Hwnd ? DllCall('GetDpiForWindow', 'Ptr', this.Hwnd, 'UInt') : A_ScreenDpi
    /**
     * Gets or sets the escapement measured in tenths of a degree.
     * @memberof XttLogfont
     * @instance
     */
    Escapement {
        Get => NumGet(this, 8, 'int')
        Set => NumPut('int', Value, this, 8)
    }
    /**
     * Gets or sets the font facename.
     * @memberof XttLogfont
     * @instance
     */
    FaceName {
        Get => StrGet(this.ptr + 28, 32, this.Encoding)
        Set => StrPut(SubStr(Value, 1, 31), this.Ptr + 28, 32, XTT_DEFAULT_ENCODING)
    }
    /**
     * Gets or sets the font family.
     * @memberof XttLogfont
     * @instance
     */
    Family {
        Get => NumGet(this, 27, 'uchar') & 0xF0
        Set => NumPut('uchar', (this.Family & 0x0F) | (Value & 0xF0), this, 27)
    }
    /**
     * Gets or sets the font size. "FontSize" requires that the {@link XttLogfont} object is associated
     * with a window handle because it needs a dpi value to work with.
     * @memberof XttLogfont
     * @instance
     */
    FontSize {
        Get => this.Hwnd ? Round(this.Height * -72 / this.Dpi, 2) : ''
        Set => this.Height := Round(Value * this.Dpi / -72)
    }
    /**
     * Gets or sets the font height.
     * @memberof XttLogfont
     * @instance
     */
    Height {
        Get => NumGet(this, 0, 'int')
        Set => NumPut('int', Value, this, 0)
    }
    /**
     * Gets or sets the italic flag.
     * @memberof XttLogfont
     * @instance
     */
    Italic {
        Get => NumGet(this, 20, 'uchar')
        Set => NumPut('uchar', Value ? 1 : 0, this, 20)
    }
    /**
     * Gets or sets the orientation measured in tenths of degrees.
     * @memberof XttLogfont
     * @instance
     */
    Orientation {
        Get => NumGet(this, 12, 'int')
        Set => NumPut('int', Value, this, 12)
    }
    /**
     * Gets or sets the behavior when multiple fonts with the same name exist on the system.
     * @memberof XttLogfont
     * @instance
     */
    OutPrecision {
        Get => NumGet(this, 24, 'uchar')
        Set => NumPut('uchar', Value, this, 24)
    }
    /**
     * Gets or sets the pitch.
     * @memberof XttLogfont
     * @instance
     */
    Pitch {
        Get => NumGet(this, 27, 'uchar') & 0x0F
        Set => NumPut('uchar', (this.Pitch & 0xF0) | (Value & 0x0F), this, 27)
    }
    /**
     * Returns the pointer to the buffer.
     * @memberof XttLogfont
     * @instance
     */
    Ptr => this.Buffer.Ptr
    /**
     * Gets or sets the quality flag.
     * @memberof XttLogfont
     * @instance
     */
    Quality {
        Get => NumGet(this, 26, 'uchar')
        Set => NumPut('uchar', Value, this, 26)
    }
    /**
     * Gets or sets the strikeout flag.
     * @memberof XttLogfont
     * @instance
     */
    StrikeOut {
        Get => NumGet(this, 22, 'uchar')
        Set => NumPut('uchar', Value ? 1 : 0, this, 22)
    }
    /**
     * Gets or sets the underline flag.
     * @memberof XttLogfont
     * @instance
     */
    Underline {
        Get => NumGet(this, 21, 'uchar')
        Set => NumPut('uchar', Value ? 1 : 0, this, 21)
    }
    /**
     * Gets or sets the weight flag.
     * @memberof XttLogfont
     * @instance
     */
    Weight {
        Get => NumGet(this, 16, 'int')
        Set => NumPut('int', Value, this, 16)
    }
    /**
     * Gets or sets the width.
     * @memberof XttLogfont
     * @instance
     */
    Width {
        Get => NumGet(this, 4, 'int')
        Set => NumPut('int', Value, this, 4)
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

Xtooltip_SetConstants(force := false) {
    global
    if !force && IsSet(g_Xtooltip_constants_set) && g_Xtooltip_constants_set {
        return
    }
    ; XTT - constants for this library
    XTT_DEFAULT_ENCODING := 'UTF-16'
    XTT_DEFAULT_TITLEMAXCHARS := 100

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

    WM_SETFONT := 0x0030
    WM_USER := 1024

    g_Xtooltip_constants_set := 1
}

/**
 * @description - Enables the usage of the "_S" suffix when calling {@link Xtooltip} instance methods,
 * {@link XttToolInfo} static methods, {@link XttToolInfo} instance methods, {@link XttRect} static methods, and {@link XttRect}
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

Static values related to fonts:

#define OUT_DEFAULT_PRECIS          0
#define OUT_STRING_PRECIS           1
#define OUT_CHARACTER_PRECIS        2
#define OUT_STROKE_PRECIS           3
#define OUT_TT_PRECIS               4
#define OUT_DEVICE_PRECIS           5
#define OUT_RASTER_PRECIS           6
#define OUT_TT_ONLY_PRECIS          7
#define OUT_OUTLINE_PRECIS          8
#define OUT_SCREEN_OUTLINE_PRECIS   9
#define OUT_PS_ONLY_PRECIS          10

#define CLIP_DEFAULT_PRECIS     0
#define CLIP_CHARACTER_PRECIS   1
#define CLIP_STROKE_PRECIS      2
#define CLIP_MASK               0xf
#define CLIP_LH_ANGLES          (1<<4)
#define CLIP_TT_ALWAYS          (2<<4)
#if (_WIN32_WINNT >= _WIN32_WINNT_LONGHORN)
#define CLIP_DFA_DISABLE        (4<<4)
#endif // (_WIN32_WINNT >= _WIN32_WINNT_LONGHORN)
#define CLIP_EMBEDDED           (8<<4)

#define DEFAULT_QUALITY         0
#define DRAFT_QUALITY           1
#define PROOF_QUALITY           2
#if(WINVER >= 0x0400)
#define NONANTIALIASED_QUALITY  3
#define ANTIALIASED_QUALITY     4
#endif // WINVER >= 0x0400

#if (_WIN32_WINNT >= _WIN32_WINNT_WINXP)
#define CLEARTYPE_QUALITY       5
#define CLEARTYPE_NATURAL_QUALITY       6
#endif

#define DEFAULT_PITCH           0
#define FIXED_PITCH             1
#define VARIABLE_PITCH          2
#if(WINVER >= 0x0400)
#define MONO_FONT               8
#endif // WINVER >= 0x0400

#define ANSI_CHARSET            0
#define DEFAULT_CHARSET         1
#define SYMBOL_CHARSET          2
#define SHIFTJIS_CHARSET        128
#define HANGEUL_CHARSET         129
#define HANGUL_CHARSET          129
#define GB2312_CHARSET          134
#define CHINESEBIG5_CHARSET     136
#define OEM_CHARSET             255
#if(WINVER >= 0x0400)
#define JOHAB_CHARSET           130
#define HEBREW_CHARSET          177
#define ARABIC_CHARSET          178
#define GREEK_CHARSET           161
#define TURKISH_CHARSET         162
#define VIETNAMESE_CHARSET      163
#define THAI_CHARSET            222
#define EASTEUROPE_CHARSET      238
#define RUSSIAN_CHARSET         204

#define MAC_CHARSET             77
#define BALTIC_CHARSET          186

#define FS_LATIN1               0x00000001L
#define FS_LATIN2               0x00000002L
#define FS_CYRILLIC             0x00000004L
#define FS_GREEK                0x00000008L
#define FS_TURKISH              0x00000010L
#define FS_HEBREW               0x00000020L
#define FS_ARABIC               0x00000040L
#define FS_BALTIC               0x00000080L
#define FS_VIETNAMESE           0x00000100L
#define FS_THAI                 0x00010000L
#define FS_JISJAPAN             0x00020000L
#define FS_CHINESESIMP          0x00040000L
#define FS_WANSUNG              0x00080000L
#define FS_CHINESETRAD          0x00100000L
#define FS_JOHAB                0x00200000L
#define FS_SYMBOL               0x80000000L
#endif // WINVER >= 0x0400

// Font Families
#define FF_DONTCARE         0x00 (0)    /* Don't care or don't know.
#define FF_ROMAN            0x10 (16)   /* Variable stroke width, serifed.
                                        /* Times Roman, Century Schoolbook, etc.
#define FF_SWISS            0x20 (32)   /* Variable stroke width, sans-serifed.
                                        /* Helvetica, Swiss, etc.
#define FF_MODERN           0x30 (48)   /* Constant stroke width, serifed or sans-serifed.
                                        /* Pica, Elite, Courier, etc.
#define FF_SCRIPT           0x40 (64)   /* Cursive, etc.
#define FF_DECORATIVE       0x50 (80)   /* Old English, etc.

/* Font Weights
#define FW_DONTCARE         0
#define FW_THIN             100
#define FW_EXTRALIGHT       200
#define FW_LIGHT            300
#define FW_NORMAL           400
#define FW_MEDIUM           500
#define FW_SEMIBOLD         600
#define FW_BOLD             700
#define FW_EXTRABOLD        800
#define FW_HEAVY            900

#define FW_ULTRALIGHT       FW_EXTRALIGHT
#define FW_REGULAR          FW_NORMAL
#define FW_DEMIBOLD         FW_SEMIBOLD
#define FW_ULTRABOLD        FW_EXTRABOLD
#define FW_BLACK            FW_HEAVY

; https://learn.microsoft.com/en-us/previous-versions/dd162618(v=vs.85)
#define RASTER_FONTTYPE     0x0001
#define DEVICE_FONTTYPE     0x0002
#define TRUETYPE_FONTTYPE   0x0004

