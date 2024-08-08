import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:realtime_chatapp/pages/edit_profile/edit_profile.dart';
import 'package:realtime_chatapp/providers/user_provider.dart';
import 'package:realtime_chatapp/services/user_status_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainNavBar extends ConsumerWidget {
  const MainNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(getCurrentUserInformationProvider);
    return Drawer(
      child: user.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
          data: (user) {
            return Column(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text('${user.lName} ${user.lName}'),
                  accountEmail: Text(user.email),
                  currentAccountPicture: GestureDetector(
                    onTap: () {
                      //TODO: Implement avatar tap
                      print('Avatar tapped');
                    },
                    child: CircleAvatar(
                      child: ClipOval(
                        child: //user.photoUrl != null
                            // ? Image.network(
                            //     user['avatar'] ??
                            //         'https://th.bing.com/th/id/OIP.7v9FOMk5DnawGSbATxlQAgHaLH?rs=1&pid=ImgDetMain',
                            //     fit: BoxFit.cover,
                            //     width: 90,
                            //     height: 90,
                            //   ) :
                            //TODO: Implement user avatar
                            Container(
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
                        Navigator.of(context).pushReplacementNamed('/profile');
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
