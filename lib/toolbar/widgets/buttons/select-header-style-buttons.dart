import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../controller/controllers/editor-controller.dart';
import '../../../document/models/attributes/attribute.model.dart';
import '../../../document/models/attributes/attributes-aliases.model.dart';
import '../../../document/models/attributes/attributes.model.dart';
import '../../../editor/services/run-build.service.dart';
import '../../../shared/models/editor-icon-theme.model.dart';
import '../../../shared/state/editor-state-receiver.dart';
import '../../../shared/state/editor.state.dart';
import '../../../styles/services/styles.service.dart';
import '../../services/toolbar.service.dart';
import '../toolbar.dart';

// Lists the 3 (currently hardcoded) heading types.
// To be replaced with a dropdown in the future.
// ignore: must_be_immutable
class SelectHeaderStyleButtons extends StatefulWidget with EditorStateReceiver {
  final EditorController controller;
  final double iconSize;
  final double buttonsSpacing;
  final EditorIconThemeM? iconTheme;
  late EditorState _state;

  SelectHeaderStyleButtons({
    required this.controller,
    required this.buttonsSpacing,
    this.iconSize = defaultIconSize,
    this.iconTheme,
    Key? key,
  }) : super(key: key) {
    controller.setStateInEditorStateReceiver(this);
  }

  @override
  _SelectHeaderStyleButtonsState createState() =>
      _SelectHeaderStyleButtonsState();

  @override
  void cacheStateStore(EditorState state) {
    _state = state;
  }
}

class _SelectHeaderStyleButtonsState extends State<SelectHeaderStyleButtons> {
  late final RunBuildService _runBuildService;
  late final ToolbarService _toolbarService;
  late final StylesService _stylesService;

  AttributeM? _attr;
  StreamSubscription? _runBuild$L;

  @override
  void initState() {
    _runBuildService = RunBuildService(widget._state);
    _toolbarService = ToolbarService(widget._state);
    _stylesService = StylesService(widget._state);

    super.initState();
    _attr = _getHeaderAttr();
    _subscribeToRunBuild();
  }

  @override
  Widget build(BuildContext context) {
    final _valueToText = <AttributeM, String>{
      AttributesM.header: 'N',
      AttributesAliasesM.h1: 'H1',
      AttributesAliasesM.h2: 'H2',
      AttributesAliasesM.h3: 'H3',
    };

    final _valueAttribute = <AttributeM>[
      AttributesM.header,
      AttributesAliasesM.h1,
      AttributesAliasesM.h2,
      AttributesAliasesM.h3
    ];
    final _valueString = <String>['N', 'H1', 'H2', 'H3'];

    final theme = Theme.of(context);
    final style = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: widget.iconSize * 0.7,
    );
    final isSelectionHeaderEnabled =
        widget._state.disabledButtons.isSelectionHeaderEnabled;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        return Container(
          // ignore: prefer_const_constructors
          margin: EdgeInsets.symmetric(
            horizontal: !kIsWeb ? 1.0 : widget.buttonsSpacing,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(
              width: widget.iconSize * iconButtonFactor,
              height: widget.iconSize * iconButtonFactor,
            ),
            child: RawMaterialButton(
              hoverElevation: 0,
              highlightElevation: 0,
              elevation: 0,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  widget.iconTheme?.borderRadius ?? 2,
                ),
              ),
              fillColor: _valueToText[_attr] == _valueString[index]
                  ? (widget.iconTheme?.iconSelectedFillColor ??
                      theme.toggleableActiveColor)
                  : (widget.iconTheme?.iconUnselectedFillColor ??
                      theme.canvasColor),

              // Export a nice and clean version of this method in the styles service. Similar to other buttons.
              onPressed: isSelectionHeaderEnabled
                  ? () => _stylesService.formatSelection(
                        _valueAttribute[index],
                      )
                  : null,
              child: Text(
                _valueString[index],
                style: style.copyWith(
                  color: isSelectionHeaderEnabled
                      ? _valueToText[_attr] == _valueString[index]
                          ? (widget.iconTheme?.iconSelectedColor ??
                              theme.primaryIconTheme.color)
                          : (widget.iconTheme?.iconUnselectedColor ??
                              theme.iconTheme.color)
                      : theme.disabledColor,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  void didUpdateWidget(covariant SelectHeaderStyleButtons oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If a new controller was generated by setState() in the parent
    // we need to subscribe to the new state store.
    if (oldWidget.controller != widget.controller) {
      _runBuild$L?.cancel();
      widget.controller.setStateInEditorStateReceiver(widget);
      _subscribeToRunBuild();
      _attr = _getHeaderAttr();
    }
  }

  @override
  void dispose() {
    _runBuild$L?.cancel();
    super.dispose();
  }

  // === PRIVATE ===

  void _subscribeToRunBuild() {
    _runBuild$L = _runBuildService.runBuild$.listen(
      (_) => setState(() {
        _attr = _getHeaderAttr();
      }),
    );
  }

  AttributeM? _getHeaderAttr() {
    if (!_documentControllerInitialised) {
      return null;
    }

    final toggler = _toolbarService.getToolbarButtonToggler();
    final attribute = toggler[AttributesM.header.key];

    if (attribute != null) {
      // Checkbox tapping causes text selection to go to offset 0
      toggler.remove(AttributesM.header.key);

      return attribute;
    }

    final selectionStyle = _stylesService.getSelectionStyle();

    return selectionStyle.attributes[AttributesM.header.key] ??
        AttributesM.header;
  }

  bool get _documentControllerInitialised {
    return widget._state.refs.documentControllerInitialised == true;
  }
}
