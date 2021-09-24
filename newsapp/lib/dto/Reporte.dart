class Reporte {
  int? idNew;
  String? rolUser;
  String? nombre;
  int? edad;
  String? sector;
  String? coordenadas;
  String? titulo;
  String? noticia;
  int? isFake;
  String? fecha;

  Reporte(
      {required this.idNew,
      required this.rolUser,
      required this.nombre,
      required this.edad,
      required this.sector,
      required this.coordenadas,
      required this.titulo,
      required this.noticia,
      required this.isFake,
      required this.fecha});

  factory Reporte.fromJson(Map<String, dynamic> json) {
    return Reporte(
      idNew : json['id'] as int?,
      rolUser : json['rol_user'] as String?,
      nombre : json['nombre'] as String?,
      edad : json['edad'] as int?,
      sector : json['sector'] as String?,
      coordenadas : json['coordenadas'] as String?,
      titulo : json['titulo'] as String?,
      noticia : json['noticia'] as String?,
      isFake : json['etiqueta'] as int?,
      fecha :  json['fecha'] as String?
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.idNew;
    data['rol_user'] = this.rolUser;
    data['nombre'] = this.nombre;
    data['edad'] = this.edad;
    data['sector'] = this.sector;
    data['coordenadas'] = this.coordenadas;
    data['titulo'] = this.titulo;
    data['noticia'] = this.noticia;
    data['etiqueta'] = this.isFake;
    data['fecha'] = this.fecha;
    return data;
  }
}
