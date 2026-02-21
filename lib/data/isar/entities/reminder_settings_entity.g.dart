// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_settings_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetReminderSettingsEntityCollection on Isar {
  IsarCollection<ReminderSettingsEntity> get reminderSettingsEntitys =>
      this.collection();
}

const ReminderSettingsEntitySchema = CollectionSchema(
  name: r'ReminderSettingsEntity',
  id: 2733925036961161003,
  properties: {
    r'enabled': PropertySchema(id: 0, name: r'enabled', type: IsarType.bool),
    r'intervalMinutes': PropertySchema(
      id: 1,
      name: r'intervalMinutes',
      type: IsarType.long,
    ),
    r'maxPerDay': PropertySchema(
      id: 2,
      name: r'maxPerDay',
      type: IsarType.long,
    ),
    r'quietEndMinutes': PropertySchema(
      id: 3,
      name: r'quietEndMinutes',
      type: IsarType.long,
    ),
    r'quietStartMinutes': PropertySchema(
      id: 4,
      name: r'quietStartMinutes',
      type: IsarType.long,
    ),
    r'skipWeekends': PropertySchema(
      id: 5,
      name: r'skipWeekends',
      type: IsarType.bool,
    ),
  },

  estimateSize: _reminderSettingsEntityEstimateSize,
  serialize: _reminderSettingsEntitySerialize,
  deserialize: _reminderSettingsEntityDeserialize,
  deserializeProp: _reminderSettingsEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _reminderSettingsEntityGetId,
  getLinks: _reminderSettingsEntityGetLinks,
  attach: _reminderSettingsEntityAttach,
  version: '3.3.0',
);

int _reminderSettingsEntityEstimateSize(
  ReminderSettingsEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _reminderSettingsEntitySerialize(
  ReminderSettingsEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.enabled);
  writer.writeLong(offsets[1], object.intervalMinutes);
  writer.writeLong(offsets[2], object.maxPerDay);
  writer.writeLong(offsets[3], object.quietEndMinutes);
  writer.writeLong(offsets[4], object.quietStartMinutes);
  writer.writeBool(offsets[5], object.skipWeekends);
}

ReminderSettingsEntity _reminderSettingsEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ReminderSettingsEntity();
  object.enabled = reader.readBool(offsets[0]);
  object.id = id;
  object.intervalMinutes = reader.readLong(offsets[1]);
  object.maxPerDay = reader.readLong(offsets[2]);
  object.quietEndMinutes = reader.readLong(offsets[3]);
  object.quietStartMinutes = reader.readLong(offsets[4]);
  object.skipWeekends = reader.readBool(offsets[5]);
  return object;
}

P _reminderSettingsEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _reminderSettingsEntityGetId(ReminderSettingsEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _reminderSettingsEntityGetLinks(
  ReminderSettingsEntity object,
) {
  return [];
}

void _reminderSettingsEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  ReminderSettingsEntity object,
) {
  object.id = id;
}

