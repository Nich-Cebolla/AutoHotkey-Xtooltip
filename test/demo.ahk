﻿
#SingleInstance force
#include ..\src\Xtooltip.ahk

demo()

class demo {
    static __New() {
        this.DeleteProp('__New')
        global ObjGetOwnPropDesc := Object.Prototype.GetOwnPropDesc
    }
    static Call() {
        width := 1100
        demoControlsOffsetX := 25
        fontName := 'Segoe Ui'
        fontOpt := 's11 q5'
        demoButtonWidth := 100
        demoEditWidth := 200
        paddingY := 15
        paddingX := 10
        tabs := this.Tabs := ['Modify', 'Create']

        eventHandler := this.EventHandler := DemoEventHandler()
        DllCall('SetThreadDpiAwarenessContext', 'ptr', -3, 'ptr')
        g := this.g := Gui('+Resize -DPIScale', 'Xtooltip demo', eventHandler)
        DllCall('SetThreadDpiAwarenessContext', 'ptr', -4, 'ptr')
        g.SetFont(fontOpt, fontName)
        g.Add('Edit', 'w' width ' vEdtInfo', DemoStrings.Welcome)
        g['EdtInfo'].GetPos(, &edty, , &edth)

        buttons := this.Buttons := []
        x := g.MarginX + demoControlsOffsetX
        y := edty + edth + paddingY
        loop 3 {
            buttons.Push(g.Add('Button', 'x' x ' y' y ' w' demoButtonWidth ' vBtn' A_Index, 'Button ' A_Index))
            buttons[-1].GetPos(, , , &btnh)
            y += btnh + paddingY
        }

        edits := this.Edits := []
        loop 3 {
            edits.Push(g.Add('Edit', 'x' x ' y' y ' r3 w' demoEditWidth ' vEdt' A_Index, DemoStrings.Edits[A_Index]))
            edits[-1].GetPos(, , , &edth)
            y += edth + paddingY
        }

        xtts := this.Xtooltips := XtooltipCollection()
        groups := this.XttGroups := XttThemeGroupCollection()
        buttonTheme := Xtooltip.Theme({
            BackColor: 0x000000
          , TextColor: XttRgb(255, 0, 0)
          , MarginL: 2
          , MarginT: 2
          , MarginR: 2
          , MarginB: 2
          , FontSize: 11
        })
        groupButton := Xtooltip.ThemeGroup()
        groupButton.ThemeAdd('General', buttonTheme)
        groups.Add('Button', groupButton)
        xttButton := Xtooltip(, , , buttonTheme)
        xtts.Set(xttButton.Hwnd, xttButton)
        for button in buttons {
            xttButton.AddControl(A_Index, DemoStrings.Buttons[A_Index], buttons[A_Index])
        }

        editTheme := Xtooltip.Theme({
            BackColor: 0x000000
          , TextColor: XttRgb(0, 255, 255)
          , MarginL: 5
          , MarginT: 5
          , MarginR: 5
          , MarginB: 5
          , FontSize: 11
        })
        groupEdit := Xtooltip.ThemeGroup()
        groupEdit.ThemeAdd('General', editTheme)
        groups.Add('Edit', groupEdit)
        xttEdit := Xtooltip(, , , editTheme)
        xtts.Set(xttEdit.Hwnd, xttEdit)
        for _edit in edits {
            xttEdit.AddControl(A_Index, DemoStrings.Edits[A_Index], edits[A_Index])
        }

        buttons[1].GetPos(, &btny)
        edits[1].GetPos(&edtx, , &edtw)
        tab := this.Tab := g.Add('Tab2', 'x' (edtx + edtw + paddingX) ' y' btny ' w' (width - edtw - edtx - g.MarginX) ' vTab', tabs)

        tab.UseTab(1)



        g.show('NoActivate')

    }
}

class DemoEventHandler {

}

class DemoStrings {
    static Welcome := (
        'Welcome to the Xtooltip demo. Try hovering your mouse over the edit controls or buttons below on the left.'
        '`r`nTo create a new tooltip, switch the tab control`'s tab to "Create". Input the parameters'
        ' then click "Create".'
        '`r`nTo modify an existing tooltip, switch the tab control`'s tab to "Modify" and select the'
        ' tooltip in the list box. Change any of the values in the "Set values" region, then click "Set".'
        '`r`nThe color sliders are dynamic and update automatically as you slide the slider.'
    )
    static Buttons := [
        'This is the text for Button 1!'
      , 'This is the text for Button 2!'
      , 'This is the text for Button 3!'
    ]
    static Edits := [
        'If you edit this text,'
      , 'the change will be reflected'
      , 'in the tooltip`'s text as well.'
    ]
}


/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * @description - Traverses an object's inheritance chain and returns the base objects.
 * @param {Object} Obj - The object from which to get the base objects.
 * @param {Integer|String} [StopAt=GBO_STOP_AT_DEFAULT ?? '-Any'] - If an integer, the number of
 * base objects to traverse up the inheritance chain. If a string, the case-insensitive name of the
 * class to stop at. If falsy, the function will traverse the entire inheritance chain up to
 * but not including `Any`.
 *
 * If you define global variable `GBO_STOP_AT_DEFAULT` with a value somewhere in your code, that
 * value will be used as the default for the function call. Otherwise, '-Any' is used.
 *
 * There are two ways to modify the function's interpretation of this value:
 *
 * - Stop before or after the class: The default is to stop after the class, such that the base object
 * associated with the class is included in the result array. To change this, include a hyphen "-"
 * anywhere in the value and `GetBaseObjects` will not include the last iterated object in the
 * result array.
 *
 * - The type of object which will be stopped at: This only applies to `StopAt` values which are
 * strings. In the code snippets below, `b` is the object being evaluated.
 *
 *   - Stop at a prototype object (default): `GetBaseObjects` will stop at the first prototype object
 * with a `__Class` property equal to `StopAt`. This is the literal condition used:
 * `Type(b) == 'Prototype' && (b.__Class = 'Any' || b.__Class = StopAt)`.
 *
 *   - Stop at a class object: To direct `GetBaseObjects` to stop at a class object tby he name
 * `StopAt`, include ":C" at the end of `StopAt`, e.g. `StopAt := "MyClass:C"`. This is the literal
 * condition used:
 * `Type(b) == 'Class' && ObjHasOwnProp(b, 'Prototype') && b.Prototype.__Class = StopAt`.
 *
 *  - Stop at an instance object: To direct `GetBaseObjects` to stop at an instance object of type
 * `StopAt`, incluide ":I" at the end of `StopAt`, e.g. `StopAt := "MyClass:I"`. This is the literal
 * condition used: `Type(b) = StopAt`.
 * @returns {Array} - The array of base objects.
 */
GetBaseObjects(Obj, StopAt := GBO_STOP_AT_DEFAULT ?? '-Any') {
    Result := []
    b := Obj
    if StopAt {
        if InStr(StopAt, '-') {
            StopAt := StrReplace(StopAt, '-', '')
            FlagStopBefore := true
        }
    } else {
        FlagStopBefore := true
        StopAt := 'Any'
    }
    if InStr(StopAt, ':C') {
        StopAt := StrReplace(StopAt, ':C', '')
        CheckStopAt := _CheckStopAtClass
    } else if InStr(StopAt, ':I') {
        StopAt := StrReplace(StopAt, ':I', '')
        CheckStopAt := _CheckStopAtInstance
    } else {
        CheckStopAt := _CheckStopAt
    }

    if IsNumber(StopAt) {
        Loop Number(StopAt) - (IsSet(FlagStopBefore) ? 2 : 1) {
            if b := b.Base {
                Result.Push(b)
            } else {
                break
            }
        }
    } else {
        if IsSet(FlagStopBefore) {
            Loop {
                if !(b := b.Base) {
                    _Throw()
                    break
                }
                if CheckStopAt() {
                    break
                }
                Result.Push(b)
            }
        } else {
            Loop {
                if !(b := b.Base) {
                    _Throw()
                    break
                }
                Result.Push(b)
                if CheckStopAt() {
                    break
                }
            }
        }
    }
    return Result

    _CheckStopAt() {
        return  Type(b) == 'Prototype' && (b.__Class = 'Any' || b.__Class = StopAt)
    }
    _CheckStopAtClass() {
        return Type(b) == 'Class' && ObjHasOwnProp(b, 'Prototype') && b.Prototype.__Class = StopAt
    }
    _CheckStopAtInstance() {
        return Type(b) = StopAt
    }
    _Throw() {
        ; If `GetBaseObjects` encounters a non-object base, that means it traversed the inheritance
        ; chain up to Any.Prototype, which returns an empty string. If `StopAt` = 'Any' and
        ; !IsSet(FlagStopBefore) (the user did not include "-" in the param string), then this is
        ; expected. In all other cases, this means that the input `StopAt` value was never
        ; encountered, and results in this error.
        if IsSet(FlagStopBefore) || StopAt != 'Any' {
            throw Error('``GetBaseObjects`` did not encounter an object that matched the ``StopAt`` value.'
            , -2, '``StopAt``: ' (IsSet(FlagStopBefore) ? '-' : '') StopAt)
        }
    }
}

/**
 * @description - Constructs a `PropsInfo` object, which is a flexible solution for cases when a
 * project would benefit from being able to quickly obtain a list of all of an object's properties,
 * and/or filter those properties.
 *
 * In this documentation, an instance of `PropsInfo` is referred to as either "a `PropsInfo` object"
 * or `PropsInfoObj`. An instance of `PropsInfoItem` is referred to as either "a `PropsInfoItem` object"
 * or `InfoItem`.
 *
 * See example-Inheritance.ahk for a walkthrough on how to use the class.
 *
 * `PropsInfo` objects are designed to be a flexible solution for accessing and/or analyzing an
 * object's properties, including inherited properties. Whereas `OwnProps` only iterates an objects'
 * own properties, `PropsInfo` objects can perform these functions for both inherited and own
 * properties:
 * - Produce an array of property names.
 * - Produce a `Map` where the key is the property name and the object is a `PropsInfoItem` object
 * for each property.
 * - Produce an array of `PropsInfoItem` objects.
 * - Be passed to a function that expects an iterable object like any of the three above bullet points.
 * - Filter the properties according to one or more conditions.
 * - Get the function objects associated with the properties.
 * - Get the values associated with the properties.
 *
 * `PropsInfoItem` objects are modified descriptor objects.
 * @see {@link https://www.autohotkey.com/docs/v2/lib/Object.htm#GetOwnPropDesc}.
 * After getting the descriptor object, `GetPropsInfo` changes the descriptor object's base, converting
 * it to a `PropsInfoItem` object and exposing additional properties. See the parameter hints above
 * each property for details.
 *
 * @param {*} Obj - The object from which to get the properties.
 * @param {Integer|String} [StopAt=GPI_STOP_AT_DEFAULT ?? '-Object'] - If an integer, the number of
 * base objects to traverse up the inheritance chain. If a string, the name of the class to stop at.
 * You can define a global variable `GPI_STOP_AT_DEFAULT` to change the default value. If
 * GPI_STOP_AT_DEFAULT is unset, the default value is '-Object', which directs `GetPropsInfo` to
 * include properties owned by objects up to but not including `Object.Prototype`.
 * @see {@link GetBaseObjects} for full details about this parameter.
 * @param {String} [Exclude=''] - A comma-delimited, case-insensitive list of properties to exclude.
 * For example: "Length,Capacity,__Item".
 * @param {Boolean} [IncludeBaseProp=true] - If true, the object's `Base` property is included. If
 * false, `Base` is excluded.
 * @param {VarRef} [OutBaseObjList] - A variable that will receive a reference to the array of
 * base objects that is generated during the function call.
 * @param {Boolean} [ExcludeMethods=false] - If true, callable properties are excluded. Note that
 * properties with a value that is a class object are unaffected by `ExcludeMethods`.
 * @returns {PropsInfo}
 */
