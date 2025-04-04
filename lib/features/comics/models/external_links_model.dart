import 'package:atlas_app/imports.dart';

class ExternalLinksModel {
  final String url;
  final String site;
  ExternalLinksModel({required this.url, required this.site});

  ExternalLinksModel copyWith({String? url, String? site}) {
    return ExternalLinksModel(url: url ?? this.url, site: site ?? this.site);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{KeyNames.url: url, KeyNames.site: site};
  }

  factory ExternalLinksModel.fromMap(Map<String, dynamic> map) {
    return ExternalLinksModel(url: map[KeyNames.url] ?? "", site: map[KeyNames.site] ?? "");
  }

  @override
  String toString() => 'ExternalLinksModel(url: $url, site: $site)';

  @override
  bool operator ==(covariant ExternalLinksModel other) {
    if (identical(this, other)) return true;

    return other.url == url && other.site == site;
  }

  @override
  int get hashCode => url.hashCode ^ site.hashCode;
}
