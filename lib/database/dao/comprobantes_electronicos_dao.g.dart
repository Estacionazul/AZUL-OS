// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comprobantes_electronicos_dao.dart';

// ignore_for_file: type=lint
mixin _$ComprobantesElectronicosDaoMixin on DatabaseAccessor<AppDatabase> {
  $ComprobantesElectronicosTable get comprobantesElectronicos =>
      attachedDatabase.comprobantesElectronicos;
  ComprobantesElectronicosDaoManager get managers =>
      ComprobantesElectronicosDaoManager(this);
}

class ComprobantesElectronicosDaoManager {
  final _$ComprobantesElectronicosDaoMixin _db;
  ComprobantesElectronicosDaoManager(this._db);
  $$ComprobantesElectronicosTableTableManager get comprobantesElectronicos =>
      $$ComprobantesElectronicosTableTableManager(
        _db.attachedDatabase,
        _db.comprobantesElectronicos,
      );
}
