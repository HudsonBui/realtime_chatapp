import 'package:flutter/material.dart';

class CallHoldingScreen extends StatefulWidget {
  const CallHoldingScreen({super.key});

  @override
  State<CallHoldingScreen> createState() => _CallHoldingScreenState();
}

class _CallHoldingScreenState extends State<CallHoldingScreen> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryColorLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    //TODO: Change with real user image 
                    backgroundImage: NetworkImage(
                        'https://th.bing.com/th/id/R.9d4e5d8f8e5c4b97a65a44c0052132ab?rik=Fvz9fHD37WlQWg&pid=ImgRaw&r=0'),
                    radius: 60,
                    backgroundColor: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    //TODO: Change with real user name
                    'Calling Cha Eun Woo...',
                    style: TextStyle(fontSize: 20, color: Colors.black45),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black45,
                  ),
                  onPressed: () {},
                  icon: const Icon(
                    Icons.mic_off,
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
                  onPressed: () {},
                  icon: const Icon(
                    Icons.videocam_off,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
