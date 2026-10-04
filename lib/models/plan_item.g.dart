// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlanItemAdapter extends TypeAdapter<PlanItem> {
  @override
  final int typeId = 3;

  @override
  PlanItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlanItem(
      id: fields[0] as String,
      category: fields[1] as String,
      plannedAmount: fields[2] as double,
      year: fields[3] as int,
      month: fields[4] as int,
      linkedGoalId: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PlanItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.plannedAmount)
      ..writeByte(3)
      ..write(obj.year)
      ..writeByte(4)
      ..write(obj.month)
      ..writeByte(5)
      ..write(obj.linkedGoalId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlanItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
