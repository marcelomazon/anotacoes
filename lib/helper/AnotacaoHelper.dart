import 'package:anotacoes/model/Anotacao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class AnotacaoHelper {

  //utilização do padrão singleton
  static final AnotacaoHelper _anotacaoHelper = AnotacaoHelper._internal();
  Database _db;

  factory AnotacaoHelper() {
    return _anotacaoHelper;
  }

  AnotacaoHelper._internal() {
  }

  get db async {

    if (_db != null){
      return _db;
    } else {
      _db = await inicializarDB();
      return _db;
    }

  }

  _onCreate(Database db, int version) async {
    String sql = "create table anotacao ("
        "id integer primary key autoincrement,"
        "titulo varchar,"
        "descricao text,"
        "data datetime)";
    await db.execute(sql);
  }

  inicializarDB() async {
    final caminhoDB = await getDatabasesPath();
    final localDB = join(caminhoDB, "bd_anotacoes.db");
    var db = await openDatabase(localDB, version: 1, onCreate: _onCreate);
    return db;
  }

  Future<int> salvarAnotacao(Anotacao anotacao) async {
    Database bancoDados = await db;
    int idAnotacao = await bancoDados.insert("anotacao", anotacao.toMap());
    return idAnotacao;
  }

  recuperarAnotacoes() async {
    Database bancoDados = await db;
    String sql = "select * from anotacao order by data desc";
    List dados = await bancoDados.rawQuery(sql);
    return dados;
  }

  formatarData(String data) {
    initializeDateFormatting("pt_BR");
    //var formatador = DateFormat("dd/MM/yy H:M:s");
    //var formatador = DateFormat.MEd("pt_BR");
    var formatador = DateFormat.yMMMd("pt_BR");

    DateTime dataConvertida = DateTime.parse(data);
    String dataFormatada = formatador.format(dataConvertida);

    return dataFormatada;
  }

  Future<int> atualizarAnotacao (Anotacao anotacao) async {
    Database bancoDados = await db;
    return await bancoDados.update(
      "anotacao",
      anotacao.toMap(),
      where: "id = ?",
      whereArgs: [anotacao.id]
    );
  }

  Future<int> removerAnotacao (int id) async {
    Database bancoDados = await db;
    return await bancoDados.delete("anotacao", where: "id = ?", whereArgs: [id]);
  }


}

