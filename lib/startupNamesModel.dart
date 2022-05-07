class StartupName {
  final String name;

  const StartupName({
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}