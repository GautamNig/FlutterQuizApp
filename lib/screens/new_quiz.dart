import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiz_app/widgets/progress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_quiz_app/screens/quizlevel_configuration.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../helpers/constant.dart';

class NewQuiz extends StatefulWidget {
  final String quizId;
  final int quizLevel;
  final bool isEditing;

  NewQuiz(this.quizId, this.quizLevel, this.isEditing);

  @override
  _NewQuizState createState() => _NewQuizState();
}

class _NewQuizState extends State<NewQuiz> with SingleTickerProviderStateMixin {
  final _firestore = FirebaseFirestore.instance;
  bool isEditing = false;
  bool isUploadInProgress = false;
  int pageNumber = 1;
  Map<String, dynamic> mappedQuestionsAndAnswers = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.isEditing)
      for (var i = 0; i < Constant.quiz.quizLevels.length; i++) {
        for (var j = 0;
            j < Constant.quiz.quizLevels[i].levelQuizQuestions.length;
            j++) {
          mappedQuestionsAndAnswers['Q.$i.$j'] =
              Constant.quiz.quizLevels[i].levelQuizQuestions[j].questionText;
          mappedQuestionsAndAnswers['A.$i.$j'] = Constant
              .quiz.quizLevels[i].levelQuizQuestions[j].correctAnswerOption;

          for (var k = 0;
              k <
                  Constant.quiz.quizLevels[i].levelQuizQuestions[j]
                      .answerOptions.length;
              k++) {
            mappedQuestionsAndAnswers['AO.$i.$j.$k'] = Constant
                .quiz
                .quizLevels[i]
                .levelQuizQuestions[j]
                .answerOptions[k]
                .optionText;
          }
        }
      }

    // for (var i = 0; i < Constant.quiz.quizLevels.length; i++) {
    //   for (var j = 0;
    //       j < Constant.quiz.quizLevels[i].levelQuizQuestions.length;
    //       j++) {
    //     print(Constant.quiz.quizLevels[i].levelQuizQuestions[j].questionText);
    //     print(Constant
    //         .quiz.quizLevels[i].levelQuizQuestions[j].correctAnswerOption);
    //     // Constant
    //     //     .quiz.quizLevels[i].levelQuizQuestions[j].answerOptions.forEach((element) {print(element.optionText);});
    //   }
    // }
  }

  @override
  void dispose() {
    print('Disposing NewQuiz');
    // TODO: implement dispose
    super.dispose();
    Constant.quiz.quizLevels.clear();
  }

  @override
  Widget build(BuildContext context) {
    Widget page = (pageNumber == 0 ||
            Constant.quiz.quizLevels[widget.quizLevel].levelQuizQuestions
                    .length <
                pageNumber)
        ? Container()
        : Page(
            key: Key('page$pageNumber'),
            question: Constant.quiz.quizLevels[widget.quizLevel]
                .levelQuizQuestions[pageNumber - 1].questionText,
            answers: Constant.quiz.quizLevels[widget.quizLevel]
                .levelQuizQuestions[pageNumber - 1].answerOptions
                .expand((element) => [element.optionText])
                .toList(),
            number: pageNumber,
            quizLevel: widget.quizLevel,
            mappedQuestionsAndAnswers: mappedQuestionsAndAnswers);

    return Constant.isBusy ? circularProgress() : WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Constant.colorTwo,
          title: Center(
              child: Text(widget.isEditing
                  ? 'Editing ${Constant.quiz.quizLevels[widget.quizLevel].levelName}'
                  : Constant.quiz.quizLevels[widget.quizLevel].levelName)),
          actions: [
            IconButton(
                onPressed: () async {
                  await Alert(
                      context: context,
                      style: AlertStyle(
                        animationType: AnimationType.fromTop,
                        isCloseButton: false,
                        isOverlayTapDismiss: false,
                        backgroundColor: Constant.colorThree,
                        titleStyle: TextStyle(color: Colors.white),
                        descStyle: TextStyle(fontWeight: FontWeight.bold),
                        animationDuration: Duration(milliseconds: 400),
                        alertBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                          side: const BorderSide(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: "Delete Quiz?",
                      content: const Text(
                          'Are you sure you want to discard cooking this quiz?'),
                      buttons: [
                        DialogButton(
                            child: const Text(
                              'Ok',
                              style: TextStyle(color: Constant.colorThree),
                            ),
                            color: Colors.white70,
                            onPressed: () async {
                              if (Constant.quiz.quizId.isNotEmpty) {
                                Constant.quiz.quizLevels.forEach((ql) {
                                  ql.levelQuizQuestions.forEach((ques) async {
                                    if (ques.questionGiphyOrImageUrl
                                            .isNotEmpty &&
                                        ques.questionGiphyOrImageUrl.startsWith(
                                            'https://firebasestorage.googleapis.com/'))
                                      await FirebaseStorage.instance
                                          .refFromURL(
                                              ques.questionGiphyOrImageUrl)
                                          .delete();
                                  });
                                });
                                await _firestore
                                    .collection('quiz')
                                    .doc(Constant.quiz.quizId)
                                    .delete();
                              }
                              Constant.quiz = Constant.newQuiz;
                              Navigator.popUntil(
                                  context, (route) => route.isFirst);
                            }),
                        DialogButton(
                            child: const Text(
                              'Cancel',
                              style:
                                  const TextStyle(color: Constant.colorThree),
                            ),
                            color: Colors.white70,
                            onPressed: () {
                              Navigator.pop(context);
                            })
                      ]).show();
                },
                icon: const FaIcon(FontAwesomeIcons.trash))
          ],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height - 80,
          decoration: Constant.backgroundDecoration,
          child: SafeArea(
            child: Stack(
              children: <Widget>[
                ArrowIcons(),
                // Plane(),
                // Line(),
                Positioned.fill(
                  left: 32.0 + 8,
                  child: AnimatedSwitcher(
                    child: Column(
                      children: [
                        page,
                        Padding(
                          padding: const EdgeInsets.only(left: 50.0),
                          child: Row(
                            children: [
                              ElevatedButton(
                                onPressed: Constant
                                            .quiz
                                            .quizLevels[widget.quizLevel]
                                            .levelQuizQuestions
                                            .length >
                                        pageNumber
                                    ? null
                                    : () async {
                                        if (await validatePageAndFillUpInMemoryQuizQuestion()) {
                                          if (widget.quizLevel ==
                                                  Constant.quiz.quizLevels
                                                          .length -
                                                      1 &&
                                              Constant
                                                      .quiz
                                                      .quizLevels[
                                                          widget.quizLevel]
                                                      .levelQuizQuestions
                                                      .length ==
                                                  pageNumber - 1) {

                                            setState((){
                                              Constant.isBusy = true;
                                            });
                                            pageNumber = 0;
                                            //TODO: Check isCooking bool updated ?
                                            Constant.quiz.isCooking = false;

                                            await _firestore
                                                .collection('quiz')
                                                .doc(Constant.quiz.quizId)
                                                .set(Constant.quiz.toJson()).then((value) {
                                              Constant.quiz = Constant.newQuiz;
                                              Constant.quizLevelCollection = null;
                                              Constant.levelQuestionsAnswers.clear();
                                              Constant.totalCorrectAnswersAcrossLevels = 0;
                                              Constant.hasPopupBeenShownForThisQuizAttempt = false;
                                              setState((){
                                                Constant.isBusy = false;
                                              });
                                              Navigator.popUntil(context,
                                                      (route) => route.isFirst);
                                            });

                                          } else {
                                            if (widget.isEditing)
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          NewQuiz(
                                                              Constant.quiz
                                                                  .quizId,
                                                              widget.quizLevel +
                                                                  1,
                                                              true)));
                                            else
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          QuizLevelConfiguration(
                                                              widget.quizLevel +
                                                                  1)));
                                          }
                                        }
                                      },
                                child: Text(widget.quizLevel ==
                                        Constant.quiz.quizLevels.length - 1
                                    ? 'Publish Quiz'
                                    : 'Next Level'),
                                style: ElevatedButton.styleFrom(
                                  primary: Constant.colorTwo,
                                  side: const BorderSide(
                                    width: 1.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                onPressed: pageNumber <
                                        Constant
                                            .quiz
                                            .quizLevels[widget.quizLevel]
                                            .levelQuizQuestions
                                            .length
                                    ? () async {
                                        await validatePageAndFillUpInMemoryQuizQuestion();
                                      }
                                    : null,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: const Text('Next Ques'),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Constant.colorTwo,
                                  side: const BorderSide(
                                    width: 1.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 250),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> validatePageAndFillUpInMemoryQuizQuestion() async {
    if (mappedQuestionsAndAnswers
        .containsKey('Q.${widget.quizLevel}.${pageNumber - 1}')) {
      Constant.quiz.quizLevels[widget.quizLevel]
              .levelQuizQuestions[pageNumber - 1].questionText =
          mappedQuestionsAndAnswers['Q.${widget.quizLevel}.${pageNumber - 1}'];
      for (var j = 0;
          j <
              Constant.quiz.quizLevels[widget.quizLevel]
                  .levelQuizQuestions[pageNumber - 1].answerOptions.length;
          j++) {
        Constant
            .quiz
            .quizLevels[widget.quizLevel]
            .levelQuizQuestions[pageNumber - 1]
            .answerOptions[j]
            .optionText = mappedQuestionsAndAnswers
                .containsKey('AO.${widget.quizLevel}.${pageNumber - 1}.$j')
            ? mappedQuestionsAndAnswers[
                'AO.${widget.quizLevel}.${pageNumber - 1}.$j']
            : '';
      }
    }
    if (
        Constant
            .quiz
            .quizLevels[widget.quizLevel]
            .levelQuizQuestions[pageNumber - 1]
            .answerOptions[Constant.quiz.quizLevels[widget.quizLevel]
                .levelQuizQuestions[pageNumber - 1].correctAnswerOption]
            .optionText
            .isNotEmpty) {
      await removeAllEmptyOptionItemsForQuestion();

      setState(() => pageNumber++);
      return true;
    }
    return false;
  }

  Future removeAllEmptyOptionItemsForQuestion() async {
    var correctAnswer = Constant
        .quiz
        .quizLevels[widget.quizLevel]
        .levelQuizQuestions[pageNumber - 1]
        .answerOptions[Constant.quiz.quizLevels[widget.quizLevel]
            .levelQuizQuestions[pageNumber - 1].correctAnswerOption]
        .optionText;

    Constant.quiz.quizLevels[widget.quizLevel]
        .levelQuizQuestions[pageNumber - 1].answerOptions
        .removeWhere((element) => element.optionText == '');

    // Update answer option number after deletion of empty records
    for (var i = 0;
        i <
            Constant.quiz.quizLevels[widget.quizLevel]
                .levelQuizQuestions[pageNumber - 1].answerOptions.length;
        i++) {
      Constant.quiz.quizLevels[widget.quizLevel]
          .levelQuizQuestions[pageNumber - 1].answerOptions[i].optionNumber = i;
    }

    Constant.quiz.quizLevels[widget.quizLevel]
            .levelQuizQuestions[pageNumber - 1].correctAnswerOption =
        Constant.quiz.quizLevels[widget.quizLevel]
            .levelQuizQuestions[pageNumber - 1].answerOptions
            .indexWhere((element) => element.optionText == correctAnswer);
  }
}

class Line extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 32.0 + 32 + 8,
      top: 40,
      bottom: 0,
      width: 1,
      child: Container(color: Colors.white.withOpacity(0.5)),
    );
  }
}

class Page extends StatefulWidget {
  final int number;
  final int quizLevel;
  final String question;
  final List<String> answers;
  final Map<String, dynamic> mappedQuestionsAndAnswers;

  const Page({
    Key? key,
    required this.number,
    required this.question,
    required this.answers,
    required this.quizLevel,
    required this.mappedQuestionsAndAnswers,
  }) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> with SingleTickerProviderStateMixin {
  List<GlobalKey<_ItemFaderState>> faderKeys = [];
  int selectedOptionKeyIndex = 0;
  late AnimationController _animationController;
  int prevQuizLevel = 0, prevQuestionNumber = 0, prevSelectedOptionKeyIndex = 0;

  @override
  void initState() {
    super.initState();
    if (!widget.mappedQuestionsAndAnswers
        .containsKey('A.${widget.quizLevel}.${widget.number - 1}'))
      widget.mappedQuestionsAndAnswers[
          'A.${widget.quizLevel}.${widget.number - 1}'] = 0;
    faderKeys = List.generate(
      3 + widget.answers.length,
      (_) => GlobalKey<_ItemFaderState>(),
    );
    print('Genrated Fader Keys: ${faderKeys.length}');
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    onInit();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Building Page');
    return Expanded(
      child: ListView(
        shrinkWrap: true,
        addAutomaticKeepAlives: true,
        children: <Widget>[
          const SizedBox(height: 32),
          ItemFader(
            key: faderKeys[0],
            child: StepNumber(number: widget.number),
          ),
          ItemFader(
            key: faderKeys[1],
            child: StepQuestion(
                question: widget.question,
                quizLevel: widget.quizLevel,
                questionNumber: widget.number - 1,
                mappedQuestionsAndAnswers: widget.mappedQuestionsAndAnswers),
          ),
          const SizedBox(height: 64),
          Padding(
            padding: const EdgeInsets.only(left: 60.0),
            child: Container(
              child: Constant
                      .quiz
                      .quizLevels[widget.quizLevel]
                      .levelQuizQuestions[widget.number - 1]
                      .questionGiphyOrImageUrl
                      .isNotEmpty
                  ? Column(
                      children: [
                        FadeInImage.assetNetwork(
                          placeholder: 'assets/loading.gif',
                          image: Constant
                              .quiz
                              .quizLevels[widget.quizLevel]
                              .levelQuizQuestions[widget.number - 1]
                              .questionGiphyOrImageUrl,
                          fit: BoxFit.cover,
                        ),
                        // Image.network(
                        //     Constant
                        //         .quiz
                        //         .quizLevels[widget.quizLevel]
                        //         .levelQuizQuestions[widget.number - 1]
                        //         .questionGiphyOrImageUrl,
                        //     headers: {'accept': 'image/*'}),
                        Visibility(
                            visible: !Constant
                                .quiz
                                .quizLevels[widget.quizLevel]
                                .levelQuizQuestions[widget.number - 1]
                                .questionGiphyOrImageUrl
                                .startsWith(
                                    'https://firebasestorage.googleapis.com/'),
                            child: Text('Powered by GIPHY',
                                style: TextStyle(fontSize: 10)))
                      ],
                    )
                  : Container(),
            ),
          ),
          // Spacer(),
          ...widget.answers.asMap().entries.map((entry) {
            int keyIndex = entry.key + 3;
            print('Creating AO with key index : $keyIndex');
            return ItemFader(
              key: faderKeys[keyIndex],
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: OptionItem(
                    isCorrectAnswer: Constant
                                .quiz
                                .quizLevels[widget.quizLevel]
                                .levelQuizQuestions[widget.number - 1]
                                .correctAnswerOption ==
                            entry.key
                        ? true
                        : false,
                    quizLevel: widget.quizLevel,
                    questionNumber: widget.number - 1,
                    answerIndex: entry.key,
                    name: entry.value,
                    onTap: (answerIndex) {
                      print(answerIndex);
                      setState(() {
                        Constant
                            .quiz
                            .quizLevels[widget.quizLevel]
                            .levelQuizQuestions[widget.number - 1]
                            .correctAnswerOption = answerIndex;
                      });

                      if (prevQuizLevel == widget.quizLevel &&
                          prevQuestionNumber == widget.number) {
                      } else {
                        // onTap(keyIndex, offset, answerIndex, widget.number,
                        //     widget.quizLevel);

                        prevQuizLevel = widget.quizLevel;
                        prevQuestionNumber = widget.number;
                      }
                    },
                    showDot: selectedOptionKeyIndex != keyIndex,
                    mappedQuestionsAndAnswers:
                        widget.mappedQuestionsAndAnswers),
              ),
            );
          }),
        ],
      ),
    );
  }

  // void onTap(int keyIndex, Offset offset, int answerIndex, int questionNumber,
  //     int quizLevel) async {
  //   var mediaQD = MediaQuery.of(context);
  //   var maxWidth = mediaQD.size.width;
  //
  //   for (GlobalKey<_ItemFaderState> key in faderKeys) {
  //     await Future.delayed(Duration(milliseconds: 40));
  //     if (key.currentState != null) key.currentState!.hide();
  //     if (faderKeys.indexOf(key) == keyIndex) {
  //       setState(() => selectedOptionKeyIndex = keyIndex);
  //       animateDot(offset);
  //
  //       prevQuizLevel = quizLevel;
  //       prevQuestionNumber = questionNumber;
  //     }
  //   }
  // }

  void onInit() async {
    for (GlobalKey<_ItemFaderState> key in faderKeys) {
      await Future.delayed(Duration(milliseconds: 40));
      key.currentState?.show();
    }
  }

  Future<void> animateDot(Offset startOffset) async {
    OverlayEntry entry = OverlayEntry(
      builder: (context) {
        double minTop = MediaQuery.of(context).padding.top + 52;
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Positioned(
              left: 26.0 + 32 + 8,
              top: minTop +
                  (startOffset.dy - minTop) * (1 - _animationController.value),
              child: child ?? Container(),
            );
          },
          child: Dot(),
        );
      },
    );
    Overlay.of(context)?.insert(entry);
    await _animationController.forward(from: 0);
    entry.remove();
  }
}

class StepNumber extends StatelessWidget {
  final int number;

  const StepNumber({Key? key, required this.number}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 64, right: 16),
      child: Text(
        '0$number',
        style: TextStyle(
          fontSize: 64,
          fontWeight: FontWeight.bold,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}

class StepQuestion extends StatefulWidget {
  final String question;
  final int quizLevel;
  final int questionNumber;
  final Map<String, dynamic> mappedQuestionsAndAnswers;

  StepQuestion({
    Key? key,
    required this.question,
    required this.quizLevel,
    required this.questionNumber,
    required this.mappedQuestionsAndAnswers,
  }) : super(key: key);

  @override
  State<StepQuestion> createState() => _StepQuestionState();
}

class _StepQuestionState extends State<StepQuestion>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 64, right: 16),
      child: TextFormField(
        initialValue: widget.mappedQuestionsAndAnswers
                .containsKey('Q.${widget.quizLevel}.${widget.questionNumber}')
            ? widget.mappedQuestionsAndAnswers[
                'Q.${widget.quizLevel}.${widget.questionNumber}']
            : '',
        onChanged: (val) {
          widget.mappedQuestionsAndAnswers[
              'Q.${widget.quizLevel}.${widget.questionNumber}'] = val;
        },
        // The validator receives the text that the user has entered.
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please provide a question';
          }
          return null;
        },
        decoration: const InputDecoration(
            hintText: 'Enter your question.',
            hintStyle:
                const TextStyle(fontStyle: FontStyle.italic, fontSize: 16)),
        textInputAction: TextInputAction.done,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}

class OptionItem extends StatefulWidget {
  final String name;
  final int quizLevel;
  final int questionNumber;
  final int answerIndex;
  final bool isCorrectAnswer;
  final Map<String, dynamic> mappedQuestionsAndAnswers;
  final void Function(int answerIndex) onTap;
  final bool showDot;

  OptionItem(
      {Key? key,
      required this.isCorrectAnswer,
      required this.quizLevel,
      required this.questionNumber,
      required this.answerIndex,
      required this.name,
      required this.onTap,
      required this.mappedQuestionsAndAnswers,
      this.showDot = true})
      : super(key: key);

  @override
  _OptionItemState createState() => _OptionItemState();
}

class _OptionItemState extends State<OptionItem>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(width: 26),
          widget.isCorrectAnswer
              ? const FaIcon(
                  FontAwesomeIcons.checkCircle,
                  color: Colors.green,
                )
              : InkWell(
                  child: Stack(children: [
                    Dot(visible: widget.showDot),
                    Container(
                      height: 50,
                      width: 50,
                    ),
                  ]),
                  onTap: () {
                    widget.mappedQuestionsAndAnswers[
                            'A.${widget.quizLevel}.${widget.questionNumber}'] =
                        widget.answerIndex;
                    RenderBox object = context.findRenderObject() as RenderBox;
                    Offset globalPosition = object.localToGlobal(Offset.zero);
                    widget.onTap(widget.answerIndex);
                  },
                ),
          const SizedBox(width: 26),
          Expanded(
            child: TextFormField(
              validator: (value) {},
              initialValue: widget.mappedQuestionsAndAnswers.containsKey(
                      'AO.${widget.quizLevel}.${widget.questionNumber}.${widget.answerIndex}')
                  ? widget.mappedQuestionsAndAnswers[
                      'AO.${widget.quizLevel}.${widget.questionNumber}.${widget.answerIndex}']
                  : '',
              onChanged: (val) {
                widget.mappedQuestionsAndAnswers[
                        'AO.${widget.quizLevel}.${widget.questionNumber}.${widget.answerIndex}'] =
                    val;
              },
              decoration: Constant.getTextFormFieldInputDecoration(
                  'Please enter an option.'),
              textInputAction: TextInputAction.done,
            ),
          )
        ],
      ),
    );
  }
}

