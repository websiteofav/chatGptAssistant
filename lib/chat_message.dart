import 'package:chatgptassistant/utils/colors.dart';
import 'package:chatgptassistant/utils/constants.dart';
import 'package:chatgptassistant/utils/tts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key, required this.text, required this.sender});
  final String text;
  final String sender;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: sender == botName
          ? EdgeInsets.only(
              right: MediaQuery.of(context).size.width / 3,
              left: 5.0,
              top: 30.0,
            )
          : EdgeInsets.only(
              left: MediaQuery.of(context).size.width / 3,
              right: 5.0,
              top: 15.0,
            ),
      decoration: BoxDecoration(
          color: sender == botName ? cC3B9B9 : c767272,
          borderRadius: sender == botName
              ? const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  bottomRight: Radius.circular(20),
                  topRight: Radius.circular(20))
              : const BorderRadius.only(
                  topRight: Radius.circular(50),
                  bottomLeft: Radius.circular(20),
                  topLeft: Radius.circular(20),
                )),
      alignment:
          sender == botName ? Alignment.centerLeft : Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 15, left: 15),
                child: CircleAvatar(
                  radius: 15,
                  child: Text(sender[0]),
                ),
              ),
              Text(
                sender,
                style: TextStyle(
                    color: sender == botName ? black : cffffff,
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              IconButton(
                  onPressed: () {
                    TextToSpeech.convertToSpeech(text);
                  },
                  icon: Icon(
                    Icons.spatial_audio_off_rounded,
                    color: sender == botName ? black : cffffff,
                  ))
            ],
          ),
          Container(
            margin: const EdgeInsets.only(left: 60),
            child: Text(
              text,
              style: TextStyle(
                  color: sender == botName ? black : cffffff,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
