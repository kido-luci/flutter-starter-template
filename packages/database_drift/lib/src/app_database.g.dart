// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, BookmarkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagsJsonMeta = const VerificationMeta(
    'tagsJson',
  );
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
    'tags_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _imageUrlsJsonMeta = const VerificationMeta(
    'imageUrlsJson',
  );
  @override
  late final GeneratedColumn<String> imageUrlsJson = GeneratedColumn<String>(
    'image_urls_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _videoUrlMeta = const VerificationMeta(
    'videoUrl',
  );
  @override
  late final GeneratedColumn<String> videoUrl = GeneratedColumn<String>(
    'video_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtUsMeta = const VerificationMeta(
    'createdAtUs',
  );
  @override
  late final GeneratedColumn<int> createdAtUs = GeneratedColumn<int>(
    'created_at_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUsMeta = const VerificationMeta(
    'updatedAtUs',
  );
  @override
  late final GeneratedColumn<int> updatedAtUs = GeneratedColumn<int>(
    'updated_at_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverUpdatedAtUsMeta = const VerificationMeta(
    'serverUpdatedAtUs',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAtUs = GeneratedColumn<int>(
    'server_updated_at_us',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revMeta = const VerificationMeta('rev');
  @override
  late final GeneratedColumn<int> rev = GeneratedColumn<int>(
    'rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStateCodeMeta = const VerificationMeta(
    'syncStateCode',
  );
  @override
  late final GeneratedColumn<int> syncStateCode = GeneratedColumn<int>(
    'sync_state_code',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    title,
    url,
    description,
    tagsJson,
    imageUrlsJson,
    videoUrl,
    createdAtUs,
    updatedAtUs,
    serverUpdatedAtUs,
    rev,
    syncStateCode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookmarkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('tags_json')) {
      context.handle(
        _tagsJsonMeta,
        tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta),
      );
    }
    if (data.containsKey('image_urls_json')) {
      context.handle(
        _imageUrlsJsonMeta,
        imageUrlsJson.isAcceptableOrUnknown(
          data['image_urls_json']!,
          _imageUrlsJsonMeta,
        ),
      );
    }
    if (data.containsKey('video_url')) {
      context.handle(
        _videoUrlMeta,
        videoUrl.isAcceptableOrUnknown(data['video_url']!, _videoUrlMeta),
      );
    }
    if (data.containsKey('created_at_us')) {
      context.handle(
        _createdAtUsMeta,
        createdAtUs.isAcceptableOrUnknown(
          data['created_at_us']!,
          _createdAtUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUsMeta);
    }
    if (data.containsKey('updated_at_us')) {
      context.handle(
        _updatedAtUsMeta,
        updatedAtUs.isAcceptableOrUnknown(
          data['updated_at_us']!,
          _updatedAtUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUsMeta);
    }
    if (data.containsKey('server_updated_at_us')) {
      context.handle(
        _serverUpdatedAtUsMeta,
        serverUpdatedAtUs.isAcceptableOrUnknown(
          data['server_updated_at_us']!,
          _serverUpdatedAtUsMeta,
        ),
      );
    }
    if (data.containsKey('rev')) {
      context.handle(
        _revMeta,
        rev.isAcceptableOrUnknown(data['rev']!, _revMeta),
      );
    }
    if (data.containsKey('sync_state_code')) {
      context.handle(
        _syncStateCodeMeta,
        syncStateCode.isAcceptableOrUnknown(
          data['sync_state_code']!,
          _syncStateCodeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookmarkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarkRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      tagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags_json'],
      )!,
      imageUrlsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_urls_json'],
      )!,
      videoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_url'],
      ),
      createdAtUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_us'],
      )!,
      updatedAtUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_us'],
      )!,
      serverUpdatedAtUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at_us'],
      ),
      rev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rev'],
      )!,
      syncStateCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_state_code'],
      )!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class BookmarkRow extends DataClass implements Insertable<BookmarkRow> {
  final int id;
  final String uuid;
  final String title;
  final String url;
  final String description;
  final String tagsJson;
  final String imageUrlsJson;
  final String? videoUrl;
  final int createdAtUs;
  final int updatedAtUs;
  final int? serverUpdatedAtUs;
  final int rev;
  final int syncStateCode;
  const BookmarkRow({
    required this.id,
    required this.uuid,
    required this.title,
    required this.url,
    required this.description,
    required this.tagsJson,
    required this.imageUrlsJson,
    this.videoUrl,
    required this.createdAtUs,
    required this.updatedAtUs,
    this.serverUpdatedAtUs,
    required this.rev,
    required this.syncStateCode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['title'] = Variable<String>(title);
    map['url'] = Variable<String>(url);
    map['description'] = Variable<String>(description);
    map['tags_json'] = Variable<String>(tagsJson);
    map['image_urls_json'] = Variable<String>(imageUrlsJson);
    if (!nullToAbsent || videoUrl != null) {
      map['video_url'] = Variable<String>(videoUrl);
    }
    map['created_at_us'] = Variable<int>(createdAtUs);
    map['updated_at_us'] = Variable<int>(updatedAtUs);
    if (!nullToAbsent || serverUpdatedAtUs != null) {
      map['server_updated_at_us'] = Variable<int>(serverUpdatedAtUs);
    }
    map['rev'] = Variable<int>(rev);
    map['sync_state_code'] = Variable<int>(syncStateCode);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      id: Value(id),
      uuid: Value(uuid),
      title: Value(title),
      url: Value(url),
      description: Value(description),
      tagsJson: Value(tagsJson),
      imageUrlsJson: Value(imageUrlsJson),
      videoUrl: videoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(videoUrl),
      createdAtUs: Value(createdAtUs),
      updatedAtUs: Value(updatedAtUs),
      serverUpdatedAtUs: serverUpdatedAtUs == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAtUs),
      rev: Value(rev),
      syncStateCode: Value(syncStateCode),
    );
  }

  factory BookmarkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarkRow(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      title: serializer.fromJson<String>(json['title']),
      url: serializer.fromJson<String>(json['url']),
      description: serializer.fromJson<String>(json['description']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      imageUrlsJson: serializer.fromJson<String>(json['imageUrlsJson']),
      videoUrl: serializer.fromJson<String?>(json['videoUrl']),
      createdAtUs: serializer.fromJson<int>(json['createdAtUs']),
      updatedAtUs: serializer.fromJson<int>(json['updatedAtUs']),
      serverUpdatedAtUs: serializer.fromJson<int?>(json['serverUpdatedAtUs']),
      rev: serializer.fromJson<int>(json['rev']),
      syncStateCode: serializer.fromJson<int>(json['syncStateCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'title': serializer.toJson<String>(title),
      'url': serializer.toJson<String>(url),
      'description': serializer.toJson<String>(description),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'imageUrlsJson': serializer.toJson<String>(imageUrlsJson),
      'videoUrl': serializer.toJson<String?>(videoUrl),
      'createdAtUs': serializer.toJson<int>(createdAtUs),
      'updatedAtUs': serializer.toJson<int>(updatedAtUs),
      'serverUpdatedAtUs': serializer.toJson<int?>(serverUpdatedAtUs),
      'rev': serializer.toJson<int>(rev),
      'syncStateCode': serializer.toJson<int>(syncStateCode),
    };
  }

  BookmarkRow copyWith({
    int? id,
    String? uuid,
    String? title,
    String? url,
    String? description,
    String? tagsJson,
    String? imageUrlsJson,
    Value<String?> videoUrl = const Value.absent(),
    int? createdAtUs,
    int? updatedAtUs,
    Value<int?> serverUpdatedAtUs = const Value.absent(),
    int? rev,
    int? syncStateCode,
  }) => BookmarkRow(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    title: title ?? this.title,
    url: url ?? this.url,
    description: description ?? this.description,
    tagsJson: tagsJson ?? this.tagsJson,
    imageUrlsJson: imageUrlsJson ?? this.imageUrlsJson,
    videoUrl: videoUrl.present ? videoUrl.value : this.videoUrl,
    createdAtUs: createdAtUs ?? this.createdAtUs,
    updatedAtUs: updatedAtUs ?? this.updatedAtUs,
    serverUpdatedAtUs: serverUpdatedAtUs.present
        ? serverUpdatedAtUs.value
        : this.serverUpdatedAtUs,
    rev: rev ?? this.rev,
    syncStateCode: syncStateCode ?? this.syncStateCode,
  );
  BookmarkRow copyWithCompanion(BookmarksCompanion data) {
    return BookmarkRow(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      title: data.title.present ? data.title.value : this.title,
      url: data.url.present ? data.url.value : this.url,
      description: data.description.present
          ? data.description.value
          : this.description,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      imageUrlsJson: data.imageUrlsJson.present
          ? data.imageUrlsJson.value
          : this.imageUrlsJson,
      videoUrl: data.videoUrl.present ? data.videoUrl.value : this.videoUrl,
      createdAtUs: data.createdAtUs.present
          ? data.createdAtUs.value
          : this.createdAtUs,
      updatedAtUs: data.updatedAtUs.present
          ? data.updatedAtUs.value
          : this.updatedAtUs,
      serverUpdatedAtUs: data.serverUpdatedAtUs.present
          ? data.serverUpdatedAtUs.value
          : this.serverUpdatedAtUs,
      rev: data.rev.present ? data.rev.value : this.rev,
      syncStateCode: data.syncStateCode.present
          ? data.syncStateCode.value
          : this.syncStateCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkRow(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('description: $description, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('imageUrlsJson: $imageUrlsJson, ')
          ..write('videoUrl: $videoUrl, ')
          ..write('createdAtUs: $createdAtUs, ')
          ..write('updatedAtUs: $updatedAtUs, ')
          ..write('serverUpdatedAtUs: $serverUpdatedAtUs, ')
          ..write('rev: $rev, ')
          ..write('syncStateCode: $syncStateCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uuid,
    title,
    url,
    description,
    tagsJson,
    imageUrlsJson,
    videoUrl,
    createdAtUs,
    updatedAtUs,
    serverUpdatedAtUs,
    rev,
    syncStateCode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarkRow &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.title == this.title &&
          other.url == this.url &&
          other.description == this.description &&
          other.tagsJson == this.tagsJson &&
          other.imageUrlsJson == this.imageUrlsJson &&
          other.videoUrl == this.videoUrl &&
          other.createdAtUs == this.createdAtUs &&
          other.updatedAtUs == this.updatedAtUs &&
          other.serverUpdatedAtUs == this.serverUpdatedAtUs &&
          other.rev == this.rev &&
          other.syncStateCode == this.syncStateCode);
}

class BookmarksCompanion extends UpdateCompanion<BookmarkRow> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> title;
  final Value<String> url;
  final Value<String> description;
  final Value<String> tagsJson;
  final Value<String> imageUrlsJson;
  final Value<String?> videoUrl;
  final Value<int> createdAtUs;
  final Value<int> updatedAtUs;
  final Value<int?> serverUpdatedAtUs;
  final Value<int> rev;
  final Value<int> syncStateCode;
  const BookmarksCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.description = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.imageUrlsJson = const Value.absent(),
    this.videoUrl = const Value.absent(),
    this.createdAtUs = const Value.absent(),
    this.updatedAtUs = const Value.absent(),
    this.serverUpdatedAtUs = const Value.absent(),
    this.rev = const Value.absent(),
    this.syncStateCode = const Value.absent(),
  });
  BookmarksCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String title,
    required String url,
    required String description,
    this.tagsJson = const Value.absent(),
    this.imageUrlsJson = const Value.absent(),
    this.videoUrl = const Value.absent(),
    required int createdAtUs,
    required int updatedAtUs,
    this.serverUpdatedAtUs = const Value.absent(),
    this.rev = const Value.absent(),
    this.syncStateCode = const Value.absent(),
  }) : uuid = Value(uuid),
       title = Value(title),
       url = Value(url),
       description = Value(description),
       createdAtUs = Value(createdAtUs),
       updatedAtUs = Value(updatedAtUs);
  static Insertable<BookmarkRow> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? title,
    Expression<String>? url,
    Expression<String>? description,
    Expression<String>? tagsJson,
    Expression<String>? imageUrlsJson,
    Expression<String>? videoUrl,
    Expression<int>? createdAtUs,
    Expression<int>? updatedAtUs,
    Expression<int>? serverUpdatedAtUs,
    Expression<int>? rev,
    Expression<int>? syncStateCode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      if (description != null) 'description': description,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (imageUrlsJson != null) 'image_urls_json': imageUrlsJson,
      if (videoUrl != null) 'video_url': videoUrl,
      if (createdAtUs != null) 'created_at_us': createdAtUs,
      if (updatedAtUs != null) 'updated_at_us': updatedAtUs,
      if (serverUpdatedAtUs != null) 'server_updated_at_us': serverUpdatedAtUs,
      if (rev != null) 'rev': rev,
      if (syncStateCode != null) 'sync_state_code': syncStateCode,
    });
  }

  BookmarksCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String>? title,
    Value<String>? url,
    Value<String>? description,
    Value<String>? tagsJson,
    Value<String>? imageUrlsJson,
    Value<String?>? videoUrl,
    Value<int>? createdAtUs,
    Value<int>? updatedAtUs,
    Value<int?>? serverUpdatedAtUs,
    Value<int>? rev,
    Value<int>? syncStateCode,
  }) {
    return BookmarksCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      url: url ?? this.url,
      description: description ?? this.description,
      tagsJson: tagsJson ?? this.tagsJson,
      imageUrlsJson: imageUrlsJson ?? this.imageUrlsJson,
      videoUrl: videoUrl ?? this.videoUrl,
      createdAtUs: createdAtUs ?? this.createdAtUs,
      updatedAtUs: updatedAtUs ?? this.updatedAtUs,
      serverUpdatedAtUs: serverUpdatedAtUs ?? this.serverUpdatedAtUs,
      rev: rev ?? this.rev,
      syncStateCode: syncStateCode ?? this.syncStateCode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (imageUrlsJson.present) {
      map['image_urls_json'] = Variable<String>(imageUrlsJson.value);
    }
    if (videoUrl.present) {
      map['video_url'] = Variable<String>(videoUrl.value);
    }
    if (createdAtUs.present) {
      map['created_at_us'] = Variable<int>(createdAtUs.value);
    }
    if (updatedAtUs.present) {
      map['updated_at_us'] = Variable<int>(updatedAtUs.value);
    }
    if (serverUpdatedAtUs.present) {
      map['server_updated_at_us'] = Variable<int>(serverUpdatedAtUs.value);
    }
    if (rev.present) {
      map['rev'] = Variable<int>(rev.value);
    }
    if (syncStateCode.present) {
      map['sync_state_code'] = Variable<int>(syncStateCode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('description: $description, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('imageUrlsJson: $imageUrlsJson, ')
          ..write('videoUrl: $videoUrl, ')
          ..write('createdAtUs: $createdAtUs, ')
          ..write('updatedAtUs: $updatedAtUs, ')
          ..write('serverUpdatedAtUs: $serverUpdatedAtUs, ')
          ..write('rev: $rev, ')
          ..write('syncStateCode: $syncStateCode')
          ..write(')'))
        .toString();
  }
}

class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, CollectionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookmarkIdsJsonMeta = const VerificationMeta(
    'bookmarkIdsJson',
  );
  @override
  late final GeneratedColumn<String> bookmarkIdsJson = GeneratedColumn<String>(
    'bookmark_ids_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _createdAtUsMeta = const VerificationMeta(
    'createdAtUs',
  );
  @override
  late final GeneratedColumn<int> createdAtUs = GeneratedColumn<int>(
    'created_at_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUsMeta = const VerificationMeta(
    'updatedAtUs',
  );
  @override
  late final GeneratedColumn<int> updatedAtUs = GeneratedColumn<int>(
    'updated_at_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverUpdatedAtUsMeta = const VerificationMeta(
    'serverUpdatedAtUs',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAtUs = GeneratedColumn<int>(
    'server_updated_at_us',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revMeta = const VerificationMeta('rev');
  @override
  late final GeneratedColumn<int> rev = GeneratedColumn<int>(
    'rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStateCodeMeta = const VerificationMeta(
    'syncStateCode',
  );
  @override
  late final GeneratedColumn<int> syncStateCode = GeneratedColumn<int>(
    'sync_state_code',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    name,
    icon,
    color,
    bookmarkIdsJson,
    createdAtUs,
    updatedAtUs,
    serverUpdatedAtUs,
    rev,
    syncStateCode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('bookmark_ids_json')) {
      context.handle(
        _bookmarkIdsJsonMeta,
        bookmarkIdsJson.isAcceptableOrUnknown(
          data['bookmark_ids_json']!,
          _bookmarkIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at_us')) {
      context.handle(
        _createdAtUsMeta,
        createdAtUs.isAcceptableOrUnknown(
          data['created_at_us']!,
          _createdAtUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUsMeta);
    }
    if (data.containsKey('updated_at_us')) {
      context.handle(
        _updatedAtUsMeta,
        updatedAtUs.isAcceptableOrUnknown(
          data['updated_at_us']!,
          _updatedAtUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUsMeta);
    }
    if (data.containsKey('server_updated_at_us')) {
      context.handle(
        _serverUpdatedAtUsMeta,
        serverUpdatedAtUs.isAcceptableOrUnknown(
          data['server_updated_at_us']!,
          _serverUpdatedAtUsMeta,
        ),
      );
    }
    if (data.containsKey('rev')) {
      context.handle(
        _revMeta,
        rev.isAcceptableOrUnknown(data['rev']!, _revMeta),
      );
    }
    if (data.containsKey('sync_state_code')) {
      context.handle(
        _syncStateCodeMeta,
        syncStateCode.isAcceptableOrUnknown(
          data['sync_state_code']!,
          _syncStateCodeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CollectionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      bookmarkIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bookmark_ids_json'],
      )!,
      createdAtUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_us'],
      )!,
      updatedAtUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_us'],
      )!,
      serverUpdatedAtUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at_us'],
      ),
      rev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rev'],
      )!,
      syncStateCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_state_code'],
      )!,
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }
}

class CollectionRow extends DataClass implements Insertable<CollectionRow> {
  final int id;
  final String uuid;
  final String name;
  final String icon;
  final int color;
  final String bookmarkIdsJson;
  final int createdAtUs;
  final int updatedAtUs;
  final int? serverUpdatedAtUs;
  final int rev;
  final int syncStateCode;
  const CollectionRow({
    required this.id,
    required this.uuid,
    required this.name,
    required this.icon,
    required this.color,
    required this.bookmarkIdsJson,
    required this.createdAtUs,
    required this.updatedAtUs,
    this.serverUpdatedAtUs,
    required this.rev,
    required this.syncStateCode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<int>(color);
    map['bookmark_ids_json'] = Variable<String>(bookmarkIdsJson);
    map['created_at_us'] = Variable<int>(createdAtUs);
    map['updated_at_us'] = Variable<int>(updatedAtUs);
    if (!nullToAbsent || serverUpdatedAtUs != null) {
      map['server_updated_at_us'] = Variable<int>(serverUpdatedAtUs);
    }
    map['rev'] = Variable<int>(rev);
    map['sync_state_code'] = Variable<int>(syncStateCode);
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      name: Value(name),
      icon: Value(icon),
      color: Value(color),
      bookmarkIdsJson: Value(bookmarkIdsJson),
      createdAtUs: Value(createdAtUs),
      updatedAtUs: Value(updatedAtUs),
      serverUpdatedAtUs: serverUpdatedAtUs == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAtUs),
      rev: Value(rev),
      syncStateCode: Value(syncStateCode),
    );
  }

  factory CollectionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionRow(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<int>(json['color']),
      bookmarkIdsJson: serializer.fromJson<String>(json['bookmarkIdsJson']),
      createdAtUs: serializer.fromJson<int>(json['createdAtUs']),
      updatedAtUs: serializer.fromJson<int>(json['updatedAtUs']),
      serverUpdatedAtUs: serializer.fromJson<int?>(json['serverUpdatedAtUs']),
      rev: serializer.fromJson<int>(json['rev']),
      syncStateCode: serializer.fromJson<int>(json['syncStateCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<int>(color),
      'bookmarkIdsJson': serializer.toJson<String>(bookmarkIdsJson),
      'createdAtUs': serializer.toJson<int>(createdAtUs),
      'updatedAtUs': serializer.toJson<int>(updatedAtUs),
      'serverUpdatedAtUs': serializer.toJson<int?>(serverUpdatedAtUs),
      'rev': serializer.toJson<int>(rev),
      'syncStateCode': serializer.toJson<int>(syncStateCode),
    };
  }

  CollectionRow copyWith({
    int? id,
    String? uuid,
    String? name,
    String? icon,
    int? color,
    String? bookmarkIdsJson,
    int? createdAtUs,
    int? updatedAtUs,
    Value<int?> serverUpdatedAtUs = const Value.absent(),
    int? rev,
    int? syncStateCode,
  }) => CollectionRow(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    bookmarkIdsJson: bookmarkIdsJson ?? this.bookmarkIdsJson,
    createdAtUs: createdAtUs ?? this.createdAtUs,
    updatedAtUs: updatedAtUs ?? this.updatedAtUs,
    serverUpdatedAtUs: serverUpdatedAtUs.present
        ? serverUpdatedAtUs.value
        : this.serverUpdatedAtUs,
    rev: rev ?? this.rev,
    syncStateCode: syncStateCode ?? this.syncStateCode,
  );
  CollectionRow copyWithCompanion(CollectionsCompanion data) {
    return CollectionRow(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      bookmarkIdsJson: data.bookmarkIdsJson.present
          ? data.bookmarkIdsJson.value
          : this.bookmarkIdsJson,
      createdAtUs: data.createdAtUs.present
          ? data.createdAtUs.value
          : this.createdAtUs,
      updatedAtUs: data.updatedAtUs.present
          ? data.updatedAtUs.value
          : this.updatedAtUs,
      serverUpdatedAtUs: data.serverUpdatedAtUs.present
          ? data.serverUpdatedAtUs.value
          : this.serverUpdatedAtUs,
      rev: data.rev.present ? data.rev.value : this.rev,
      syncStateCode: data.syncStateCode.present
          ? data.syncStateCode.value
          : this.syncStateCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionRow(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('bookmarkIdsJson: $bookmarkIdsJson, ')
          ..write('createdAtUs: $createdAtUs, ')
          ..write('updatedAtUs: $updatedAtUs, ')
          ..write('serverUpdatedAtUs: $serverUpdatedAtUs, ')
          ..write('rev: $rev, ')
          ..write('syncStateCode: $syncStateCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uuid,
    name,
    icon,
    color,
    bookmarkIdsJson,
    createdAtUs,
    updatedAtUs,
    serverUpdatedAtUs,
    rev,
    syncStateCode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionRow &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.bookmarkIdsJson == this.bookmarkIdsJson &&
          other.createdAtUs == this.createdAtUs &&
          other.updatedAtUs == this.updatedAtUs &&
          other.serverUpdatedAtUs == this.serverUpdatedAtUs &&
          other.rev == this.rev &&
          other.syncStateCode == this.syncStateCode);
}

class CollectionsCompanion extends UpdateCompanion<CollectionRow> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> name;
  final Value<String> icon;
  final Value<int> color;
  final Value<String> bookmarkIdsJson;
  final Value<int> createdAtUs;
  final Value<int> updatedAtUs;
  final Value<int?> serverUpdatedAtUs;
  final Value<int> rev;
  final Value<int> syncStateCode;
  const CollectionsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.bookmarkIdsJson = const Value.absent(),
    this.createdAtUs = const Value.absent(),
    this.updatedAtUs = const Value.absent(),
    this.serverUpdatedAtUs = const Value.absent(),
    this.rev = const Value.absent(),
    this.syncStateCode = const Value.absent(),
  });
  CollectionsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String name,
    required String icon,
    required int color,
    this.bookmarkIdsJson = const Value.absent(),
    required int createdAtUs,
    required int updatedAtUs,
    this.serverUpdatedAtUs = const Value.absent(),
    this.rev = const Value.absent(),
    this.syncStateCode = const Value.absent(),
  }) : uuid = Value(uuid),
       name = Value(name),
       icon = Value(icon),
       color = Value(color),
       createdAtUs = Value(createdAtUs),
       updatedAtUs = Value(updatedAtUs);
  static Insertable<CollectionRow> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<int>? color,
    Expression<String>? bookmarkIdsJson,
    Expression<int>? createdAtUs,
    Expression<int>? updatedAtUs,
    Expression<int>? serverUpdatedAtUs,
    Expression<int>? rev,
    Expression<int>? syncStateCode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (bookmarkIdsJson != null) 'bookmark_ids_json': bookmarkIdsJson,
      if (createdAtUs != null) 'created_at_us': createdAtUs,
      if (updatedAtUs != null) 'updated_at_us': updatedAtUs,
      if (serverUpdatedAtUs != null) 'server_updated_at_us': serverUpdatedAtUs,
      if (rev != null) 'rev': rev,
      if (syncStateCode != null) 'sync_state_code': syncStateCode,
    });
  }

  CollectionsCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String>? name,
    Value<String>? icon,
    Value<int>? color,
    Value<String>? bookmarkIdsJson,
    Value<int>? createdAtUs,
    Value<int>? updatedAtUs,
    Value<int?>? serverUpdatedAtUs,
    Value<int>? rev,
    Value<int>? syncStateCode,
  }) {
    return CollectionsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      bookmarkIdsJson: bookmarkIdsJson ?? this.bookmarkIdsJson,
      createdAtUs: createdAtUs ?? this.createdAtUs,
      updatedAtUs: updatedAtUs ?? this.updatedAtUs,
      serverUpdatedAtUs: serverUpdatedAtUs ?? this.serverUpdatedAtUs,
      rev: rev ?? this.rev,
      syncStateCode: syncStateCode ?? this.syncStateCode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (bookmarkIdsJson.present) {
      map['bookmark_ids_json'] = Variable<String>(bookmarkIdsJson.value);
    }
    if (createdAtUs.present) {
      map['created_at_us'] = Variable<int>(createdAtUs.value);
    }
    if (updatedAtUs.present) {
      map['updated_at_us'] = Variable<int>(updatedAtUs.value);
    }
    if (serverUpdatedAtUs.present) {
      map['server_updated_at_us'] = Variable<int>(serverUpdatedAtUs.value);
    }
    if (rev.present) {
      map['rev'] = Variable<int>(rev.value);
    }
    if (syncStateCode.present) {
      map['sync_state_code'] = Variable<int>(syncStateCode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('bookmarkIdsJson: $bookmarkIdsJson, ')
          ..write('createdAtUs: $createdAtUs, ')
          ..write('updatedAtUs: $updatedAtUs, ')
          ..write('serverUpdatedAtUs: $serverUpdatedAtUs, ')
          ..write('rev: $rev, ')
          ..write('syncStateCode: $syncStateCode')
          ..write(')'))
        .toString();
  }
}

