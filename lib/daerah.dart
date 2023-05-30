import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'detail.dart';

class HalamanDaerah extends StatefulWidget {
  const HalamanDaerah({super.key});

  @override
  State<HalamanDaerah> createState() => _HalamanDaerahState();
}

class _HalamanDaerahState extends State<HalamanDaerah> {
  List<Map<String, dynamic>> home = [];
  bool load = false;

  @override
  void initState() {
    super.initState();
    fetchHome();
  }

  fetchHome() async {
    setState(() {
      load = true;
    });
    var url = "https://api-berita-indonesia.vercel.app/republika/daerah";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<dynamic> items = data['data']['posts'];

      setState(() {
        home = items
            .map((item) => {
                  'link': item['link'],
                  'title': item['title'],
                  'pubDate': item['pubDate'],
                  'description': item['description'],
                  'thumbnail': item['thumbnail'],
                })
            .toList();
        load = false;
      });
    } else {
      setState(() {
        home = [];
        load = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("REPUBLIKA DAERAH"),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 23, 120, 134),
      ),
      body: getBody(),
    );
  }

  Widget getBody() {
    // ignore: prefer_is_empty
    if (home.contains(null) || home.length < 0 || load) {
      return Center(
          child: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(Colors.blueGrey),
      ));
    }
    return ListView.builder(
        itemCount: home.length,
        itemBuilder: (context, index) {
          return getCard(home[index]);
        });
  }

  Widget getCard(item) {
    //nama=>nama di api
    var link = item['link'];
    var title = item['title'];
    var pubDate = item['pubDate'];
    var description = item['description'];
    var thumbnail = item['thumbnail'];

    return Card(
        margin: const EdgeInsets.all(10),
        child: InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => Detail(
                    link: link,
                    title: title,
                    pubDate: pubDate,
                    description: description,
                    thumbnail: thumbnail,
                  ))),
          child: Container(
            height: MediaQuery.of(context).size.height / 7,
            padding: const EdgeInsets.all(12),
            child: ListTile(
              trailing: SizedBox(
                width: MediaQuery.of(context).size.height / 9,
                child: ClipRRect(
                  child: Image.network(
                    thumbnail.toString(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.shop,
                        size: 12,
                      );
                    },
                  ),
                ),
              ),
              title: Text(
                title.toString(),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 2,
              ),
            ),
          ),
        ));
  }
}
