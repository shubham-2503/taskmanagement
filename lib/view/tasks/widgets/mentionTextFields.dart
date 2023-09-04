import 'package:flutter/material.dart';

class MentionTextField extends StatefulWidget {
  final TextEditingController controller;
  final List<String> users;
  final String hintText;

  MentionTextField({
    required this.controller,
    required this.users,
    required this.hintText,
  });

  @override
  _MentionTextFieldState createState() => _MentionTextFieldState();
}

class _MentionTextFieldState extends State<MentionTextField> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textEditingController = TextEditingController();
  List<String> _mentionSuggestions = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _textEditingController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _textEditingController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      setState(() {
        _mentionSuggestions = widget.users;
      });
    } else {
      // Hide mention suggestions here
      setState(() {
        _mentionSuggestions = [];
      });
    }
  }

  void _onTextChanged() {
    final text = _textEditingController.text;
    if (text.isNotEmpty && text.endsWith('@')) {
      // Show mention suggestions here
      setState(() {
        _mentionSuggestions = widget.users;
      });
    } else {
      // Hide mention suggestions here
      setState(() {
        _mentionSuggestions = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _textEditingController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: widget.hintText,
          ),
        ),
        if (_mentionSuggestions.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _mentionSuggestions.length,
              itemBuilder: (context, index) {
                String mention = _mentionSuggestions[index];
                return ListTile(
                  title: Text(mention),
                  onTap: () {
                    String currentText = _textEditingController.text;
                    int cursorPosition = _textEditingController.selection.baseOffset;
                    String newText = currentText.substring(0, cursorPosition) +
                        '$mention ' +
                        currentText.substring(cursorPosition);
                    _textEditingController.text = newText;
                    _textEditingController.selection = TextSelection.fromPosition(
                      TextPosition(offset: cursorPosition + mention.length + 2), // +2 to account for the "@" symbol and the space
                    );
                    setState(() {
                      _mentionSuggestions = [];
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}