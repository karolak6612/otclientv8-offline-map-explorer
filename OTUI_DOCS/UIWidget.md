Here is a detailed documentation of the OTUI properties handled in uiwidgetbasestyle.cpp. Each property is mapped to its corresponding C++ method and includes a description of its purpose and expected arguments.

---

# OTUI Properties Documentation

## General Properties

### `background-draw-order`
- **Description**: Sets the draw order of the widget's background.
- **Arguments**: Integer.

### `border-draw-order`
- **Description**: Sets the draw order of the widget's border.
- **Arguments**: Integer.

### `icon-draw-order`
- **Description**: Sets the draw order of the widget's icon.
- **Arguments**: Integer.

### `image-draw-order`
- **Description**: Sets the draw order of the widget's image.
- **Arguments**: Integer.

### `text-draw-order`
- **Description**: Sets the draw order of the widget's text.
- **Arguments**: Integer.

---

## Position and Size

### `x`, `y`
- **Description**: Sets the x or y position of the widget.
- **Arguments**: Integer.

### `pos`
- **Description**: Sets the position of the widget as a point.
- **Arguments**: `Point` (e.g., `x y`).

### `width`, `height`
- **Description**: Sets the width or height of the widget.
- **Arguments**: Integer.

### `min-width`, `max-width`
- **Description**: Sets the minimum or maximum width of the widget.
- **Arguments**: Integer.

### `min-height`, `max-height`
- **Description**: Sets the minimum or maximum height of the widget.
- **Arguments**: Integer.

### `rect`
- **Description**: Sets the widget's rectangle (position and size).
- **Arguments**: `Rect` (e.g., `x y width height`).

---

## Background

### `background`
- **Description**: Sets the background color of the widget.
- **Arguments**: `Color` (e.g., `#RRGGBBAA`).

### `background-color`
- **Description**: Alias for `background`.

### `background-offset-x`, `background-offset-y`
- **Description**: Sets the x or y offset of the background.
- **Arguments**: Integer.

### `background-offset`
- **Description**: Sets the offset of the background as a point.
- **Arguments**: `Point` (e.g., `x y`).

### `background-width`, `background-height`
- **Description**: Sets the width or height of the background.
- **Arguments**: Integer.

### `background-size`
- **Description**: Sets the size of the background.
- **Arguments**: `Size` (e.g., `width height`).

### `background-rect`
- **Description**: Sets the rectangle of the background.
- **Arguments**: `Rect` (e.g., `x y width height`).

---

## Icon

### `icon`
- **Description**: Sets the icon texture file.
- **Arguments**: String (file path).

### `icon-source`
- **Description**: Alias for `icon`.

### `icon-color`
- **Description**: Sets the color of the icon.
- **Arguments**: `Color` (e.g., `#RRGGBBAA`).

### `icon-offset-x`, `icon-offset-y`
- **Description**: Sets the x or y offset of the icon.
- **Arguments**: Integer.

### `icon-offset`
- **Description**: Sets the offset of the icon as a point.
- **Arguments**: `Point` (e.g., `x y`).

### `icon-width`, `icon-height`
- **Description**: Sets the width or height of the icon.
- **Arguments**: Integer.

### `icon-size`
- **Description**: Sets the size of the icon.
- **Arguments**: `Size` (e.g., `width height`).

### `icon-rect`
- **Description**: Sets the rectangle of the icon.
- **Arguments**: `Rect` (e.g., `x y width height`).

### `icon-clip`
- **Description**: Sets the clipping rectangle of the icon.
- **Arguments**: `Rect` (e.g., `x y width height`).

### `icon-align`
- **Description**: Sets the alignment of the icon.
- **Arguments**: Alignment string (e.g., `top-left`, `center`, etc.).

---

## Visual Properties

### `opacity`
- **Description**: Sets the opacity of the widget.
- **Arguments**: Float (0.0 to 1.0).

### `rotation`
- **Description**: Sets the rotation of the widget.
- **Arguments**: Float (degrees).

---

## State Properties

### `enabled`
- **Description**: Enables or disables the widget.
- **Arguments**: Boolean (`true` or `false`).

### `visible`
- **Description**: Sets the visibility of the widget.
- **Arguments**: Boolean (`true` or `false`).

### `checked`
- **Description**: Sets the checked state of the widget.
- **Arguments**: Boolean (`true` or `false`).

### `draggable`
- **Description**: Enables or disables dragging for the widget.
- **Arguments**: Boolean (`true` or `false`).

### `on`
- **Description**: Sets the "on" state of the widget.
- **Arguments**: Boolean (`true` or `false`).

### `focusable`
- **Description**: Enables or disables focus for the widget.
- **Arguments**: Boolean (`true` or `false`).

### `auto-focus`
- **Description**: Sets the auto-focus policy of the widget.
- **Arguments**: String (e.g., `none`, `first`, etc.).

### `phantom`
- **Description**: Sets the widget as a phantom (invisible to input).
- **Arguments**: Boolean (`true` or `false`).

---

## Size Constraints

### `size`
- **Description**: Sets the size of the widget.
- **Arguments**: `Size` (e.g., `width height`).

### `fixed-size`
- **Description**: Sets whether the widget has a fixed size.
- **Arguments**: Boolean (`true` or `false`).

### `min-size`, `max-size`
- **Description**: Sets the minimum or maximum size of the widget.
- **Arguments**: `Size` (e.g., `width height`).

---

## Clipping

### `clipping`
- **Description**: Enables or disables clipping for the widget.
- **Arguments**: Boolean (`true` or `false`).

---

## Border

### `border`
- **Description**: Sets the border width and color.
- **Arguments**: String (e.g., `width color`).

### `border-width`
- **Description**: Sets the border width.
- **Arguments**: Integer.

### `border-width-top`, `border-width-right`, `border-width-bottom`, `border-width-left`
- **Description**: Sets the border width for each side.
- **Arguments**: Integer.

### `border-color`
- **Description**: Sets the border color.
- **Arguments**: `Color` (e.g., `#RRGGBBAA`).

### `border-color-top`, `border-color-right`, `border-color-bottom`, `border-color-left`
- **Description**: Sets the border color for each side.
- **Arguments**: `Color` (e.g., `#RRGGBBAA`).

---

## Margin and Padding

### `margin`
- **Description**: Sets the margin for all sides.
- **Arguments**: Integer or `top right bottom left`.

### `margin-top`, `margin-right`, `margin-bottom`, `margin-left`
- **Description**: Sets the margin for a specific side.
- **Arguments**: Integer.

### `padding`
- **Description**: Sets the padding for all sides.
- **Arguments**: Integer or `top right bottom left`.

### `padding-top`, `padding-right`, `padding-bottom`, `padding-left`
- **Description**: Sets the padding for a specific side.
- **Arguments**: Integer.

---

## Layout

### `layout`
- **Description**: Sets the layout type for the widget.
- **Arguments**: String (e.g., `horizontalBox`, `verticalBox`, `grid`, `anchor`).

---

## Anchors

### `anchors.*`
- **Description**: Defines anchors for the widget.
- **Arguments**: String (e.g., `fill`, `centerIn`, or `widget.edge`).

---

This documentation provides a comprehensive overview of the OTUI properties handled in uiwidgetbasestyle.cpp. Each property is mapped to its corresponding method and includes its purpose and expected arguments.