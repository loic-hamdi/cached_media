import 'dart:typed_data';

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
  late double fileSize;
  late int dateCreated;
  Uint8List? bytes;

  CachedMediaInfo({
    required this.id,
    required this.mediaUrl,
    required this.cachedMediaUrl,
    required this.fileSize,
    required this.dateCreated,
    this.bytes,
  });

  CachedMediaInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    mediaUrl = json['mediaUrl'];
    cachedMediaUrl = json['cachedMediaUrl'];
    fileSize = (json['fileSize']).toDouble();
    dateCreated = json['dateCreated'];
    if (json['bytes'] != null) {
      final intlist = List<int>.from(json['bytes']);
      bytes = Uint8List.fromList(intlist);
    } else {
      bytes = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['mediaUrl'] = mediaUrl;
    data['cachedMediaUrl'] = cachedMediaUrl;
    data['fileSize'] = fileSize;
    data['dateCreated'] = dateCreated;
    data['bytes'] = bytes?.toList();
    return data;
  }
}


// import 'dart:typed_data';

// class AllCachedMediaInfo {
//   List<CachedMediaInfo>? cachedMediaInfo;

//   AllCachedMediaInfo({this.cachedMediaInfo});

//   AllCachedMediaInfo.fromJson(Map<String, dynamic> json) {
//     if (json['CachedMediaInfo'] != null) {
//       cachedMediaInfo = <CachedMediaInfo>[];
//       json['CachedMediaInfo'].forEach((v) {
//         cachedMediaInfo!.add(CachedMediaInfo.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     if (cachedMediaInfo != null) {
//       data['CachedMediaInfo'] = cachedMediaInfo!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }

// class CachedMediaInfo {
//   late String id;
//   late String mediaUrl;
//   late double fileSize;
//   late int dateCreated;
//   Uint8List? bytes;
//   String? mimeType;

//   CachedMediaInfo({
//     required this.id,
//     required this.mediaUrl,
//     required this.fileSize,
//     required this.dateCreated,
//     required this.bytes,
//     required this.mimeType,
//   });

//   CachedMediaInfo.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     mediaUrl = json['mediaUrl'];
//     fileSize = json['fileSize'];
//     dateCreated = json['dateCreated'];
//     mimeType = json['mimeType'];
//     if (json['bytes'] != null) {
//       final intlist = List<int>.from(json['bytes']);
//       bytes = Uint8List.fromList(intlist);
//     } else {
//       bytes = null;
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['mediaUrl'] = mediaUrl;
//     data['fileSize'] = fileSize;
//     data['dateCreated'] = dateCreated;
//     data['bytes'] = bytes?.toList();
//     data['mimeType'] = mimeType;
//     return data;
//   }
// }
