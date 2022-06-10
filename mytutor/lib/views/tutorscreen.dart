import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'package:intl/intl.dart';
import '../models/tutor.dart';

class TutorScreen extends StatefulWidget {
  const TutorScreen({Key? key}) : super(key: key);

  @override
  State<TutorScreen> createState() => _TutorScreenState();
}

class _TutorScreenState extends State<TutorScreen> {
  List<Tutors> tutorList = <Tutors>[];
  String titlecenter = "Loading...";
  late double screenHeight, screenWidth, resWidth;
  var numofpage, curpage = 1;
  var color;
  TextEditingController searchController = TextEditingController();
  String search = "";
  final df = DateFormat('dd/MM/yyyy hh:mm a');

  @override
  void initState() {
    super.initState();
    _loadTutors(1, search);
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 600) {
      resWidth = screenWidth;
      //rowcount = 2;
    } else {
      resWidth = screenWidth * 0.75;
      //rowcount = 3;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Tutor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _loadSearchDialog();
            },
          )
        ],
      ),
      body: tutorList.isEmpty
          ? Center(
              child: Text(titlecenter,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)))
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
                  child: Text("Tutors List",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                    child: GridView.count(
                        crossAxisCount: 1,
                        childAspectRatio: (1 / 0.6),
                        children: List.generate(tutorList.length, (index) {
                          return InkWell(
                            child: Card(
                                color: Colors.grey[200],
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: SizedBox(
                                        height: screenHeight,
                                        width: resWidth / 5,
                                        child: CachedNetworkImage(
                                          imageUrl: CONSTANTS.server +
                                              "/mytutor/mobile/assets/tutors/" +
                                              tutorList[index]
                                                  .tutorId
                                                  .toString() +
                                              '.jpg',
                                          placeholder: (context, url) =>
                                              const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                      ),
                                      title: Text(
                                          tutorList[index].tutorName.toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      subtitle: Text(
                                          "\nEmail: " +
                                              tutorList[index]
                                                  .tutorEmail
                                                  .toString() +
                                              "\n\nPhone number: " +
                                              tutorList[index]
                                                  .tutorPhone
                                                  .toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      trailing: const Icon(Icons.more_vert),
                                      onTap: () => {_loadTutorDetails(index)},
                                    ),
                                  ],
                                )),
                          );
                        }))),
                SizedBox(
                  height: 30,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: numofpage,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      if ((curpage - 1) == index) {
                        color = Colors.deepOrange;
                      } else {
                        color = Colors.black;
                      }
                      return SizedBox(
                        width: 40,
                        child: TextButton(
                            onPressed: () => {_loadTutors(index + 1, "")},
                            child: Text(
                              (index + 1).toString(),
                              style: TextStyle(color: color),
                            )),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _loadTutors(int pageno, String _search) {
    curpage = pageno;
    numofpage ?? 1;
    http.post(
        Uri.parse(CONSTANTS.server + "/mytutor/mobile/php/load_tutor.php"),
        body: {
          'pageno': pageno.toString(),
          'search': _search,
        }).then((response) {
      var jsondata = jsonDecode(response.body);
      print(jsondata);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        var extractdata = jsondata['data'];
        numofpage = int.parse(jsondata['numofpage']);
        if (extractdata['tutors'] != null) {
          tutorList = <Tutors>[];
          extractdata['tutors'].forEach((v) {
            tutorList.add(Tutors.fromJson(v));
          });
        } else {
          titlecenter = "No Tutor Available";
        }
        setState(() {});
      }
    });
  }

  void _loadSearchDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, StateSetter setState) {
                return AlertDialog(
                  title: const Text(
                    "Search ",
                  ),
                  content: SizedBox(
                    height: screenHeight / 3.5,
                    child: Column(
                      children: [
                        TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                              labelText: 'Search',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0))),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: () {
                            search = searchController.text;
                            Navigator.of(context).pop();
                            _loadTutors(1, search);
                          },
                          child: const Text("Search"),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  _loadTutorDetails(int index) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (content) => Scaffold(
                  appBar: AppBar(
                    title: const Text(
                      'Tutor Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  body: SingleChildScrollView(
                    child: Center(
                      child: SizedBox(
                        width: resWidth,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(32, 32, 32, 32),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 2,
                                        ),
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl: CONSTANTS.server +
                                            "/mytutor/mobile/assets/tutors/" +
                                            tutorList[index]
                                                .tutorId
                                                .toString() +
                                            '.jpg',
                                        fit: BoxFit.cover,
                                        width: resWidth,
                                        placeholder: (context, url) =>
                                            const LinearProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      tutorList[index].tutorName.toString(),
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("\nDescription: \n" +
                                              tutorList[index]
                                                  .tutorDescription
                                                  .toString()),
                                          Text("\nEmail: " +
                                              tutorList[index]
                                                  .tutorEmail
                                                  .toString()),
                                          Text("\nPhone number: " +
                                              tutorList[index]
                                                  .tutorPhone
                                                  .toString()),
                                          Text("\nRegistration Date: " +
                                              df.format(DateTime.parse(
                                                  tutorList[index]
                                                      .tutorDatereg
                                                      .toString()))),
                                        ])
                                  ],
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                )));
  }
}
