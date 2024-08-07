class Member {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String created_at;

  Member(
      {required this.id,
      required this.name,
      required this.email,
      required this.phone,
      required this.address,
      required this.created_at});

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      created_at: json['created_at'],
    );
  }
}
