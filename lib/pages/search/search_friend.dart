import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchFriend extends SearchDelegate<String> {
  Future<List<Map<String, dynamic>>> getUserInfor() async {
    var querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    var userData = querySnapshot.docs.map((e) => e.data()).toList();
    return userData;
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // return FutureBuilder<List<Map<String, dynamic>>>(future: getUserInfor(), builder: (ctx, snp) {
    //   if(snp.connectionState == ConnectionState.waiting) {
    //     return const Center(child: CircularProgressIndicator());
    //   }if(snp.hasError) {
    //     return const Center(child: Text('An error occurred!'));
    //   }if(snp.hasData) {
    //     return ListView.builder(
    //       itemCount: snp.data!.length,
    //       itemBuilder: (context, index) {
    //         return ListTile(

    //         )
    //       },
    //     )
    //   }
    // });
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    throw UnimplementedError();
  }
}