class $NotificationsTable extends Notifications
    with TableInfo<$NotificationsTable, NotificationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdAtUsMeta = const VerificationMeta(
    'createdAtUs',
  );
  @override
  late final GeneratedColumn<int> createdAtUs = GeneratedColumn<int>(
    'created_at_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pendingReadMeta = const VerificationMeta(
    'pendingRead',
  );
  @override
  late final GeneratedColumn<bool> pendingRead = GeneratedColumn<bool>(
    'pending_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    title,
    body,
    type,
    isRead,
    createdAtUs,
    pendingRead,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    } else if (isInserting) {
      context.missing(_isReadMeta);
    }
    if (data.containsKey('created_at_us')) {
      context.handle(
        _createdAtUsMeta,
        createdAtUs.isAcceptableOrUnknown(
          data['created_at_us']!,
          _createdAtUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUsMeta);
    }
    if (data.containsKey('pending_read')) {
      context.handle(
        _pendingReadMeta,
        pendingRead.isAcceptableOrUnknown(
          data['pending_read']!,
          _pendingReadMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      createdAtUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_us'],
      )!,
      pendingRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending_read'],
      )!,
    );
  }

  @override
  $NotificationsTable createAlias(String alias) {
    return $NotificationsTable(attachedDatabase, alias);
  }
}

