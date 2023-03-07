class AllCachedMediaInfo {
  List<CachedMediaInfo>? cachedMediaInfo;

  AllCachedMediaInfo({this.cachedMediaInfo});

  AllCachedMediaInfo.fromJson(Map<String, dynamic> json) {
    if (json['CachedMediaInfo'] != null) {
      cachedMediaInfo = <CachedMediaInfo>[];
      json['CachedMediaInfo'].forEach((v) {
        cachedMediaInfo!.add(CachedMediaInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (cachedMediaInfo != null) {
      data['CachedMediaInfo'] = cachedMediaInfo!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CachedMediaInfo {
  late String id;
  late String mediaUrl;
  late String cachedMediaUrl;
  late int fileSize;
  late int dateCreated;

  CachedMediaInfo({
    required this.id,
    required this.mediaUrl,
    required this.cachedMediaUrl,
    required this.fileSize,
    required this.dateCreated,
  });

  CachedMediaInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    mediaUrl = json['mediaUrl'];
    cachedMediaUrl = json['cachedMediaUrl'];
    fileSize = json['fileSize'];
    dateCreated = json['dateCreated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['mediaUrl'] = mediaUrl;
    data['cachedMediaUrl'] = cachedMediaUrl;
    data['fileSize'] = fileSize;
    data['dateCreated'] = dateCreated;
    return data;
  }
}
