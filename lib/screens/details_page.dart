import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiz_app/helpers/constant.dart';
import 'package:flutter_quiz_app/json_parsers/json_parser_sliding_cards.dart';
import 'package:flutter_quiz_app/widgets/bordericon.dart';

class DetailsPage extends StatefulWidget {
  final SlidingCard slidingCard;

  const DetailsPage({Key? key, required this.slidingCard}) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  int selectionStart = 0;
  int selectionEnd = 0;
  bool isTextSelectable = false;
  String selectedText = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery
        .of(context)
        .size;
    final ThemeData themeData = Theme.of(context);
    final double padding = 25;
    final sidePadding = EdgeInsets.symmetric(horizontal: padding);
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: Constant.backgroundDecoration,
          width: size.width,
          height: size.height,
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.4,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                  widget.slidingCard.picUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          width: size.width,
                          top: padding,
                          child: Padding(
                            padding: sidePadding,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: BorderIcon(
                                    height: 50,
                                    width: 50,
                                    child: Icon(
                                      Icons.keyboard_backspace,
                                      color: Constant.COLOR_BLACK,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    addVerticalSpace(padding),
                    Padding(
                      padding: sidePadding,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Text(
                          widget.slidingCard.name,
                          style: Constant.appHeaderTextSTyle,
                        ),
                      ),
                    ),
                    addVerticalSpace(padding),
                    // SingleChildScrollView(
                    //   scrollDirection: Axis.horizontal,
                    //   physics: BouncingScrollPhysics(),
                    //   child: Row(
                    //       children: getInformationTiles(widget.slidingCard)),
                    // ),
                    // addVerticalSpace(padding),
                    Padding(
                      padding: const EdgeInsets.only(left: 28.0),
                      child: Text(widget.slidingCard.description, style: TextStyle(
                        fontSize: 14)),
                    )
                    // Uncomment below to get Text with MARKER.
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 28.0),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.start,
                    //     children: [
                    //       InkWell(
                    //         onTap: () {
                    //           setState(() {
                    //             isTextSelectable = true;
                    //           });
                    //           var userNotesMap = (Constant.box
                    //               .get(Constant.userNotesBox) as Map);
                    //           if (!userNotesMap
                    //               .containsKey(widget.slidingCard.name))
                    //             userNotesMap[widget.slidingCard.name] = <int>[];
                    //           for (var i = selectionStart;
                    //           i < selectionEnd;
                    //           ++i) {
                    //             if (!(userNotesMap[widget.slidingCard.name]
                    //             as List<int>)
                    //                 .contains(i)) {
                    //               (userNotesMap[widget.slidingCard.name]
                    //               as List<int>)
                    //                   .add(i);
                    //             }
                    //           }
                    //           (userNotesMap[widget.slidingCard.name]
                    //           as List<int>)
                    //               .sort();
                    //           Constant.box
                    //               .put(Constant.userNotesBox, userNotesMap);
                    //           (Constant.box.get(Constant.userNotesBox)[
                    //           widget.slidingCard.name] as List<int>)
                    //               .forEach((element) {
                    //             print(element);
                    //           });
                    //         },
                    //         child: Icon(
                    //           Icons.brush_outlined,
                    //           color: Colors.grey,
                    //         ),
                    //       ),
                    //       Padding(
                    //         padding: const EdgeInsets.only(left: 8.0),
                    //         child: InkWell(
                    //           onTap: () {
                    //             setState(() {
                    //               isTextSelectable = true;
                    //             });
                    //
                    //             var userNotesMap = (Constant.box
                    //                 .get(Constant.userNotesBox) as Map);
                    //
                    //             if (!userNotesMap
                    //                 .containsKey(widget.slidingCard.name))
                    //               userNotesMap[widget.slidingCard.name] =
                    //               <int>[];
                    //
                    //             for (var i = selectionStart;
                    //             i < selectionEnd;
                    //             ++i) {
                    //               if ((userNotesMap[widget.slidingCard.name]
                    //               as List<int>)
                    //                   .contains(i))
                    //                 (userNotesMap[widget.slidingCard.name]
                    //                 as List<int>)
                    //                     .remove(i);
                    //             }
                    //             (userNotesMap[widget.slidingCard.name]
                    //             as List<int>)
                    //                 .sort();
                    //             Constant.box
                    //                 .put(Constant.userNotesBox, userNotesMap);
                    //             (Constant.box.get(Constant.userNotesBox)[
                    //             widget.slidingCard.name] as List<int>)
                    //                 .forEach((element) {
                    //               print(element);
                    //             });
                    //           },
                    //           child: Icon(
                    //             Icons.phonelink_erase,
                    //             color: Colors.grey,
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // addVerticalSpace(padding),
                    // Padding(
                    //   padding: sidePadding,
                    //   child: TextSelectionTheme(
                    //     data: TextSelectionThemeData(
                    //         cursorColor: Colors.white,
                    //         selectionColor: Colors.grey),
                    //     child: SelectableText.rich(
                    //       TextSpan(children: getTextSpans()),
                    //       textAlign: TextAlign.justify,
                    //       style: themeData.textTheme.bodyText2,
                    //       onSelectionChanged: (selection, cause) {
                    //         final selectedText = widget.slidingCard.description
                    //             .substring(
                    //             selection.start, selection.end);
                    //         selectionStart = selection.start;
                    //         selectionEnd = selection.end;
                    //         print(selection.start);
                    //         print(selection.end);
                    //         print(selectedText);
                    //         print(cause);
                    //       },
                    //       toolbarOptions: ToolbarOptions(
                    //           copy: false,
                    //           cut: false,
                    //           paste: false,
                    //           selectAll: false),
                    //       showCursor: true,
                    //       cursorWidth: 5,
                    //       cursorRadius: Radius.circular(20),
                    //     ),
                    //   ),
                    // ),
                    // addVerticalSpace(100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget addVerticalSpace(double height) {
    return SizedBox(height: height);
  }

