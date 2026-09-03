import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/empresa_model.dart';

class EmpresaMapper {
  /// Convierte Empresa (Drift) a EmpresaModel
  static EmpresaModel toModel(EmpresaData empresa) {
    return EmpresaModel(
      id: empresa.id,
      nombre: empresa.nombre,
      ruc: empresa.ruc,
      tipoContribuyente: empresa.tipoContribuyente,
      direccion: empresa.direccion ?? '',
      telefono: empresa.telefono ?? '',
      instagram: empresa.instagram ?? '',
      logo: empresa.logo ?? '',
      serieBoleta: empresa.serieBoleta,
      serieFactura: empresa.serieFactura,
      correlativoBoleta: empresa.correlativoBoleta,
      correlativoFactura: empresa.correlativoFactura,
      igv: empresa.igv,
      moneda: empresa.moneda,
      impresora: empresa.impresora ?? '',
    );
  }

  /// Convierte EmpresaModel a EmpresaCompanion
  static EmpresaCompanion toCompanion(EmpresaModel model) {
    return EmpresaCompanion(
      id: model.id == null ? const Value.absent() : Value(model.id!),
      nombre: Value(model.nombre),
      ruc: Value(model.ruc),
      tipoContribuyente: Value(model.tipoContribuyente),
      direccion: model.direccion.isEmpty
          ? const Value.absent()
          : Value(model.direccion),
      telefono: model.telefono.isEmpty
          ? const Value.absent()
          : Value(model.telefono),
      instagram: model.instagram.isEmpty
          ? const Value.absent()
          : Value(model.instagram),
      logo: model.logo.isEmpty ? const Value.absent() : Value(model.logo),
      serieBoleta: Value(model.serieBoleta),
      serieFactura: Value(model.serieFactura),
      correlativoBoleta: Value(model.correlativoBoleta),
      correlativoFactura: Value(model.correlativoFactura),
      igv: Value(model.igv),
      moneda: Value(model.moneda),
      impresora: model.impresora.isEmpty
          ? const Value.absent()
          : Value(model.impresora),
    );
  }
}
