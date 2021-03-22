class Band {
  String id;
  String name;
  int vote;

  Band({this.id, this.name, this.vote});

  // Genera una nueva instancia de la clase
  factory Band.fromMap(Map<String, dynamic> obj) 
  =>Band(
    id: obj['id'], 
    name: obj['name'], 
    vote: obj['vote']
  );
}