class ItemFader extends StatefulWidget {
  final Widget child;

  const ItemFader({Key? key, required this.child}) : super(key: key);

  @override
  _ItemFaderState createState() => _ItemFaderState();
}

class _ItemFaderState extends State<ItemFader>
    with SingleTickerProviderStateMixin {
  //1 means its below, -1 means its above
  int position = 1;
  late AnimationController _animationController;
  late Animation _animation;

  void show() {
    setState(() => position = 1);
    _animationController.forward();
  }

  void hide() {
    setState(() => position = -1);
    _animationController.reverse();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset:
              Offset(0, (64 * position * (1 - _animation.value)).toDouble()),
          child: Opacity(
            opacity: _animation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class Dot extends StatelessWidget {
  final bool visible;

  const Dot({Key? key, this.visible = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: visible ? Colors.white : Colors.transparent,
      ),
    );
  }
}

class ArrowIcons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 8,
      bottom: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.arrow_upward),
            onPressed: () {},
          ),
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: IconButton(
              color: const Color.fromRGBO(120, 58, 183, 1),
              icon: const Icon(Icons.arrow_downward),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

// class Plane extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       left: 32.0 + 8,
//       top: 32,
//       child: Container(
//         height: 60,
//         width: 60,
//         child: Image.asset('assets/BowlingPin.png'),
//       ),
//     );
//   }
// }
