Feature: can change a node's value
    Given node = new SimpleNode();
    And testValue = "A new value.";
    And initialValue = node.value;
    And node.value = testValue;
    And expect(node.value, isNot(initialValue));
    And expect(node.value, equals(testValue));
    And testValue2 = 42;
    And initialValue2 = node.value;
    When node.value = testValue2;
    Then expect(node.value, isNot(initialValue2));
    And  expect(node.value, equals(testValue2.toString()));

Feature: can add a child and retrieve it through the same key
    Given node = new SimpleNode();
    And testValue = "The value of the child node.";
    And childKey = "name-of-the-child";
    And childNode = new SimpleNode()..value = testValue;
    When node[childKey] = childNode;
    Then expect(node[childKey], equals(childNode));

Feature: getting unset child key returns null
    Given node = new SimpleNode();
    Then expect(node["sdasdasd"], isNull);

Feature: setting new node at an existing key replaces the old one
    Given node = new SimpleNode();
    And node["key"] = new SimpleNode()..value="Node #1";
    And expect(node["key"].value, equals("Node #1"));
    When node["key"] = new SimpleNode()..value="Node #2";
    Then expect(node["key"].value, equals("Node #2"));
