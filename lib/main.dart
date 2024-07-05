import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'dart:html' as html;
// import 'dart:io' if (dart.library.html) 'dart:ui' as ui;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // ui.platformViewRegistry.registerViewFactory(
  //     'example', (_) => html.DivElement()..innerText = 'Hello, HTML!');
  try {
    MediaKit.ensureInitialized();
  } catch (e) {
    print(e.toString());
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final player = Player();
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    checkPermissions();
  }

  void checkPermissions() async {
    try {
      if (!kIsWeb) {
        if (Platform.isAndroid) {
          int sdkInt = (await getSdkInt());
          if (sdkInt >= 33) {
            // Android 13 or higher (API level 33)
            // Video permissions.
            if (await Permission.videos.isDenied ||
                await Permission.videos.isPermanentlyDenied) {
              final state = await Permission.videos.request();
              if (!state.isGranted) {
                await SystemNavigator.pop();
              }
            }
            // Audio permissions.
            if (await Permission.audio.isDenied ||
                await Permission.audio.isPermanentlyDenied) {
              final state = await Permission.audio.request();
              if (!state.isGranted) {
                await SystemNavigator.pop();
              }
            }
          } else {
            if (await Permission.storage.isDenied ||
                await Permission.storage.isPermanentlyDenied) {
              final state = await Permission.storage.request();
              if (!state.isGranted) {
                await SystemNavigator.pop();
              }
            }
          }
        } else if (Platform.isIOS) {
          // iOS specific permissions
          if (await Permission.photos.isDenied ||
              await Permission.photos.isPermanentlyDenied) {
            final state = await Permission.photos.request();
            if (!state.isGranted) {
              await SystemNavigator.pop();
            }
          }
          if (await Permission.microphone.isDenied ||
              await Permission.microphone.isPermanentlyDenied) {
            final state = await Permission.microphone.request();
            if (!state.isGranted) {
              await SystemNavigator.pop();
            }
          }
        }
      }
    } catch (e) {
      print(e.toString());
    }
    // Play a [Media] or [Playlist].
    player.open(Media('rtsp://guardnet.selfip.com:7100'));
  }

  Future<int> getSdkInt() async {
    try {
      final String sdkIntString =
          await const MethodChannel('getSdkInt').invokeMethod('getSdkInt');
      return int.parse(sdkIntString);
    } catch (e) {
      return 0; // default to 0 if unable to retrieve SDK version
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialDesktopVideoControlsTheme(
      normal: MaterialDesktopVideoControlsThemeData(
        // Modify theme options:
        seekBarThumbColor: Colors.blue,
        seekBarPositionColor: Colors.blue,
        toggleFullscreenOnDoublePress: true,
        // Modify top button bar:
        topButtonBar: [
          const Spacer(),
          MaterialDesktopCustomButton(
            onPressed: () {
              debugPrint('Custom "Settings" button pressed.');
            },
            icon: const Icon(Icons.settings),
          ),
        ],
        // Modify bottom button bar:
        bottomButtonBar: [
          MaterialButton(
            onPressed: () {},
            child: StreamBuilder<bool>(
                initialData: false,
                stream: player.stream.playing,
                builder: (context, snapshot) {
                  return Icon(snapshot.data! ? Icons.stop : Icons.play_arrow);
                }),
          ),
        ],
      ),
      fullscreen: const MaterialDesktopVideoControlsThemeData(
        displaySeekBar: true,
        automaticallyImplySkipNextButton: true,
        automaticallyImplySkipPreviousButton: true,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width * 9.0 / 16.0,
              child: Video(
                controller: controller,
                subtitleViewConfiguration:
                    const SubtitleViewConfiguration(visible: true),
                //                controls: (state) {
                //   return Center(
                //     child: IconButton(
                //       onPressed: () {
                //         state.widget.controller.player.playOrPause();
                //       },
                //       icon: StreamBuilder(
                //         stream: state.widget.controller.player.stream.playing,
                //         builder: (context, playing) => Icon(
                //           playing.data == true ? Icons.pause : Icons.play_arrow,
                //         ),
                //       ),
                //       // It's not necessary to use [StreamBuilder] or to use [Player] & [VideoController] from [state].
                //       // [StreamSubscription]s can be made inside [initState] of this widget.
                //     ),
                //   );
                // },
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
              height: 45,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    color: Colors.white,
                    onPressed: () async {
                      await player.previous();
                    },
                    iconSize: 28,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  StreamBuilder<bool>(
                      initialData: false,
                      stream: player.stream.playing,
                      builder: (context, snapshot) {
                        return IconButton(
                          icon: Icon(
                              snapshot.data! ? Icons.pause : Icons.play_arrow),
                          color: Colors.white,
                          onPressed: () async {
                            await player.playOrPause();
                          },
                          iconSize: 28,
                        );
                      }),
                  const SizedBox(
                    width: 10,
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    color: Colors.white,
                    onPressed: () async {
                      await player.next();
                    },
                    iconSize: 28,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
