Here is the documentation for using `UITextEdit` in OTUI. This widget is an advanced text input field that supports features like text editing, selection, placeholders, and more.

---

# Using `UITextEdit` in OTUI

The `UITextEdit` widget is a versatile text input field that allows users to input, edit, and interact with text. It supports various properties for customization, including text alignment, selection, placeholders, and more.

---

## UITextEdit Style Properties

### 1. **Text Content**

- **`text`**: The text to be displayed or edited in the widget.
  - **Type**: String.
  - **Example**: `text: "Enter your name"`

- **`text-hidden`**: Hides the text by replacing it with asterisks (e.g., for password fields).
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `text-hidden: true`

---

### 2. **Text Behavior**

- **`editable`**: Enables or disables text editing.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `editable: true`

- **`multiline`**: Allows multiple lines of text.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `multiline: true`

- **`max-length`**: Sets the maximum number of characters allowed in the text field.
  - **Type**: Integer.
  - **Example**: `max-length: 50`

- **`shift-navigation`**: Enables navigation using the Shift key.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `shift-navigation: true`

---

### 3. **Text Selection**

- **`selectable`**: Enables or disables text selection.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `selectable: true`

- **`selection-color`**: Sets the color of the selected text.
  - **Type**: `Color` (e.g., `#RRGGBBAA`).
  - **Example**: `selection-color: #FFFFFF`

- **`selection-background-color`**: Sets the background color of the selected text.
  - **Type**: `Color` (e.g., `#RRGGBBAA`).
  - **Example**: `selection-background-color: #0000FF`

- **`selection`**: Defines the selection range as a point (start and end positions).
  - **Type**: `Point` (e.g., `start end`).
  - **Example**: `selection: 0 5`

---

### 4. **Cursor Behavior**

- **`cursor-visible`**: Shows or hides the text cursor.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `cursor-visible: true`

- **`change-cursor-image`**: Changes the cursor image when hovering over the text field.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `change-cursor-image: true`

---

### 5. **Scrolling**

- **`auto-scroll`**: Automatically scrolls the text field to keep the cursor visible.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `auto-scroll: true`

---

### 6. **Placeholder**

- **`placeholder`**: Sets the placeholder text to display when the text field is empty.
  - **Type**: String.
  - **Example**: `placeholder: "Enter text here"`

- **`placeholder-color`**: Sets the color of the placeholder text.
  - **Type**: `Color` (e.g., `#RRGGBBAA`).
  - **Example**: `placeholder-color: #AAAAAA`

- **`placeholder-align`**: Aligns the placeholder text within the widget.
  - **Type**: String.
  - **Values**:
    - `left`
    - `right`
    - `center`
    - `top-left`
    - `top-right`
    - `bottom-left`
    - `bottom-right`
  - **Example**: `placeholder-align: center`

- **`placeholder-font`**: Specifies the font for the placeholder text.
  - **Type**: String (font name).
  - **Example**: `placeholder-font: "verdana-11px"`

---

## Example OTUI Definition

```otui
TextEdit
  id: exampleTextEdit
  text: "Hello, World!"
  text-hidden: false
  editable: true
  multiline: true
  max-length: 100
  selectable: true
  selection-color: #FFFFFF
  selection-background-color: #0000FF
  cursor-visible: true
  auto-scroll: true
  placeholder: "Type something..."
  placeholder-color: #AAAAAA
  placeholder-align: center
  placeholder-font: "verdana-11px"
```

---

## Summary Table

| Property                     | Type       | Description                                      | Example                     |
|------------------------------|------------|--------------------------------------------------|-----------------------------|
| `text`                       | String     | The text to display or edit.                    | `text: "Hello, World!"`     |
| `text-hidden`                | Boolean    | Hides the text (e.g., for passwords).           | `text-hidden: true`         |
| `editable`                   | Boolean    | Enables or disables text editing.               | `editable: true`            |
| `multiline`                  | Boolean    | Allows multiple lines of text.                  | `multiline: true`           |
| `max-length`                 | Integer    | Sets the maximum number of characters.          | `max-length: 50`            |
| `selectable`                 | Boolean    | Enables or disables text selection.             | `selectable: true`          |
| `selection-color`            | Color      | Sets the color of the selected text.            | `selection-color: #FFFFFF`  |
| `selection-background-color` | Color      | Sets the background color of the selection.     | `selection-background-color: #0000FF` |
| `cursor-visible`             | Boolean    | Shows or hides the text cursor.                 | `cursor-visible: true`      |
| `auto-scroll`                | Boolean    | Automatically scrolls to keep the cursor visible.| `auto-scroll: true`         |
| `placeholder`                | String     | Sets the placeholder text.                      | `placeholder: "Enter text"` |
| `placeholder-color`          | Color      | Sets the color of the placeholder text.         | `placeholder-color: #AAAAAA`|
| `placeholder-align`          | String     | Aligns the placeholder text.                    | `placeholder-align: center` |
| `placeholder-font`           | String     | Specifies the font for the placeholder text.    | `placeholder-font: "verdana-11px"` |

---

This documentation provides a comprehensive guide to using `UITextEdit` in OTUI. It covers all the properties available for customizing the behavior and appearance of the text input field.