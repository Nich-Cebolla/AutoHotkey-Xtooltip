
# Xtooltip

`Xtooltip` is a class that implements most of the Windows API tools regarding tooltip controls,
allowing developers to create and use highly customizable and responsive tooltip windows with as
little as two lines of code.

A tooltip is a popup window that displays information. Tooltips are often designed to appear when
the user hovers the mouse over a control or specific area for a short period of time, displaying
information related to that particular control / area.

The AHK [`ToolTip`](https://www.autohotkey.com/docs/v2/lib/ToolTip.htm) function can be used to
display text in a tooltip window, and that window can be
manipulated like other windows using `WinGetPos` and the other
[`Win...`](https://www.autohotkey.com/docs/v2/lib/Win.htm) functions. However, `ToolTip`
does not provide tools for customizing the window or its behavior.

`Xtooltip` bridges the gap between our AHK code and the Windows API, providing the following tools:
- Associate a tooltip with a [control or window](#control-or-window) so the tooltip appears when the mouse hovers over the window.
- Associate a tooltip with a [rectangular area](#rectangular-area) so the tooltip appears when the mouse hovers over the area.
- Create a ["tracking"](#tracking) tooltip that can be displayed at any position at-will.
- Create [customizable themes](#themes) to quickly swap all customizable attributes.
- Create [theme groups](#theme-groups) to group together tooltips and themes to keep your code organized.
- Customize all available attributes:
  - Background color
  - Font
    - Bold
    - Escapement
    - Face name
    - Font size
    - Italic
    - Quality
    - Strikeout
    - Underline
    - Weight
  - Icon
  - Margins
  - Maximum width
  - Text color
  - Title

Learning to use `Xtooltip` is easy and brief. Read the [quick start](#quick-start) guide (< 2 mins)
and you'll be ready to go.

# Quick start

The following is a brief introduction intended to share enough information for you to make use
of this library.

## The tooltip window

A tooltip is a window with the following basic components:
- Theme (Text color, background color, window styles)
- Display text
- Parent window

A single tooltip can be associated with any number of "tools". For example, say I have
three buttons in a gui window. I can prepare one tooltip window that displays different text
when the user hovers the mouse cursor over each button. To accomplish this, we add three
"tools" to the tooltip.

## Tools and {@link TtToolInfo} objects

A "tool" is an application-defined group of configuration options organized into a TTTOOLINFO
structure. In this library, the {@link TtToolInfo} class has properties mapped to each of the members
of the TTTOOLINFO structure, so you will be interacting with the Windows API through familiar
object properties instead of byte offsets.

The TTTOOLINFO structure is used heavily by the tooltip-related functions offered by the Windows
API. Whenever we need to get information about a tool, or update a value associated with a tool,
we supply a {@link TtToolInfo} object which mediates this exchange.

Because a tooltip can be associated with multiple tools, we cannot cache one {@link TtToolInfo} object
and use it repeatedly with the Windows API functions. We must fill the structure's members
with updated values when we call a function that requires it. In order to fill the members, our
code must set two poperties: "Hwnd" and "Id". These identify the tool with which the upcoming function
call will be interacting.

This is the pattern for sending many of the TTM window messages WITHOUT using this library:
```ahk
; Assume the `xtt` is an `XTooltip` object
ti :== ToolInfo(xtt.Hwnd) ; get a {@link TtToolInfo} object (mapped to a TTTOOLINFO structure)
ti.Hwnd := parentHwnd ; Set the "hwnd" property
ti.Id := uniqueId ; set the "id" property
; For this example, we want to update the tooltip's text
str := "Hello, world!"
buf := Buffer(StrPut(str, "UTF-16"))
StrPut(str, buf, "UTF-16")
NumPut("ptr", buf.Ptr, ti, 24 + A_PtrSize * 3)
SendMessage(TTM_UPDATETIPTEXTW, ti.Ptr, 0, xtt.Hwnd)
```

## ToolInfo.Params objects

As you explore the library, you will see that many methods require a {@link TtToolInfo} object. In order to do this, our code must set two
properties: "hwnd" and "uId".

To simplify and systematize this pattern that will be repeated in our code, the `Xtt` object
has a property "Tools" which is a map object that stores references to {@link TtToolInfo.Params} objects.
A {@link TtToolInfo.Params} object contains the static data that defines a particular tool. Instead of
caching a {@link TtToolInfo} object, which has values that will change as time goes on, this library
will have you cache one {@link TtToolInfo.Params} object for every tool added to a tooltip.





The "tool" is represented in our AHK code by a {@link TtToolInfo} object. The {@link TtToolInfo} object is a buffer
object with its properties mapped to the members of the TTTOOLINFO structure.
This library handles the details of the API, but if you are interested the relevant information
is here: https://learn.microsoft.com/en-us/windows/win32/api/commctrl/ns-commctrl-tttoolinfoa

This is your process when writing the code that will create the tooltip:

1. Decide which tooltip mode is appropriate for your project

## Tooltip modes

There are three configurations predefined by this library:

1. If you want your code to have full control over the tooltip's display and position, see
"Setting up a tracking tooltip.
2. If you want the tooltip to be visible when the user moves the mouse over a window or control,
see "Setting up a tooltip for a window".
3. If you want the tooltip to be visible when the user moves the mouse over a rectangular area
defined by you, see "Setting up a tooltip with a trigger area".

### Setting up a tracking tooltip



If your intent is to have the tooltip display when the user moves the mouse cursor over
a window or control, the relevant section below is "Setting up a tooltip for a window".

- If your intent is to have the tooltip display when the user moves the mouse cursor over
a rectangular area within a window's client area, the relevant section below is "Setting
up a tooltip for a rectangular area".



Minimally the TTTOOLINFO structure must have members "hwnd" and "uId". What this means
for us in our AHK code is that the {@link TtToolInfo} object (from this library) must be associated
with a parent window, and must have an ID.

Understand that neither the "hwnd" nor "uId" members of TTTOOLINFO are the same thing
as the tooltip's window handle.

Depending on your use case, you may be able to leave one or both of "Hwnd" and "Id" unset.
The following sections can help you decide how to proceed.

This library assists with the preparation and usage of three behavior patterns:


### Setting up a tracking tooltip

This information is for preparing a tooltip that your code will maintain full control of.
If you want the system to display / hide a tooltip when the user's mouse cursor enters
or leaves an area, read the other sections.



This information is to help you set the correct values when your code will control the
activation, deactivation, and position of the tooltip. If your intent is to manipulate
the tooltip as-needed in your AHK code (as opposed to relying on the Windows API to display
and hide the tooltip when the user's mouse enters a certain area), then this is the sectionMany of the TTM window messages
require a TTTOOLINFO structure, and so even if you don't plan on associating a tooltip
with a particular tool, you may find that you still need to get a {@link TtToolInfo} object to
use one of the methods.

When you call the constructor {@link Xtooltip.Prototype.__New}, a generic {@link TtToolInfo.Params} object
is created using the text passed to the constructor. It is safe to use this object for
any method that does not involve associating it with a new tool. To get a reference to
the object, access it from the "Tools" property, passing numeric zero (0) to the method
"Get":

```ahk
; Get a `Xtooltip` object.
xtt := Xtooltip("Hello, world!")
; Get a reference to the generic {@link TtToolInfo.Params} object.
TiParams := xtt.Tools.Get(0)
; Convert the {@link TtToolInfo.Params} object to a `ToolInfo` object.
ti := TiParams(xtt)
```

Or to save a line of code, pass numeric zero (0) to the method "GetToolInfo" of the
{@link Xtooltip} object:

```ahk
; Get a `Xtooltip` object.
xtt := Xtooltip("Hello, world!")
; Get a reference to the generic `ToolInfo` object.
ti := xtt.GetToolInfo(0)
```

If you need a new generic {@link TtToolInfo.Params} object, follow these steps:

```ahk
; Assume we already have a `Xtooltip` object referenced by the symbol `xtt`.
; Get a new {@link TtToolInfo.Params} object.
TiParams := xtt.GetParamsGeneric()
; Make changes to the object.
TiParams.Text := "Goodbye, world!"
; Validate the object. Errors should be handled during the development of the application.
; During development, I would just allow any errors to be thrown.
TiParams.Validate()
```

### If the tool is a window

This information is to help you set the correct values when the tool is a window (for
example, a gui control). The behavior we want is: When the user's mouse moves over the
window, the tooltip should display after a short delay. When the mouse leaves the window's
area, the tooltip should automatically hide after a short delay. To achieve this behavior,
follow these guidelines:

- Set Params.Flags with TTF_IDISHWND. Unless you plan on enabling tracking behavior,
  you'll likely also want to include TTF_SUBCLASS. You'll know if you **don't** need
  TTF_SUBCLASS, so you should default to setting "Flags" with both TTF_IDISHWND and
  TTF_SUBCLASS, plus any other flags. Example: `Params.Flags := 0x0001 | 0x0010`
- Set `Params.Id` with the handle to the window (e.g. the handle to a gui control).
- If the window has a parent window, set `Params.Hwnd` with the handle to the parent window.
  If the window does not have a parent window, set `Params.Hwnd` with the same handle as "Id".

You can use {@link ToolInfo.Params.GetWindow} or {@link ToolInfo.Params.GetToolControl} to get an
object with the minimum required properties. If you make changes to the properties, I
recommend calling {@link ToolInfo.Params.Prototype.Validate} within the same scope that your
code makes the changes to catch any problems immediately.

### If the tool is a rectangular area within a window's client area

This information is to help you set the correct values when the tool is a rectangular
area within a window's client area. The behavior we want is: When the user's mouse moves
into the area, the tooltip should display after a short delay. When the mouse leaves
the window's area, the tooltip should automatically hide after a short delay. To
achieve this behavior, follow these guidelines:

- Set `Params.Flags := TTF_SUBCLASS`.
- Set `Params.Hwnd` with the handle to the window whose client area contains the area
  that will be associated with the tooltip.
- Set properties "L", "T", "R", "B", with the left, top, right, and bottom client coordinates
  (that is, coordinates relative to the top-left corner of the window's client area).

You can use {@link ToolInfo.Params.GetRect} to get an object with the minimum required
properties. If you make changes to the properties, I recommend  calling
{@link ToolInfo.Params.Prototype.Validate} within the same scope that your code makes the changes
to catch any problems immediately.

### Enable tracking

This information is to help you set the correct values to enable tracking behavior. This
library does not implement TTM_TRACKACTIVATE or TTM_TRACKPOSITION messages. The Windows
API provides functions for associating a tooltip with a window and for using the window's
procedure for sending TTM_TRACKACTIVATE or TTM_TRACKPOSITION messages to the tooltip.
However, in our AHK code, we don't typically interact directly with a window procedure,
and writing that kind of code into this library is unnecessary because a tooltip is
a window and can be manipulated like any other window. To enable tracking behavior, all
we need is:
- An event that activates the tooltip by using {@link Xtooltip.Prototype.Show}.
- One or more events that adjusts the position of the tooltip by using
  {@link Xtooltip.Prototype.MoveWindow} or {@link Xtooltip.Prototype.MoveDisplay}.
- An event that deactivates the tooltip by using {@link Xtooltip.Prototype.Hide}.

To this end, the needed properties for the {@link TtToolInfo.Params} object are the same as
described in the section "If your code will control the tooltip's activation, deactivation,
and position".

For further reading, these webpages contain instructions and guidance for creating a tooltip:
- How to create a tooltip for a gui control:
{@link https://learn.microsoft.com/en-us/windows/win32/controls/create-a-tooltip-for-a-control}.
- How to create a tooltip for a rectangular area:
{@link https://learn.microsoft.com/en-us/windows/win32/controls/create-a-tooltip-for-a-rectangular-area}.
- How to implement tracking tooltips (note this library does not implement TTM_TRACKACTIVATE
  nor TTM_TRACKPOSITION):
{@link https://learn.microsoft.com/en-us/windows/win32/controls/implement-tracking-tooltips}.
- How to implement multiline tooltips:
{@link https://learn.microsoft.com/en-us/windows/win32/controls/implement-multiline-tooltips}.
- How to implement balloon tooltips:
{@link https://learn.microsoft.com/en-us/windows/win32/controls/implement-balloon-tooltips}.
- How to implement tooltips for status bar icons:
{@link https://learn.microsoft.com/en-us/windows/win32/controls/implement-tooltips-for-status-bar-icons}.
- How to implement in-place tooltips:
{@link https://learn.microsoft.com/en-us/windows/win32/controls/implement-in-place-tooltips}.

# Notes

These are conclusions about the tooltip API's behavior that I found during testing.

- Only one tracking tool can be added to a tooltip at a time.
- Setting the max width is a prerequisite for multi-line tooltip, even if the text contains line breaks.
- TTM_GETCURRENTTOOL will get the tool's text but only if that text does not exceed a threshold, which I believe is 160 bytes.
- Using TTM_GETTEXT does not present any sort of unexpected quirks. If the text exceeds the value passed to wParam (the number of characters), then the return value is appropriately truncated. If the value passed to wParam exceeds the actual text length, there is no issue and the full text is retrieved. If the value passed to wParam is exactly correct, the full text is retrieved.
- Text controls don't work with the "AddControl" method. The "AddRect" method must be used.
- A tracking tooltip (and probably all tooltips) needs to be shown at least once before `GetWindowRect` can return correct values.
- TTM_GETCURRENTTOOL requires a tooltip to be visible.
- TTM_GETTITLE requires the TTGETTITLE structure to be filled before sending the message.