GetPropsInfo(Obj, StopAt := GPI_STOP_AT_DEFAULT ?? '-Object', Exclude := '', IncludeBaseProp := true, &OutBaseObjList?, ExcludeMethods := false) {
    OutBaseObjList := GetBaseObjects(Obj, StopAt)
    Container := Map()
    Container.Default := Container.CaseSense := false
    Excluded := ','
    for s in StrSplit(Exclude, ',', '`s`t') {
        if (s) {
            Container.Set(s, -1)
        }
    }

    PropsInfoItemBase := PropsInfoItem(Obj, OutBaseObjList.Length)

    if ExcludeMethods {
        for Prop in ObjOwnProps(Obj) {
            if (HasMethod(Obj, Prop) && not Obj.%Prop% is Class) || Container.Get(Prop) {
                if !InStr(Excluded, ',' Prop ',') {
                    Excluded .= Prop ','
                }
                continue
            }
            ObjSetBase(ItemBase := {
                /**
                 * The property name.
                 * @memberof PropsInfoItem
                 * @instance
                 */
                    Name: Prop
                /**
                 * `Count` gets incremented by one for each object which owns a property by the same name.
                 * @memberof PropsInfoItem
                 * @instance
                 */
                  , Count: 1
                }
              , PropsInfoItemBase)
            ObjSetBase(Item := ObjGetOwnPropDesc(Obj, Prop), ItemBase)
            Item.Index := 0
            Container.Set(Prop, Item)
        }
        if IncludeBaseProp {
            ObjSetBase(ItemBase := { Name: 'Base', Count: 1 }, PropsInfoItemBase)
            ObjSetBase(InfoItem_Base := { Value: Obj.Base }, ItemBase)
            InfoItem_Base.Index := 0
            Container.Set('Base', InfoItem_Base)
        }
        i := 0
        for b in OutBaseObjList {
            i++
            for Prop in ObjOwnProps(b) {
                if HasMethod(b, Prop) {
                    if !InStr(Excluded, ',' Prop ',') {
                        Excluded .= Prop ','
                    }
                }
                if r := Container.Get(Prop) {
                    if r == -1 {
                        if !InStr(Excluded, ',' Prop ',') {
                            Excluded .= Prop ','
                        }
                        continue
                    }
                    ; It's an existing property
                    ObjSetBase(Item := ObjGetOwnPropDesc(b, Prop), r.Base)
                    Item.Index := i
                    r.__SetAlt(Item)
                    r.Base.Count++
                } else {
                    ; It's a new property
                    ObjSetBase(ItemBase := { Name: Prop, Count: 1 }, PropsInfoItemBase)
                    ObjSetBase(Item := ObjGetOwnPropDesc(b, Prop), ItemBase)
                    Item.Index := i
                    Container.Set(Prop, Item)
                }
            }
            if IncludeBaseProp {
                ObjSetBase(Item := { Value: b.Base }, InfoItem_Base.Base)
                Item.Index := i
                InfoItem_Base.__SetAlt(Item)
                InfoItem_Base.Base.Count++
            }
        }
    } else {
        for Prop in ObjOwnProps(Obj) {
            if Container.Get(Prop) {
                ; Prop is in `Exclude`
                if !InStr(Excluded, ',' Prop ',') {
                    Excluded .= Prop ','
                }
                continue
            }
            ObjSetBase(ItemBase := {
                /**
                 * The property name.
                 * @memberof PropsInfoItem
                 * @instance
                 */
                    Name: Prop
                /**
                 * `Count` gets incremented by one for each object which owns a property by the same name.
                 * @memberof PropsInfoItem
                 * @instance
                 */
                  , Count: 1
                }
              , PropsInfoItemBase)
            ObjSetBase(Item := ObjGetOwnPropDesc(Obj, Prop), ItemBase)
            Item.Index := 0
            Container.Set(Prop, Item)
        }
        if IncludeBaseProp {
            ObjSetBase(ItemBase := { Name: 'Base', Count: 1 }, PropsInfoItemBase)
            ObjSetBase(InfoItem_Base := { Value: Obj.Base }, ItemBase)
            InfoItem_Base.Index := 0
            Container.Set('Base', InfoItem_Base)
        }
        i := 0
        for b in OutBaseObjList {
            i++
            for Prop in ObjOwnProps(b) {
                if r := Container.Get(Prop) {
                    if r == -1 {
                        if !InStr(Excluded, ',' Prop ',') {
                            Excluded .= Prop ','
                        }
                        continue
                    }
                    ObjSetBase(Item := ObjGetOwnPropDesc(b, Prop), r.Base)
                    Item.Index := i
                    r.__SetAlt(Item)
                    r.Base.Count++
                } else {
                    ; It's a new property
                    ObjSetBase(ItemBase := { Name: Prop, Count: 1 }, PropsInfoItemBase)
                    ObjSetBase(Item := ObjGetOwnPropDesc(b, Prop), ItemBase)
                    Item.Index := i
                    Container.Set(Prop, Item)
                }
            }
            if IncludeBaseProp {
                ObjSetBase(Item := { Value: b.Base }, InfoItem_Base.Base)
                Item.Index := i
                InfoItem_Base.__SetAlt(Item)
                InfoItem_Base.Base.Count++
            }
        }
    }
    for s in StrSplit(Exclude, ',', '`s`t') {
        if s {
            Container.Delete(s)
        }
    }
    if !IncludeBaseProp {
        Excluded .= 'Base'
    }
    return PropsInfo(Container, PropsInfoItemBase, Trim(Excluded, ','))
}

/**
 * @classdesc - The return value for `GetPropsInfo`. See the parameter hint above `GetPropsInfo`
 * for information.
 */
class PropsInfo {
    static __New() {
        if this.Prototype.__Class == 'PropsInfo' {
            Proto := this.Prototype
            Proto.DefineProp('Filter', { Value: '' })
            Proto.DefineProp('__FilterActive', { Value: 0 })
            Proto.DefineProp('__StringMode', { Value: 0 })
            Proto.DefineProp('Get', Proto.GetOwnPropDesc('__ItemGet_Bitypic'))
            Proto.DefineProp('__OnFilterProperties', { Value: ['Has', 'ToArray', 'ToMap'
            , 'Capacity', 'Count', 'Length'] })
            Proto.DefineProp('__FilteredItems', { Value: '' })
            Proto.DefineProp('__FilteredIndex', { Value: '' })
            Proto.DefineProp('__FilterCache', { Value: '' })
        }
    }

    /**
     * @class - The constructor is intended to be called from `GetPropsInfo`.
     * @param {Map} Container - The keys are property names and the values are `PropsInfoItem` objects.
     * @param {PropsInfoItem} PropsInfoItemBase - The base object shared by all instances of
     * `PropsInfoItem` associated with this `PropsInfo` object.
     * @param {String} [Excluded] - A comma-delimited list of properties that were excluded from the
     * collection.
     * @returns {PropsInfo} - The `PropsInfo` instance.
     */
    __New(Container, PropsInfoItemBase, Excluded?) {
        this.__InfoIndex := Map()
        this.__InfoIndex.Default := this.__InfoIndex.CaseSense := false
        this.__InfoItems := []
        this.__InfoItems.Capacity := this.__InfoIndex.Capacity := Container.Count
        for Prop, InfoItem in Container {
            this.__InfoItems.Push(InfoItem)
            this.__InfoIndex.Set(Prop, A_Index)
        }
        this.__PropsInfoItemBase := PropsInfoItemBase
        this.__FilterActive := 0
        this.Excluded := Excluded ?? ''
    }

    /**
     * @description - Removes a `PropsInfoItem` object from the collection. This does not change the
     * items exposed by the currently active filter nor any cached filters. To update a filter,
     * call `PropsInfo.Prototype.FilterActivate` after calling `PropsInfo.Prototype.Delete`,
     * `PropsInfo.Prototype.Refresh`, or `PropsInfo.Prototype.RefreshProp`.
     * @param {String} Names - A comma-delimited list of property names to delete.
     * @returns {PropsInfoItem[]} - An array of deleted `PropsInfoItem` objects.
     */
    Delete(Names) {
        InfoItems := this.__InfoItems
        InfoIndex := this.__InfoIndex
        NewInfoItems := this.__InfoItems := []
        Deleted := []
        NewInfoIndex := this.__InfoIndex := Map()
        NewInfoIndex.CaseSense := false
        NewInfoItems.Capacity := NewInfoIndex.Capacity := Deleted.Capacity := InfoItems.Length
        Names := ',' Names ','
        for InfoItem in InfoItems {
            if InStr(Names, ',' InfoItem.Name ',') {
                Deleted.Push(InfoItem)
            } else {
                NewInfoItems.Push(InfoItem)
                NewInfoIndex.Set(InfoItem.Name, NewInfoItems.Length)
            }
        }
        Excluded := this.Excluded ','
        for Prop in StrSplit(Trim(Names, ','), ',', '`s`t') {
            if !InStr(Excluded, ',' Prop ',') {
                Excluded .= Prop ','
            }
        }
        this.Excluded := Trim(Excluded, ',')
        NewInfoItems.Capacity := NewInfoItems.Length
        NewInfoIndex.Capacity := NewInfoIndex.Count
        Deleted.Capacity := Deleted.Length
        return Deleted
    }

