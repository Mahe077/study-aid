import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DrawingController _drawingController = DrawingController();
  Color _currentColor = Colors.black;
  double _currentStrokeWidth = 5.0;
  bool _isWritingMode = false;
  final quill.QuillController _quillController = quill.QuillController.basic();
  final FocusNode _focusNode = FocusNode();

  void _pickColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Pick a color"),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _currentColor,
            onColorChanged: (color) {
              setState(() {
                _currentColor = color;
                _drawingController.setStyle(color: _currentColor);
              });
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text("Got it"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _toggleMode() {
    setState(() {
      _isWritingMode = !_isWritingMode;
    });
  }

  void _saveTextToCanvas() {
    final text = _quillController.document.toPlainText();
    // Here you can add logic to save the text to the canvas
    // For simplicity, we'll just print the text
    print(text);

    setState(() {
      _isWritingMode = false;
    });
  }

  Widget _actions() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.color_lens),
              onPressed: _pickColor,
            ),
            IconButton(
              icon: Icon(Icons.undo),
              onPressed: () => _drawingController.undo(),
            ),
            IconButton(
              icon: Icon(Icons.redo),
              onPressed: () => _drawingController.redo(),
            ),
            IconButton(
              icon: Icon(Icons.rotate_right),
              onPressed: () => _drawingController.turn(),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _drawingController.clear(),
            ),
            Expanded(
              child: Slider(
                value: _currentStrokeWidth,
                min: 1.0,
                max: 20.0,
                divisions: 19,
                label: _currentStrokeWidth.round().toString(),
                onChanged: (value) {
                  setState(() {
                    _currentStrokeWidth = value;
                    _drawingController.setStyle(
                        strokeWidth: _currentStrokeWidth);
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuillEditor() {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: quill.QuillEditor.basic(
              configurations: quill.QuillEditorConfigurations(
                controller: _quillController,
              ),
              // readOnly: false,
              focusNode: _focusNode,
            ),
          ),
        ),
        quill.QuillToolbar.simple(
          configurations: quill.QuillSimpleToolbarConfigurations(
            controller: _quillController,
            multiRowsDisplay: false,
          ),
        ),
        ElevatedButton(
          onPressed: _saveTextToCanvas,
          child: Text('Save Text to Canvas'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawing Test'),
        actions: [
          ElevatedButton(
            onPressed: _toggleMode,
            child: Text(
                _isWritingMode ? 'Switch to Drawing' : 'Switch to Writing'),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return DrawingBoard(
                      controller: _drawingController,
                      background: Container(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        color: Colors.white,
                      ),
                      showDefaultActions: false,
                      showDefaultTools: true,
                    );
                  },
                ),
              ),
            ],
          ),
          _actions(),
          if (_isWritingMode) _buildQuillEditor(),
        ],
      ),
    );
  }
}
