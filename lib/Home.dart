import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _listaTarefas = [];

  Future<File> _getFile() async {

    //Capturando local do diretorio e criando arquivo dados.json no local
    final diretorio = await getApplicationDocumentsDirectory();
    return File( "${diretorio.path}/dados.json");
  }

  _salvarArquivo() async {

    //recuperando arquivo File
    var arquivo = await _getFile();

    //Criar dados
    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = "ir ao mercado";
    tarefa["realizada"] = false;
    _listaTarefas.add(tarefa);

    //Convertendo a lista em json e salvando dentro do arquivo criado
    String dados = json.encode(_listaTarefas);
    arquivo.writeAsString(dados);
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
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: _listaTarefas.length,
                  itemBuilder: (context, index){

                    return ListTile(
                      title: Text(_listaTarefas[index]['titulo']),
                    );
                  })
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor:  Colors.purple,
        child: Icon(Icons.add),
        onPressed: (){

          showDialog(
              context: context,
            builder: (context){
                return AlertDialog(
                  title: Text("Adicionar tarefa"),
                  content: TextField(
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
                          Navigator.pop(context);
                        },
                        child: Text("Salvar")
                    ),
                  ],

                );
            }
          );
        },
      ),
    );
  }
}