    /**
     * @description - Performs these actions:
     * - Deletes the `Root` property from the `PropsInfoItem` object that is used as the base for
     * all `PropsInfoItem` objects associated with this `PropsInfo` object. This action invalidates
     * some of the `PropsInfoItem` objects' methods and properties, and they should be considered
     * effectively disposed.
     * - Clears the `PropsInfo` object's container properties and sets their capacity to 0
     * - Deletes the `PropsInfo` object's own properties.
     */
    Dispose() {
        this.__PropsInfoItemBase.DeleteProp('Root')
        this.__InfoIndex.Clear()
        this.__InfoIndex.Capacity := this.__InfoItems.Capacity := 0
        if this.__FilteredIndex {
            this.__FilteredIndex.Capacity := 0
        }
        if this.__FilteredItems {
            this.__FilteredItems.Clear()
            this.__FilteredItems.Capacity := 0
        }
        if this.HasOwnProp('Filter') {
            this.DeleteProp('Filter')
        }
        if this.HasOwnProp('__FilterCache') {
            this.__FilterCache.Clear()
            this.__FilterCache.Capacity := 0
        }
        for Prop in this.OwnProps() {
            this.DeleteProp(Prop)
        }
        this.DefineProp('Dispose', { Call: (*) => '' })
    }

    /**
     * @description - Activates the filter, setting property `PropsInfoObj.FilterActive := 1`. While
     * `PropsInfoObj.FilterActive == 1`, the values returned by the following methods and properties
     * will be filtered:
     * __Enum, Get, GetFilteredProps (if a function object is not passed to it), Has, ToArray, ToMap,
     * __item, Capacity, Count, Length
     * @param {String|Number} [CacheName] - If set, the filtered containers will be cached under this name.
     * Else, the containers are not cached.
     * @throws {UnsetItemError} - If no filters have been added.
     */
    FilterActivate(CacheName?) {
        if !this.Filter {
            throw UnsetItemError('No filters have been added.', -1)
        }
        Filter := this.Filter
        this.DefineProp('__FilteredIndex', { Value: FilteredIndex := [] })
        this.DefineProp('__FilteredItems', { Value: FilteredItems := Map() })
        FilteredIndex.Capacity := FilteredItems.Capacity := this.__InfoItems.Length
        ; If there's only one filter object in the collection, we can save a bit of processing
        ; time by just getting a reference to the object and skipping the second loop.
        if Filter.Count == 1 {
            for FilterIndex, FilterObj in Filter {
                Fn := FilterObj
            }
            for InfoItem in this.__InfoItems {
                if Fn(InfoItem) {
                    continue
                }
                FilteredItems.Set(A_Index, InfoItem)
                FilteredIndex.Push(A_Index)
            }
        } else {
            for InfoItem in this.__InfoItems {
                for FilterIndex, FilterObj in Filter {
                    if FilterObj(InfoItem) {
                        continue 2
                    }
                }
                FilteredItems.Set(A_Index, InfoItem)
                FilteredIndex.Push(A_Index)
            }
        }
        FilteredIndex.Capacity := FilteredItems.Capacity := FilteredItems.Count
        this.__FilterActive := 1
        if IsSet(CacheName) {
            this.FilterCache(CacheName)
        }
        this.__FilterSwitchProps(1)
    }

    /**
     * @description - Activates a cached filter.
     * @param {String|Number} Name - The name of the filter to activate.
     */
    FilterActivateFromCache(Name) {
        this.__FilterActive := 1
        this.__FilteredItems := this.__FilterCache.Get(Name).Items
        this.__FilteredIndex := this.__FilterCache.Get(Name).Index
        this.Filter := this.__FilterCache.Get(Name).FilterGroup
        this.__FilterSwitchProps(1)
    }

    /**
     * @description - Adds a filter to `PropsInfoObj.Filter`.
     * @param {Boolean} [Activate=true] - If true, the filter is activated immediately.
     * @param {...String|Func|Object} Filters - The filters to add. This parameter is variadic.
     * There are four built-in filters which you can include by integer:
     * - 1: Exclude all items that are not own properties of the root object.
     * - 2: Exclude all items that are own properties of the root object.
     * - 3: Exclude all items that have an `Alt` property, i.e. exclude all properties that have
     * multiple owners.
     * - 4: Exclude all items that do not have an `Alt` property, i.e. exclude all properties that
     * have only one owner.
     *
     * In addition to the above, you can pass any of the following:
     * - A string value as a property name to exclude, or a comma-delimited list of property
     * names to exclude.
     * - A `Func`, `BoundFunc` or `Closure`.
     * - An object with a `Call` method.
     * - An object with a `__Call` method.
     *
     * Function objects should accept the `PropsInfoItem` object as its only parameter, and
     * should return a nonzero value to exclude the property. To keep the property, return zero
     * or nothing.
     * @returns {Integer} - If at least one custom filter is added (i.e. a function object or
     * callable object was added), the index that was assignedd to the filter. Indices begin from 5
     * and increment by 1 for each custom filter added. Once an index is used, it will never be used
     * by the `PropsInfo` object again. You can use the index to later delete a filter if needed.
     * Saving the index isn't necessary; you can also delete a filter by passing the function object
     * to `PropsInfo.Prototype.FilterDelete`.
     * The following built-in indices always refer to the same function:
     * - 0: The function which excludes by property name.
     * - 1 through 4: The other built-in filters described above.
     * @throws {ValueError} - If the one of the values passed to `Filters` is invalid.
     */
    FilterAdd(Activate := true, Filters*) {
        if !this.Filter {
            this.DefineProp('Filter', { Value: PropsInfo.FilterGroup() })
        }
        this.DefineProp('FilterAdd', { Call: _FilterAdd })
        this.FilterAdd(Activate, Filters*)

        _FilterAdd(Self, Activate := true, Filters*) {
            result := Self.Filter.Add(Filters*)
            if Activate {
                Self.FilterActivate()
            }
            return result
        }
    }

    /**
     * @description - Adds the currently active filter to the cache.
     * @param {String|Number} Name - The value which will be the key that accesses the filter.
     */
    FilterCache(Name) {
        if !this.__FilterCache {
            this.__FilterCache := Map()
        }
        this.DefineProp('FilterCache', { Call: _FilterCache })
        this.FilterCache(Name)
        _FilterCache(Self, Name) => Self.__FilterCache.Set(Name, { Items: Self.__FilteredItems, Index: Self.__FilteredIndex, FilterGroup: this.Filter })
    }

    /**
     * @description - Clears the filter.
     * @throws {Error} - If the filter is empty.
     */
    FilterClear() {
        if !this.Filter {
            throw Error('The filter is empty.', -1)
        }
        this.Filter.Clear()
        this.Filter.Capacity := 0
        this.Filter.Exclude := ''
    }

    /**
     * @description - Clears the filter cache.
     * @throws {Error} - If the filter cache is empty.
     */
    FilterClearCache() {
        if !this.__FilterCache {
            throw Error('The filter cache is empty.', -1)
        }
        this.__FilterCache.Clear()
        this.__FilterCache.Capacity := 0
    }

    /**
     * @description - Deactivates the currently active filter.
     * @param {String|Number} [CacheName] - If set, the filter is added to the cache with this name prior
     * to being deactivated.
     * @throws {Error} - If the filter is not currently active.
     */
    FilterDeactivate(CacheName?) {
        if !this.__FilterActive {
            throw Error('The filter is not currently active.', -1)
        }
        if IsSet(CacheName) {
            this.FilterCache(CacheName)
        }
        this.__FilterActive := 0
        this.__FilteredItems := ''
        this.__FilteredIndex := ''
        this.__FilterSwitchProps(0)
    }

    /**
     * @description - Deletes an item from the filter.
     * @param {Func|Integer|PropsInfo.Filter|String} Key - One of the following:
     * - The function object.
     * - The index assigned to the `PropsInfo.Filter` object.
     * - The `PropsInfo.Filter` object.
     * - The function object's name.
     * @returns {PropsInfo.Filter} - The filter object that was just deleted.
     * @throws {UnsetItemError} - If `Key` is a function object and the filter does not contain
     * that function.
     * @throws {UnsetItemError} - If `Key` is a string and the filter does not contain a function
     * with that name.
     */
    FilterDelete(Key) {
        return this.Filter.Delete(Key)
    }

    /**
     * @description - Deletes a filter from the cache.
     * @param {String|Integer} Name - The name assigned to the filter.
     * @returns {Map} - The object containing the filter functions that were just deleted.
     * @throws {Error} - If the filter cache is empty.
     */
    FilterDeleteFromCache(Name) {
        if !this.__FilterCache {
            throw Error('The filter cache is empty.', -1)
        }
        r := this.__FilterCache.Get(Name)
        this.__FilterCache.Delete(Name)
        return r
    }

    /**
     * @description - Returns a comma-delimited list of names of properties that were filtered out
     * of the collection.
     * @returns {String}
     */
    FilterGetList() {
        if !this.Filter {
            throw UnsetItemError('No filters have been added.', -1)
        }
        s := ''
        for InfoItem in this.__FilteredItems {
            s .= InfoItem.Name ','
        }
        return SubStr(s, 1, -1)
    }

    /**
     * @description - Removes one or more property names from the exclude list.
     * @param {String} Name - The name to remove or a comma-delimited list of names to remove.
     * @throws {Error} - If the filter is empty.
     */
    FilterRemoveFromExclude(Name) {
        if !this.Filter {
            throw Error('The filter is empty.', -1)
        }
        Filter := this.Filter
        for _name in StrSplit(Name, ',') {
            Filter.Exclude := RegExReplace(Filter.Exclude, ',' _name '(?=,)', '')
        }
    }

    /**
     * @description - Sets the `PropsInfoObj.Filter` property with the filter group.
     * @param {PropsInfo.FilterGroup} FilterGroup - The `PropsInfo.FilterGroup` object.
     * @param {String} [CacheName] - If set, the current filter will be cached. If unset, the
     * current filter is replaced without being cached.
     * @param {Boolean} [Activate := true] - If true, the filter is activated immediately.
     */
    FilterSet(FilterGroup, CacheName?, Activate := true) {
        if IsSet(CacheName) {
            this.FilterCache(CacheName)
        }
        this.DefineProp('Filter', { Value: FilterGroup })
        if Activate {
            this.FilterActivate()
        }
    }

    /**
     * @description - Retrieves a `PropsInfoItem` object.
     * @param {String|Integer} Key - While `PropsInfoObj.StringMode == true`, `Key` must be an
     * integer index value. While `PropsInfoObj.StringMode == false`, `Key` can be either a string
     * property name or an integer index value.
     * @returns {PropsInfoItem}
     * @throws {TypeError} - If `Key` is not a number and `PropsInfoObj.StringMode == true`.
     */
    Get(Key) {
        ; This is overridden
    }

    /**
     * @description - Retrieves the index of a property.
     * @param {String} Name - The name of the property.
     * @returns {Integer} - The index of the property.
     */
    GetIndex(Name) {
        return this.__InfoIndex.Get(Name)
    }

