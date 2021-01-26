import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _listaTarefas = [];                                              //lista onde as tarefas serão salvas
  Map<String, dynamic> _tarefaRecuperada = Map();
  TextEditingController _controllerTarefa = TextEditingController();    // controller para salvar o que foi digitado dentro do showDialog

  Future<File> _getFile() async {

    //Capturando local do diretorio e criando arquivo dados.json no local
    final diretorio = await getApplicationDocumentsDirectory();
    return File(diretorio.path + "/dadosLista.json");
  }

  _salvarArquivo() async {

    //recuperando arquivo File
    var arquivo = await _getFile();

    final diretorio = await getApplicationDocumentsDirectory();

    //Convertendo a lista em json e salvando dentro do arquivo criado
    String dados = json.encode(_listaTarefas);
    arquivo.writeAsString(dados);
  }

  _salvarTarefa() {

    String textoDigitado = _controllerTarefa.text;

    //Criar dados
    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;

    //Adiciona a nova tarefa na lista e chama o metodo para salvar o arquivo
    setState(() {
      _listaTarefas.add(tarefa);
    });
    _salvarArquivo();
    _controllerTarefa.text = "";
  }

  _lerArquivo() async {

    try{
      //recuperando arquivo File
      final arquivo = await _getFile();
      return arquivo.readAsString();

    }catch(e){
      return null;
    }
  }

  _criarItem() {
    showDialog(
        context: context,
        builder: (context){

          return AlertDialog(
            title: Text("Adicionar tarefa"),
            content: TextField(
              controller: _controllerTarefa,
              decoration: InputDecoration(
                  labelText: "Digite sua tarefa"
              ),
              onChanged: (text){},
            ),
            actions: [
              FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar")
              ),
              FlatButton(
                  onPressed: (){
                    _salvarTarefa();
                    Navigator.pop(context);
                  },
                  child: Text("Salvar")
              ),
            ],

          );
        }
    );
  }

  _confirmarExclusao(context, index) {
    showDialog(
        context: context,
        builder: (context){

          return AlertDialog(
            title: Text("Tem certeza que deseja remover tarefa?"),
            actions: [
              FlatButton(
                  onPressed: (){
                    _listaTarefas.removeAt(index);
                    _salvarArquivo();
                    Navigator.pop(context);
                  },
                  child: Text("Sim")
              ),

              FlatButton(
                  onPressed: (){
                    setState(() {
                    });
                    Navigator.pop(context);
                  },
                  child: Text("Não")
              ),
            ],

          );
        }
    );

  }


  _snackbarDesfazer(context, index){

    final snackbar = SnackBar(
      duration: Duration(seconds: 4),
      content: Text("Tarefa removida"),
      action: SnackBarAction(
          label: "Desfazer",
          onPressed: (){
            setState(() {
              _listaTarefas.insert(index, _tarefaRecuperada);
            });
            _salvarArquivo();
          }
      ),
    );
    Scaffold.of(context).showSnackBar(snackbar);

  }

  Widget criarItemLista(context, index){

    final itemKey = DateTime.now().millisecondsSinceEpoch.toString();

    return Dismissible(
        key: Key(itemKey),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Icon(
                  Icons.delete,
                color: Colors.white,
              )
            ],
          ),
        ),
        child: CheckboxListTile(
          title: Text(_listaTarefas[index]['titulo']),
          value: _listaTarefas[index]['realizada'],
          onChanged: (valorAlterado){

            setState(() {
              _listaTarefas[index]['realizada'] = valorAlterado;
            });

            _salvarArquivo();

          },
        ),
        onDismissed: (direction){
          //recupera e guarda item antes de remover da lista
          _tarefaRecuperada = _listaTarefas[index];

          //verifica intensão de remover item
          _confirmarExclusao(context, index);

        }
    );

  }

  @override
  void initState() {
    super.initState();

    _lerArquivo().then((dados){
      setState(() {
        _listaTarefas = json.decode(dados);
      });
    });

  }

  @override
  Widget build(BuildContext context) {

    _salvarArquivo();

    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de tarefas"),
        backgroundColor: Colors.purple,

      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: ListView.builder(
                  itemCount: _listaTarefas.length,
                  itemBuilder: criarItemLista,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor:  Colors.purple,
        child: Icon(Icons.add),
        onPressed: _criarItem,
      ),
    );
  }
}
