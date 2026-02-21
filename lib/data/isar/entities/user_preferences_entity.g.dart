// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserPreferencesEntityCollection on Isar {
  IsarCollection<UserPreferencesEntity> get userPreferencesEntitys =>
      this.collection();
}

const UserPreferencesEntitySchema = CollectionSchema(
  name: r'UserPreferencesEntity',
  id: -5444499565034733150,
  properties: {
    r'hasCompletedOnboarding': PropertySchema(
      id: 0,
      name: r'hasCompletedOnboarding',
      type: IsarType.bool,
    ),
    r'primaryExerciseKey': PropertySchema(
      id: 1,
      name: r'primaryExerciseKey',
      type: IsarType.string,
    ),
    r'storageVersion': PropertySchema(
      id: 2,
      name: r'storageVersion',
      type: IsarType.long,
    ),
  },

  estimateSize: _userPreferencesEntityEstimateSize,
  serialize: _userPreferencesEntitySerialize,
  deserialize: _userPreferencesEntityDeserialize,
  deserializeProp: _userPreferencesEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _userPreferencesEntityGetId,
  getLinks: _userPreferencesEntityGetLinks,
  attach: _userPreferencesEntityAttach,
  version: '3.3.0',
);

int _userPreferencesEntityEstimateSize(
  UserPreferencesEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.primaryExerciseKey.length * 3;
  return bytesCount;
}

void _userPreferencesEntitySerialize(
  UserPreferencesEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.hasCompletedOnboarding);
  writer.writeString(offsets[1], object.primaryExerciseKey);
  writer.writeLong(offsets[2], object.storageVersion);
}

UserPreferencesEntity _userPreferencesEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserPreferencesEntity();
  object.hasCompletedOnboarding = reader.readBool(offsets[0]);
  object.id = id;
  object.primaryExerciseKey = reader.readString(offsets[1]);
  object.storageVersion = reader.readLong(offsets[2]);
  return object;
}

P _userPreferencesEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userPreferencesEntityGetId(UserPreferencesEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userPreferencesEntityGetLinks(
  UserPreferencesEntity object,
) {
  return [];
}

void _userPreferencesEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  UserPreferencesEntity object,
) {
  object.id = id;
}

extension UserPreferencesEntityQueryWhereSort
    on QueryBuilder<UserPreferencesEntity, UserPreferencesEntity, QWhere> {
  QueryBuilder<UserPreferencesEntity, UserPreferencesEntity, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserPreferencesEntityQueryWhere
    on
        QueryBuilder<
          UserPreferencesEntity,
          UserPreferencesEntity,
          QWhereClause
        > {
  QueryBuilder<UserPreferencesEntity, UserPreferencesEntity, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<UserPreferencesEntity, UserPreferencesEntity, QAfterWhereClause>
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

  QueryBuilder<UserPreferencesEntity, UserPreferencesEntity, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserPreferencesEntity, UserPreferencesEntity, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserPreferencesEntity, UserPreferencesEntity, QAfterWhereClause>
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
}

extension UserPreferencesEntityQueryFilter
    on
        QueryBuilder<
          UserPreferencesEntity,
          UserPreferencesEntity,
          QFilterCondition
        > {
  QueryBuilder<
    UserPreferencesEntity,
    UserPreferencesEntity,
    QAfterFilterCondition
  >
  hasCompletedOnboardingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'hasCompletedOnboarding',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    UserPreferencesEntity,
    UserPreferencesEntity,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    UserPreferencesEntity,
    UserPreferencesEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    UserPreferencesEntity,
    UserPreferencesEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    UserPreferencesEntity,
    UserPreferencesEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    UserPreferencesEntity,
    UserPreferencesEntity,
    QAfterFilterCondition
  >
  primaryExerciseKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'primaryExerciseKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserPreferencesEntity,
    UserPreferencesEntity,
    QAfterFilterCondition
  >
  primaryExerciseKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'primaryExerciseKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserPreferencesEntity,
    UserPreferencesEntity,
    QAfterFilterCondition
  >
  primaryExerciseKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'primaryExerciseKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserPreferencesEntity,
    UserPreferencesEntity,
    QAfterFilterCondition
  >
  primaryExerciseKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'primaryExerciseKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserPreferencesEntity,
    UserPreferencesEntity,
    QAfterFilterCondition
  >
  primaryExerciseKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'primaryExerciseKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserPreferencesEntity,
    UserPreferencesEntity,
    QAfterFilterCondition
  >
  primaryExerciseKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'primaryExerciseKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserPreferencesEntity,
    UserPreferencesEntity,
    QAfterFilterCondition
  >
  primaryExerciseKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'primaryExerciseKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserPreferencesEntity,
    UserPreferencesEntity,
    QAfterFilterCondition
  >
  primaryExerciseKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'primaryExerciseKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserPreferencesEntity,
    UserPreferencesEntity,
    QAfterFilterCondition
  >
  primaryExerciseKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'primaryExerciseKey', value: ''),
      );
    });
  }

  QueryBuilder<
    UserPreferencesEntity,
    UserPreferencesEntity,
    QAfterFilterCondition
  >
  primaryExerciseKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'primaryExerciseKey', value: ''),
      );
    });
  }

  QueryBuilder<
    UserPreferencesEntity,
    UserPreferencesEntity,
    QAfterFilterCondition
  >
  storageVersionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'storageVersion', value: value),
      );
    });
  }

  QueryBuilder<
    UserPreferencesEntity,
    UserPreferencesEntity,
    QAfterFilterCondition
  >
  storageVersionGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'storageVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    UserPreferencesEntity,
    UserPreferencesEntity,
    QAfterFilterCondition
  >
  storageVersionLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'storageVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    UserPreferencesEntity,
    UserPreferencesEntity,
    QAfterFilterCondition
  >
  storageVersionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'storageVersion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension UserPreferencesEntityQueryObject
    on
        QueryBuilder<
          UserPreferencesEntity,
          UserPreferencesEntity,
          QFilterCondition
        > {}

