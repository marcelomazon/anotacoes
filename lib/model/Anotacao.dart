class Anotacao {
  int id;
  String titulo;
  String descricao;
  String data;

  Anotacao(this.titulo, this.descricao, this.data);

  Anotacao.fromMap(Map obj) {
    this.id = obj['id'];
    this.titulo = obj['titulo'];
    this.descricao = obj['descricao'];
    this.data = obj['data'];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      "titulo": this.titulo,
      "descricao": this.descricao,
      "data": this.data
    };

    if (this.id != null)
      map["id"] = this.id;

    return map;
  }



}