    /**
     * @description - Retrieves a proxy object.
     * @param {String} ProxyType - The type of proxy to create. Valid values are:
     * - 1: `PropsInfo.Proxy_Array`
     * - 2: `PropsInfo.Proxy_Map`
     * @returns {PropsInfo.Proxy_Array|PropsInfo.Proxy_Map}
     * @throws {ValueError} - If `ProxyType` is not 1 or 2.
     */
    GetProxy(ProxyType) {
        switch ProxyType, 0 {
            case '1': return PropsInfo.Proxy_Array(this)
            case '2': return PropsInfo.Proxy_Map(this)
        }
        throw ValueError('The input ``ProxyType`` must be ``1`` or ``2``.', -1
        , IsObject(ProxyType) ? 'Type(ProxyType) == ' Type(ProxyType) : ProxyType)
    }

    /**
     * @description - Iterates the `PropsInfo` object, adding the `PropsInfoItem` objects to
     * a container.
     * @param {*} [Container] - The container to add the filtered `PropsInfoItem` objects to. If set,
     * the object must inherit from either `Map` or `Array`.
     * - If `Container` inherits from `Array`, the `PropsInfoItem` objects are added to the array using
     * `Push`.
     * - If `Container` inherits from `Map`, the `PropsInfoItem` objects are added to the map using
     * `Set`, with the property name as the key. The map's `CaseSense` property must be set to
     * "Off".
     * - If `Container` is unset, `GetFilteredProps` returns a new `PropsInfo` object.
     * @param {Function} [Function] -
     * - If set, a function object that accepts a `PropsInfoItem` object as its only parameter. The
     * function should return a nonzero value to exclude the property. Any currently active filters
     * are ignored.
     * - If unset, `GetFilteredProps` uses the filters that are currently active. The difference
     * between `GetFilteredProps` and either `ToMap` or `ToArray` in this case is that you can
     * supply your own container, or get a new `PropsInfo` object.
     * @returns {PropsInfo|Array|Map} - The container with the filtered `PropsInfoItem` objects.
     * If `Container` is unset, a new `PropsInfo` object is returned.
     * @throws {TypeError} - If `Container` is not an `Array` or `Map`.
     * @throws {Error} - If `Container` is a `Map` and its `CaseSense` property is not set to "Off".
     * @throws {Error} - If the filter is empty.
     */
    GetFilteredProps(Container?, Function?) {
        if IsSet(Container) {
            if Container is Array {
                Set := _Set_Array
                GetCount := () => Container.Length
            } else if Container is Map {
                if Container.CaseSense !== 'Off' {
                    throw Error('CaseSense must be set to "Off".', -1)
                }
                Set := _Set_Map
                GetCount := () => Container.Count
            } else {
                throw TypeError('Unexpected container type.', -1, 'Type(Container) == ' Type(Container))
            }
        } else {
            Container := Map()
            Container.CaseSense := false
            Set := _Set_Map
            GetCount := () => Container.Count
            Flag_MakePropsInfo := true
        }
        Excluded := this.Excluded ','
        InfoItems := this.__InfoItems
        Container.Capacity := InfoItems.Length
        if IsSet(Function)  {
            for InfoItem in InfoItems {
                if Function(InfoItem) {
                    if !InStr(Excluded, ',' InfoItem.Name ',') {
                        Excluded .= InfoItem.Name ','
                    }
                    continue
                }
                Set(InfoItem)
            }
        } else if this.Filter {
            Filter := this.Filter
            if Filter.Count == 1 {
                for FilterIndex, FilterObj in Filter {
                    Fn := FilterObj
                }
                for InfoItem in InfoItems {
                    if Fn(InfoItem) {
                        if !InStr(Excluded, ',' InfoItem.Name ',') {
                            Excluded .= InfoItem.Name ','
                        }
                        continue
                    }
                    Set(InfoItem)
                }
            } else {
                for InfoItem in Infoitems {
                    for FilterIndex, FilterObj in Filter {
                        if FilterObj(InfoItem) {
                            if !InStr(Excluded, ',' InfoItem.Name ',') {
                                Excluded .= InfoItem.Name ','
                            }
                            continue 2
                        }
                    }
                    Set(InfoItem)
                }
            }
        } else {
            throw Error('The filter is empty.', -1)
        }
        Container.Capacity := GetCount()
        return IsSet(Flag_MakePropsInfo) ? PropsInfo(Container, this.__PropsInfoItemBase, Trim(StrReplace(Excluded, ',,', ','), ',')) : Container

        _Set_Array(InfoItem) => Container.Push(InfoItem)
        _Set_Map(InfoItem) => Container.Set(InfoItem.Name, InfoItem)
    }

    /**
     * @description - Checks if a property exists in the `PropsInfo` object.
     */
    Has(Key) {
        return IsNumber(Key) ? this.__InfoItems.Has(Key) : this.__InfoIndex.Has(Key)
    }

    /**
     * @description - Iterates the root object's properties, updating the `PropsInfo` object's
     * internal containers to reflect the current state of the objects. This does not change the
     * items exposed by the currently active filter nor any cached filters. To update a filter,
     * call `PropsInfo.Prototype.FilterActivate` after calling `PropsInfo.Prototype.Delete`,
     * `PropsInfo.Prototype.Refresh`, or `PropsInfo.Prototype.RefreshProp`.
     *
     * - The reason for using `PropsInfo.Prototype.Refresh` instead of calling `GetPropsInfo`
     * would be to preserve any changes that external code has made to the `PropsInfo` object or the
     * `PropsInfoItem` objects. If your code has not made any changes to any of the objects,
     * calling `GetPropsInfo` will perform better than calling `PropsInfo.Prototype.Refresh`.
     *
     * - `PropsInfoObj.FilterActive` and `PropsInfoObj.StringMode` are set to `0` at the start of the
     * procedure, and returned to their original values at the end.
     *
     * - `PropsInfo.Prototype.Refresh` will update the `InfoItem.Alt` array to be consistent with
     * the objects' current state. Any items that are removed are returned when the function ends.
     *
     * - `PropsInfo.Prototype.Refresh` updates the `PropsInfoObj.Excluded` property and the
     * `PropsInfoObj.InheritanceDepth` property.
     *
     * - If an object no longer owns a property by the name, the `PropsInfoItem` object is removed
     * from the collection and added to the returned array.
     *
     * - `InfoItem.Count` is updated for any additions and deletions.
     *
     * - `PropsInfo.Prototype.Refresh` will swap the top-level `PropsInfoItem` object if a new
     * `PropsInfoItem` object is created with a lower `Index` property value than the current top-level
     * item. The original top-level item has the `Alt` property deleted if present, then gets added
     * to the `Alt` property of the new top-level item. This is to ensure consistency that the top-level
     * `PropsInfoItem` object is always associated with either the root object or the object from
     * which the root object inherits the property.
     *
     * @param {Integer|String} [StopAt=GPI_STOP_AT_DEFAULT ?? '-Object'] - If an integer, the number of
     * base objects to traverse up the inheritance chain. If a string, the name of the class to stop at.
     * You can define a global variable `GPI_STOP_AT_DEFAULT` to change the default value. If
     * GPI_STOP_AT_DEFAULT is unset, the default value is '-Object', which directs
     * `PropsInfo.Prototype.Refresh` to include properties owned by objects up to but not including
     * `Object.Prototype`.
     * @see {@link GetBaseObjects} for full details about this parameter.
     * @param {String} [Exclude=''] - A comma-delimited, case-insensitive list of properties to exclude.
     * For example: "Length,Capacity,__Item".
     * @param {Boolean} [IncludeBaseProp=true] - If true, the object's `Base` property is included. If
     * false, `Base` is excluded.
     * @param {VarRef} [OutBaseObjList] - A variable that will receive a reference to the array of
     * base objects that is generated during the function call.
     * @param {Boolean} [ExcludeMethods=false] - If true, callable properties are excluded. Note that
     * properties with a value that is a class object are unaffected by `ExcludeMethods`.
     * @returns {PropsInfoItem[]|String} - If any items are removed from the collection they are
     * added to an array to be returned. Else, returns an empty string.
     */
    Refresh(StopAt := GPI_STOP_AT_DEFAULT ?? '-Object', Exclude := '', IncludeBaseProp := true, &OutBaseObjList?, ExcludeMethods := false) {
        if this.FilterActive {
            OriginalFilterActive := this.FilterActive
            this.FilterActive := 0
        }
        Excluded := ','
        InfoItems := this.__InfoItems
        InfoIndex := this.__InfoIndex
        OriginalStringMode := this.StringMode
        this.StringMode := 0
        Obj := this.Root
        AltMap := Map()
        AltMap.CaseSense := false
        OutBaseObjList := GetBaseObjects(Obj, StopAt)
        this.__PropsInfoItemBase.InheritanceDepth := OutBaseObjList.Length
        OutBaseObjList.InsertAt(1, Obj)
        Exclude := ',' Exclude ','
        ToDelete := ''
        ActivePropsList := this.ToMap()
        Deleted := []
        i := -1
        for b in OutBaseObjList {
            ++i
            for Prop in ObjOwnProps(b) {
                if InStr(Exclude, ',' Prop ',') || (ExcludeMethods && HasMethod(Obj, Prop) && not Obj.%Prop% is Class) {
                    if this.Has(Prop) {
                        ToDelete .= Prop ','
                    }
                    if !InStr(Excluded, ',' Prop ',') {
                        Excluded .= Prop ','
                    }
                    continue
                }
                this.__RefreshProcess(ActivePropsList, AltMap, i, Prop, b)
            }
            if IncludeBaseProp {
                this.__RefreshProcess(ActivePropsList, AltMap, i, 'Base', b)
            }
        }
        for name, InfoItem in ActivePropsList {
            ToDelete .= name ','
        }
        if ToDelete := Trim(ToDelete, ',') {
            if DeletedItems := this.Delete(ToDelete) {
                Deleted.Push(DeletedItems*)
            }
        }
        for Prop, IndexList in AltMap {
            if InfoItem := this.Get(Prop) {
                if IndexList := Trim(IndexList, ',') {
                    if InfoItem.HasOwnProp('Alt') {
                        for s in StrSplit(IndexList, ',') {
                            if s {
                                i := 0
                                Alt := InfoItem.Alt
                                loop Alt.Length {
                                    if Alt[++i].Index = s {
                                        Deleted.Push(Alt.RemoveAt(i))
                                        this.__RefreshIncrementCount(InfoItem, -1)
                                        i--
                                        break
                                    }
                                }
                            }
                        }
                    }
                }
                if InfoItem.HasOwnProp('Alt') && !InfoItem.Alt.Length {
                    InfoItem.DeleteProp('Alt')
                }
            }
        }
        if IsSet(OriginalFilterActive) {
            this.FilterActive := OriginalFilterActive
        }
        this.StringMode := OriginalStringMode
        this.Excluded := Trim(Excluded, ',')
        return Deleted.Length ? Deleted : ''
    }

