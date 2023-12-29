import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  const ErrorText(
      {super.key,
      required this.text,
      required this.code,
      required this.scriptName,
      required this.moveToError});

  final String text;
  final String code;
  final String scriptName;
  final Function(int position) moveToError;

  int getPosition(String text, String code, String scriptName, Match match) {
    final indexSubstring =
        text.substring(match.start + scriptName.length + 1, match.end);

    final secondColonIndex = indexSubstring.indexOf(":");

    int rowNumber, characterNumber;
    if (secondColonIndex >= 0) {
      rowNumber = int.parse(indexSubstring.substring(0, secondColonIndex));
      characterNumber =
          int.parse(indexSubstring.substring(secondColonIndex + 1)) - 1;
    } else {
      rowNumber = int.parse(indexSubstring);
      characterNumber = 0;
    }

    int subtextLength = 0;
    code.split('\n').sublist(0, rowNumber - 1).forEach((row) {
      subtextLength += row.length;
    });

    return subtextLength + characterNumber + (rowNumber - 1);
  }

  @override
  Widget build(BuildContext context) {
    final regex = RegExp(r'' + scriptName + r':\d*(:\d*)?');
    const normalTextStyle = TextStyle(color: Colors.red);
    const clickableTextStyle = TextStyle(color: Colors.blue);

    final matches = regex.allMatches(text);

    List<TextSpan> widgetList = [];
    int previousEnd = 0;
    for (final match in matches) {
      final normalText = text.substring(previousEnd, match.start);
      final clickableText = text.substring(match.start, match.end);
      previousEnd = match.end;

      final normalTextWidget =
          TextSpan(text: normalText, style: normalTextStyle);
      final clickableTextWidget = TextSpan(
          text: clickableText,
          style: clickableTextStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              moveToError(getPosition(text, code, scriptName, match));
            });

      widgetList.addAll([normalTextWidget, clickableTextWidget]);
    }

    final leftoverText = text.substring(previousEnd, text.length);
    widgetList.add(TextSpan(text: leftoverText, style: normalTextStyle));

    return RichText(
        text: TextSpan(
      style: normalTextStyle,
      children: widgetList,
    ));
  }
}
