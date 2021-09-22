class Band {
  String id;
  String name;
  int vote;

  Band({this.id, this.name, this.vote});

  // Genera una nueva instancia de la clase
  factory Band.fromMap(Map<String, dynamic> obj)
    =>Band(
      id    : obj.containsKey('id')   ? obj['id']  :'no-id',  // obj.containsKey --> se verifica que este el elmento dentro de la información 
      name  : obj.containsKey('name') ? obj['name']:'no-name',
      vote  : obj.containsKey('votes') ? obj['votes']:'no-votes'
    );
}
