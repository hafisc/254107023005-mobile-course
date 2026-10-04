class AppRoutes {
  static const login = '/login';
  static const home = '/';
  
  static const announcementPrefix = '/pengumuman';
  static String announcement(String id) => '$announcementPrefix/$id';
}
