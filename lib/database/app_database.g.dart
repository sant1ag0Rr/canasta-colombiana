// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProductNotesTable extends ProductNotes
    with TableInfo<$ProductNotesTable, ProductNoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pendingSyncMeta = const VerificationMeta(
    'pendingSync',
  );
  @override
  late final GeneratedColumn<bool> pendingSync = GeneratedColumn<bool>(
    'pending_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    productId,
    note,
    priority,
    updatedAt,
    pendingSync,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductNoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('pending_sync')) {
      context.handle(
        _pendingSyncMeta,
        pendingSync.isAcceptableOrUnknown(
          data['pending_sync']!,
          _pendingSyncMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {productId};
  @override
  ProductNoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductNoteRow(
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      pendingSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending_sync'],
      )!,
    );
  }

  @override
  $ProductNotesTable createAlias(String alias) {
    return $ProductNotesTable(attachedDatabase, alias);
  }
}

class ProductNoteRow extends DataClass implements Insertable<ProductNoteRow> {
  final int productId;
  final String note;
  final int priority;
  final DateTime updatedAt;
  final bool pendingSync;
  const ProductNoteRow({
    required this.productId,
    required this.note,
    required this.priority,
    required this.updatedAt,
    required this.pendingSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['product_id'] = Variable<int>(productId);
    map['note'] = Variable<String>(note);
    map['priority'] = Variable<int>(priority);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['pending_sync'] = Variable<bool>(pendingSync);
    return map;
  }

  ProductNotesCompanion toCompanion(bool nullToAbsent) {
    return ProductNotesCompanion(
      productId: Value(productId),
      note: Value(note),
      priority: Value(priority),
      updatedAt: Value(updatedAt),
      pendingSync: Value(pendingSync),
    );
  }

  factory ProductNoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductNoteRow(
      productId: serializer.fromJson<int>(json['productId']),
      note: serializer.fromJson<String>(json['note']),
      priority: serializer.fromJson<int>(json['priority']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      pendingSync: serializer.fromJson<bool>(json['pendingSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'productId': serializer.toJson<int>(productId),
      'note': serializer.toJson<String>(note),
      'priority': serializer.toJson<int>(priority),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'pendingSync': serializer.toJson<bool>(pendingSync),
    };
  }

  ProductNoteRow copyWith({
    int? productId,
    String? note,
    int? priority,
    DateTime? updatedAt,
    bool? pendingSync,
  }) => ProductNoteRow(
    productId: productId ?? this.productId,
    note: note ?? this.note,
    priority: priority ?? this.priority,
    updatedAt: updatedAt ?? this.updatedAt,
    pendingSync: pendingSync ?? this.pendingSync,
  );
  ProductNoteRow copyWithCompanion(ProductNotesCompanion data) {
    return ProductNoteRow(
      productId: data.productId.present ? data.productId.value : this.productId,
      note: data.note.present ? data.note.value : this.note,
      priority: data.priority.present ? data.priority.value : this.priority,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      pendingSync: data.pendingSync.present
          ? data.pendingSync.value
          : this.pendingSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductNoteRow(')
          ..write('productId: $productId, ')
          ..write('note: $note, ')
          ..write('priority: $priority, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('pendingSync: $pendingSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(productId, note, priority, updatedAt, pendingSync);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductNoteRow &&
          other.productId == this.productId &&
          other.note == this.note &&
          other.priority == this.priority &&
          other.updatedAt == this.updatedAt &&
          other.pendingSync == this.pendingSync);
}

class ProductNotesCompanion extends UpdateCompanion<ProductNoteRow> {
  final Value<int> productId;
  final Value<String> note;
  final Value<int> priority;
  final Value<DateTime> updatedAt;
  final Value<bool> pendingSync;
  const ProductNotesCompanion({
    this.productId = const Value.absent(),
    this.note = const Value.absent(),
    this.priority = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.pendingSync = const Value.absent(),
  });
  ProductNotesCompanion.insert({
    this.productId = const Value.absent(),
    required String note,
    required int priority,
    required DateTime updatedAt,
    this.pendingSync = const Value.absent(),
  }) : note = Value(note),
       priority = Value(priority),
       updatedAt = Value(updatedAt);
  static Insertable<ProductNoteRow> custom({
    Expression<int>? productId,
    Expression<String>? note,
    Expression<int>? priority,
    Expression<DateTime>? updatedAt,
    Expression<bool>? pendingSync,
  }) {
    return RawValuesInsertable({
      if (productId != null) 'product_id': productId,
      if (note != null) 'note': note,
      if (priority != null) 'priority': priority,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (pendingSync != null) 'pending_sync': pendingSync,
    });
  }

  ProductNotesCompanion copyWith({
    Value<int>? productId,
    Value<String>? note,
    Value<int>? priority,
    Value<DateTime>? updatedAt,
    Value<bool>? pendingSync,
  }) {
    return ProductNotesCompanion(
      productId: productId ?? this.productId,
      note: note ?? this.note,
      priority: priority ?? this.priority,
      updatedAt: updatedAt ?? this.updatedAt,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (pendingSync.present) {
      map['pending_sync'] = Variable<bool>(pendingSync.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductNotesCompanion(')
          ..write('productId: $productId, ')
          ..write('note: $note, ')
          ..write('priority: $priority, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('pendingSync: $pendingSync')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProductNotesTable productNotes = $ProductNotesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [productNotes];
}

typedef $$ProductNotesTableCreateCompanionBuilder =
    ProductNotesCompanion Function({
      Value<int> productId,
      required String note,
      required int priority,
      required DateTime updatedAt,
      Value<bool> pendingSync,
    });
typedef $$ProductNotesTableUpdateCompanionBuilder =
    ProductNotesCompanion Function({
      Value<int> productId,
      Value<String> note,
      Value<int> priority,
      Value<DateTime> updatedAt,
      Value<bool> pendingSync,
    });

class $$ProductNotesTableFilterComposer
    extends Composer<_$AppDatabase, $ProductNotesTable> {
  $$ProductNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductNotesTable> {
  $$ProductNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductNotesTable> {
  $$ProductNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => column,
  );
}

class $$ProductNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductNotesTable,
          ProductNoteRow,
          $$ProductNotesTableFilterComposer,
          $$ProductNotesTableOrderingComposer,
          $$ProductNotesTableAnnotationComposer,
          $$ProductNotesTableCreateCompanionBuilder,
          $$ProductNotesTableUpdateCompanionBuilder,
          (
            ProductNoteRow,
            BaseReferences<_$AppDatabase, $ProductNotesTable, ProductNoteRow>,
          ),
          ProductNoteRow,
          PrefetchHooks Function()
        > {
  $$ProductNotesTableTableManager(_$AppDatabase db, $ProductNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> productId = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
              }) => ProductNotesCompanion(
                productId: productId,
                note: note,
                priority: priority,
                updatedAt: updatedAt,
                pendingSync: pendingSync,
              ),
          createCompanionCallback:
              ({
                Value<int> productId = const Value.absent(),
                required String note,
                required int priority,
                required DateTime updatedAt,
                Value<bool> pendingSync = const Value.absent(),
              }) => ProductNotesCompanion.insert(
                productId: productId,
                note: note,
                priority: priority,
                updatedAt: updatedAt,
                pendingSync: pendingSync,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProductNotesTable, ProductNoteRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ProductNotesTable,
                    ProductNoteRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductNotesTable,
      ProductNoteRow,
      $$ProductNotesTableFilterComposer,
      $$ProductNotesTableOrderingComposer,
      $$ProductNotesTableAnnotationComposer,
      $$ProductNotesTableCreateCompanionBuilder,
      $$ProductNotesTableUpdateCompanionBuilder,
      (
        ProductNoteRow,
        BaseReferences<_$AppDatabase, $ProductNotesTable, ProductNoteRow>,
      ),
      ProductNoteRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProductNotesTableTableManager get productNotes =>
      $$ProductNotesTableTableManager(_db, _db.productNotes);
}
