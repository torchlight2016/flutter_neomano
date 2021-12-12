import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neomano/domain/entities/device.dart';
import 'package:neomano/domain/usecases/control_device_usecase.dart';
import 'package:neomano/presentation/viewmodels/control_device_viewmodel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../locator.dart';

class ControlDevicePage extends StatefulWidget {
  static const routeName = 'DeviceControlPage';

  final Device device;
  const ControlDevicePage({Key key, this.device}) : super(key: key);

  @override
  _ControlDevicePageState createState() =>
      _ControlDevicePageState(getIt.get<ControlDeviceViewModel>());
}

class _ControlDevicePageState extends State<ControlDevicePage> {
  final deviceMotionMinSpeed = 0.0;
  final deviceMotionMaxSpeed = 6.0;

  final grabWord = ['grab', '쥐다'];
  final releaseWord = ['release', '펴다'];
  final stop = ['stop', '중지'];

  final ControlDeviceViewModel _controlDeviceViewModel;
  double _speedSliderValue = 3;

  var _speechInitialized = false;
  var _stopSpeech = false;
  var _speechText = '';
  String _actionBySpeech;
  var _speechListening = false;

  _ControlDevicePageState(this._controlDeviceViewModel);

  var speechApi = SpeechApi();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _controlDeviceViewModel.disconnectDevice();
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(ControlDevicePage.routeName),
          actions: [
            Center(
                child: FlatButton(
                    onPressed: () {
                      _controlDeviceViewModel.disconnectDevice();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'disconnect',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    )))
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(border: Border.all(width: 1)),
                    child: GestureDetector(
                        onTap: () {},
                        onTapDown: _onGripTapDown,
                        onTapUp: _onGripTapUp,
                        child: Container(
                            width: 100,
                            padding: const EdgeInsets.all(8.0),
                            child: Center(child: Text("Grab")))),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(border: Border.all(width: 1)),
                    child: GestureDetector(
                        onTap: () {},
                        onTapDown: _onReleaseTapDown,
                        onTapUp: _onReleaseTapUp,
                        child: Container(
                            width: 100,
                            padding: const EdgeInsets.all(8.0),
                            child: Center(child: Text("Release")))),
                  ),
                ],
              ),
            ),
            Slider(
                value: _speedSliderValue,
                min: deviceMotionMinSpeed,
                max: deviceMotionMaxSpeed,
                divisions: deviceMotionMaxSpeed.toInt(),
                label: _speedSliderValue.round().toString(),
                onChanged: (value) {
                  setState(() {
                    _speedSliderValue = value;
                  });
                }),
            Center(child: Text(grabWord.toString())),
            Center(child: Text(releaseWord.toString())),
            Center(child: Text(stop.toString())),
            SizedBox(height: 20),
            Center(child: Text(_speechText, maxLines: 3)),
            if (_actionBySpeech != null)
              Center(
                  child: Text(_actionBySpeech,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor, fontSize: 16)))
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: AvatarGlow(
          animate: _speechListening,
          endRadius: 100,
          glowColor: Theme.of(context).primaryColor,
          child: FloatingActionButton(
            onPressed: () {
              _toggleSTT();
            },
            child:
                Icon(_speechListening ? Icons.mic : Icons.mic_none, size: 36),
          ),
        ),
      ),
    );
  }

  _onGripTapDown(TapDownDetails tapDownDetails) {
    _controlDeviceViewModel.controlDevice(ControlDeviceParam(DeviceAction.start,
        direction: DeviceDirection.grip, speed: _speedSliderValue.toInt()));
  }

  _onGripTapUp(TapUpDetails tapDownDetails) {
    _controlDeviceViewModel
        .controlDevice(ControlDeviceParam(DeviceAction.stop));
  }

  _onReleaseTapDown(TapDownDetails tapDownDetails) {
    _controlDeviceViewModel.controlDevice(ControlDeviceParam(DeviceAction.start,
        direction: DeviceDirection.release, speed: _speedSliderValue.toInt()));
  }

  _onReleaseTapUp(TapUpDetails tapDownDetails) {
    _controlDeviceViewModel
        .controlDevice(ControlDeviceParam(DeviceAction.stop));
  }

  _startSpeechListening() async {
    SpeechToText speech = SpeechToText();
    await speech.listen(onResult: (result) {
      setState(() {
        _speechText = result.recognizedWords.toLowerCase();
        _actionBySpeech = null;
      });
      _recognizeWord(_speechText);
      if (speech.isListening) _startSpeechListening();
    });
  }

  _toggleSTT() async {
    SpeechToText speech = SpeechToText();
    if (_speechListening) {
      _stopSpeech = true;
      await speech.stop();
    } else {
      // Map<Permission, PermissionStatus> statuses =
      await [
        Permission.microphone,
      ].request();

      if (await Permission.location.isPermanentlyDenied) {
        openAppSettings();
        return;
      }

      if (await Permission.microphone.isGranted) {
        if (_speechInitialized == false) {
          _speechInitialized =
              await speech.initialize(onStatus: (status) async {
            if (status == SpeechToText.listeningStatus) {
              setState(() {
                _speechListening = true;
              });
            } else if (status == SpeechToText.notListeningStatus) {
              if (_stopSpeech) {
                setState(() {
                  _speechListening = false;
                });
              }
              else {
                await speech.stop();
                await Future.delayed(Duration(milliseconds: 100));
                await _startSpeechListening();
              }
            }
            logger.d('[speech.initialize]status=$status,stop=$_stopSpeech');
          }, onError: (error) async {
            logger.e('[speech.initialize]', error);
            await speech.stop();
            await Future.delayed(Duration(milliseconds: 100));
            await _startSpeechListening();

            if (error.errorMsg == 'error_speech_timeout' ||
                error.errorMsg == 'error_no_match') {}
          });
        }
        if (_speechInitialized) {
          _stopSpeech = false;
          await _startSpeechListening();
        }
      }
    }
  }

  _recognizeWord(String speechText) {

    if (grabWord.any((word) => speechText.contains(word))) {
      setState(() {
        _actionBySpeech = 'GRAB';
      });
      _controlDeviceViewModel.controlDevice(ControlDeviceParam(
          DeviceAction.start,
          direction: DeviceDirection.grip,
          speed: _speedSliderValue.toInt()));
    } else if (releaseWord.any((word) => speechText.contains(word))) {
      setState(() {
        _actionBySpeech = 'RELEASE';
      });
      _controlDeviceViewModel.controlDevice(ControlDeviceParam(
          DeviceAction.start,
          direction: DeviceDirection.release,
          speed: _speedSliderValue.toInt()));
    } else if (stop.any((word) => speechText.contains(word))) {
      setState(() {
        _actionBySpeech = 'STOP';
      });
      _controlDeviceViewModel
          .controlDevice(ControlDeviceParam(DeviceAction.stop));
    }
  }
}

class SpeechApi {
  static final _speech = SpeechToText();

  static Future<bool> toggleRecording({
    @required Function(String text) onResult,
    @required ValueChanged<bool> onListening,
  }) async {
    if (_speech.isListening) {
      _speech.stop();
      return true;
    }

    final isAvailable = await _speech.initialize(
      onStatus: (status) => onListening(_speech.isListening),
      onError: (e) => print('Error: $e'),
    );

    if (isAvailable) {
      _speech.listen(onResult: (value) => onResult(value.recognizedWords));
    }

    return isAvailable;
  }
}
