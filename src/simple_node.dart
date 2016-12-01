import 'node.dart';

class SimpleNode implements Node {
  String _value;
  Map<String, Node> _children = new Map<String, Node>();

  get value => _value;
  set value(newValue) => _value = newValue.toString();

  @override
  operator [](String key) => _children[key];

  @override
  operator []=(String key, Node node) {
    _children[key] = node;
  }
}
