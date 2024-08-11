import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:realtime_chatapp/models/user_models.dart';
import 'package:realtime_chatapp/pages/edit_profile/edit_profile.dart';
import 'package:realtime_chatapp/providers/account_provider.dart';
import 'package:realtime_chatapp/services/user_status_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime/mime.dart';

class MainNavBar extends ConsumerStatefulWidget {
  const MainNavBar({super.key});

  @override
  ConsumerState<MainNavBar> createState() => _MainNavBarState();
}

class _MainNavBarState extends ConsumerState<MainNavBar> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(accountInformationNotifierProvider);
    File? pickedImageFile;

    String getImageExtension(String imagePath) {
      final mimeType = lookupMimeType(imagePath);
      return mimeType!.split('.').last;
    }

    //What to do when the user picks an image
    Future handleImage(XFile pickedImage, UserModel user) async {
      var imageExtension = getImageExtension(pickedImage.path);
      print('Image extension: $imageExtension');
      try {
        final storageRef =
            FirebaseStorage.instance.ref().child('user_avatar').child(user.uid);
        final metaData = SettableMetadata(
          contentType: imageExtension,
        );
        await storageRef.putFile(File(pickedImage.path), metaData);
      } on FirebaseException catch (e) {
        print(e);
      }
      print(user.uid);
      var imageUrl = await FirebaseStorage.instance
          .ref('user_avatar/${user.uid}')
          .getDownloadURL();
      print('Image URL: $imageUrl');
      ref.read(accountInformationNotifierProvider.notifier).updateUser(
            UserModel(
              uid: user.uid,
              fName: user.fName,
              lName: user.lName,
              phone: user.phone,
              email: user.email,
              photoUrl: imageUrl,
              isProfileComplete: user.isProfileComplete,
              dateOfBirth: user.dateOfBirth,
            ),
          );
      Navigator.of(context).pop();
    }

    //Get the image extension for the uploading image to Firebase Storage

    return Drawer(
      child: user.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
          data: (user) {
            return Column(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text('${user.fName} ${user.lName}'),
                  accountEmail: Text(user.email),
                  currentAccountPicture: GestureDetector(
                    onTap: () {
                      //TODO: Implement avatar tap
                      showDialog(
                        context: context,
                        builder: (ctx) {
                          return Dialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Change your avatar',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        icon: const Icon(Icons.close),
                                        iconSize: 20,
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton(
                                        onPressed: () async {
                                          final pickedImage =
                                              await ImagePicker().pickImage(
                                                  source: ImageSource.camera,
                                                  imageQuality: 50,
                                                  maxWidth: 150,
                                                  maxHeight: 150);
                                          if (pickedImage == null) {
                                            return;
                                          }
                                          await handleImage(pickedImage, user);
                                        },
                                        child: const Text('Take a photo'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          final pickedImage =
                                              await ImagePicker().pickImage(
                                                  source: ImageSource.gallery,
                                                  imageQuality: 50,
                                                  maxWidth: 150,
                                                  maxHeight: 150);
                                          if (pickedImage == null) {
                                            return;
                                          }
                                          await handleImage(pickedImage, user);
                                        },
                                        child:
                                            const Text('Choose from gallery'),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: CircleAvatar(
                      child: ClipOval(
                        child: user.photoUrl != ''
                            ? Image.network(
                                user.photoUrl,
                                fit: BoxFit.cover,
                                width: 90,
                                height: 90,
                              )
                            : Container(
                                height: 90,
                                width: 90,
                                color: Colors.blue.shade600,
                                child: Center(
                                  child: Text(
                                      user.fName
                                          .toString()
                                          .split(' ')
                                          .last
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 30)),
                                ),
                              ),
                      ),
                    ),
                  ),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://th.bing.com/th/id/R.1c2f7081273fb29e12408878415d7e74?rik=UO%2bvsC6miB9pXA&riu=http%3a%2f%2fgetwallpapers.com%2fwallpaper%2ffull%2f6%2f7%2fe%2f679953.jpg&ehk=DQw0a%2bHlbWlfAWx6q%2fb793Vv8%2f50X7BJeoyV3G5T1ho%3d&risl=&pid=ImgRaw&r=0',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                ListView(
                  padding: const EdgeInsets.only(top: 0),
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      title: const Row(
                        children: [
                          Icon(Icons.person),
                          SizedBox(width: 10),
                          Text('Edit Profile'),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(
                              user: user,
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: const Row(
                        children: [
                          Icon(Icons.settings),
                          SizedBox(width: 10),
                          Text('Settings'),
                        ],
                      ),
                      onTap: () {
                        print('Settings');
                      },
                    ),
                    ListTile(
                      title: const Row(
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 10),
                          Text('Sign out'),
                        ],
                      ),
                      onTap: () async {
                        await UserStatusServices().setUserStatus('offline');
                        await FirebaseAuth.instance.signOut();
                      },
                    ),
                  ],
                ),
              ],
            );
          }),
    );
  }
}
