import 'dart:async';


import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Liste extends StatefulWidget {



  @override
  _ListeState createState() => _ListeState();
}

class _ListeState extends State<Liste> {
  late FirebaseDatabase db;
  late DatabaseReference ref;
  List items = [];
  bool isLoaded = false;

  @override
  void initState() {


    init();

  }

  init() async
  {
    FirebaseApp app = await Firebase.app();

    db = FirebaseDatabase.instanceFor(app: app);
    /*
    ref = db.ref("/items");
    var obj = { "ad" : "Süt", "adet" : "1 lt" };
    ref.push().set(obj);

    var obj2 = { "ad" : "Yumurta", "adet" : "1 Kutu" };
    ref.push().set(obj2);

    var obj3 = { "ad" : "Domates", "adet" : "1 kg" };
    ref.push().set(obj3);*/

    ref = db.ref("/items");
    ref.onValue.listen((event)
    {
      print("Veri Geldi");

      items = event.snapshot.children.map((ds)
      {
        var veri = ds.value as Map;
        veri.putIfAbsent("id", () => ds.key);
        return veri;
      }).toList();


      setState(() {
        isLoaded = true;
      });

    });
  }

  //https://cms.tuxapp.xyz/fb.html
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shopping List"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            tooltip: "Delete All",
            iconSize: 32,
            color: Colors.white,
            onPressed: ()
            {
              ref.set(null);
              setState(() {

              });
            },
          )
        ],
      ),

      body:
      isLoaded == false ?
      Center(
        child: CircularProgressIndicator(),
      ) :
        Container(
        width: double.maxFinite,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index)
            {
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                elevation: 8,
                child: InkWell(
                  onTap: () async
                  {
                    showUpdate(context, index);
                  },
                  child: Container(
                    padding: EdgeInsets.all(15),
                    child: Text("${items[index]["adet"]} - ${items[index]["ad"]}")
                  ),
                ),
              );

            },
          ),
    ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {

          showInsert();
        },
        child: Icon(Icons.plus_one),
        backgroundColor: Colors.green,
      ),
    );
  }


  void showInsert() async
  {
    TextEditingController tecAd = TextEditingController();
    TextEditingController tecAdet = TextEditingController();

    showDialog(context: context, builder: (context)
    {
      return AlertDialog(
        title: Center(child: Text("Add Item"),),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Adet : "),
            TextFormField(controller: tecAdet,),
            SizedBox(height: 20,),
            Text("Ad : "),
            TextFormField(controller: tecAd,),
            SizedBox(height: 30,),
            ElevatedButton(onPressed: () {

              var obj = { "ad" : tecAd.text, "adet" : tecAdet.text };
              isLoaded = false;

              Navigator.pop(context);
              setState(() {

              });
              ref.push().set(obj);

            }, child: Text("Add Item"))


          ],
        ),
      ) ;
    },);
  }






  void showUpdate(BuildContext context, index) async
  {
    var selItem = items[index];
    var selId = selItem["id"];
    print("Seçilen Item : ${selItem}");
    TextEditingController tecAd =
    TextEditingController(text: "${selItem["ad"]}");
    TextEditingController tecAdet = TextEditingController(text: "${selItem["adet"]}");
    showDialog(context: context, builder: (context)
    {
      return AlertDialog(
        title: Center(child: Text("Update Item"),),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Adet : "),
            TextFormField(controller: tecAdet,),
            SizedBox(height: 20,),
            Text("Ad : "),
            TextFormField(controller: tecAd,),
            SizedBox(height: 30,),
            ElevatedButton(onPressed: () {

              var obj = { "ad" : tecAd.text, "adet" : tecAdet.text };
              isLoaded = false;

              Navigator.pop(context);
              setState(() {

              });
              var ref2 = db.ref("/items/${selId}");
              ref2.set(obj);

            }, child: Text("Update Item")),

            SizedBox(height: 10,),
            ElevatedButton(

                onPressed: () {


              Navigator.pop(context);
              setState(() {

              });
              var ref2 = db.ref("/items/${selId}");
              ref2.set(null);

            }, child: Text("Delete Item"))


          ],
        ),
      ) ;
    },);
  }
}
