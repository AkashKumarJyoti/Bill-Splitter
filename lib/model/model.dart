class UserModel
{
  final String name;
  const UserModel({required this.name});
  toJson()
  {
    return {
      "Name" : name,
    };
  }
}
