// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_log_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetExerciseLogEntityCollection on Isar {
  IsarCollection<ExerciseLogEntity> get exerciseLogEntitys => this.collection();
}

const ExerciseLogEntitySchema = CollectionSchema(
  name: r'ExerciseLogEntity',
  id: -6284474096130259305,
  properties: {
    r'logId': PropertySchema(id: 0, name: r'logId', type: IsarType.string),
    r'reps': PropertySchema(id: 1, name: r'reps', type: IsarType.long),
    r'timestamp': PropertySchema(
      id: 2,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'typeKey': PropertySchema(id: 3, name: r'typeKey', type: IsarType.string),
  },

  estimateSize: _exerciseLogEntityEstimateSize,
  serialize: _exerciseLogEntitySerialize,
  deserialize: _exerciseLogEntityDeserialize,
  deserializeProp: _exerciseLogEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'logId': IndexSchema(
      id: 3089637606214822530,
      name: r'logId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'logId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'timestamp': IndexSchema(
      id: 1852253767416892198,
      name: r'timestamp',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'timestamp',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'typeKey': IndexSchema(
      id: 6289095459379303969,
      name: r'typeKey',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'typeKey',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _exerciseLogEntityGetId,
  getLinks: _exerciseLogEntityGetLinks,
  attach: _exerciseLogEntityAttach,
  version: '3.3.0',
);

int _exerciseLogEntityEstimateSize(
  ExerciseLogEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.logId.length * 3;
  bytesCount += 3 + object.typeKey.length * 3;
  return bytesCount;
}

void _exerciseLogEntitySerialize(
  ExerciseLogEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.logId);
  writer.writeLong(offsets[1], object.reps);
  writer.writeDateTime(offsets[2], object.timestamp);
  writer.writeString(offsets[3], object.typeKey);
}

ExerciseLogEntity _exerciseLogEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ExerciseLogEntity();
  object.id = id;
  object.logId = reader.readString(offsets[0]);
  object.reps = reader.readLong(offsets[1]);
  object.timestamp = reader.readDateTime(offsets[2]);
  object.typeKey = reader.readString(offsets[3]);
  return object;
}

P _exerciseLogEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _exerciseLogEntityGetId(ExerciseLogEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _exerciseLogEntityGetLinks(
  ExerciseLogEntity object,
) {
  return [];
}

void _exerciseLogEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  ExerciseLogEntity object,
) {
  object.id = id;
}

extension ExerciseLogEntityByIndex on IsarCollection<ExerciseLogEntity> {
  Future<ExerciseLogEntity?> getByLogId(String logId) {
    return getByIndex(r'logId', [logId]);
  }

  ExerciseLogEntity? getByLogIdSync(String logId) {
    return getByIndexSync(r'logId', [logId]);
  }

  Future<bool> deleteByLogId(String logId) {
    return deleteByIndex(r'logId', [logId]);
  }

  bool deleteByLogIdSync(String logId) {
    return deleteByIndexSync(r'logId', [logId]);
  }

  Future<List<ExerciseLogEntity?>> getAllByLogId(List<String> logIdValues) {
    final values = logIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'logId', values);
  }

  List<ExerciseLogEntity?> getAllByLogIdSync(List<String> logIdValues) {
    final values = logIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'logId', values);
  }

  Future<int> deleteAllByLogId(List<String> logIdValues) {
    final values = logIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'logId', values);
  }

  int deleteAllByLogIdSync(List<String> logIdValues) {
    final values = logIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'logId', values);
  }

  Future<Id> putByLogId(ExerciseLogEntity object) {
    return putByIndex(r'logId', object);
  }

  Id putByLogIdSync(ExerciseLogEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'logId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByLogId(List<ExerciseLogEntity> objects) {
    return putAllByIndex(r'logId', objects);
  }

  List<Id> putAllByLogIdSync(
    List<ExerciseLogEntity> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'logId', objects, saveLinks: saveLinks);
  }
}

extension ExerciseLogEntityQueryWhereSort
    on QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QWhere> {
  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterWhere>
  anyTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timestamp'),
      );
    });
  }
}

