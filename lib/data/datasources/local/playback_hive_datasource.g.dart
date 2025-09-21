// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_hive_datasource.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlaybackProgressAdapter extends TypeAdapter<PlaybackProgress> {
  @override
  final int typeId = 0;

  @override
  PlaybackProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return PlaybackProgress(
      contentId: fields[0] as String,
      positionMillis: fields[1] as int,
      updatedAt: fields[2] as DateTime?,
    )..updatedAt = fields[2] as DateTime;
  }

  @override
  void write(BinaryWriter writer, PlaybackProgress obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.contentId)
      ..writeByte(1)
      ..write(obj.positionMillis)
      ..writeByte(2)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaybackProgressAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}