  Widget addHorizontalSpace(double width) {
    return SizedBox(width: width);
  }

  List<InformationTile> getInformationTiles(SlidingCard slidingCard) {
    List<InformationTile> informationTiles = [];
    slidingCard.informationTiles.forEach((element) {
      informationTiles
          .add(InformationTile(content: element.content, name: element.name));
    });
    return informationTiles;
  }

  List<TextSpan> getTextSpans() {
    List<TextSpan> spans = [];
    var userNotesMap = (Constant.box.get(Constant.userNotesBox) as Map);

    for (var i = 0; i < widget.slidingCard.description.length; ++i) {
      if (userNotesMap.containsKey(widget.slidingCard.name) &&
          (userNotesMap[widget.slidingCard.name] as List<int>).contains(i)) {
        spans.add(
          TextSpan(
            text: widget.slidingCard.description[i],
            style: TextStyle(
                background: Paint()
                  ..color = Color(0xffF0A07C)
                  ..style = PaintingStyle.fill
                  ..strokeWidth = 0.0
              //..strokeJoin = StrokeJoin.bevel
              //..blendMode = BlendMode.difference,
            ),
          ),
        );
      } else {
        spans.add(TextSpan(text: widget.slidingCard.description[i]));
      }
    }
    return spans;
  }
}

class InformationTile extends StatelessWidget {
  final String content;
  final String name;

  const InformationTile({Key? key, required this.content, required this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final Size size = MediaQuery
        .of(context)
        .size;
    final double tileSize = size.width * 0.20;
    return Container(
      margin: const EdgeInsets.only(left: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BorderIcon(
              width: tileSize,
              height: tileSize,
              child: Text(
                content,
                style: TextStyle(color: Colors.black),
              )),
          Text(
            name,
            style: TextStyle(fontSize: 14),
          )
        ],
      ),
    );
  }
}
