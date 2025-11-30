The OTUI format is parsed and processed using the `OTMLDocument` and `OTMLNode` classes, which are part of the OTML (Open Tibia Markup Language) framework. Below is a documentation draft for the OTUI format:

---

# OTUI Format Documentation

The OTUI format is a custom markup language used in the OTClient project to define user interface elements, styles, and layouts. It is based on the OTML (Open Tibia Markup Language) framework and is parsed using the `OTMLDocument` and `OTMLNode` classes.

## Structure

An OTUI file consists of hierarchical nodes, where each node represents a widget, style, or property. Nodes can have attributes, child nodes, and values.

### Example

```otui
MainWindow
  size: 800 600
  background-color: #000000
  children:
    Button
      id: closeButton
      text: "Close"
      size: 100 50
      position: 700 550
```

### Key Components

1. **Nodes**: Represent elements in the UI, such as widgets or styles.
2. **Attributes**: Define properties of a node, such as size, position, or color.
3. **Child Nodes**: Represent nested elements or sub-widgets.

---

## Syntax

### Nodes

- Each node starts with a tag name.
- Tags can represent widgets, styles, or other UI elements.

### Attributes

- Attributes are defined as `key: value` pairs.
- Common attributes include:
  - `id`: A unique identifier for the widget.
  - `size`: The width and height of the widget.
  - `position`: The x and y coordinates of the widget.
  - `text`: The text displayed on the widget.
  - `background-color`: The background color of the widget.

### Child Nodes

- Child nodes are indented under their parent node.
- The `children` attribute can be used to group child nodes explicitly.

---

## Parsing and Validation

The OTUI format is parsed using the `OTMLDocument` and `OTMLNode` classes. Key methods include:

- `OTMLDocument::parse`: Parses an OTUI file or input stream into an OTML document.
- `OTMLNode::children`: Retrieves the child nodes of a given node.
- `UIManager::loadUI`: Loads an OTUI file and creates widgets based on its content.

### Error Handling

Errors in OTUI files are reported using the `OTMLException` class, which provides detailed error messages, including the source file and line number.

---

## Integration with OTClient

The OTUI format is tightly integrated with the OTClient project. Widgets and styles defined in OTUI files are processed and rendered using the `UIManager` class. Key methods include:

- `UIManager::createWidgetFromOTML`: Creates a widget from an OTML node.
- `UIManager::importStyleFromOTML`: Imports styles from an OTML document.

---

## Advanced Features

### Device-Specific Styles

The `UIManager::loadDeviceUI` method allows loading device-specific styles by appending a device name to the file name (e.g., `file.desktop.otui`).

### Dynamic UI Loading

The `UIManager::loadUIFromString` method enables loading UI definitions dynamically from a string.

---

## References

- OTMLDocument (/otclient/src/framework/otml/otmldocument.h)
- OTMLNode (/otclient/src/framework/otml/otmlnode.h)
- UIManager (/otclient/src/framework/ui/uimanager.h)
- OTMLException (/otclient/src/framework/otml/otmlexception.h)