    /**
     * @description - For each name listed in `Names`, the root object and its base objects are
     * iterated. If an object owns a property with a given name, and if the current collection does not
     * have an associated `PropsInfoItem` object for the property, a `PropsInfoItem` object is
     * created and added to the collection. This does not change the items exposed by the currently
     * active filter nor any cached filters. To update a filter, call
     * `PropsInfo.Prototype.FilterActivate` after calling `PropsInfo.Prototype.Delete`,
     * `PropsInfo.Prototype.Refresh`, or `PropsInfo.Prototype.RefreshProp`.
     *
     * - `PropsInfoObj.FilterActive` and `PropsInfoObj.StringMode` are set to `0` at the start of the
     * procedure, and returned to their original values at the end.
     *
     * - `PropsInfo.Prototype.RefreshProp` will update the `InfoItem.Alt` array to be consistent with
     * the objects' current state. Any items that are removed are returned when the function ends.
     *
     * - `PropsInfo.Prototype.RefreshProp` updates the `PropsInfoObj.Excluded` property and the
     * `PropsInfoObj.InheritanceDepth` property.
     *
     * - If an object no longer owns a property by the name, the `PropsInfoItem` object is removed
     * from the collection and added to the returned array.
     *
     * - `InfoItem.Count` is updated for any additions and deletions.
     *
     * - `PropsInfo.Prototype.RefreshProp` will swap the top-level `PropsInfoItem` object if a new
     * `PropsInfoItem` object is created with a lower `Index` property value than the current top-level
     * item. The original top-level item has the `Alt` property deleted if present, then gets added
     * to the `Alt` property of the new top-level item. This is to ensure consistency that the top-level
     * `PropsInfoItem` object is always associated with either the root object or the object from
     * which the root object inherits the property.
     *
     * @param {String} Names - A comma-delimited list of property names to update. For example,
     * "__Class,Length".
     * @param {Integer|String} [StopAt=GPI_STOP_AT_DEFAULT ?? '-Object'] - If an integer, the number of
     * base objects to traverse up the inheritance chain. If a string, the name of the class to stop at.
     * You can define a global variable `GPI_STOP_AT_DEFAULT` to change the default value. If
     * GPI_STOP_AT_DEFAULT is unset, the default value is '-Object', which directs
     * `PropsInfo.Prototype.Add` to include properties owned by objects up to but not including
     * `Object.Prototype`.
     * @see {@link GetBaseObjects} for full details about this parameter.
     * @param {VarRef} [OutBaseObjList] - A variable that will receive a reference to the array of
     * base objects that is generated during the function call.
     * @returns {PropsInfoItem[]|String} - If any items are removed from the collection they are
     * added to an array to be returned. Else, returns an empty string.
     */
    RefreshProp(Names, StopAt := GPI_STOP_AT_DEFAULT ?? '-Object', &OutBaseObjList?) {
        if this.FilterActive {
            OriginalFilterActive := this.FilterActive
            this.FilterActive := 0
        }
        OriginalStringMode := this.StringMode
        this.StringMode := 0
        OutBaseObjList := GetBaseObjects(this.Root, StopAt)
        this.__PropsInfoItemBase.InheritanceDepth := OutBaseObjList.Length
        OutBaseObjList.InsertAt(1, this.Root)
        Names := StrSplit(Trim(Names, ','), ',', '`s`t')
        Deleted := []
        Excluded := ',' this.Excluded ','
        for Prop in Names {
            i := -1
            if InStr(Excluded, ',' Prop ',') {
                Excluded := StrReplace(Excluded, ',' Prop, '')
            }
            if this.Has(prop) {
                InfoItem := this.Get(Prop)
                IndexList := ',' InfoItem.Index ','
                if InfoItem.HasOwnProp('Alt') {
                    for AltInfoItem in InfoItem.Alt {
                        IndexList .= AltInfoItem.Index ','
                    }
                }
                for b in OutBaseObjList {
                    ++i
                    if b.HasOwnProp(Prop) {
                        if InStr(IndexList, ',' i ',') {
                            if InfoItem.Index = i {
                                InfoItem.Refresh()
                            } else {
                                for AltInfoItem in InfoItem.Alt {
                                    if AltInfoItem.Index = i {
                                        AltInfoItem.Refresh()
                                        break
                                    }
                                }
                            }
                        } else {
                            if Prop = 'Base' {
                                if i < InfoItem.Index {
                                    this.__RefreshSwap(i, InfoItem, b)
                                } else {
                                    this.__RefreshBaseProp(i, b)
                                }
                            } else {
                                if i < InfoItem.Index {
                                    this.__RefreshSwap(i, InfoItem, b)
                                } else {
                                    this.__RefreshAdd(i, Prop, b)
                                }
                            }
                        }
                    } else {
                        if InStr(IndexList, ',' i ',') {
                            if InfoItem.Index = i {
                                if InfoItem.HasOwnProp('Alt') {
                                    if InfoItem.Alt.Length > 1 {
                                        lowest := 9223372036854775807
                                        for AltInfoItem in InfoItem.Alt {
                                            if AltInfoItem.Index < lowest {
                                                lowest := AltInfoItem.Index
                                                LowestIndex := A_Index
                                            }
                                        }
                                        AltInfoItem := InfoItem.Alt.RemoveAt(LowestIndex)
                                        AltInfoItem.DefineProp('Alt', { Value: InfoItem.Alt })
                                    } else {
                                        AltInfoItem := InfoItem.Alt[1]
                                        InfoItem.DeleteProp('Alt')
                                    }
                                    this.__InfoItems[this.__InfoIndex.Get(Prop)] := AltInfoItem
                                    Deleted.Push(InfoItem)
                                    this.__RefreshIncrementCount(InfoItem, -1)
                                    AltInfoItem.Refresh()
                                } else {
                                    Deleted.Push(this.__InfoItems.RemoveAt(this.__InfoIndex.Get(Prop)))
                                    this.__RefreshIncrementCount(InfoItem, -1)
                                }
                            } else {
                                for AltInfoItem in InfoItem.Alt {
                                    if AltInfoItem.Index = i {
                                        Deleted.Push(InfoItem.Alt.RemoveAt(A_Index))
                                        this.__RefreshIncrementCount(InfoItem, -1)
                                        break
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                if Prop = 'Base' {
                    for b in OutBaseObjList {
                        this.__RefreshBaseProp(++i, b)
                    }
                } else {
                    for b in OutBaseObjList {
                        ++i
                        if b.HasOwnProp(Prop) {
                            this.__RefreshAdd(i, Prop, b)
                        }
                    }
                }
            }
        }
        if IsSet(OriginalFilterActive) {
            this.FilterActive := OriginalFilterActive
        }
        this.StringMode := OriginalStringMode
        this.Excluded := Trim(Excluded, ',')

        return Deleted.Length ? Deleted : ''
    }

    /**
     * @description - Iterates the `PropsInfo` object, adding the `PropsInfoItem` objects to an array,
     * or adding the property names to an array.
     * @param {Boolean} [NamesOnly=false] - If true, the property names are added to the array. If
     * false, the `PropsInfoItem` objects are added to the array.
     * @returns {Array} - The array of property names or `PropsInfoItem` objects.
     */
    ToArray(NamesOnly := false) {
        Result := []
        Result.Capacity := this.__InfoItems.Length
        if NamesOnly {
            for Item in this.__InfoItems {
                Result.Push(Item.Name)
            }
        } else {
            for Item in this.__InfoItems {
                Result.Push(Item)
            }
        }
        return Result
    }

    /**
     * @description - Iterates the `PropsInfo` object, adding the `PropsInfoItem` objects to a map.
     * The keys are the property names.
     * @returns {Map} - The map of property names and `PropsInfoItem` objects.
     */
    ToMap() {
        Result := Map()
        Result.Capacity := this.__InfoItems.Length
        for InfoItem in this.__InfoItems {
            Result.Set(InfoItem.Name, InfoItem)
        }
        return Result
    }

    /**
     * @memberof PropsInfo
     * @instance
     * @readonly
     */
    Capacity => this.__InfoIndex.Capacity
    /**
     * @memberof PropsInfo
     * @instance
     * @readonly
     */
    CaseSense => this.__InfoIndex.CaseSense
    /**
     * @memberof PropsInfo
     * @instance
     * @readonly
     */
    Count => this.__InfoIndex.Count
    /**
     * @memberof PropsInfo
     * @instance
     * @readonly
     */
    Default => this.__InfoIndex.Default
    /**
     * @memberof PropsInfo
     * @instance
     * @readonly
     */
    InheritanceDepth => this.__PropsInfoItemBase.InheritanceDepth
    /**
     * @memberof PropsInfo
     * @instance
     * @readonly
     */
    Length => this.__InfoItems.Length
    /**
     * @memberof PropsInfo
     * @instance
     * @readonly
     */
    Root => this.__PropsInfoItemBase.Root

    /**
     * Set to a nonzero value to activate the current filter. Set to a falsy value to deactivate.
     * While a filter is active, the values retured by the `PropsInfo` object's methods and properties
     * will be filtered. See the parameter hint above `PropsInfo.Prototype.FilterActivate` for
     * additional details.
     * @memberof PropsInfo
     * @instance
     */
    FilterActive {
        Get => this.__FilterActive
        Set {
            if Value {
                this.FilterActivate()
            } else {
                this.FilterDeactivate()
            }
        }
    }

    /**
     * Set to a nonzero value to activate string mode. Set to a falsy value to deactivate.
     * While string mode is active, the `PropsInfo` object emulates the behavior of an array of
     * strings. The following properties and methods are influenced by string mode:
     * __Enum, Get, __Item
     * By extension, the proxies are also affected.
     * @memberof PropsInfo
     * @instance
     */
    StringMode {
        Get => this.__StringMode
        Set {
            if this.__FilterActive {
                if Value {
                    this.DefineProp('__StringMode', { Value: 1 })
                    this.DefineProp('Get', { Call: this.__FilteredGet_StringMode })
                } else {
                    this.DefineProp('__StringMode', { Value: 0 })
                    this.DefineProp('Get', { Call: this.__FilteredGet_Bitypic })
                }
            } else {
                if Value {
                    this.DefineProp('__StringMode', { Value: 1 })
                    this.DefineProp('Get', { Call: this.__ItemGet_StringMode })
                } else {
                    this.DefineProp('__StringMode', { Value: 0 })
                    this.DefineProp('Get', { Call: this.__ItemGet_Bitypic })
                }
            }
        }
    }

    /**
     * @description - `__Enum` is influenced by both string mode and any active filters. It can
     * be called in either 1-param mode or 2-param mode.
     */
    __Enum(VarCount) {
        i := 0
        if this.__FilterActive {
            Index := this.__FilteredIndex
            FilteredItems := this.__FilteredItems
            return this.__StringMode ? _Filtered_Enum_StringMode_%VarCount% : _Filtered_Enum_%VarCount%
        } else {
            InfoItems := this.__InfoItems
            return this.__StringMode ? _Enum_StringMode_%VarCount% : _Enum_%VarCount%
        }
        _Enum_1(&InfoItem) {
            if ++i > InfoItems.Length {
                return 0
            }
            InfoItem := InfoItems[i]
            return 1
        }
        _Enum_2(&Prop, &InfoItem) {
            if ++i > InfoItems.Length {
                return 0
            }
            InfoItem := InfoItems[i]
            Prop := InfoItem.Name
            return 1
        }
        _Enum_StringMode_1(&Prop) {
            if ++i > InfoItems.Length {
                return 0
            }
            Prop := InfoItems[i].Name
            return 1
        }
        _Enum_StringMode_2(&Index, &Prop) {
            if ++i > InfoItems.Length {
                return 0
            }
            Index := i
            Prop := InfoItems[i].Name
            return 1
        }
        _Filtered_Enum_1(&InfoItem) {
            if ++i > Index.Length {
                return 0
            }
            InfoItem := FilteredItems[Index[i]]
            return 1
        }
        _Filtered_Enum_2(&Prop, &InfoItem) {
            if ++i > Index.Length {
                return 0
            }
            InfoItem := FilteredItems[Index[i]]
            Prop := InfoItem.Name
            return 1
        }
        _Filtered_Enum_StringMode_1(&Prop) {
            if ++i > Index.Length {
                return 0
            }
            Prop := FilteredItems[Index[i]].Name
            return 1
        }
        _Filtered_Enum_StringMode_2(&Index, &Prop) {
            if ++i > Index.Length {
                return 0
            }
            Index := i
            Prop := FilteredItems[Index[i]].Name
            return 1
        }
    }

    /**
     * @description - Allows access to the `PropsInfoItem` objects using `Obj[Key]` syntax. Forwards
     * the `Key` to the `Get` method. {@link PropsInfo#Get}.
     */
    __Item[Key] => this.Get(Key)

    __ItemGet_StringMode(Index) {
        if !IsNumber(Index) {
            this.__ThrowTypeError()
        }
        return this.__InfoItems[Index].Name
    }

    __ItemGet_Bitypic(Key) {
        return this.__InfoItems[IsNumber(Key) ? Key : this.__InfoIndex.Get(Key)]
    }

    __FilteredGet_StringMode(Index) {
        if !IsNumber(Index) {
            this.__ThrowTypeError()
        }
        return this.__InfoItems[this.__FilteredIndex[Index]].Name
    }

    __FilteredGet_Bitypic(Key) {
        if IsNumber(Key) {
            return this.__InfoItems[this.__FilteredIndex[Key]]
        } else {
            return this.__FilteredItems.Get(this.__InfoIndex.Get(Key))
        }
    }

    __FilteredHas(Key) {
        if IsNumber(Key) {
            return this.__FilteredItems.Has(this.__InfoIndex.Get(this.__InfoItems[Key].Name))
        } else {
            return this.__FilteredItems.Has(this.__InfoIndex.Get(Key))
        }
    }

    __FilteredToArray(NamesOnly := false) {
        Result := []
        Result.Capacity := this.__FilteredItems.Count
        if NamesOnly {
            for i, InfoItem in this.__FilteredItems {
                Result.Push(InfoItem.Name)
            }
        } else {
            for i, InfoItem in this.__FilteredItems {
                Result.Push(InfoItem)
            }
        }
        return Result
    }

    __FilteredToMap(NamesOnly := false) {
        Result := Map()
        Result.Capacity := this.__FilteredItems.Count
        for i, InfoItem in this.__FilteredItems {
            Result.Set(InfoItem.Name, InfoItem)
        }
        return Result
    }

    __FilterSwitchProps(Value) {
        Proto := PropsInfo.Prototype
        if Value {
            for Name in this.__OnFilterProperties {
                this.DefineProp(Name, Proto.GetOwnPropDesc('__Filtered' Name))
            }
            this.DefineProp('Get', Proto.GetOwnPropDesc(this.__StringMode ? '__FilteredGet_StringMode' : '__FilteredGet_Bitypic'))
        } else {
            for Name in this.__OnFilterProperties {
                this.DefineProp(Name, Proto.GetOwnPropDesc(Name))
            }
            this.DefineProp('Get', Proto.GetOwnPropDesc(this.__StringMode ? '__ItemGet_StringMode' : '__ItemGet_Bitypic'))
        }
    }

    __RefreshAdd(Index, Prop, Obj) {
        if this.Has(Prop) {
            b := InfoItem := this.Get(Prop)
            while !b.HasOwnProp('Name') {
                b := b.Base
            }
            ObjSetBase(Item := ObjGetOwnPropDesc(Obj, InfoItem.Name), b)
            Item.Index := Index
            InfoItem.__SetAlt(Item)
            b.Count++
        } else {
            ObjSetBase(ItemBase := { Name: Prop, Count: 1 }, this.__PropsInfoItemBase)
            ObjSetBase(Item := ObjGetOwnPropDesc(Obj, Prop), ItemBase)
            Item.Index := Index
            this.__InfoItems.Push(Item)
            this.__InfoIndex.Set(Prop, this.__InfoItems.Length)
        }
    }

    __RefreshBaseProp(Index, Obj) {
        if this.Has('Base') {
            b := InfoItem := this.Get('Base')
            while !b.HasOwnProp('Name') {
                b := b.Base
            }
            ObjSetBase(Item := { Value: Obj.Base, Index: Index }, b)
            InfoItem.__SetAlt(Item)
            b.Count++
        } else {
            ObjSetBase(ItemBase := { Name: 'Base', Count: 1 }, this.__PropsInfoItemBase)
            ObjSetBase(InfoItem := { Value: Obj.Base, Index: Index }, ItemBase)
            this.__InfoItems.Push(InfoItem)
            this.__InfoIndex.Set('Base', this.__InfoItems.Length)
        }
    }

    __RefreshIncrementCount(InfoItem, Count) {
        loop this.InheritanceDepth {
            if InfoItem.HasOwnProp('Count') {
                InfoItem.Count += Count
                return
            } else {
                InfoItem := InfoItem.Base
            }
        }
        throw Error('Failed to increment the count.', -1, '``InfoItem.Name == ' InfoItem.Name)
    }

    __RefreshProcess(ActivePropsList, AltMap, Index, Prop, Obj) {
        if ActivePropslist && ActivePropsList.Has(Prop) {
            ActivePropsList.Delete(Prop)
        }
        if this.Has(Prop) {
            InfoItem := this.Get(Prop)
            if !AltMap.Has(InfoItem.Name) {
                indexList := ',' InfoItem.Index ','
                if InfoItem.HasOwnProp('Alt') {
                    for AltInfoItem in InfoItem.Alt {
                        indexList .= AltInfoItem.Index ','
                    }
                }
                AltMap.Set(InfoItem.Name, indexList)
            }
            if InStr(AltMap.Get(InfoItem.Name), ',' Index ',') {
                AltMap.Set(InfoItem.Name, StrReplace(AltMap.Get(InfoItem.Name), ',' Index, ''))
                InfoItem.Refresh()
            } else {
                if Index < InfoItem.Index {
                    this.__RefreshSwap(Index, InfoItem, Obj)
                } else {
                    if Prop == 'Base' {
                        this.__RefreshBaseProp(Index, Obj)
                    } else {
                        this.__RefreshAdd(Index, Prop, Obj)
                    }
                }
            }
        } else {
            if Prop == 'Base' {
                this.__RefreshBaseProp(Index, Obj)
            } else {
                this.__RefreshAdd(Index, Prop, Obj)
            }
        }
    }

    __RefreshSwap(Index, InfoItem, Obj) {
        if InfoItem.Name = 'Base' {
            if Type(Obj) == 'Prototype' && Obj.__Class == 'Any' {
                return
            }
            Item := { Value: Obj.Base, Index: Index }
        } else {
            Item := ObjGetOwnPropDesc(Obj, InfoItem.Name)
            Item.Index := InfoItem.Index
        }
        InfoItem.Index := Index
        switch InfoItem.KindIndex {
            case 1: _SwapProps(['Call'], ['Get', 'Set', 'Value'])
            case 2: _SwapProps(['Get'], ['Call', 'Set', 'Value'])
            case 3: _SwapProps(['Get', 'Set'], ['Call', 'Value'])
            case 4: _SwapProps(['Set'], ['Call', 'Get', 'Value'])
            case 5: _SwapProps(['Value'], ['Call', 'Get', 'Set'])
        }
        b := InfoItem.Base
        while !b.HasOwnProp('Name') {
            b := b.Base
        }
        ObjSetBase(Item, b)
        b.Count++
        InfoItem.__SetAlt(Item)
        InfoItem.__DefineKindIndex()

        _SwapProps(PrimaryProps, AlternateProps) {
            for Prop in PrimaryProps {
                if Item.HasOwnProp(Prop) {
                    temp := InfoItem.%Prop%
                    InfoItem.DefineProp(Prop, { Value: Item.%Prop% })
                    Item.DefineProp(Prop, { Value: temp })
                } else {
                    Item.DefineProp(Prop, { Value: InfoItem.%Prop% })
                    InfoItem.DeleteProp(Prop)
                }
            }
            for Prop in AlternateProps {
                if Item.HasOwnProp(Prop) {
                    InfoItem.DefineProp(Prop, { Value: Item.%Prop% })
                    Item.DeleteProp(Prop)
                }
            }
        }
    }

    __ThrowTypeError() {
        ; To aid in debugging; if `StringMode == true`, then the object is supposed to behave
        ; like an array of strings, and so accessing an item by name is invalid and represents
        ; an error in the code.
        throw TypeError('Invalid input. While the ``PropsInfo`` object is in string mode,'
        ' items can only be accessed using numeric indices.', -2)
    }

    __FilteredCapacity => this.__FilteredItems.Capacity
    __FilteredCount => this.__FilteredItems.Count
    __FilteredLength => this.__FilteredItems.Count

    /**
     * `PropsInfo.Filter` constructs the filter objects when a filter is added using
     * `PropsInfo.Prototype.FilterAdd`. Filter objects have four properties:
     * - Index: The object's index which can be used to access or delete the object from the filter.
     * - Function: The function object.
     * - Call: The `Call` method which redirects the input parameter to the function and returns
     * the return value.
     * - Name: Returns the function's built-in name.
     * @classdesc
     */
    class Filter {
        __New(Function, Index) {
            this.DefineProp('Call', { Call: _Filter })
            this.Function := Function
            this.Index := Index

            _Filter(Self, Item) {
                Function := this.Function
                return Function(Item)
            }
        }
        Name => this.Function.Name
    }

    class FilterGroup extends Map {
        __New(Filters*) {
            this.Exclude := ''
            this.__Index := 5
            if Filters.Length {
                this.Add(Filters*)
            }
        }

        /**
         * @see {@link PropsInfo#FilterAdd}
         */
        Add(Filters*) {
            for filter in Filters {
                if IsObject(filter) {
                    if filter is Func || HasMethod(filter, 'Call') || HasMethod(filter, '__Call') {
                        if !IsSet(Start) {
                            Start := this.__Index
                        }
                        this.Set(this.__Index, PropsInfo.Filter(filter, this.__Index++))
                    } else {
                        throw ValueError('A value passed to the ``Filters`` parameter is invalid.', -1
                        , 'Type(Value): ' Type(filter))
                    }
                } else {
                    switch filter, 0 {
                        case '1', '2', '3', '4':
                            this.Set(filter, PropsInfo.Filter(_filter_%filter%, filter))
                        default:
                            if SubStr(this.Exclude, -1, 1) == ',' {
                                this.Exclude .= filter
                            } else {
                                this.Exclude .= ',' filter
                            }
                            Flag_Exclude := true
                    }
                }
            }
            if IsSet(Flag_Exclude) {
                ; By ensuring every name has a comma on both sides, we can check the names by
                ; using `InStr(Filter.Exclude, ',' Prop ',')` which should perform better than RegExMatch.
                this.Exclude .= ','
                this.Set(0, PropsInfo.Filter(_Exclude, 0))
            }

            ; If a custom filter is added, return the start index so the caller function can keep track.
            return Start ?? ''

            _Exclude(InfoItem) {
                return InStr(this.Exclude, ',' InfoItem.Name ',')
            }
            _Filter_1(InfoItem) => InfoItem.Index
            _Filter_2(InfoItem) => !InfoItem.Index
            _Filter_3(InfoItem) => InfoItem.HasOwnProp('Alt')
            _Filter_4(InfoItem) => !InfoItem.HasOwnProp('Alt')
        }

        /**
         * @see {@link PropsInfo#FilterDelete}
         */
        Delete(Key) {
            local r
            if Key is Func {
                ptr := ObjPtr(Key)
                for Index, FilterObj in this {
                    if ObjPtr(FilterObj.Function) == ptr {
                        r := FilterObj
                        break
                    }
                }
                if IsSet(r) {
                    this.__MapDelete(r.Index)
                } else {
                    throw UnsetItemError('The function passed to ``Key`` is not in the filter.', -1)
                }
            } else if IsObject(Key) {
                r := this.Get(Key.Index)
                this.__MapDelete(Key.Index)
            } else if IsNumber(Key) {
                r := this.Get(Key)
                this.__MapDelete(Key)
            } else {
                for Fn in this {
                    if Fn.Name == Key {
                        r := Fn
                        break
                    }
                }
                if IsSet(r) {
                    this.__MapDelete(r.Index)
                } else {
                    throw UnsetItemError('The filter does not contain a function with that name.', -2, Key)
                }
            }
            return r
        }

        /**
         * @see {@link PropsInfo#FilterRemoveFromExclude}
         */
        RemoveFromExclude(Name) {
            for _name in StrSplit(Name, ',') {
                this.Exclude := RegExReplace(this.Exclude, ',' _name '(?=,)', '')
            }
        }

        static __New() {
            this.DeleteProp('__New')
            this.Prototype.DefineProp('__MapDelete', Map.Prototype.GetOwnPropDesc('Delete'))
        }
    }

    /**
     * `PropsInfo.Proxy_Array` constructs a proxy that can be passed to an external function as an
     * iterable object. Use `PropsInfo.Proxy_Array` when an external function expects an iterable Array
     * object. Using a proxy is slightly more performant than calling `PropsInfo.Prototype.ToArray` in
     * cases where the object will only be iterated once.
     * The function should not try to set or change the items in the collection. If this is necessary,
     * use `PropsInfo.Prototype.ToArray`.
     * @classdesc
     */
    class Proxy_Array extends Array {
        static __New() {
            if this.Prototype.__Class == 'PropsInfo.Proxy_Array' {
                this.Prototype.DefineProp('__Class', { Value: 'Array' })
            }
        }
        __New(Client) {
            this.DefineProp('Client', { Value: Client })
        }
        Get(Index) => this.Client.Get(Index)
        Has(Index) => this.Client.__InfoItems.Has(Index)
        __Enum(VarCount) => this.Client.__Enum(VarCount)
        Capacity {
            Get => this.Client.__InfoItems.Capacity
            Set => this.Client.__InfoItems.Capacity := Value
        }
        Default {
            Get => this.Client.__InfoItems.Default
            Set => this.Client.__InfoItems.Default := Value
        }
        Length {
            Get => this.Client.__InfoItems.Length
            Set => this.Client.__InfoItems.Length := Value
        }
        __Item[Index] {
            Get => this.Client.__Item[Index]
            ; `PropsInfo` is not compatible with addint new items to the collection.
            ; Set => this.Client.__Item[Index] := Value
        }
        __Get(Name, Params) {
            if Params.Length {
                return this.Client.%Name%[Params*]
            } else {
                return this.Client.%Name%
            }
        }
        __Set(Name, Params, Value) {
            if Params.Length {
                return this.Client.%Name%[Params*] := Value
            } else {
                return this.Client.%Name% := Value
            }
        }
        __Call(Name, Params) {
            if Params.Length {
                return this.Client.%Name%(Params*)
            } else {
                return this.Client.%Name%()
            }
        }
    }

    /**
     * `PropsInfo.Proxy_Map` constructs a proxy that can be passed to an external function as an
     * iterable object. Use `PropsInfo.Proxy_Map` when an external function expects an iterable Map
     * object. Using a proxy is slightly more performant than calling `PropsInfo.Prototype.ToMap` in
     * cases where the object will only be iterated once.
     * The function should not try to set or change the items in the collection. If this is necessary,
     * use `PropsInfo.Prototype.ToMap`.
     * @classdesc
     */
    class Proxy_Map extends Map {
        static __New() {
            if this.Prototype.__Class == 'PropsInfo.Proxy_Map' {
                this.Prototype.DefineProp('__Class', { Value: 'Map' })
            }
        }
        __New(Client) {
            this.DefineProp('Client', { Value: Client })
        }
        Get(Key) => this.Client.Get(Key)
        Has(Key) => this.Client.__InfoIndex.Has(Key)
        __Enum(VarCount) => this.Client.__Enum(VarCount)
        Capacity {
            Get => this.Client.__InfoIndex.Capacity
            Set => this.Client.___InfoIndex.Capacity := Value
        }
        CaseSense => this.Client.__InfoIndex.CaseSense
        Count => this.Client.__InfoIndex.Count
        Default {
            Get => this.Client.__InfoIndex.Default
            Set => this.Client.__InfoIndex.Default := Value
        }
        __Item[Key] {
            Get => this.Client.__Item[Key]
            ; `PropsInfo` is not compatible with addint new items to the collection.
            ; Set => this.Client.__Item[Key] := Value
        }
        __Get(Name, Params) {
            if Params.Length {
                return this.Client.%Name%[Params*]
            } else {
                return this.Client.%Name%
            }
        }
        __Set(Name, Params, Value) {
            if Params.Length {
                return this.Client.%Name%[Params*] := Value
            } else {
                return this.Client.%Name% := Value
            }
        }
        __Call(Name, Params) {
            if Params.Length {
                return this.Client.%Name%(Params*)
            } else {
                return this.Client.%Name%()
            }
        }
    }
}

/**
 * @classdesc - For each base object in the input object's inheritance chain (up to the stopping
 * point), the base object's own properties are iterated, generating a `PropsInfoItem` object for
 * each property (unless the property is excluded).
 */
class PropsInfoItem {
    static __New() {
        if this.Prototype.__Class == 'PropsInfoItem' {
            this.Prototype.__KindNames := ['Call', 'Get', 'Get_Set', 'Set', 'Value']
        }
    }

    /**
     * @description - Each time `GetPropsInfo` is called, a new `PropsInfoItem` is created.
     * The `PropsInfoItem` object is used as the base object for all further `PropsInfoItem`
     * instances generated within that `GetPropsInfo` function call (and only that function call),
     * allowing properties to be defined once on the base and shared by the rest.
     * `PropsInfoItem.Prototype.__New` is not intended to be called directly.
     * @param {Object} Root - The object that was passed to `GetPropsInfo`.
     * @param {Integer}InheritanceDepth - The number of base objects traversed during the `GetPropsInfo`
     * call.
     * @returns {PropsInfoItem} - The `PropsInfoItem` instance.
     * @class
     */
    __New(Root, InheritanceDepth) {
        this.Root := Root
        this.InheritanceDepth := InheritanceDepth
    }

    /**
     * @description - Returns the function object, optionally binding an object to the hidden `this`
     * parameter. See {@link https://www.autohotkey.com/docs/v2/Objects.htm#Custom_Classes_method}
     * for information about the hidden `this`.
     * @param {VarRef} [OutSet] - A variable that will receive the `Set` function if this object
     * has both `Get` and `Set`. If this object only has a `Set` property, the `Set` function object
     * is returned as the return value and `OutSet` remains unset.
     * @param {Integer} Flag_Bind - One of the following values:
     * - 0: The function objects are returned as-is, with the hidden `this` parameter still exposed.
     * - 1: The object that was passed to `GetPropsInfo` is bound to the function object(s).
     * - 2: The owner of the property that produced this `PropsInfoItem` object is bound to the
     * function object(s).
     * @returns {Func|BoundFunc} - The function object.
     * @throws {ValueError} - If `Flag_Bind` is not 0, 1, or 2.
     */
    GetFunc(&OutSet?, Flag_Bind := 0) {
        switch Flag_Bind, 0 {
            case '0':
                switch this.KindIndex {
                    case 1: return this.Call
                    case 2: return this.Get
                    case 3:
                        OutSet := this.Set
                        return this.Get
                    case 4: return this.Set
                    case 5: return ''
                }
            case '1': return _Proc(this.Root)
            case '2': return _Proc(this.Owner)
            default: throw ValueError('Invalid value passed to the ``Flag_Bind`` parameter.', -1
            , IsObject(Flag_Bind) ? 'Type(Flag_Bind) == ' Type(Flag_Bind) : Flag_Bind)
        }

        _Proc(Obj) {
            switch this.KindIndex {
                case 1: return this.Call.Bind(Obj)
                case 2: return this.Get.Bind(Obj)
                case 3:
                    OutSet := this.Set.Bind(Obj)
                    return this.Get.Bind(Obj)
                case 4: return this.Set.Bind(Obj)
                case 5: return ''
            }
        }
    }

    /**
     * @description - `PropsInfoItem.Prototye.GetOwner` travels up the root object's inheritance chain
     * for `InfoItem.Index` objects, and if that object owns a property named `InfoItem.Name`, the
     * object is returned. If it does not own a property with that name,`PropsInfoItem.Prototype.GetOwner`
     * returns `0`.
     * The `InfoItem.Index` value represents the position in the inheritance chain of the object
     * that produced this `PropsInfoItem` object, beginning with the root object passed to
     * `GetPropsInfo`. Unless something has changed, the object at `InfoItem.Index` will be the
     * original owner of the property `InfoItem.Name`
     *
     * This example depicts a scenario in which the value returned by `PropsInfoItem.Prototype.GetOwner`
     * is not the original owner of the property that produced the `PropsInfoItem` object.
     * @example
     *  class a {
     *      __SomeProp := 0
     *      SomeProp => this.__SomeProp
     *  }
     *  class b extends a {
     *
     *  }
     *  class c {
     *      __SomeOtherProp := 1
     *      SomeProp => this.__SomeOtherProp
     *  }
     *  Obj := b()
     *  PropsInfoObj := GetPropsInfo(Obj)
     *  InfoItem := PropsInfoObj.Get('SomeProp')
     *  OriginalOwner := InfoItem.GetOwner()
     *  Obj.Base.Base := c.Prototype
     *  NewOwner := InfoItem.GetOwner()
     *  MsgBox(ObjPtr(OriginalOwner) == ObjPtr(NewOwner)) ; 0
     * @
     *
     * @returns {*} - If the object owns the property, the object. Else, returns 0.
     */
    GetOwner() {
        b := this.Root
        loop this.Index {
            b := b.Base
        }
        if this.Name = 'Base' || b.HasOwnProp(this.Name) {
            return b
        }
        return 0
    }

    /**
     * @description - If this is associated with a value property, provides the value that the property
     * had at the time this `PropsInfoItem` object was created. If this is associated with a dynamic
     * property with a `Get` accessor, attempts to access and provide the value.
     * @param {VarRef} OutValue - Because `GetValue` is expected to sometimes fail, the property's
     * value is set to the `OutValue` variable, and a status code is returned by the function.
     * @param {Boolean} [FromOwner=false] - When true, the object that produced this `PropsInfoItem`
     * object is passed as the first parameter to the `Get` accessor. When false, the root object
     * (the object passed to the `GetPropsInfo` call) is passed as the first parameter to the `Get`
     * accessor.
     * @returns {Integer} - One of these status codes:
     * - An empty string: The value was successfully accessed and `OutValue` is the value.
     * - 1: This `PropsInfoItem` object does not have a `Get` or `Value` property and the `OutValue`
     * variable remains unset.
     * - 2: An error occurred while calling the `Get` function, and `OutValue` is the error object.
     */
    GetValue(&OutValue, FromOwner := false) {
        switch this.KindIndex {
            case 1, 4: return 1 ; Call, Set
            case 2, 3:
                try {
                    if FromOwner {
                        OutValue := (Get := this.Get)(this.Owner)
                    } else {
                        OutValue := (Get := this.Get)(this.Root)
                    }
                } catch Error as err {
                    OutValue := err
                    return 2
                }
            case 5:
                OutValue := this.Value
        }
    }

    /**
     * @description - Calls `PropsInfo.Prototype.GetOwner` to retrieve the owner of the property that
     * produced this `PropsInfoItem` object, then calls `Object.Prototype.GetOwnPropDesc` and updates
     * this `PropsInfoItem` object according to the return value, replacing or removing the existing
     * properties as needed.
     *
     * If the property is "Base", calls `this.DefineProp('Value', { Value: Owner })` and returns `5`.
     * @returns {Integer} - The kind index, which indicates the kind of property. They are:
     * - 1: Callable property
     * - 2: Dynamic property with only a getter
     * - 3: Dynamic property with both a getter and setter
     * - 4: Dynamic property with only a setter
     * - 5: Value property
     *
     * If the object returned by `PropsInfoItem.Prototype.GetOwner` no longer owns a property by
     * the name `InfoItem.Name`, then `PropsInfoItem.Prototype.Refresh` returns 0. You can call
     * `PropsInfo.Prototype.RefreshProp` to adjust the collection to reflect the objects' current
     * state.
     */
    Refresh() {
        if !(Owner := this.Owner) {
            return 0
        }
        if this.Name = 'Base' {
            this.DefineProp('Value', { Value: Owner })
            return 5
        }
        desc := Owner.GetOwnPropDesc(this.Name)
        n := 0
        KindIndex := this.KindIndex
        for Prop, Val in desc.OwnProps() {
            if this.HasOwnProp(Prop) {
                n++
            }
            this.DefineProp(Prop, { Value: Val })
        }
        switch KindIndex {
            case 1,2,4,5:
                ; The type of property changed
                if !n {
                    this.DeleteProp(this.Type)
                }
            case 3:
                ; One of the accessors no longer exists
                if n == 1 {
                    if desc.HasOwnProp('Get') {
                        this.DeleteProp('Set')
                    } else {
                        this.DeleteProp('Get')
                    }
                ; The type of property changed
                } else if !n {
                    this.DeleteProp('Get')
                    this.DeleteProp('Set')
                }
        }
        return this.__DefineKindIndex()
    }

    /**
     * Returns the owner of the property which produced this `PropsInfoItem` object.
     * @memberof PropsInfoItem
     * @instance
     */
    Owner => this.GetOwner()
    /**
     * A string representation of the kind of property which produced this `PropsInfoItem` object.
     * The possible values are:
     * - Call
     * - Get
     * - Get_Set
     * - Set
     * - Value
     * @memberof PropsInfoItem
     * @instance
     */
    Kind => this.__KindNames[this.KindIndex]
    /**
     * An integer that indicates the kind of property which produced this `PropsInfoItem` object.
     * The possible values are:
     * - 1: Callable property
     * - 2: Dynamic property with only a getter
     * - 3: Dynamic property with both a getter and setter
     * - 4: Dynamic property with only a setter
     * - 5: Value property
     * @memberof PropsInfoItem
     * @instance
     */
    KindIndex => this.__DefineKindIndex()

    /**
     * @description - The first time `KindIndex` is accessed, evaluates the object to determine
     * the property kind, then overrides `KindIndex`.
     */
    __DefineKindIndex() {
        ; Override with a value property so this is only processed once
        if this.HasOwnProp('Call') {
            this.DefineProp('KindIndex', { Value: 1 })
        } else if this.HasOwnProp('Get') {
            if this.HasOwnProp('Set') {
                this.DefineProp('KindIndex', { Value: 3 })
            } else {
                this.DefineProp('KindIndex', { Value: 2 })
            }
        } else if this.HasOwnProp('Set') {
            this.DefineProp('KindIndex', { Value: 4 })
        } else if this.HasOwnProp('Value') {
            this.DefineProp('KindIndex', { Value: 5 })
        } else {
            throw Error('Unable to process an unexpected value.', -1)
        }
        return this.KindIndex
    }
    /**
     * @description - The first time `PropsInfoItem.Prototype.__SetAlt` is called, it sets the `Alt`
     * property with an array, then overrides `__SetAlt` to a function which just add items to the
     * array.
     */
    __SetAlt(Item) {
        /**
         * An array of `PropsInfoItem` objects, each sharing the same name. The property associated
         * with the `PropsInfoItem` object that has the `Alt` property is the property owned by
         * or inherited by the object passed to the `GetPropsInfo` function call. Exactly zero of
         * the `PropsInfoItem` objects contained within the `Alt` array will have an `Alt` property.
         * The below example illustrates this concept but expressed in code:
         * @example
         * Obj := [1, 2]
         * OutputDebug('`n' A_LineNumber ': ' Obj.Length) ; 2
         * ; Ordinarily when we access the `Length` property from an array
         * ; instance, the `Array.Prototype.Length.Get` function is called.
         * OutputDebug('`n' A_LineNumber ': ' Obj.Base.GetOwnPropDesc('Length').Get.Name) ; Array.Prototype.Length.Get
         * ; We override the property for some reason.
         * Obj.DefineProp('Length', { Value: 'Arbitrary' })
         * OutputDebug('`n' A_LineNumber ': ' Obj.Length) ; Arbitrary
         * ; GetPropsInfo
         * PropsInfoObj := GetPropsInfo(Obj)
         * ; Get the `PropsInfoItem` for "Length".
         * InfoItem_Length := PropsInfoObj.Get('Length')
         * if code := InfoItem_Length.GetValue(&Value) {
         *     throw Error('GetValue failed.', -1, 'Code: ' code)
         * } else {
         *     OutputDebug('`n' A_LineNumber ': ' Value) ; Arbitrary
         * }
         * ; Checking if the property was overridden (we already know
         * ; it was, but just for example)
         * OutputDebug('`n' A_LineNumber ': ' InfoItem_Length.Count) ; 2
         * OutputDebug('`n' A_LineNumber ': ' (InfoItem_Length.HasOwnProp('Alt'))) ; 1
         * InfoItem_Length_Alt := InfoItem_Length.Alt[1]
         * ; Calling `GetValue()` below returns the true length because
         * ; `Obj` is passed to `Array.Prototype.Length.Get`, producing
         * ; the same result as `Obj.Length` if we never overrode the
         * ; property.
         * if code := InfoItem_Length_Alt.GetValue(&Value) {
         *     throw Error('GetValue failed.', -1, 'Code: ' code)
         * } else {
         *     OutputDebug('`n' A_LineNumber ': ' Value) ; 2
         * }
         * ; The objects nested in the `Alt` array never have an `Alt`
         * ; property, but have the other properties.
         * OutputDebug('`n' A_LineNumber ': ' (InfoItem_Length_Alt.HasOwnProp('Alt'))) ; 0
         * OutputDebug('`n' A_LineNumber ': ' InfoItem_Length_Alt.Count) ; 2
         * OutputDebug('`n' A_LineNumber ': ' InfoItem_Length_Alt.Name) ; Length
         * @instance
         */
        if this.HasOwnProp('Alt') {
            this.Alt.Push(Item)
        } else {
            this.Alt := [ Item ]
        }
    }
}
