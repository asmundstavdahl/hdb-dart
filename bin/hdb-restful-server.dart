import "dart:convert";
import 'dart:io';

int port = 44550;
String persistanceFileName = "data.json";

String usage = """Usage:
\t\$0 <port>

\tport\tdefault: $port""";

Map<String, String> data = new Map<String, String>();

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
    print(request.method + " " + request.uri.toString());

    String key = request.uri.path;
    key = key.replaceAll(new RegExp('//+'), "/");
    String value = await UTF8.decodeStream(request);

    switch (request.method) {
      case "GET":
        String result;
        if (key.endsWith("/")) {
          result = getChildrenAtKey(key).join("\n");
        } else {
          result = getData(key);
        }
        request.response.write(result);
        request.response.close();
        break;
      case "PUT":
        setData(key, value);
        request.response.write("");
        request.response.close();
        break;
      case "POST":
        int index = 1 + getLastNumberedChildIndexAtKey(key);
        String childKey = key + "/${index}";
        setData(childKey, value);
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
  await new File(persistanceFileName).writeAsString(JSON.encode(data));
}

List<String> getChildrenAtKey(parentKey) {
  List<String> children = new List<String>();

  data.forEach((key, value) {
    if (key.startsWith(parentKey) && key != parentKey) {
      children.add(key.split("/").last);
    }
  });

  return children;
}
