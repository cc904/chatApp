class AvatarUrlBuilder {
  final String baseUrl;

  AvatarUrlBuilder(String baseUrl)
      : baseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;

  /// djb2 哈希，返回无符号32位整数
  int _djb2(String input) {
    int hash = 5381;
    for (int i = 0; i < input.length; i++) {
      hash = ((hash << 5) + hash) + input.codeUnitAt(i);
      hash &= 0xFFFFFFFF; // 约束为32位
    }
    return hash;
  }

  /// 由 userId 派生 bucket: hex((djb2(userId) & 0xff)).padStart(2, '0')
  String _bucketFromUserId(String userId) {
    final bucketByte = _djb2(userId) & 0xff;
    return bucketByte.toRadixString(16).padLeft(2, '0');
  }

  /// 原图 URL: /avatar/{bucket}/{userId}/{nanoId}.jpg
  String original(String userId, String nanoId) {
    final bucket = _bucketFromUserId(userId);
    return "$baseUrl/avatar/$bucket/$userId/$nanoId.jpg";
  }

  /// 缩略图 URL: /avatar/{bucket}/{userId}/{nanoId}.thumb.jpg
  String thumb(String userId, String nanoId) {
    final bucket = _bucketFromUserId(userId);
    return "$baseUrl/avatar/$bucket/$userId/$nanoId.thumb.jpg";
  }
}


