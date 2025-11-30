class UserModel {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String accountType;
  final String bio;
  final ProfilePicture profilePicture;
  final CoverPhoto? coverPhoto;
  final String location;
  final String website;
  final String businessEmail;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final bool isVerified;
  final bool isPrivate;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.accountType,
    required this.bio,
    required this.profilePicture,
    this.coverPhoto,
    required this.location,
    required this.website,
    required this.businessEmail,
    required this.followersCount,
    required this.followingCount,
    required this.postsCount,
    required this.isVerified,
    required this.isPrivate,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      accountType: json['accountType'] ?? 'personal',
      bio: json['bio'] ?? '',
      profilePicture: ProfilePicture.fromJson(json['profilePicture'] ?? {}),
      coverPhoto: json['coverPhoto'] != null 
          ? CoverPhoto.fromJson(json['coverPhoto']) 
          : null,
      location: json['location'] ?? '',
      website: json['website'] ?? '',
      businessEmail: json['businessEmail'] ?? '',
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      postsCount: json['postsCount'] ?? 0,
      isVerified: json['isVerified'] ?? false,
      isPrivate: json['isPrivate'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'accountType': accountType,
      'bio': bio,
      'profilePicture': profilePicture.toJson(),
      'coverPhoto': coverPhoto?.toJson(),
      'location': location,
      'website': website,
      'businessEmail': businessEmail,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'isVerified': isVerified,
      'isPrivate': isPrivate,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ProfilePicture {
  final String? publicId;
  final String url;

  ProfilePicture({this.publicId, required this.url});

  factory ProfilePicture.fromJson(Map<String, dynamic> json) {
    return ProfilePicture(
      publicId: json['public_id'],
      url: json['url'] ?? 'https://via.placeholder.com/150',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'public_id': publicId,
      'url': url,
    };
  }
}

class CoverPhoto {
  final String? publicId;
  final String url;

  CoverPhoto({this.publicId, required this.url});

  factory CoverPhoto.fromJson(Map<String, dynamic> json) {
    return CoverPhoto(
      publicId: json['public_id'],
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'public_id': publicId,
      'url': url,
    };
  }
}