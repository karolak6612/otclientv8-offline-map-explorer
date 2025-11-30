Here is a detailed documentation of layout usage in OTUI, based on the provided code for various layout types (`UIBoxLayout`, `UIVerticalLayout`, `UIHorizontalLayout`, `UIGridLayout`, and `UIAnchorLayout`).

---

# OTUI Layouts Documentation

Layouts in OTUI are used to organize and position child widgets within a parent widget. Each layout type has specific properties and behaviors that can be configured in OTUI files.

---

## 1. **Box Layout**

### Description
The `UIBoxLayout` is a base class for layouts that arrange widgets in a single direction (horizontal or vertical). It provides basic properties like spacing and child fitting.

### Common Properties
- **`spacing`**: Sets the spacing between child widgets.
  - **Type**: Integer.
  - **Example**: `spacing: 10`
- **`fit-children`**: Automatically adjusts the parent widget's size to fit its children.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `fit-children: true`

---

## 2. **Vertical Layout**

### Description
The `UIVerticalLayout` arranges child widgets vertically, from top to bottom or bottom to top (if `align-bottom` is enabled).

### Properties
- **`align-bottom`**: Aligns child widgets to the bottom of the parent widget.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `align-bottom: true`

### Example
```otui
VerticalLayout
  spacing: 5
  fit-children: true
  align-bottom: false
  children:
    Label
      text: "Item 1"
    Label
      text: "Item 2"
```

---

## 3. **Horizontal Layout**

### Description
The `UIHorizontalLayout` arranges child widgets horizontally, from left to right or right to left (if `align-right` is enabled).

### Properties
- **`align-right`**: Aligns child widgets to the right of the parent widget.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `align-right: true`

### Example
```otui
HorizontalLayout
  spacing: 10
  fit-children: true
  align-right: false
  children:
    Button
      text: "OK"
    Button
      text: "Cancel"
```

---

## 4. **Grid Layout**

### Description
The `UIGridLayout` arranges child widgets in a grid with configurable cell sizes, spacing, and flow.

### Properties
- **`cell-size`**: Sets the size of each grid cell.
  - **Type**: `Size` (e.g., `width height`).
  - **Example**: `cell-size: 50 50`
- **`cell-width`**: Sets the width of each grid cell.
  - **Type**: Integer.
  - **Example**: `cell-width: 50`
- **`cell-height`**: Sets the height of each grid cell.
  - **Type**: Integer.
  - **Example**: `cell-height: 50`
- **`cell-spacing`**: Sets the spacing between grid cells.
  - **Type**: Integer.
  - **Example**: `cell-spacing: 5`
- **`num-columns`**: Sets the number of columns in the grid.
  - **Type**: Integer.
  - **Example**: `num-columns: 3`
- **`num-lines`**: Sets the number of rows in the grid.
  - **Type**: Integer.
  - **Example**: `num-lines: 2`
- **`fit-children`**: Automatically adjusts the parent widget's size to fit its children.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `fit-children: true`
- **`auto-spacing`**: Automatically adjusts spacing between cells to fit the grid.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `auto-spacing: true`
- **`flow`**: Enables flow layout, where widgets are placed in rows based on available space.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `flow: true`

### Example
```otui
GridLayout
  cell-size: 50 50
  cell-spacing: 10
  num-columns: 3
  fit-children: true
  flow: true
  children:
    Button
      text: "1"
    Button
      text: "2"
    Button
      text: "3"
    Button
      text: "4"
```

---

## 5. **Anchor Layout**

### Description
The `UIAnchorLayout` allows precise positioning of child widgets by anchoring them to specific edges or centers of other widgets or the parent widget.

### Properties
- **`anchors.*`**: Defines anchors for the widget. Anchors specify how a widget is positioned relative to another widget or the parent widget.
  - **Type**: String (e.g., `fill`, `centerIn`, or `widget.edge`).
  - **Examples**:
    - `anchors.fill: parent`
    - `anchors.centerIn: parent`
    - `anchors.left: otherWidget.right`

### Special Anchors
- **`fill`**: Stretches the widget to fill the parent or another widget.
- **`centerIn`**: Centers the widget within the parent or another widget.

### Example
```otui
AnchorLayout
  children:
    Label
      text: "Centered"
      anchors.centerIn: parent
    Button
      text: "Bottom Right"
      anchors.bottom: parent.bottom
      anchors.right: parent.right
```

---

## Summary Table

| Layout Type       | Key Properties                                                                 | Description                                                                 |
|--------------------|--------------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| **Box Layout**     | `spacing`, `fit-children`                                                     | Base layout for vertical and horizontal layouts.                           |
| **Vertical Layout**| `align-bottom`                                                               | Arranges widgets vertically.                                               |
| **Horizontal Layout**| `align-right`                                                              | Arranges widgets horizontally.                                             |
| **Grid Layout**    | `cell-size`, `cell-spacing`, `num-columns`, `fit-children`, `flow`            | Arranges widgets in a grid.                                                |
| **Anchor Layout**  | `anchors.*`                                                                  | Positions widgets using anchors relative to other widgets or the parent.   |

---

This documentation provides an overview of how to use layouts in OTUI files, including their properties and examples. Each layout type is designed to handle specific use cases for widget arrangement and positioning.