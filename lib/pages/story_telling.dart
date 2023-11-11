import 'package:flutter/material.dart';
import 'story.dart';
import 'story_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StoryTelling extends StatelessWidget {
  const StoryTelling({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Noted',
      home: StorytellingApp(),
    );
  }
}

class StorytellingApp extends StatefulWidget {
  const StorytellingApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StorytellingAppState createState() => _StorytellingAppState();
}

class _StorytellingAppState extends State<StorytellingApp> {
  List<Story> stories = [];
  TextEditingController sentenceController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  Set<int> checkedIndices = {};

  @override
  void initState() {
    super.initState();
    _loadStories();
    _loadCheckedIndices();
  }

  Future<void> _loadStories() async {
    final prefs = await SharedPreferences.getInstance();
    final storiesJson = prefs.getStringList('stories') ?? [];
    setState(() {
      stories =
          storiesJson.map((json) => Story.fromMap(jsonDecode(json))).toList();
    });
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

  Future<void> _saveStories() async {
    final prefs = await SharedPreferences.getInstance();
    final storiesJson =
        stories.map((story) => jsonEncode(story.toMap())).toList();
    prefs.setStringList('stories', storiesJson);
  }

  void addSentence(Story? selectedStory) {
    setState(() {
      String newSentence = sentenceController.text;
      if (newSentence.isNotEmpty && selectedStory != null) {
        Story story = stories.firstWhere((s) => s.id == selectedStory.id);
        story.sentences.add(newSentence);
        sentenceController.clear();
        _saveStories();
      }
    });
  }

  void addStory(String title) {
    setState(() {
      String id = DateTime.now().millisecondsSinceEpoch.toString();
      stories.add(Story(id: id, title: title, sentences: []));
      _saveStories();
    });
  }

  void deleteStory(int index) {
    setState(() {
      stories.removeAt(index);
      _saveStories();
    });
  }

  void editStory(int index, String newTitle) {
    setState(() {
      stories[index].title = newTitle;
      _saveStories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildHomePage(),
    );
  }

  Widget _buildHomePage() {
    return Column(
      children: [
        const Padding(padding: EdgeInsets.only(top: 5)),
        Expanded(
          child: ListView.builder(
            itemCount: stories.length,
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
                          color: Colors.black26,
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
                        child: Text(
                          stories[index].title,
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.grey.shade50,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Edit Title'),
                                  content: TextField(
                                    controller: TextEditingController()
                                      ..text = stories[index].title,
                                    onChanged: (newText) {
                                      stories[index].title = newText;
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
                                        editStory(index, stories[index].title);
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
                            deleteStory(index);
                          },
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoryDetail(
                            story: stories[index], onSave: _saveStories),
                      ),
                    );
                  },
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
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: Colors.black),
                        cursorColor: Colors.black,
                        controller: searchController,
                        decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade200),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade200),
                            ),
                            hintText: 'New Note',
                            hintStyle: const TextStyle(color: Colors.black),
                            focusColor: Colors.black,
                            prefixIcon: const Icon(
                              Icons.note_add,
                              color: Colors.black,
                            )),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        addStory(searchController.text);
                        searchController.clear();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
