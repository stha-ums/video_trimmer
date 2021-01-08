import 'dart:io';

import 'package:example/preview.dart';
import 'package:example/trimmer_view.dart';
import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:video_trimmer/video_trimmer.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Trimmer _trimmer = Trimmer();
  String outputPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Trimmer"),
      ),
      body: ListView(
        children: [
          RaisedButton(
            child: Text("LOAD VIDEO"),
            onPressed: () async {
              FilePickerResult result = await FilePicker.platform.pickFiles(
                type: FileType.video,
                allowCompression: false,
              );
              if (result != null) {
                File file = File(result.files.single.path);
                print(file.path);
                await _trimmer.loadVideo(videoFile: file);
                outputPath = null;
                setState(() {});
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return TrimmerView(_trimmer);
                  }),
                );
                setState(() {});
              }
            },
          ),
          if (outputPath != null)
            Container(height: 500, child: Preview(outputPath))
        ],
      ),
    );
  }
}
