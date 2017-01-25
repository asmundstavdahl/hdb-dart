import 'dart:async';
import "dart:convert";
import 'dart:io';

int port = 44550;
String persistanceFileName = "data.json";

String usage = """Usage:
\t\$0 <port>

\tport\tdefault: $port""";

Map<String, String> data = new Map<String, String>();
Map<String, Completer> changeFutures = new Map<String, Completer>();

main(List<String> args) async {
  try {
    String persistedData = await new File(persistanceFileName).readAsString();
    if (persistedData.length > 0) {
      data = JSON.decode(persistedData);
    } else {
      print("No persistance data; starting fresh.");
    }
  } catch (e) {
    print("Could not import persisted data: " + e.toString());
  }

  if (args.length > 0) {
    if (args.first == "--help") {
      print(usage);
      exitCode = 0;
      return;
    }
    port = int.parse(args[0]);
  }

  var requestServer = await HttpServer.bind(InternetAddress.ANY_IP_V4, port);
  print('listening on localhost, port ${requestServer.port}');

  await for (HttpRequest request in requestServer) {
    var parameters = request.uri.queryParameters;

    print("\x1b[34m" +
        new DateTime.now().toString() +
        "\x1b[0m  " +
        request.method +
        " " +
        request.uri.toString() +
        "  \x1b[33m" +
        parameters["as"] +
        "\x1b[0m  " +
        request.connectionInfo.remoteAddress.host);

    String key = request.uri.path;
    key = key.replaceAll(new RegExp('//+'), "/");
    String value = await UTF8.decodeStream(request);

    String finalMethod = request.method;
    if (null != parameters["method"]) {
      finalMethod = parameters["method"];
    }

    String finalValue = value;
    if (null != parameters["value"]) {
      finalValue = parameters["value"];
    }

    switch (finalMethod) {
      case "GET":
        if (parameters.containsKey("wait")) {
          changeFutures[key] = new Completer();
          changeFutures[key].future.then((value) {
            request.response.write(value);
            request.response.close();
          }).catchError((e) {
            request.response.statusCode = 500;
            request.response.write(e.toString());
            request.response.close();
          });
        } else {
          String result;
          if (key.endsWith("/")) {
            result = getChildrenAtKey(key).join("\n");
          } else {}
          result = getData(key);
          request.response.write(result);
          request.response.close();
        }
        break;
      case "PUT":
        setData(key, finalValue);
        request.response.write("");
        request.response.close();
        break;
      case "POST":
        int index = 1 + getLastNumberedChildIndexAtKey(key);
        String childKey = key + "/${index}";
        setData(childKey, finalValue);
        request.response.write("${index}");
        request.response.close();
        break;
      default:
        request.response.write("Unsupported method.");
        request.response.close();
    }
  }
}

int getLastNumberedChildIndexAtKey(String parentKey) {
  int lastNumberedChildIndex = 0;

  String childIndex;
  data.forEach((key, value) {
    if (key.startsWith(parentKey) && key != parentKey) {
      childIndex = key.split("/").last;
      try {
        var childNumberedIndex = int.parse(childIndex);
        if (childNumberedIndex > lastNumberedChildIndex) {
          lastNumberedChildIndex = childNumberedIndex;
        }
      } catch (exception) {
        //print(exception);
      }
    }
  });

  return lastNumberedChildIndex;
}

String getData(key) {
  String value = data[key];
  print("\t" + key + " → " + (value != null ? value : "<NO VALUE>"));
  return value != null ? value : "";
}

setData(key, value) async {
  print("\t" + key + " ← " + value);
  data[key] = value;
  if (changeFutures.containsKey(key)) {
    changeFutures[key].complete(value);
    changeFutures.remove(key);
  }
  await new File(persistanceFileName).writeAsString(JSON.encode(data));
}

List<String> getChildrenAtKey(parentKey, [recursive = false]) {
  List<String> children = new List<String>();

  data.forEach((key, value) {
    if (key.startsWith(parentKey) && key != parentKey) {
      String childKey = key.replaceFirst(parentKey, "");
      if (recursive || !childKey.contains("/")) {
        children.add(childKey);
      }
    }
  });

  children.sort();

  List<String> uniqueChildren = new List<String>();

  uniqueChildren.add(children.first);
  for (String child in children) {
    if (uniqueChildren.last != child) {
      uniqueChildren.add(child);
    }
  }

  return uniqueChildren;
}
