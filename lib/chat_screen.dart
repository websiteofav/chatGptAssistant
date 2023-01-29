import 'dart:async';
import 'dart:developer';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:chatgptassistant/chat_message.dart';
import 'package:chatgptassistant/environment.dart';
import 'package:chatgptassistant/utils/colors.dart';
import 'package:chatgptassistant/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  List<ChatMessage> _allQueries = [];
  ChatGPT? _chatGPT;
  StreamSubscription? _streamSubscription;
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  bool isListening = false, speechEnabled = false;

  ValueNotifier listenedText = ValueNotifier<String>('');

  @override
  void initState() {
    _chatGPT = ChatGPT.instance;
    _initSpeech();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _streamSubscription?.cancel();

    super.dispose();
  }

  void _initSpeech() async {
    speechEnabled = await _speechToText.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatGpt'),
        centerTitle: true,
        elevation: 12,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _allQueries.isEmpty
                ? const Expanded(
                    child: Center(child: Text('No queries available')))
                : Expanded(
                    child: ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(10),
                        itemCount: _allQueries.length,
                        shrinkWrap: true,
                        itemBuilder: ((context, index) {
                          return _allQueries[index];
                        })),
                  ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white24,
              ),
              child: _textFieldWidget(),
            )
          ],
        ),
      ),
    );
  }

  Widget _textFieldWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              onSubmitted: (value) =>
                  _textEditingController.text.trim().isNotEmpty
                      ? sendQuery()
                      : null,
              controller: _textEditingController,
              decoration:
                  const InputDecoration.collapsed(hintText: 'Enter your query'),
            ),
          ),
          IconButton(
            onPressed: () => _startListening(),
            icon: const Icon(
              Icons.keyboard_voice_rounded,
              color: coC54BE,
            ),
            color: Colors.black,
          ),
          IconButton(
            onPressed: () => _textEditingController.text.trim().isNotEmpty
                ? sendQuery()
                : null,
            icon: const Icon(Icons.send),
            color: Colors.black,
          )
        ],
      ),
    );
  }

  void sendQuery({QueryTypes queryType = QueryTypes.text}) {
    ChatMessage query = ChatMessage(
        text: queryType == QueryTypes.text
            ? _textEditingController.text
            : listenedText.value,
        sender: 'Avi');
    setState(() {
      _allQueries.insert(0, query);
    });

    _textEditingController.clear();

    final request = CompleteReq(
      prompt: query.text,
      model: kTranslateModelV3,
      max_tokens: 200,
    );

    _streamSubscription = _chatGPT!
        .builder(Environment.chatGPTKey)
        .onCompleteStream(request: request)
        .listen((response) {
      log(response.toString());
      ChatMessage botResponse =
          ChatMessage(text: response!.choices[0].text, sender: "Bot");

      setState(() {
        _allQueries.insert(0, botResponse);
      });
    });
  }

  void _startListening() async {
    if (speechEnabled) {
      _listeningDialog();
      debugPrint('stt initialized');
      isListening = true;
      _speechToText.listen(onResult: ((result) {
        listenedText.value = result.recognizedWords;
      }));

      Future.delayed(const Duration(seconds: 5), () {
        sendQuery(queryType: QueryTypes.voice);
        Navigator.of(context).pop();
      });
    }
  }

  void _listeningDialog() async {
    bool? result = await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: Colors.transparent,
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              content: ValueListenableBuilder(
                  valueListenable: listenedText,
                  builder: (BuildContext context, value, child) {
                    return SingleChildScrollView(
                      child: AvatarGlow(
                        endRadius: 70.0,
                        child: Column(
                          children: [
                            Text(
                              'Listening for 5 secs \n  ${listenedText.value}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            CircleAvatar(
                              backgroundColor: Colors.grey[100],
                              radius: 30.0,
                              child: IconButton(
                                icon: const Icon(Icons.mic),
                                onPressed: () {
                                  if (mounted) {
                                    isListening = false;
                                    _speechToText.stop();
                                    Navigator.of(context).pop(true);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ));
  }
}