class NotificationRow extends DataClass implements Insertable<NotificationRow> {
  final int id;
  final String uuid;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final int createdAtUs;
  final bool pendingRead;
  const NotificationRow({
    required this.id,
    required this.uuid,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAtUs,
    required this.pendingRead,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['type'] = Variable<String>(type);
    map['is_read'] = Variable<bool>(isRead);
    map['created_at_us'] = Variable<int>(createdAtUs);
    map['pending_read'] = Variable<bool>(pendingRead);
    return map;
  }

  NotificationsCompanion toCompanion(bool nullToAbsent) {
    return NotificationsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      title: Value(title),
      body: Value(body),
      type: Value(type),
      isRead: Value(isRead),
      createdAtUs: Value(createdAtUs),
      pendingRead: Value(pendingRead),
    );
  }

  factory NotificationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationRow(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      type: serializer.fromJson<String>(json['type']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      createdAtUs: serializer.fromJson<int>(json['createdAtUs']),
      pendingRead: serializer.fromJson<bool>(json['pendingRead']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'type': serializer.toJson<String>(type),
      'isRead': serializer.toJson<bool>(isRead),
      'createdAtUs': serializer.toJson<int>(createdAtUs),
      'pendingRead': serializer.toJson<bool>(pendingRead),
    };
  }

  NotificationRow copyWith({
    int? id,
    String? uuid,
    String? title,
    String? body,
    String? type,
    bool? isRead,
    int? createdAtUs,
    bool? pendingRead,
  }) => NotificationRow(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    title: title ?? this.title,
    body: body ?? this.body,
    type: type ?? this.type,
    isRead: isRead ?? this.isRead,
    createdAtUs: createdAtUs ?? this.createdAtUs,
    pendingRead: pendingRead ?? this.pendingRead,
  );
  NotificationRow copyWithCompanion(NotificationsCompanion data) {
    return NotificationRow(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      type: data.type.present ? data.type.value : this.type,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      createdAtUs: data.createdAtUs.present
          ? data.createdAtUs.value
          : this.createdAtUs,
      pendingRead: data.pendingRead.present
          ? data.pendingRead.value
          : this.pendingRead,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationRow(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('type: $type, ')
          ..write('isRead: $isRead, ')
          ..write('createdAtUs: $createdAtUs, ')
          ..write('pendingRead: $pendingRead')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uuid,
    title,
    body,
    type,
    isRead,
    createdAtUs,
    pendingRead,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationRow &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.title == this.title &&
          other.body == this.body &&
          other.type == this.type &&
          other.isRead == this.isRead &&
          other.createdAtUs == this.createdAtUs &&
          other.pendingRead == this.pendingRead);
}

class NotificationsCompanion extends UpdateCompanion<NotificationRow> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> title;
  final Value<String> body;
  final Value<String> type;
  final Value<bool> isRead;
  final Value<int> createdAtUs;
  final Value<bool> pendingRead;
  const NotificationsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.type = const Value.absent(),
    this.isRead = const Value.absent(),
    this.createdAtUs = const Value.absent(),
    this.pendingRead = const Value.absent(),
  });
  NotificationsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String title,
    required String body,
    required String type,
    required bool isRead,
    required int createdAtUs,
    this.pendingRead = const Value.absent(),
  }) : uuid = Value(uuid),
       title = Value(title),
       body = Value(body),
       type = Value(type),
       isRead = Value(isRead),
       createdAtUs = Value(createdAtUs);
  static Insertable<NotificationRow> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? type,
    Expression<bool>? isRead,
    Expression<int>? createdAtUs,
    Expression<bool>? pendingRead,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (type != null) 'type': type,
      if (isRead != null) 'is_read': isRead,
      if (createdAtUs != null) 'created_at_us': createdAtUs,
      if (pendingRead != null) 'pending_read': pendingRead,
    });
  }

  NotificationsCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String>? title,
    Value<String>? body,
    Value<String>? type,
    Value<bool>? isRead,
    Value<int>? createdAtUs,
    Value<bool>? pendingRead,
  }) {
    return NotificationsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAtUs: createdAtUs ?? this.createdAtUs,
      pendingRead: pendingRead ?? this.pendingRead,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (createdAtUs.present) {
      map['created_at_us'] = Variable<int>(createdAtUs.value);
    }
    if (pendingRead.present) {
      map['pending_read'] = Variable<bool>(pendingRead.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('type: $type, ')
          ..write('isRead: $isRead, ')
          ..write('createdAtUs: $createdAtUs, ')
          ..write('pendingRead: $pendingRead')
          ..write(')'))
        .toString();
  }
}

