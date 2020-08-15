import 'package:anotacoes/helper/AnotacaoHelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'model/Anotacao.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  var _db = AnotacaoHelper();
  List<Anotacao> _listaAnotacoes = List<Anotacao>();


  _exibirTelaCadastro({Anotacao anotacao}) {

    String acao = "";
    if (anotacao == null){
      _tituloController.text = "";
      _descricaoController.text = "";
      acao = "Criar";
    } else {
      _tituloController.text = anotacao.titulo;
      _descricaoController.text = anotacao.descricao;
      acao = "Atualizar";
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("${acao} anotação"),
          content: Column(
            mainAxisSize: MainAxisSize.min, // ocupa o espaço mínimo pro seu conteúdo
            children: [
              TextField(
                controller: _tituloController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "Título",
                  hintText: "Digite o título"
                ),
              ),
              TextField(
                controller: _descricaoController,
                decoration: InputDecoration(
                  labelText: "Descrição",
                  hintText: "Digite a descrição"
                ),
              ),
            ],
          ),
          actions: [
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            FlatButton(
              onPressed: () {
                _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);
                Navigator.pop(context);
              },
              child: Text("Salvar"),
            )
          ],
        );
      }
    );
  }

  _recuperarAnotacao() async {

    List dados = await _db.recuperarAnotacoes();
    print("lista anotações: "+dados.toString());

    // convert map (retornado do banco) para o objeto Anotacao
    List<Anotacao> listTemp = List<Anotacao>();
    for (var item in dados) {
      Anotacao anotacao = Anotacao.fromMap(item);
      listTemp.add(anotacao);
    }

    setState(() {
      _listaAnotacoes = listTemp;
    });
    listTemp = null;

  }

  _salvarAtualizarAnotacao({Anotacao anotacaoSelecionada}) async {
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;
    int idAnotacao;

    if (anotacaoSelecionada == null) {
      Anotacao anotacao = Anotacao(titulo, descricao, DateTime.now().toString());
      idAnotacao = await _db.salvarAnotacao(anotacao);
    } else {
      anotacaoSelecionada.titulo = titulo;
      anotacaoSelecionada.descricao = descricao;
      idAnotacao = await _db.atualizarAnotacao(anotacaoSelecionada);
    }

    print('anotacao ${idAnotacao} salva com sucesso.');
    _tituloController.clear();
    _descricaoController.clear();

    _recuperarAnotacao();

  }

  _removerAnotacao(int id) async {
    int result = await _db.removerAnotacao(id);
    print("${result} registo(s) excluído(s)");
    _recuperarAnotacao();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarAnotacao();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas anotações"),
        backgroundColor: Colors.lightGreen,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _listaAnotacoes.length,
              itemBuilder: (context, index) {

                final anotacao = _listaAnotacoes[index];

                return Card(
                  child: ListTile(
                    title: Text(anotacao.titulo),
                    subtitle: Text(_db.formatarData(anotacao.data) + ": " + anotacao.descricao),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: (){
                            _exibirTelaCadastro(anotacao: anotacao);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Icon(Icons.edit, color: Colors.green),
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Excluir anotação?"),
                                  content: Text("Deseja realmente exluir a anotação '" + anotacao.titulo + "'"),
                                  actions: [
                                    FlatButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("Cancelar"),
                                    ),
                                    FlatButton(
                                      onPressed: () {
                                        _removerAnotacao(anotacao.id);
                                        Navigator.pop(context);
                                      },
                                      child: Text("Excluir"),
                                    ),
                                  ],
                                );
                              }

                            );
                            ////_removerAnotacao(anotacao.id);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 0),
                            child: Icon(Icons.remove_circle, color: Colors.red),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        onPressed: _exibirTelaCadastro,
        child: Icon(Icons.add),
      ),
    );
  }
}