extension ExerciseLogEntityQueryWhere
    on QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QWhereClause> {
  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterWhereClause>
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterWhereClause>
  logIdEqualTo(String logId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'logId', value: [logId]),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterWhereClause>
  logIdNotEqualTo(String logId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'logId',
                lower: [],
                upper: [logId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'logId',
                lower: [logId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'logId',
                lower: [logId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'logId',
                lower: [],
                upper: [logId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterWhereClause>
  timestampEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'timestamp', value: [timestamp]),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterWhereClause>
  timestampNotEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'timestamp',
                lower: [],
                upper: [timestamp],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'timestamp',
                lower: [timestamp],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'timestamp',
                lower: [timestamp],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'timestamp',
                lower: [],
                upper: [timestamp],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterWhereClause>
  timestampGreaterThan(DateTime timestamp, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'timestamp',
          lower: [timestamp],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterWhereClause>
  timestampLessThan(DateTime timestamp, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'timestamp',
          lower: [],
          upper: [timestamp],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterWhereClause>
  timestampBetween(
    DateTime lowerTimestamp,
    DateTime upperTimestamp, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'timestamp',
          lower: [lowerTimestamp],
          includeLower: includeLower,
          upper: [upperTimestamp],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterWhereClause>
  typeKeyEqualTo(String typeKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'typeKey', value: [typeKey]),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterWhereClause>
  typeKeyNotEqualTo(String typeKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'typeKey',
                lower: [],
                upper: [typeKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'typeKey',
                lower: [typeKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'typeKey',
                lower: [typeKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'typeKey',
                lower: [],
                upper: [typeKey],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension ExerciseLogEntityQueryFilter
    on QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QFilterCondition> {
  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  logIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'logId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  logIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'logId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  logIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'logId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  logIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'logId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  logIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'logId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  logIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'logId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  logIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'logId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  logIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'logId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  logIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'logId', value: ''),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  logIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'logId', value: ''),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  repsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'reps', value: value),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  repsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'reps',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  repsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'reps',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  repsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'reps',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timestamp', value: value),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  timestampGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  timestampLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'timestamp',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  typeKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'typeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  typeKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'typeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  typeKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'typeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  typeKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'typeKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  typeKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'typeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  typeKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'typeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  typeKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'typeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  typeKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'typeKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  typeKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'typeKey', value: ''),
      );
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterFilterCondition>
  typeKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'typeKey', value: ''),
      );
    });
  }
}

extension ExerciseLogEntityQueryObject
    on QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QFilterCondition> {}

extension ExerciseLogEntityQueryLinks
    on QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QFilterCondition> {}

extension ExerciseLogEntityQuerySortBy
    on QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QSortBy> {
  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterSortBy>
  sortByLogId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logId', Sort.asc);
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterSortBy>
  sortByLogIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logId', Sort.desc);
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterSortBy>
  sortByReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reps', Sort.asc);
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterSortBy>
  sortByRepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reps', Sort.desc);
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterSortBy>
  sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterSortBy>
  sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterSortBy>
  sortByTypeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'typeKey', Sort.asc);
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterSortBy>
  sortByTypeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'typeKey', Sort.desc);
    });
  }
}

extension ExerciseLogEntityQuerySortThenBy
    on QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QSortThenBy> {
  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterSortBy>
  thenByLogId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logId', Sort.asc);
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterSortBy>
  thenByLogIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logId', Sort.desc);
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterSortBy>
  thenByReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reps', Sort.asc);
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterSortBy>
  thenByRepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reps', Sort.desc);
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterSortBy>
  thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterSortBy>
  thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterSortBy>
  thenByTypeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'typeKey', Sort.asc);
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QAfterSortBy>
  thenByTypeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'typeKey', Sort.desc);
    });
  }
}

extension ExerciseLogEntityQueryWhereDistinct
    on QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QDistinct> {
  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QDistinct>
  distinctByLogId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'logId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QDistinct>
  distinctByReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reps');
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QDistinct>
  distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QDistinct>
  distinctByTypeKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'typeKey', caseSensitive: caseSensitive);
    });
  }
}

extension ExerciseLogEntityQueryProperty
    on QueryBuilder<ExerciseLogEntity, ExerciseLogEntity, QQueryProperty> {
  QueryBuilder<ExerciseLogEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ExerciseLogEntity, String, QQueryOperations> logIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'logId');
    });
  }

  QueryBuilder<ExerciseLogEntity, int, QQueryOperations> repsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reps');
    });
  }

  QueryBuilder<ExerciseLogEntity, DateTime, QQueryOperations>
  timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<ExerciseLogEntity, String, QQueryOperations> typeKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'typeKey');
    });
  }
}
