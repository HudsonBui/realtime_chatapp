import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:realtime_chatapp/models/user_models.dart';
import 'package:realtime_chatapp/screen/call_screen/call_holding_screen.dart';
import 'package:realtime_chatapp/services/agora_token_service.dart';
import 'package:realtime_chatapp/utils/utils.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen(
      {required this.chatId, required this.participants, super.key});
  final List<UserModel> participants;
  final String chatId;

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  String channelName = '';
  int? _remoteUid;
  bool _localUserJoined = false;
  bool _remoteUserJoined = false;
  late RtcEngine _engine;
  bool isMute = false;
  bool isVideoOff = false;

  @override
  void initState() {
    super.initState();
    debugPrint('Initialize Agora Engine');
    _initializeAgora();
  }

  void _initializeAgora() async {
    if (widget.chatId.isEmpty) {
      return null;
    }
    channelName = widget.chatId;
    await [Permission.camera, Permission.microphone].request();

    // Initialize the Agora engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      const RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication1v1,
      ),
    );

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print("local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("remote user $remoteUid joined");
          setState(() {
            _remoteUserJoined = true;
            print(
                'User join the meeting (UI - VideoCallScreen): $_remoteUserJoined');
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          print("remote user $remoteUid left channel");
          setState(() {
            _remoteUserJoined = false;
            debugPrint(
                'User leave the meeting (UI - VideoCallScreen): $_remoteUserJoined');
            _remoteUid = null;
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );

    /// Enable video
    /// this is also comment
    /// other comment, just need /// + enter
    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();
  }

  Future joinChannel(token) async {
    await _engine.joinChannel(
      //Create temp token and channel name base on need
      token: tempToken,
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    _dispose();
    debugPrint('Dispose Agora Engine');
    super.dispose();
  }

  Future<void> _dispose() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

  @override
  Widget build(BuildContext context) {
    var channelName = widget.chatId;
    return FutureBuilder(
      future: getAgoraToken(channelName, 0),
      builder: (ctx, snp) {
        if (snp.connectionState == ConnectionState.waiting) {
          return const CallHoldingScreen();
        }
        if (snp.hasError) {
          debugPrint('Token Error: ${snp.error}');
          return const Center(
            child: Text('Failed to get token'),
          );
        } else {
          debugPrint('AGORA TOKEN (video_call_screen.dart): ${snp.data}');
          return FutureBuilder(
              future: joinChannel(snp.data.toString()),
              builder: (stx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CallHoldingScreen();
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Failed to join channel'),
                  );
                } else {
                  return _remoteUserJoined
                      ? Scaffold(
                          appBar: AppBar(
                            title: const Text('Agora Video Call'),
                          ),
                          body: Stack(
                            children: [
                              Center(
                                child: _remoteVideo(),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: SizedBox(
                                  width: 100,
                                  height: 150,
                                  child: Center(
                                    child: _localUserJoined
                                        ? AgoraVideoView(
                                            controller: VideoViewController(
                                              rtcEngine: _engine,
                                              canvas: const VideoCanvas(uid: 0),
                                            ),
                                          )
                                        : const CircularProgressIndicator(),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.black45,
                                        ),
                                        onPressed: () {
                                          _engine.muteLocalAudioStream(isMute);
                                          setState(() {
                                            isMute = !isMute;
                                          });
                                        },
                                        icon: isMute
                                            ? const Icon(
                                                Icons.mic_off,
                                                size: 30,
                                                color: Colors.white,
                                              )
                                            : const Icon(
                                                Icons.mic,
                                                size: 30,
                                                color: Colors.white,
                                              ),
                                      ),
                                      IconButton(
                                        padding: const EdgeInsets.all(20),
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        icon: const Icon(
                                          Icons.call_end,
                                          size: 35,
                                          color: Colors.white,
                                        ),
                                      ),
                                      IconButton(
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.black45,
                                        ),
                                        onPressed: () {
                                          _engine.disableVideo();
                                          setState(() {
                                            isVideoOff = !isVideoOff;
                                          });
                                        },
                                        icon: isVideoOff
                                            ? const Icon(
                                                Icons.videocam_off,
                                                size: 30,
                                                color: Colors.white,
                                              )
                                            : const Icon(
                                                Icons.videocam,
                                                size: 30,
                                                color: Colors.white,
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const CallHoldingScreen();
                }
              });
        }
      },
    );
  }

  Widget _remoteVideo() {
    if (_remoteUid != null && channelName.isNotEmpty) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: channelName),
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }
}
