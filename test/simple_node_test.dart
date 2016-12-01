import "package:astest/bdd.dart";
import "package:test/test.dart";

import '../src/simple_node.dart';

main() {
  feature("can change a node's value")
    ..given("node = new SimpleNode();", (c) {
      c.node = new SimpleNode();
    })
    ..and("testValue = \"A new value.\";", (c) {
      c.testValue = "A new value.";
    })
    ..and("initialValue = node.value;", (c) {
      c.initialValue = c.node.value;
    })
    ..and("node.value = testValue;", (c) {
      c.node.value = c.testValue;
    })
    ..and("expect(node.value, isNot(initialValue));", (c) {
      expect(c.node.value, isNot(c.initialValue));
    })
    ..and("expect(node.value, equals(testValue));", (c) {
      expect(c.node.value, equals(c.testValue));
    })
    ..and("testValue2 = 42;", (c) {
      c.testValue2 = 42;
    })
    ..and("initialValue2 = node.value;", (c) {
      c.initialValue2 = c.node.value;
    })
    ..when("node.value = testValue2;", (c) {
      c.node.value = c.testValue2;
    })
    ..then("expect(node.value, isNot(initialValue2));", (c) {
      expect(c.node.value, isNot(c.initialValue2));
    })
    ..and("expect(node.value, equals(testValue2.toString()));", (c) {
      expect(c.node.value, equals(c.testValue2.toString()));
    })();

  feature("can add a child and retrieve it through the same key")
    ..given("node = new SimpleNode();", (c) {
      c.node = new SimpleNode();
    })
    ..and("testValue = \"The value of the child node.\";", (c) {
      c.testValue = "The value of the child node.";
    })
    ..and("childKey = \"name-of-the-child\";", (c) {
      c.childKey = "name-of-the-child";
    })
    ..and("childNode = new c.SimpleNode()..value = testValue;", (c) {
      c.childNode = new SimpleNode()..value = c.testValue;
    })
    ..when("node[childKey] = c.childNode;", (c) {
      c.node[c.childKey] = c.childNode;
    })
    ..then("expect(c.node[childKey], equals(childNode));", (c) {
      expect(c.node[c.childKey], equals(c.childNode));
    })();

  feature("getting unset child key returns null")
    ..given("node = new SimpleNode();", (c) {
      c.node = new SimpleNode();
    })
    ..then("expect(c.node[\"sdasdasd\"], isNull);", (c) {
      expect(c.node["sdasdasd"], isNull);
    })();

  feature("setting new node at an existing key replaces the old one")
    ..given("node = new SimpleNode();", (c) {
      c.node = new SimpleNode();
    })
    ..and("node[\"key\"] = new SimpleNode()..value=\"Node #1\";", (c) {
      c.node["key"] = new SimpleNode()..value="Node #1";
    })
    ..and("expect(c.node[\"key\"].value, equals(\"Node #1\"));", (c) {
      expect(c.node["key"].value, equals("Node #1"));
    })
    ..when("node[\"key\"] = new SimpleNode()..value=\"Node #2\";", (c) {
      c.node["key"] = new SimpleNode()..value="Node #2";
    })
    ..then("expect(c.node[\"key\"].value, equals(\"Node #2\"));", (c) {
      expect(c.node["key"].value, equals("Node #2"));
    })();
}
