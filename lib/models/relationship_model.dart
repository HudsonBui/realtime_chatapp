class RelationshipModel {
  final String id;
  final String userID1;
  final String userID2;

  RelationshipModel({
    required this.id,
    required this.userID1,
    required this.userID2,
  });

  factory RelationshipModel.fromMap(Map<String, dynamic> data) {
    return RelationshipModel(
      id: data['id'],
      userID1: data['userID1'],
      userID2: data['userID2'],
    );
  }
}
