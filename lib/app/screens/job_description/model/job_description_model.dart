class JobDescriptionModel {
  final String? designation;
  final String? version;
  final String? body;
  final String? fileUrl;
  final String? updatedAt;

  const JobDescriptionModel({
    this.designation,
    this.version,
    this.body,
    this.fileUrl,
    this.updatedAt,
  });

  factory JobDescriptionModel.fromJson(Map<String, dynamic> json) {
    return JobDescriptionModel(
      designation: json['designation'] as String?,
      version: json['version'] as String?,
      body: json['body'] as String?,
      fileUrl: json['file_url'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'designation': designation,
    'version': version,
    'body': body,
    'file_url': fileUrl,
    'updated_at': updatedAt,
  };
}
