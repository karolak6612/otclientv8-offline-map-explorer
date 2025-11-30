Here is the documentation for using `UIWidgetText` in OTUI. This widget allows you to display and style text with various properties such as alignment, wrapping, font customization, and more.

---

# Using `UIWidgetText` in OTUI

The `UIWidgetText` widget is used to display text in the user interface. It supports a variety of properties to control the appearance, alignment, and behavior of the text.

---

## Text Style Properties

### 1. **Text Content**

- **`text`**: The text to be displayed in the widget.
  - **Type**: String.
  - **Example**: `text: "Hello, World!"`

---

### 2. **Text Alignment**

- **`text-align`**: Specifies the alignment of the text within the widget.
  - **Type**: String.
  - **Values**:
    - `left`
    - `right`
    - `center`
    - `top-left`
    - `top-right`
    - `bottom-left`
    - `bottom-right`
  - **Example**: `text-align: center`

---

### 3. **Text Offset**

- **`text-offset`**: Sets the offset of the text within the widget.
  - **Type**: `Point` (e.g., `x y`).
  - **Example**: `text-offset: 10 5`

---

### 4. **Text Wrapping**

- **`text-wrap`**: Enables or disables text wrapping.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `text-wrap: true`

---

### 5. **Text Auto-Resize**

- **`text-auto-resize`**: Automatically resizes the widget to fit the text.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `text-auto-resize: true`

- **`text-horizontal-auto-resize`**: Automatically resizes the widget's width to fit the text.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `text-horizontal-auto-resize: true`

- **`text-vertical-auto-resize`**: Automatically resizes the widget's height to fit the text.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `text-vertical-auto-resize: true`

---

### 6. **Text Case**

- **`text-only-upper-case`**: Converts all text to uppercase.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `text-only-upper-case: true`

---

### 7. **Font Customization**

- **`font`**: Specifies the font to be used for the text.
  - **Type**: String (font name).
  - **Example**: `font: "verdana-11px"`

- **`font-scale`**: Scales the font size.
  - **Type**: Float.
  - **Example**: `font-scale: 1.5`

---

## Example OTUI Definition

```otui
Widget
  id: exampleTextWidget
  text: "Hello, OTClient!"
  text-align: center
  text-offset: 5 5
  text-wrap: true
  text-auto-resize: true
  text-only-upper-case: false
  font: "verdana-11px"
  font-scale: 1.2
```

---

## Advanced Features

### Colored Text

The `UIWidgetText` widget supports colored text using a special syntax. Colors can be applied to specific parts of the text.

- **Syntax**: `{text,color}`
  - **Example**: `{Hello,#FF0000} {World,#00FF00}`

### Example with Colored Text

```otui
Widget
  id: coloredTextWidget
  text: "{Hello,#FF0000} {World,#00FF00}"
  text-align: left
  font: "verdana-11px"
```

---

## Summary Table

| Property                     | Type       | Description                                      | Example                     |
|------------------------------|------------|--------------------------------------------------|-----------------------------|
| `text`                       | String     | The text to display.                            | `text: "Hello, World!"`     |
| `text-align`                 | String     | Aligns the text within the widget.              | `text-align: center`        |
| `text-offset`                | Point      | Sets the offset of the text.                    | `text-offset: 10 5`         |
| `text-wrap`                  | Boolean    | Enables or disables text wrapping.              | `text-wrap: true`           |
| `text-auto-resize`           | Boolean    | Resizes the widget to fit the text.             | `text-auto-resize: true`    |
| `text-horizontal-auto-resize`| Boolean    | Resizes the widget's width to fit the text.      | `text-horizontal-auto-resize: true` |
| `text-vertical-auto-resize`  | Boolean    | Resizes the widget's height to fit the text.     | `text-vertical-auto-resize: true` |
| `text-only-upper-case`       | Boolean    | Converts all text to uppercase.                 | `text-only-upper-case: true`|
| `font`                       | String     | Specifies the font to use.                      | `font: "verdana-11px"`      |
| `font-scale`                 | Float      | Scales the font size.                           | `font-scale: 1.5`           |

---

This documentation provides a comprehensive guide to using `UIWidgetText` in OTUI. It covers all the properties available for customizing text appearance and behavior.