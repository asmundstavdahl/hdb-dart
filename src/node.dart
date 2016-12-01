abstract class Node {
  String get value;
  void set value(newValue);

  Node operator [](String key);
  void operator []=(String key, Node node);
}
