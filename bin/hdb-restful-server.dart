import 'dart:io';
import "dart:convert" show UTF8;

Map<String, String> data = new Map<String, String>();

main() async {
  var requestServer =
      await HttpServer.bind(InternetAddress.ANY_IP_V4, 44550);
  print('listening on localhost, port ${requestServer.port}');

  await for (HttpRequest request in requestServer) {
    print(request.method + " " + request.uri.toString());

    String key = request.uri.toString();
    key = key.replaceAll(new RegExp('//+'), "/");
    String value = await UTF8.decodeStream(request);

    switch(request.method) {
      case "GET":
        String result;
        if(key.endsWith("/")){
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
        String childKey = key+"/${index}";
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

int getLastNumberedChildIndexAtKey(String parentKey){
  int lastNumberedChildIndex = 0;

  String childIndex;
  data.forEach((key, value) {
    if(key.startsWith(parentKey) && key != parentKey){
      childIndex = key.split("/").last;
      try {
        var childNumberedIndex = int.parse(childIndex);
        if(childNumberedIndex > lastNumberedChildIndex){
          lastNumberedChildIndex = childNumberedIndex;
        }
      } catch(exception){
        //print(exception);
      }
    }
  });

  return lastNumberedChildIndex;
}

String getData(key){
  return data[key];
}

void setData(key, value){
  print("\t" + key + " ← " + value);
  data[key] = value;
}

List<String> getChildrenAtKey(parentKey){
  List<String> children = new List<String>();

  data.forEach((key, value) {
    if(key.startsWith(parentKey) && key != parentKey){
      children.add(key.split("/").last);
    }
  });

  return children;
}
