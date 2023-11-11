import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'story.dart';

class StoryDetail extends StatefulWidget {
  final Story story;
  final Function onSave;

  const StoryDetail({super.key, required this.story, required this.onSave});

  @override
  // ignore: library_private_types_in_public_api
  _StoryDetailState createState() => _StoryDetailState();
}

class _StoryDetailState extends State<StoryDetail> {
  TextEditingController sentenceController = TextEditingController();
  Set<int> checkedIndices = {};

  @override
  void initState() {
    super.initState();
    _loadCheckedIndices();
  }

  Future<void> _saveCheckedIndices() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('checkedIndices',
        checkedIndices.map((index) => index.toString()).toList());
  }

  Future<void> _loadCheckedIndices() async {
    final prefs = await SharedPreferences.getInstance();
    final loadedIndices = prefs.getStringList('checkedIndices') ?? [];
    setState(() {
      checkedIndices = loadedIndices.map((index) => int.parse(index)).toSet();
    });
  }

  void addSentence() {
    setState(() {
      String newSentence = sentenceController.text;
      if (newSentence.isNotEmpty) {
        widget.story.sentences.add(newSentence);
        sentenceController.clear();
        widget.onSave();
      }
    });
  }

  void deleteSentence(int index) {
    setState(() {
      widget.story.sentences.removeAt(index);
      widget.onSave();
    });
  }

  void editSentence(int index, String newText) {
    setState(() {
      widget.story.sentences[index] = newText;
      widget.onSave();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.story.title,
          style: const TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.grey.shade600),
        backgroundColor: Colors.grey.shade400,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(padding: EdgeInsets.only(top: 10)),
          Expanded(
            child: ListView.builder(
              itemCount: widget.story.sentences.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey.shade200,
                      boxShadow: [
                        const BoxShadow(
                            offset: Offset(10, 10),
                            color: Colors.black38,
                            blurRadius: 20),
                        BoxShadow(
                            offset: const Offset(-10, -10),
                            color: Colors.white.withOpacity(0.85),
                            blurRadius: 20)
                      ]),
                  child: ListTile(
                    title: Row(
                      children: [
                        Checkbox(
                          value: checkedIndices.contains(index),
                          onChanged: (value) {
                            setState(() {
                              if (value != null && value) {
                                checkedIndices.add(index);
                              } else {
                                checkedIndices.remove(index);
                              }
                              _saveCheckedIndices();
                            });
                          },
                          activeColor: Colors.black,
                        ),
                        Expanded(
                          child: Text(widget.story.sentences[index]),
                        ),
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.grey.shade50,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Edit Sentence'),
                                    content: TextField(
                                      controller: TextEditingController()
                                        ..text = widget.story.sentences[index],
                                      onChanged: (newText) {
                                        widget.story.sentences[index] = newText;
                                      },
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          editSentence(index,
                                              widget.story.sentences[index]);
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'Save',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(left: 10)),
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.grey.shade900,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              // Delete the sentence
                              deleteSentence(index);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              height: 70,
              width: 500,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade200,
                  boxShadow: [
                    const BoxShadow(
                        offset: Offset(10, 10),
                        color: Colors.black38,
                        blurRadius: 20),
                    BoxShadow(
                        offset: const Offset(-10, -10),
                        color: Colors.white.withOpacity(0.85),
                        blurRadius: 20)
                  ]),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: sentenceController,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.abc),
                        hintText: 'Add Text',
                        labelStyle: const TextStyle(color: Colors.black),
                        prefixIconColor: Colors.black,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: addSentence,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
