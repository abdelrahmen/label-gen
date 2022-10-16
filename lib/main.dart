import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ImagePicker picker = ImagePicker();
  XFile? image;
  String? result;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Labeler"),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              image = null;
              result = null;
            }),
            child: const Text("Clear"),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 250,
                  width: 260,
                  color: Colors.grey,
                  child: (image == null)
                      ? null
                      : Image(
                          image: FileImage(File(image!.path)),
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //gallery button
                    InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () async {
                        await picker
                            .pickImage(source: ImageSource.gallery)
                            .then((value) {
                          setState(() {
                            image = value;
                          });
                          final inputImage = InputImage.fromFilePath(value!.path);
                          startLabeling(inputImage, 0.7).then((value) {
                            setState(() {
                              result = value;
                            });
                          });
                        });
                      },
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.photo),
                            Text("Gallery"),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    // camera button
                    InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () async{
                         await picker
                            .pickImage(source: ImageSource.camera)
                            .then((value) {
                          setState(() {
                            image = value;
                          });
                          final inputImage = InputImage.fromFilePath(value!.path);
                          startLabeling(inputImage, 0.7).then((value) {
                            setState(() {
                              result = value;
                            });
                          });
                        });
                      },
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.camera_alt),
                            Text("Camera"),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                if (result != null) Text("$result"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> startLabeling(inputImage, double confidence) async {
    final ImageLabelerOptions options = ImageLabelerOptions(
      confidenceThreshold: confidence,
    );
    final imageLabeler = ImageLabeler(options: options);
    String result = "";
    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
    for (var prediction in labels) {
      result += prediction.label;
      result += " : ";
      result += "${prediction.confidence.toStringAsFixed(2)}%\n\n";
    }
    imageLabeler.close();
    return result;
  }
}
