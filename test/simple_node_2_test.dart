import "package:test/test.dart";

import "../src/simple_node.dart";

main() {
  test("can change a node's value", () {
    var node = new SimpleNode();
    var testValue = "A new value.";
    var initialValue = node.value;
    node.value = testValue;
    expect(node.value, isNot(initialValue));
    expect(node.value, equals(testValue));

    var testValue2 = 42;
    var initialValue2 = node.value;
    node.value = testValue2;
    expect(node.value, isNot(initialValue2));
    expect(node.value, equals(testValue2.toString()));
  });

  test("can add a child and retrieve it through the same key", () {
    var node = new SimpleNode();
    var testValue = "The value of the child node.";
    var childKey = "name-of-the-child";
    var childNode = new SimpleNode()
      ..value = testValue;
    node[childKey] = childNode;
    expect(node[childKey], equals(childNode));
  });

  test("getting unset child key returns null", () {
    var node = new SimpleNode();
    expect(node["sdasdasd"], isNull);
  });

  test("setting new node at an existing key replaces the old one", (){
    var node = new SimpleNode();
    node["key"] = new SimpleNode()..value="Node #1";
    expect(node["key"].value, equals("Node #1"));
    node["key"] = new SimpleNode()..value="Node #2";
    expect(node["key"].value, equals("Node #2"));
  });
}
