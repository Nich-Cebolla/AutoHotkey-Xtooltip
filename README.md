
# Notes

These are conclusions about the tooltip API's behavior that I found during testing.

- Only one tracking tool can be added to a tooltip at a time.
- Setting the max width is a prerequisite for multi-line tooltip, even if the text contains line breaks.
- TTM_GETCURRENTTOOL will get the tool's text but only if that text does not exceed a threshold, which I believe is 160 bytes.
- Using TTM_GETTEXT does not present any sort of unexpected quirks. If the text exceeds the value passed to wParam (the number of characters), then the return value is appropriately truncated. If the value passed to wParam exceeds the actual text length, there is no issue and the full text is retrieved. If the value passed to wParam is exactly correct, the full text is retrieved.
- Text controls don't work with the "AddControl" method. The "AddRect" method must be used.
- A tracking tooltip (and probably all tooltips) needs to be shown at least once before `GetWindowRect` can return correct values.
- TTM_GETCURRENTTOOL requires a tooltip to be visible.