class $ActivitiesTable extends Activities
    with TableInfo<$ActivitiesTable, ActivityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUsMeta = const VerificationMeta(
    'createdAtUs',
  );
  @override
  late final GeneratedColumn<int> createdAtUs = GeneratedColumn<int>(
    'created_at_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    description,
    type,
    createdAtUs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('created_at_us')) {
      context.handle(
        _createdAtUsMeta,
        createdAtUs.isAcceptableOrUnknown(
          data['created_at_us']!,
          _createdAtUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      createdAtUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_us'],
      )!,
    );
  }

  @override
  $ActivitiesTable createAlias(String alias) {
    return $ActivitiesTable(attachedDatabase, alias);
  }
}

class ActivityRow extends DataClass implements Insertable<ActivityRow> {
  final int id;
  final String uuid;
  final String description;
  final String type;
  final int createdAtUs;
  const ActivityRow({
    required this.id,
    required this.uuid,
    required this.description,
    required this.type,
    required this.createdAtUs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['description'] = Variable<String>(description);
    map['type'] = Variable<String>(type);
    map['created_at_us'] = Variable<int>(createdAtUs);
    return map;
  }

  ActivitiesCompanion toCompanion(bool nullToAbsent) {
    return ActivitiesCompanion(
      id: Value(id),
      uuid: Value(uuid),
      description: Value(description),
      type: Value(type),
      createdAtUs: Value(createdAtUs),
    );
  }

  factory ActivityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityRow(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      description: serializer.fromJson<String>(json['description']),
      type: serializer.fromJson<String>(json['type']),
      createdAtUs: serializer.fromJson<int>(json['createdAtUs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'description': serializer.toJson<String>(description),
      'type': serializer.toJson<String>(type),
      'createdAtUs': serializer.toJson<int>(createdAtUs),
    };
  }

  ActivityRow copyWith({
    int? id,
    String? uuid,
    String? description,
    String? type,
    int? createdAtUs,
  }) => ActivityRow(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    description: description ?? this.description,
    type: type ?? this.type,
    createdAtUs: createdAtUs ?? this.createdAtUs,
  );
  ActivityRow copyWithCompanion(ActivitiesCompanion data) {
    return ActivityRow(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      description: data.description.present
          ? data.description.value
          : this.description,
      type: data.type.present ? data.type.value : this.type,
      createdAtUs: data.createdAtUs.present
          ? data.createdAtUs.value
          : this.createdAtUs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityRow(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('createdAtUs: $createdAtUs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, uuid, description, type, createdAtUs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityRow &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.description == this.description &&
          other.type == this.type &&
          other.createdAtUs == this.createdAtUs);
}

class ActivitiesCompanion extends UpdateCompanion<ActivityRow> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> description;
  final Value<String> type;
  final Value<int> createdAtUs;
  const ActivitiesCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.description = const Value.absent(),
    this.type = const Value.absent(),
    this.createdAtUs = const Value.absent(),
  });
  ActivitiesCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String description,
    required String type,
    required int createdAtUs,
  }) : uuid = Value(uuid),
       description = Value(description),
       type = Value(type),
       createdAtUs = Value(createdAtUs);
  static Insertable<ActivityRow> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? description,
    Expression<String>? type,
    Expression<int>? createdAtUs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (createdAtUs != null) 'created_at_us': createdAtUs,
    });
  }

  ActivitiesCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String>? description,
    Value<String>? type,
    Value<int>? createdAtUs,
  }) {
    return ActivitiesCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      description: description ?? this.description,
      type: type ?? this.type,
      createdAtUs: createdAtUs ?? this.createdAtUs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (createdAtUs.present) {
      map['created_at_us'] = Variable<int>(createdAtUs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('createdAtUs: $createdAtUs')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors
    with TableInfo<$SyncCursorsTable, SyncCursorRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _resourceMeta = const VerificationMeta(
    'resource',
  );
  @override
  late final GeneratedColumn<String> resource = GeneratedColumn<String>(
    'resource',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _revMeta = const VerificationMeta('rev');
  @override
  late final GeneratedColumn<int> rev = GeneratedColumn<int>(
    'rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, resource, rev];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncCursorRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('resource')) {
      context.handle(
        _resourceMeta,
        resource.isAcceptableOrUnknown(data['resource']!, _resourceMeta),
      );
    } else if (isInserting) {
      context.missing(_resourceMeta);
    }
    if (data.containsKey('rev')) {
      context.handle(
        _revMeta,
        rev.isAcceptableOrUnknown(data['rev']!, _revMeta),
      );
    } else if (isInserting) {
      context.missing(_revMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncCursorRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursorRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      resource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource'],
      )!,
      rev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rev'],
      )!,
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }
}

class SyncCursorRow extends DataClass implements Insertable<SyncCursorRow> {
  final int id;
  final String resource;
  final int rev;
  const SyncCursorRow({
    required this.id,
    required this.resource,
    required this.rev,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['resource'] = Variable<String>(resource);
    map['rev'] = Variable<int>(rev);
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(
      id: Value(id),
      resource: Value(resource),
      rev: Value(rev),
    );
  }

  factory SyncCursorRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursorRow(
      id: serializer.fromJson<int>(json['id']),
      resource: serializer.fromJson<String>(json['resource']),
      rev: serializer.fromJson<int>(json['rev']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'resource': serializer.toJson<String>(resource),
      'rev': serializer.toJson<int>(rev),
    };
  }

  SyncCursorRow copyWith({int? id, String? resource, int? rev}) =>
      SyncCursorRow(
        id: id ?? this.id,
        resource: resource ?? this.resource,
        rev: rev ?? this.rev,
      );
  SyncCursorRow copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursorRow(
      id: data.id.present ? data.id.value : this.id,
      resource: data.resource.present ? data.resource.value : this.resource,
      rev: data.rev.present ? data.rev.value : this.rev,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorRow(')
          ..write('id: $id, ')
          ..write('resource: $resource, ')
          ..write('rev: $rev')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, resource, rev);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursorRow &&
          other.id == this.id &&
          other.resource == this.resource &&
          other.rev == this.rev);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursorRow> {
  final Value<int> id;
  final Value<String> resource;
  final Value<int> rev;
  const SyncCursorsCompanion({
    this.id = const Value.absent(),
    this.resource = const Value.absent(),
    this.rev = const Value.absent(),
  });
  SyncCursorsCompanion.insert({
    this.id = const Value.absent(),
    required String resource,
    required int rev,
  }) : resource = Value(resource),
       rev = Value(rev);
  static Insertable<SyncCursorRow> custom({
    Expression<int>? id,
    Expression<String>? resource,
    Expression<int>? rev,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (resource != null) 'resource': resource,
      if (rev != null) 'rev': rev,
    });
  }

  SyncCursorsCompanion copyWith({
    Value<int>? id,
    Value<String>? resource,
    Value<int>? rev,
  }) {
    return SyncCursorsCompanion(
      id: id ?? this.id,
      resource: resource ?? this.resource,
      rev: rev ?? this.rev,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (resource.present) {
      map['resource'] = Variable<String>(resource.value);
    }
    if (rev.present) {
      map['rev'] = Variable<int>(rev.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('id: $id, ')
          ..write('resource: $resource, ')
          ..write('rev: $rev')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $NotificationsTable notifications = $NotificationsTable(this);
  late final $ActivitiesTable activities = $ActivitiesTable(this);
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    bookmarks,
    collections,
    notifications,
    activities,
    syncCursors,
  ];
}

typedef $$BookmarksTableCreateCompanionBuilder =
    BookmarksCompanion Function({
      Value<int> id,
      required String uuid,
      required String title,
      required String url,
      required String description,
      Value<String> tagsJson,
      Value<String> imageUrlsJson,
      Value<String?> videoUrl,
      required int createdAtUs,
      required int updatedAtUs,
      Value<int?> serverUpdatedAtUs,
      Value<int> rev,
      Value<int> syncStateCode,
    });
typedef $$BookmarksTableUpdateCompanionBuilder =
    BookmarksCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String> title,
      Value<String> url,
      Value<String> description,
      Value<String> tagsJson,
      Value<String> imageUrlsJson,
      Value<String?> videoUrl,
      Value<int> createdAtUs,
      Value<int> updatedAtUs,
      Value<int?> serverUpdatedAtUs,
      Value<int> rev,
      Value<int> syncStateCode,
    });

class $$BookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrlsJson => $composableBuilder(
    column: $table.imageUrlsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get videoUrl => $composableBuilder(
    column: $table.videoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUs => $composableBuilder(
    column: $table.createdAtUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUs => $composableBuilder(
    column: $table.updatedAtUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAtUs => $composableBuilder(
    column: $table.serverUpdatedAtUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncStateCode => $composableBuilder(
    column: $table.syncStateCode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrlsJson => $composableBuilder(
    column: $table.imageUrlsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get videoUrl => $composableBuilder(
    column: $table.videoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUs => $composableBuilder(
    column: $table.createdAtUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUs => $composableBuilder(
    column: $table.updatedAtUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAtUs => $composableBuilder(
    column: $table.serverUpdatedAtUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStateCode => $composableBuilder(
    column: $table.syncStateCode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<String> get imageUrlsJson => $composableBuilder(
    column: $table.imageUrlsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get videoUrl =>
      $composableBuilder(column: $table.videoUrl, builder: (column) => column);

  GeneratedColumn<int> get createdAtUs => $composableBuilder(
    column: $table.createdAtUs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUs => $composableBuilder(
    column: $table.updatedAtUs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverUpdatedAtUs => $composableBuilder(
    column: $table.serverUpdatedAtUs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rev =>
      $composableBuilder(column: $table.rev, builder: (column) => column);

  GeneratedColumn<int> get syncStateCode => $composableBuilder(
    column: $table.syncStateCode,
    builder: (column) => column,
  );
}

class $$BookmarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarksTable,
          BookmarkRow,
          $$BookmarksTableFilterComposer,
          $$BookmarksTableOrderingComposer,
          $$BookmarksTableAnnotationComposer,
          $$BookmarksTableCreateCompanionBuilder,
          $$BookmarksTableUpdateCompanionBuilder,
          (
            BookmarkRow,
            BaseReferences<_$AppDatabase, $BookmarksTable, BookmarkRow>,
          ),
          BookmarkRow,
          PrefetchHooks Function()
        > {
  $$BookmarksTableTableManager(_$AppDatabase db, $BookmarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<String> imageUrlsJson = const Value.absent(),
                Value<String?> videoUrl = const Value.absent(),
                Value<int> createdAtUs = const Value.absent(),
                Value<int> updatedAtUs = const Value.absent(),
                Value<int?> serverUpdatedAtUs = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<int> syncStateCode = const Value.absent(),
              }) => BookmarksCompanion(
                id: id,
                uuid: uuid,
                title: title,
                url: url,
                description: description,
                tagsJson: tagsJson,
                imageUrlsJson: imageUrlsJson,
                videoUrl: videoUrl,
                createdAtUs: createdAtUs,
                updatedAtUs: updatedAtUs,
                serverUpdatedAtUs: serverUpdatedAtUs,
                rev: rev,
                syncStateCode: syncStateCode,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required String title,
                required String url,
                required String description,
                Value<String> tagsJson = const Value.absent(),
                Value<String> imageUrlsJson = const Value.absent(),
                Value<String?> videoUrl = const Value.absent(),
                required int createdAtUs,
                required int updatedAtUs,
                Value<int?> serverUpdatedAtUs = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<int> syncStateCode = const Value.absent(),
              }) => BookmarksCompanion.insert(
                id: id,
                uuid: uuid,
                title: title,
                url: url,
                description: description,
                tagsJson: tagsJson,
                imageUrlsJson: imageUrlsJson,
                videoUrl: videoUrl,
                createdAtUs: createdAtUs,
                updatedAtUs: updatedAtUs,
                serverUpdatedAtUs: serverUpdatedAtUs,
                rev: rev,
                syncStateCode: syncStateCode,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarksTable,
      BookmarkRow,
      $$BookmarksTableFilterComposer,
      $$BookmarksTableOrderingComposer,
      $$BookmarksTableAnnotationComposer,
      $$BookmarksTableCreateCompanionBuilder,
      $$BookmarksTableUpdateCompanionBuilder,
      (
        BookmarkRow,
        BaseReferences<_$AppDatabase, $BookmarksTable, BookmarkRow>,
      ),
      BookmarkRow,
      PrefetchHooks Function()
    >;
typedef $$CollectionsTableCreateCompanionBuilder =
    CollectionsCompanion Function({
      Value<int> id,
      required String uuid,
      required String name,
      required String icon,
      required int color,
      Value<String> bookmarkIdsJson,
      required int createdAtUs,
      required int updatedAtUs,
      Value<int?> serverUpdatedAtUs,
      Value<int> rev,
      Value<int> syncStateCode,
    });
typedef $$CollectionsTableUpdateCompanionBuilder =
    CollectionsCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String> name,
      Value<String> icon,
      Value<int> color,
      Value<String> bookmarkIdsJson,
      Value<int> createdAtUs,
      Value<int> updatedAtUs,
      Value<int?> serverUpdatedAtUs,
      Value<int> rev,
      Value<int> syncStateCode,
    });

class $$CollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookmarkIdsJson => $composableBuilder(
    column: $table.bookmarkIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUs => $composableBuilder(
    column: $table.createdAtUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUs => $composableBuilder(
    column: $table.updatedAtUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAtUs => $composableBuilder(
    column: $table.serverUpdatedAtUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncStateCode => $composableBuilder(
    column: $table.syncStateCode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookmarkIdsJson => $composableBuilder(
    column: $table.bookmarkIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUs => $composableBuilder(
    column: $table.createdAtUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUs => $composableBuilder(
    column: $table.updatedAtUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAtUs => $composableBuilder(
    column: $table.serverUpdatedAtUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStateCode => $composableBuilder(
    column: $table.syncStateCode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get bookmarkIdsJson => $composableBuilder(
    column: $table.bookmarkIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtUs => $composableBuilder(
    column: $table.createdAtUs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUs => $composableBuilder(
    column: $table.updatedAtUs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverUpdatedAtUs => $composableBuilder(
    column: $table.serverUpdatedAtUs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rev =>
      $composableBuilder(column: $table.rev, builder: (column) => column);

  GeneratedColumn<int> get syncStateCode => $composableBuilder(
    column: $table.syncStateCode,
    builder: (column) => column,
  );
}

class $$CollectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionsTable,
          CollectionRow,
          $$CollectionsTableFilterComposer,
          $$CollectionsTableOrderingComposer,
          $$CollectionsTableAnnotationComposer,
          $$CollectionsTableCreateCompanionBuilder,
          $$CollectionsTableUpdateCompanionBuilder,
          (
            CollectionRow,
            BaseReferences<_$AppDatabase, $CollectionsTable, CollectionRow>,
          ),
          CollectionRow,
          PrefetchHooks Function()
        > {
  $$CollectionsTableTableManager(_$AppDatabase db, $CollectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<String> bookmarkIdsJson = const Value.absent(),
                Value<int> createdAtUs = const Value.absent(),
                Value<int> updatedAtUs = const Value.absent(),
                Value<int?> serverUpdatedAtUs = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<int> syncStateCode = const Value.absent(),
              }) => CollectionsCompanion(
                id: id,
                uuid: uuid,
                name: name,
                icon: icon,
                color: color,
                bookmarkIdsJson: bookmarkIdsJson,
                createdAtUs: createdAtUs,
                updatedAtUs: updatedAtUs,
                serverUpdatedAtUs: serverUpdatedAtUs,
                rev: rev,
                syncStateCode: syncStateCode,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required String name,
                required String icon,
                required int color,
                Value<String> bookmarkIdsJson = const Value.absent(),
                required int createdAtUs,
                required int updatedAtUs,
                Value<int?> serverUpdatedAtUs = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<int> syncStateCode = const Value.absent(),
              }) => CollectionsCompanion.insert(
                id: id,
                uuid: uuid,
                name: name,
                icon: icon,
                color: color,
                bookmarkIdsJson: bookmarkIdsJson,
                createdAtUs: createdAtUs,
                updatedAtUs: updatedAtUs,
                serverUpdatedAtUs: serverUpdatedAtUs,
                rev: rev,
                syncStateCode: syncStateCode,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CollectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionsTable,
      CollectionRow,
      $$CollectionsTableFilterComposer,
      $$CollectionsTableOrderingComposer,
      $$CollectionsTableAnnotationComposer,
      $$CollectionsTableCreateCompanionBuilder,
      $$CollectionsTableUpdateCompanionBuilder,
      (
        CollectionRow,
        BaseReferences<_$AppDatabase, $CollectionsTable, CollectionRow>,
      ),
      CollectionRow,
      PrefetchHooks Function()
    >;
typedef $$NotificationsTableCreateCompanionBuilder =
    NotificationsCompanion Function({
      Value<int> id,
      required String uuid,
      required String title,
      required String body,
      required String type,
      required bool isRead,
      required int createdAtUs,
      Value<bool> pendingRead,
    });
typedef $$NotificationsTableUpdateCompanionBuilder =
    NotificationsCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String> title,
      Value<String> body,
      Value<String> type,
      Value<bool> isRead,
      Value<int> createdAtUs,
      Value<bool> pendingRead,
    });

class $$NotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUs => $composableBuilder(
    column: $table.createdAtUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendingRead => $composableBuilder(
    column: $table.pendingRead,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUs => $composableBuilder(
    column: $table.createdAtUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendingRead => $composableBuilder(
    column: $table.pendingRead,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<int> get createdAtUs => $composableBuilder(
    column: $table.createdAtUs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pendingRead => $composableBuilder(
    column: $table.pendingRead,
    builder: (column) => column,
  );
}

class $$NotificationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationsTable,
          NotificationRow,
          $$NotificationsTableFilterComposer,
          $$NotificationsTableOrderingComposer,
          $$NotificationsTableAnnotationComposer,
          $$NotificationsTableCreateCompanionBuilder,
          $$NotificationsTableUpdateCompanionBuilder,
          (
            NotificationRow,
            BaseReferences<_$AppDatabase, $NotificationsTable, NotificationRow>,
          ),
          NotificationRow,
          PrefetchHooks Function()
        > {
  $$NotificationsTableTableManager(_$AppDatabase db, $NotificationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<int> createdAtUs = const Value.absent(),
                Value<bool> pendingRead = const Value.absent(),
              }) => NotificationsCompanion(
                id: id,
                uuid: uuid,
                title: title,
                body: body,
                type: type,
                isRead: isRead,
                createdAtUs: createdAtUs,
                pendingRead: pendingRead,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required String title,
                required String body,
                required String type,
                required bool isRead,
                required int createdAtUs,
                Value<bool> pendingRead = const Value.absent(),
              }) => NotificationsCompanion.insert(
                id: id,
                uuid: uuid,
                title: title,
                body: body,
                type: type,
                isRead: isRead,
                createdAtUs: createdAtUs,
                pendingRead: pendingRead,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationsTable,
      NotificationRow,
      $$NotificationsTableFilterComposer,
      $$NotificationsTableOrderingComposer,
      $$NotificationsTableAnnotationComposer,
      $$NotificationsTableCreateCompanionBuilder,
      $$NotificationsTableUpdateCompanionBuilder,
      (
        NotificationRow,
        BaseReferences<_$AppDatabase, $NotificationsTable, NotificationRow>,
      ),
      NotificationRow,
      PrefetchHooks Function()
    >;
typedef $$ActivitiesTableCreateCompanionBuilder =
    ActivitiesCompanion Function({
      Value<int> id,
      required String uuid,
      required String description,
      required String type,
      required int createdAtUs,
    });
typedef $$ActivitiesTableUpdateCompanionBuilder =
    ActivitiesCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String> description,
      Value<String> type,
      Value<int> createdAtUs,
    });

class $$ActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUs => $composableBuilder(
    column: $table.createdAtUs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUs => $composableBuilder(
    column: $table.createdAtUs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get createdAtUs => $composableBuilder(
    column: $table.createdAtUs,
    builder: (column) => column,
  );
}

class $$ActivitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivitiesTable,
          ActivityRow,
          $$ActivitiesTableFilterComposer,
          $$ActivitiesTableOrderingComposer,
          $$ActivitiesTableAnnotationComposer,
          $$ActivitiesTableCreateCompanionBuilder,
          $$ActivitiesTableUpdateCompanionBuilder,
          (
            ActivityRow,
            BaseReferences<_$AppDatabase, $ActivitiesTable, ActivityRow>,
          ),
          ActivityRow,
          PrefetchHooks Function()
        > {
  $$ActivitiesTableTableManager(_$AppDatabase db, $ActivitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> createdAtUs = const Value.absent(),
              }) => ActivitiesCompanion(
                id: id,
                uuid: uuid,
                description: description,
                type: type,
                createdAtUs: createdAtUs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required String description,
                required String type,
                required int createdAtUs,
              }) => ActivitiesCompanion.insert(
                id: id,
                uuid: uuid,
                description: description,
                type: type,
                createdAtUs: createdAtUs,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActivitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivitiesTable,
      ActivityRow,
      $$ActivitiesTableFilterComposer,
      $$ActivitiesTableOrderingComposer,
      $$ActivitiesTableAnnotationComposer,
      $$ActivitiesTableCreateCompanionBuilder,
      $$ActivitiesTableUpdateCompanionBuilder,
      (
        ActivityRow,
        BaseReferences<_$AppDatabase, $ActivitiesTable, ActivityRow>,
      ),
      ActivityRow,
      PrefetchHooks Function()
    >;
typedef $$SyncCursorsTableCreateCompanionBuilder =
    SyncCursorsCompanion Function({
      Value<int> id,
      required String resource,
      required int rev,
    });
typedef $$SyncCursorsTableUpdateCompanionBuilder =
    SyncCursorsCompanion Function({
      Value<int> id,
      Value<String> resource,
      Value<int> rev,
    });

class $$SyncCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resource => $composableBuilder(
    column: $table.resource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resource => $composableBuilder(
    column: $table.resource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get resource =>
      $composableBuilder(column: $table.resource, builder: (column) => column);

  GeneratedColumn<int> get rev =>
      $composableBuilder(column: $table.rev, builder: (column) => column);
}

class $$SyncCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncCursorsTable,
          SyncCursorRow,
          $$SyncCursorsTableFilterComposer,
          $$SyncCursorsTableOrderingComposer,
          $$SyncCursorsTableAnnotationComposer,
          $$SyncCursorsTableCreateCompanionBuilder,
          $$SyncCursorsTableUpdateCompanionBuilder,
          (
            SyncCursorRow,
            BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursorRow>,
          ),
          SyncCursorRow,
          PrefetchHooks Function()
        > {
  $$SyncCursorsTableTableManager(_$AppDatabase db, $SyncCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> resource = const Value.absent(),
                Value<int> rev = const Value.absent(),
              }) => SyncCursorsCompanion(id: id, resource: resource, rev: rev),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String resource,
                required int rev,
              }) => SyncCursorsCompanion.insert(
                id: id,
                resource: resource,
                rev: rev,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncCursorsTable,
      SyncCursorRow,
      $$SyncCursorsTableFilterComposer,
      $$SyncCursorsTableOrderingComposer,
      $$SyncCursorsTableAnnotationComposer,
      $$SyncCursorsTableCreateCompanionBuilder,
      $$SyncCursorsTableUpdateCompanionBuilder,
      (
        SyncCursorRow,
        BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursorRow>,
      ),
      SyncCursorRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$NotificationsTableTableManager get notifications =>
      $$NotificationsTableTableManager(_db, _db.notifications);
  $$ActivitiesTableTableManager get activities =>
      $$ActivitiesTableTableManager(_db, _db.activities);
  $$SyncCursorsTableTableManager get syncCursors =>
      $$SyncCursorsTableTableManager(_db, _db.syncCursors);
}
