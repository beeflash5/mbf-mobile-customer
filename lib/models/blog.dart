class Blog {
  int id;
  String name;
  String description;
  String photo;
  String created_at;

  Blog({
    required this.id,
    required this.name,
    required this.description,
    required this.photo,
    required this.created_at,
  });

  factory Blog.fromJson(dynamic jsonObject) {
    return Blog(
      id: jsonObject["id"],
      name: jsonObject["name"],
      description: jsonObject["description"],
      photo: jsonObject["photo"],
      created_at: jsonObject["created_at"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "photo": photo,
    "description": description,
    "created_at": created_at,
  };
}
