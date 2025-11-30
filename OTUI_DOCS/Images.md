Here is the documentation for defining the style of an image in OTUI using the properties handled in uiwidgetimage.cpp.

---

# Defining Image Styles in OTUI

The `UIWidget` class supports various properties for styling images. These properties allow you to define the source, size, position, appearance, and behavior of images in your OTUI files.

---

## Image Style Properties

### 1. **Image Source**

- **`image-source`**: Specifies the source of the image.
  - **Type**: String.
  - **Format**: 
    - File path (e.g., `images/example.png`).
    - Base64-encoded string (e.g., `base64:...`).
    - `"none"` to remove the image.
  - **Example**:
    ```otui
    image-source: "images/example.png"
    image-source: "base64:...encoded-data..."
    image-source: "none"
    ```

---

### 2. **Image Position**

- **`image-offset-x`**: Sets the horizontal offset of the image.
  - **Type**: Integer.
  - **Example**: `image-offset-x: 10`

- **`image-offset-y`**: Sets the vertical offset of the image.
  - **Type**: Integer.
  - **Example**: `image-offset-y: 20`

- **`image-offset`**: Sets both horizontal and vertical offsets as a point.
  - **Type**: `Point` (e.g., `x y`).
  - **Example**: `image-offset: 10 20`

---

### 3. **Image Size**

- **`image-width`**: Sets the width of the image.
  - **Type**: Integer.
  - **Example**: `image-width: 100`

- **`image-height`**: Sets the height of the image.
  - **Type**: Integer.
  - **Example**: `image-height: 50`

- **`image-size`**: Sets both width and height of the image.
  - **Type**: `Size` (e.g., `width height`).
  - **Example**: `image-size: 100 50`

---

### 4. **Image Clipping**

- **`image-rect`**: Defines the rectangle of the image to be displayed.
  - **Type**: `Rect` (e.g., `x y width height`).
  - **Example**: `image-rect: 0 0 50 50`

- **`image-clip`**: Specifies the clipping rectangle for the image.
  - **Type**: `Rect` (e.g., `x y width height`).
  - **Example**: `image-clip: 10 10 40 40`

---

### 5. **Image Appearance**

- **`image-fixed-ratio`**: Maintains the aspect ratio of the image.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `image-fixed-ratio: true`

- **`image-repeated`**: Repeats the image to fill the widget.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `image-repeated: true`

- **`image-smooth`**: Enables smoothing for the image.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `image-smooth: true`

- **`image-color`**: Applies a color overlay to the image.
  - **Type**: `Color` (e.g., `#RRGGBBAA`).
  - **Example**: `image-color: #FF0000FF`

---

### 6. **Image Borders**

- **`image-border-top`**: Sets the top border size of the image.
  - **Type**: Integer.
  - **Example**: `image-border-top: 5`

- **`image-border-right`**: Sets the right border size of the image.
  - **Type**: Integer.
  - **Example**: `image-border-right: 5`

- **`image-border-bottom`**: Sets the bottom border size of the image.
  - **Type**: Integer.
  - **Example**: `image-border-bottom: 5`

- **`image-border-left`**: Sets the left border size of the image.
  - **Type**: Integer.
  - **Example**: `image-border-left: 5`

- **`image-border`**: Sets all border sizes to the same value.
  - **Type**: Integer.
  - **Example**: `image-border: 5`

---

### 7. **Image Behavior**

- **`image-auto-resize`**: Automatically resizes the widget to fit the image.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `image-auto-resize: true`

- **`image-individual-animation`**: Enables individual animation for animated textures.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `image-individual-animation: true`

---

## Example OTUI Definition

```otui
Widget
  id: exampleWidget
  image-source: "images/example.png"
  image-offset: 10 20
  image-size: 100 50
  image-fixed-ratio: true
  image-smooth: true
  image-border: 5
  image-color: #FFFFFF80
  image-auto-resize: true
```

---

This documentation provides a comprehensive overview of the image-related properties available in OTUI. These properties allow you to customize the appearance and behavior of images in your widgets.