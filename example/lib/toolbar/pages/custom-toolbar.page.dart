import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:visual_editor/document/models/attributes/attributes.model.dart';
import 'package:visual_editor/visual-editor.dart';

import '../../shared/widgets/demo-page-scaffold.dart';
import '../../shared/widgets/loading.dart';

// Custom toolbar made from a mix of buttons (library and custom made buttons).
class CustomToolbarPage extends StatefulWidget {
  @override
  _CustomToolbarPageState createState() => _CustomToolbarPageState();
}

class _CustomToolbarPageState extends State<CustomToolbarPage> {
  EditorController? _controller;
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    _loadDocumentAndInitController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => _scaffold(
        children: _controller != null
            ? [
                _editor(),
                _toolbar(),
              ]
            : [
                Loading(),
              ],
      );

  Widget _scaffold({required List<Widget> children}) => DemoPageScaffold(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        ),
      );

  Widget _editor() => Flexible(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: VisualEditor(
            controller: _controller!,
            scrollController: _scrollController,
            focusNode: _focusNode,
            config: EditorConfigM(
              placeholder: 'Enter text',
            ),
          ),
        ),
      );

  Widget _toolbar() => Container(
        padding: EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 8,
        ),
        child: Column(
          children: [
            Text('Extended Toolbar'),
            EditorToolbar.basic(
              controller: _controller!,
              multiRowsDisplay: false,
              customButtons: [
                // Custom icon
                CustomToolbarButtonM(icon: Icons.favorite, onTap: () {}),
              ],
            ),
            Text('Custom Toolbar'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ToggleStyleButton(
                  attribute: AttributesM.bold,
                  icon: Icons.format_bold,
                  buttonsSpacing: 10,
                  iconSize: 30,
                  controller: _controller!,
                ),
                ToggleStyleButton(
                  attribute: AttributesM.italic,
                  icon: Icons.format_italic,
                  buttonsSpacing: 10,
                  iconSize: 30,
                  controller: _controller!,
                ),
                ToggleStyleButton(
                  attribute: AttributesM.small,
                  icon: Icons.format_size,
                  buttonsSpacing: 10,
                  iconSize: 30,
                  controller: _controller!,
                ),
                ColorButton(
                  icon: Icons.color_lens,
                  iconSize: 30,
                  controller: _controller!,
                  background: false,
                  buttonsSpacing: 10,
                ),
              ],
            ),
          ],
        ),
      );

  Future<void> _loadDocumentAndInitController() async {
    final deltaJson = await rootBundle.loadString(
      'lib/toolbar/assets/custom-toolbar.json',
    );
    final document = DeltaDocM.fromJson(jsonDecode(deltaJson));

    setState(() {
      _controller = EditorController(
        document: document,
      );
    });
  }
}
