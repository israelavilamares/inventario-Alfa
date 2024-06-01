import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class Newsheet extends StatefulWidget {
  const Newsheet({super.key});
  @override
  State<Newsheet> createState() => _NewsheetState();
}

class _NewsheetState extends State<Newsheet> {
  List<dynamic> datos = []; // List to store retrieved data
  @override
  void initState() {
    super.initState();
    _fetchData(); // Call the data fetching function on widget initialization
  }
  Future<void> _fetchData() async{
    try{
      final db =  FirebaseFirestore.instance;
      final collectionRef = db.collection("table_herramientas");
      final query = await collectionRef.get();
    setState(() {
        datos = query.docs.map((doc) => doc.data()).toList(); // Update state with retrieved data
    });



    }catch(e){
      debugPrint("Error fetching data: $e");
    }
  }


  void addItem()async{
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddForm()),
    );
    _fetchData();
  
  }

 Future<void> _delete(String nombre) async {
  try {
    final db = FirebaseFirestore.instance;
    
    // Realiza una consulta para obtener el documento con el nombre especificado
    QuerySnapshot querySnapshot = await db
        .collection("table_herramientas")
        .where("nombre", isEqualTo: nombre)
        .get();

    // Verifica si se encontraron documentos con el nombre especificado
    if (querySnapshot.docs.isNotEmpty) {
      // Si se encontró al menos un documento, elimina el primero encontrado
      await querySnapshot.docs.first.reference.delete();
      
      // Actualiza los datos después de la eliminación
      await _fetchData();
      
      print("Documento con nombre $nombre eliminado correctamente.");
    } else {
      print("No se encontraron documentos con nombre $nombre.");
    }
  } catch (e) {
    debugPrint("Error al eliminar datos: $e");
  }
}

void search() async{
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const  Search()),);
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 127, 210, 251),
      appBar: AppBar(title: const Text("Herramientas"),
      actions: <Widget>[
        IconButton(onPressed: () => search(), icon: const Icon(Icons.search)
        ),
        ],
        ),
      body: datos.isNotEmpty
          ? ListView.builder(
              itemCount: datos.length,
              itemBuilder: (context, index) {
                final data = datos[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(data["nombre"] ?? ""),
                    trailing: IconButton(
                    onPressed: () => _delete(data["nombre"] ?? ""),
                    icon: const Icon(Icons.delete),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Cantidad: ${data["cantidad"].toString()}"),
                        Text("Lugar: ${data["lugar"] ?? ""}"),
                        // Add more fields as needed
                        
                      ],
                    ),
                  ),
                );
              },
            )
          : const Center(
              child: Text("Cargando datos.."),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: addItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}


class AddForm extends StatefulWidget{
  const AddForm({super.key});

  @override
  State<AddForm> createState() => _AddFormState();
}

class _AddFormState extends State<AddForm> {
  var myMap = <String, int>{};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // A key for managing the form 
  String nombre = ''; // Variable to store the entered name 
  int cantidad = 0; // Variable to store the entered cantidad 
  String lugar = ''; // Variable to store the entered lugar

 Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save the form data 

      try {
        final db = FirebaseFirestore.instance;
        await db.collection("table_herramientas").add({'nombre': nombre, 'cantidad': cantidad, 'lugar': lugar});
        Navigator.pop(context); // Go back to the previous screen after adding the item

      } catch (e) {
        debugPrint("Error adding data: $e");
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agregar")),
      backgroundColor: const Color.fromARGB(255, 180, 226, 243),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              TextFormField( 
                decoration: const InputDecoration(labelText: 'Nombre'), // Label for the nombre field 
                validator: (value) { 
                  // Validation function for the nombre field 
                  if (value!.isEmpty) { 
                    return 'Por favor ingresa un nombre.'; // Return an error message if the nombre is empty 
                  } 
                  return null; // Return null if the nombre is valid 
                }, 
                onSaved: (value) { 
                  nombre = value!; // Save the entered nombre 
                }, 
              ),
              TextFormField( 
                decoration: const InputDecoration(labelText: 'Cantidad'), // Label for the cantidad field 
                keyboardType: TextInputType.number,
                validator: (value) { 
                  // Validation function for the cantidad field 
                  if (value!.isEmpty) { 
                    return 'Por favor ingresa una cantidad.'; // Return an error message if the cantidad is empty 
                  } 
                  return null; // Return null if the cantidad is valid 
                }, 
                onSaved: (value) { 
                  cantidad = int.parse(value!); // Save the entered cantidad 
                }, 
              ),
              TextFormField( 
                decoration: const InputDecoration(labelText: 'Lugar'), // Label for the lugar field 
                validator: (value) { 
                  // Validation function for the lugar field 
                  if (value!.isEmpty) { 
                    return 'Por favor ingresa un lugar.'; // Return an error message if the lugar is empty 
                  } 
                  return null; // Return null if the lugar is valid 
                }, 
                onSaved: (value) { 
                  lugar = value!; // Save the entered lugar 
                }, 
              ),
              const SizedBox(height: 60.0), 
              ElevatedButton( 
                onPressed: _submitForm,
                style: ButtonStyle(iconSize:WidgetStateProperty.all(45.9),
                backgroundColor: WidgetStateProperty.all(const Color.fromARGB(255, 228, 222, 238))), // Call the _submitForm function when the button is pressed 
                child: const Icon(Icons.done_outline)
               ) // Text on the button 
            ],
          ),
        ),
      ),
    );
  }
}


class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();
  final String _searchText = "";
  List<DocumentSnapshot> _searchResults = [];

  void _search() async {
    String query = _searchController.text.trim();
    if (query.isNotEmpty) {
      var result = await FirebaseFirestore.instance
          .collection('table_herramientas') // Reemplaza con tu colección
          .where('nombre', isGreaterThanOrEqualTo: query)
          .where('nombre', isLessThanOrEqualTo: '$query\uf8ff')
          .get();
      setState(() {
        _searchResults = result.docs;
      });
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 127, 210, 251),
        appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Buscar...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black),
          ),
          style: const TextStyle(color: Color.fromARGB(255, 116, 115, 115), fontSize: 18.0),
          onChanged: (text) {
            _search();

          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchResults = [];
              });
            },
          ),
        ],
      ),
      body: _buildSearchResults(),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Column(
        children: <Widget>[Text(
          'No se encontraron resultados.',
          style: TextStyle(fontSize: 24.0),
        ),]
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        var document = _searchResults[index];
        return ListTile(
          title: Text(document['nombre']),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Cantidad: ${document['cantidad'].toString()}"),
              Text("Lugar: ${document['lugar']}"),
            ],
          ),
        );
      },
    );
  }
}
