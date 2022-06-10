import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'package:intl/intl.dart';
import '../models/subject.dart';
import '../models/tutor.dart';

class SubjectScreen extends StatefulWidget {
  const SubjectScreen({Key? key}) : super(key: key);

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  List<Subjects> subjectList = <Subjects>[];
  List<Tutors> tutorList = <Tutors>[];
  String titlecenter = "Loading...";
  late double screenHeight, screenWidth, resWidth;
  var numofpage, curpage = 1;
  var color;
  TextEditingController searchController = TextEditingController();
  String search = "";

  @override
  void initState() {
    super.initState();
    _loadSubjects(1, search);
  }

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
      body: subjectList.isEmpty
          ? Center(
              child: Text(titlecenter,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)))
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
                  child: Text("Subjects List",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                    child: GridView.count(
                        crossAxisCount: 1,
                        childAspectRatio: (1 / 0.7),
                        children: List.generate(subjectList.length, (index) {
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
                                              "/mytutor/mobile/assets/courses/" +
                                              subjectList[index]
                                                  .subjectId
                                                  .toString() +
                                              '.png',
                                          placeholder: (context, url) =>
                                              const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                      ),
                                      title: Text(
                                          subjectList[index]
                                              .subjectName
                                              .toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      subtitle: Text(
                                          "\nRM " +
                                              double.parse(subjectList[index]
                                                      .subjectPrice
                                                      .toString())
                                                  .toStringAsFixed(2) +
                                              "\n\n" +
                                              subjectList[index]
                                                  .subjectSessions
                                                  .toString() +
                                              " sessions" +
                                              "\n\n" +
                                              "Rate: " +
                                              subjectList[index]
                                                  .subjectRating
                                                  .toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      trailing: const Icon(Icons.more_vert),
                                      onTap: () => {_loadSubjectDetails(index)},
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
                            onPressed: () => {_loadSubjects(index + 1, "")},
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

  void _loadSubjects(int pageno, String _search) {
    curpage = pageno;
    numofpage ?? 1;
    http.post(
        Uri.parse(CONSTANTS.server + "/mytutor/mobile/php/load_subject.php"),
        body: {
          'pageno': pageno.toString(),
          'search': _search,
        }).then((response) {
      var jsondata = jsonDecode(response.body);
      print(jsondata);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        var extractdata = jsondata['data'];
        numofpage = int.parse(jsondata['numofpage']);
        if (extractdata['subjects'] != null) {
          subjectList = <Subjects>[];
          extractdata['subjects'].forEach((v) {
            subjectList.add(Subjects.fromJson(v));
          });
        } else {
          titlecenter = "No Subject Available";
        }
        setState(() {});
      }
    });
  }

  _loadSubjectDetails(int index) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (content) => Scaffold(
                  appBar: AppBar(
                    title: const Text(
                      'Subject Details',
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
                                            "/mytutor/mobile/assets/courses/" +
                                            subjectList[index]
                                                .subjectId
                                                .toString() +
                                            '.png',
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
                                      subjectList[index].subjectName.toString(),
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("\nDescription: \n" +
                                              subjectList[index]
                                                  .subjectDescription
                                                  .toString()),
                                          Text("\nPrice: RM " +
                                              double.parse(subjectList[index]
                                                      .subjectPrice
                                                      .toString())
                                                  .toStringAsFixed(2)),
                                          Text("\nSessions: " +
                                              subjectList[index]
                                                  .subjectSessions
                                                  .toString() +
                                              " sessions"),
                                          Text("\nRating: " +
                                              subjectList[index]
                                                  .subjectRating
                                                  .toString()),
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
                            _loadSubjects(1, search);
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
}
