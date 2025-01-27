class NadaSubjectModel {
  final String title;
  final String slug;
  final String photo;
  final int totalCourses;

 NadaSubjectModel({
    required this.title,
    required this.slug,
    required this.photo,
    required this.totalCourses,
  });

  factory NadaSubjectModel.fromJson(Map<String, dynamic> json) {
    return NadaSubjectModel(
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      photo: json['photo'] ?? '',
      totalCourses: json['total_courses'] ?? 0,
    );
  }
}