extension ReminderSettingsEntityQueryWhereSort
    on QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QWhere> {
  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ReminderSettingsEntityQueryWhere
    on
        QueryBuilder<
          ReminderSettingsEntity,
          ReminderSettingsEntity,
          QWhereClause
        > {
  QueryBuilder<
    ReminderSettingsEntity,
    ReminderSettingsEntity,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    ReminderSettingsEntity,
    ReminderSettingsEntity,
    QAfterWhereClause
  >
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

  QueryBuilder<
    ReminderSettingsEntity,
    ReminderSettingsEntity,
    QAfterWhereClause
  >
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<
    ReminderSettingsEntity,
    ReminderSettingsEntity,
    QAfterWhereClause
  >
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<
    ReminderSettingsEntity,
    ReminderSettingsEntity,
    QAfterWhereClause
  >
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

extension ReminderSettingsEntityQueryFilter
    on
        QueryBuilder<
          ReminderSettingsEntity,
          ReminderSettingsEntity,
          QFilterCondition
        > {
  QueryBuilder<
    ReminderSettingsEntity,
    ReminderSettingsEntity,
    QAfterFilterCondition
  >
  enabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'enabled', value: value),
      );
    });
  }

  QueryBuilder<
    ReminderSettingsEntity,
    ReminderSettingsEntity,
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
    ReminderSettingsEntity,
    ReminderSettingsEntity,
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
    ReminderSettingsEntity,
    ReminderSettingsEntity,
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
    ReminderSettingsEntity,
    ReminderSettingsEntity,
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
    ReminderSettingsEntity,
    ReminderSettingsEntity,
    QAfterFilterCondition
  >
  intervalMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'intervalMinutes', value: value),
      );
    });
  }

  QueryBuilder<
    ReminderSettingsEntity,
    ReminderSettingsEntity,
    QAfterFilterCondition
  >
  intervalMinutesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'intervalMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ReminderSettingsEntity,
    ReminderSettingsEntity,
    QAfterFilterCondition
  >
  intervalMinutesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'intervalMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ReminderSettingsEntity,
    ReminderSettingsEntity,
    QAfterFilterCondition
  >
  intervalMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'intervalMinutes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    ReminderSettingsEntity,
    ReminderSettingsEntity,
    QAfterFilterCondition
  >
  maxPerDayEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'maxPerDay', value: value),
      );
    });
  }

  QueryBuilder<
    ReminderSettingsEntity,
    ReminderSettingsEntity,
    QAfterFilterCondition
  >
  maxPerDayGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'maxPerDay',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ReminderSettingsEntity,
    ReminderSettingsEntity,
    QAfterFilterCondition
  >
  maxPerDayLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'maxPerDay',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ReminderSettingsEntity,
    ReminderSettingsEntity,
    QAfterFilterCondition
  >
  maxPerDayBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'maxPerDay',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    ReminderSettingsEntity,
    ReminderSettingsEntity,
    QAfterFilterCondition
  >
  quietEndMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'quietEndMinutes', value: value),
      );
    });
  }

  QueryBuilder<
    ReminderSettingsEntity,
    ReminderSettingsEntity,
    QAfterFilterCondition
  >
  quietEndMinutesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'quietEndMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ReminderSettingsEntity,
    ReminderSettingsEntity,
    QAfterFilterCondition
  >
  quietEndMinutesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'quietEndMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ReminderSettingsEntity,
    ReminderSettingsEntity,
    QAfterFilterCondition
  >
  quietEndMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'quietEndMinutes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    ReminderSettingsEntity,
    ReminderSettingsEntity,
    QAfterFilterCondition
  >
  quietStartMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'quietStartMinutes', value: value),
      );
    });
  }

  QueryBuilder<
    ReminderSettingsEntity,
    ReminderSettingsEntity,
    QAfterFilterCondition
  >
  quietStartMinutesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'quietStartMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ReminderSettingsEntity,
    ReminderSettingsEntity,
    QAfterFilterCondition
  >
  quietStartMinutesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'quietStartMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ReminderSettingsEntity,
    ReminderSettingsEntity,
    QAfterFilterCondition
  >
  quietStartMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'quietStartMinutes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    ReminderSettingsEntity,
    ReminderSettingsEntity,
    QAfterFilterCondition
  >
  skipWeekendsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'skipWeekends', value: value),
      );
    });
  }
}

extension ReminderSettingsEntityQueryObject
    on
        QueryBuilder<
          ReminderSettingsEntity,
          ReminderSettingsEntity,
          QFilterCondition
        > {}

extension ReminderSettingsEntityQueryLinks
    on
        QueryBuilder<
          ReminderSettingsEntity,
          ReminderSettingsEntity,
          QFilterCondition
        > {}