extension UserPreferencesEntityQueryLinks
    on
        QueryBuilder<
          UserPreferencesEntity,
          UserPreferencesEntity,
          QFilterCondition
        > {}

extension UserPreferencesEntityQuerySortBy
    on QueryBuilder<UserPreferencesEntity, UserPreferencesEntity, QSortBy> {
  QueryBuilder<UserPreferencesEntity, UserPreferencesEntity, QAfterSortBy>
  sortByHasCompletedOnboarding() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCompletedOnboarding', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesEntity, UserPreferencesEntity, QAfterSortBy>
  sortByHasCompletedOnboardingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCompletedOnboarding', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesEntity, UserPreferencesEntity, QAfterSortBy>
  sortByPrimaryExerciseKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryExerciseKey', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesEntity, UserPreferencesEntity, QAfterSortBy>
  sortByPrimaryExerciseKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryExerciseKey', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesEntity, UserPreferencesEntity, QAfterSortBy>
  sortByStorageVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storageVersion', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesEntity, UserPreferencesEntity, QAfterSortBy>
  sortByStorageVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storageVersion', Sort.desc);
    });
  }
}

extension UserPreferencesEntityQuerySortThenBy
    on QueryBuilder<UserPreferencesEntity, UserPreferencesEntity, QSortThenBy> {
  QueryBuilder<UserPreferencesEntity, UserPreferencesEntity, QAfterSortBy>
  thenByHasCompletedOnboarding() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCompletedOnboarding', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesEntity, UserPreferencesEntity, QAfterSortBy>
  thenByHasCompletedOnboardingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCompletedOnboarding', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesEntity, UserPreferencesEntity, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesEntity, UserPreferencesEntity, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesEntity, UserPreferencesEntity, QAfterSortBy>
  thenByPrimaryExerciseKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryExerciseKey', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesEntity, UserPreferencesEntity, QAfterSortBy>
  thenByPrimaryExerciseKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryExerciseKey', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesEntity, UserPreferencesEntity, QAfterSortBy>
  thenByStorageVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storageVersion', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesEntity, UserPreferencesEntity, QAfterSortBy>
  thenByStorageVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storageVersion', Sort.desc);
    });
  }
}

extension UserPreferencesEntityQueryWhereDistinct
    on QueryBuilder<UserPreferencesEntity, UserPreferencesEntity, QDistinct> {
  QueryBuilder<UserPreferencesEntity, UserPreferencesEntity, QDistinct>
  distinctByHasCompletedOnboarding() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasCompletedOnboarding');
    });
  }

  QueryBuilder<UserPreferencesEntity, UserPreferencesEntity, QDistinct>
  distinctByPrimaryExerciseKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'primaryExerciseKey',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<UserPreferencesEntity, UserPreferencesEntity, QDistinct>
  distinctByStorageVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'storageVersion');
    });
  }
}

extension UserPreferencesEntityQueryProperty
    on
        QueryBuilder<
          UserPreferencesEntity,
          UserPreferencesEntity,
          QQueryProperty
        > {
  QueryBuilder<UserPreferencesEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserPreferencesEntity, bool, QQueryOperations>
  hasCompletedOnboardingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasCompletedOnboarding');
    });
  }

  QueryBuilder<UserPreferencesEntity, String, QQueryOperations>
  primaryExerciseKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'primaryExerciseKey');
    });
  }

  QueryBuilder<UserPreferencesEntity, int, QQueryOperations>
  storageVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'storageVersion');
    });
  }
}