extension ReminderSettingsEntityQuerySortBy
    on QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QSortBy> {
  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QAfterSortBy>
  sortByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QAfterSortBy>
  sortByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QAfterSortBy>
  sortByIntervalMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalMinutes', Sort.asc);
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QAfterSortBy>
  sortByIntervalMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalMinutes', Sort.desc);
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QAfterSortBy>
  sortByMaxPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxPerDay', Sort.asc);
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QAfterSortBy>
  sortByMaxPerDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxPerDay', Sort.desc);
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QAfterSortBy>
  sortByQuietEndMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quietEndMinutes', Sort.asc);
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QAfterSortBy>
  sortByQuietEndMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quietEndMinutes', Sort.desc);
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QAfterSortBy>
  sortByQuietStartMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quietStartMinutes', Sort.asc);
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QAfterSortBy>
  sortByQuietStartMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quietStartMinutes', Sort.desc);
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QAfterSortBy>
  sortBySkipWeekends() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipWeekends', Sort.asc);
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QAfterSortBy>
  sortBySkipWeekendsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipWeekends', Sort.desc);
    });
  }
}

extension ReminderSettingsEntityQuerySortThenBy
    on
        QueryBuilder<
          ReminderSettingsEntity,
          ReminderSettingsEntity,
          QSortThenBy
        > {
  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QAfterSortBy>
  thenByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QAfterSortBy>
  thenByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QAfterSortBy>
  thenByIntervalMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalMinutes', Sort.asc);
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QAfterSortBy>
  thenByIntervalMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalMinutes', Sort.desc);
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QAfterSortBy>
  thenByMaxPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxPerDay', Sort.asc);
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QAfterSortBy>
  thenByMaxPerDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxPerDay', Sort.desc);
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QAfterSortBy>
  thenByQuietEndMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quietEndMinutes', Sort.asc);
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QAfterSortBy>
  thenByQuietEndMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quietEndMinutes', Sort.desc);
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QAfterSortBy>
  thenByQuietStartMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quietStartMinutes', Sort.asc);
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QAfterSortBy>
  thenByQuietStartMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quietStartMinutes', Sort.desc);
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QAfterSortBy>
  thenBySkipWeekends() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipWeekends', Sort.asc);
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QAfterSortBy>
  thenBySkipWeekendsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipWeekends', Sort.desc);
    });
  }
}

extension ReminderSettingsEntityQueryWhereDistinct
    on QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QDistinct> {
  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QDistinct>
  distinctByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enabled');
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QDistinct>
  distinctByIntervalMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'intervalMinutes');
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QDistinct>
  distinctByMaxPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxPerDay');
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QDistinct>
  distinctByQuietEndMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quietEndMinutes');
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QDistinct>
  distinctByQuietStartMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quietStartMinutes');
    });
  }

  QueryBuilder<ReminderSettingsEntity, ReminderSettingsEntity, QDistinct>
  distinctBySkipWeekends() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'skipWeekends');
    });
  }
}

extension ReminderSettingsEntityQueryProperty
    on
        QueryBuilder<
          ReminderSettingsEntity,
          ReminderSettingsEntity,
          QQueryProperty
        > {
  QueryBuilder<ReminderSettingsEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ReminderSettingsEntity, bool, QQueryOperations>
  enabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enabled');
    });
  }

  QueryBuilder<ReminderSettingsEntity, int, QQueryOperations>
  intervalMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'intervalMinutes');
    });
  }

  QueryBuilder<ReminderSettingsEntity, int, QQueryOperations>
  maxPerDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxPerDay');
    });
  }

  QueryBuilder<ReminderSettingsEntity, int, QQueryOperations>
  quietEndMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quietEndMinutes');
    });
  }

  QueryBuilder<ReminderSettingsEntity, int, QQueryOperations>
  quietStartMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quietStartMinutes');
    });
  }

  QueryBuilder<ReminderSettingsEntity, bool, QQueryOperations>
  skipWeekendsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'skipWeekends');
    });
  }
}
