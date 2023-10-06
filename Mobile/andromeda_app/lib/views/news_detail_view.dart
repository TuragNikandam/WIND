import 'package:andromeda_app/main.dart';
import 'package:andromeda_app/models/news_article_model.dart';
import 'package:andromeda_app/models/topic_model.dart';
import 'package:andromeda_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailView extends StatefulWidget {
  final NewsArticle newsArticle;
  final List<NewsArticleComment> comments;
  final Function(NewsArticleComment comment) onSendComments;

  const NewsDetailView({
    Key? key,
    required this.newsArticle,
    required this.comments,
    required this.onSendComments,
  }) : super(key: key);

  @override
  State<NewsDetailView> createState() => _NewsDetailViewState();
}

class _NewsDetailViewState extends State<NewsDetailView> {
  DateFormat dateFormat = DateFormat("dd.MM.yyyy");
  List<NewsArticleComment> comments = List.empty(growable: true);
  late User user;
  bool isExpandedWidget = false;

  @override
  void initState() {
    super.initState();
    user = Provider.of<User>(context, listen: false);

    comments = widget.comments;
  }

  @override
  Widget build(BuildContext context) {
    double imageHeight = MediaQuery.of(context).size.height * 0.25;
    const double paddingLeftRight = 25;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.newsArticle.getHeadline),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    paddingLeftRight, 15, paddingLeftRight, 0),
                child: Text(
                  TopicManager()
                      .getTopicById(widget.newsArticle.getTopic)
                      .getName,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                    fontSize: 20,
                    color: Colors.orange,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    paddingLeftRight, 5, paddingLeftRight, 0),
                child: Text(
                  dateFormat.format(widget.newsArticle.getCreationDate),
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                    color: Color(0x9d858383),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    paddingLeftRight, 10, paddingLeftRight, 0),
                child: SizedBox(
                  height: imageHeight,
                  child: Align(
                    alignment: Alignment.center,
                    child: FadeInImage(
                      image: NetworkImage(widget.newsArticle.getImage.getUrl),
                      imageErrorBuilder:
                          (BuildContext context, Object y, StackTrace? z) {
                        return SizedBox(
                          height: imageHeight / 2.5,
                          child: const FittedBox(
                            fit: BoxFit.cover,
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.black26,
                              ),
                            ),
                          ),
                        );
                      },
                      fit: BoxFit.cover,
                      placeholder:
                          const AssetImage("assets/images/placeholder.png"),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    paddingLeftRight, 5, paddingLeftRight, 10),
                child: RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                    text: widget.newsArticle.getContent,
                    style: DefaultTextStyle.of(context)
                        .style
                        .copyWith(fontSize: 15),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    paddingLeftRight, 5, paddingLeftRight, 10),
                child: SingleChildScrollView(
                  child: ExpansionPanelList(
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        isExpandedWidget = !isExpanded;
                      });
                    },
                    children: [
                      ExpansionPanel(
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return const ListTile(
                            title: Text("Referenzen"),
                          );
                        },
                        isExpanded: isExpandedWidget,
                        body: ListView.builder(
                          itemCount: widget.newsArticle.getSources.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            String url = widget.newsArticle.getSources[index];
                            Uri? uri = getUriByStringURL(url);
                            if (uri != null) {
                              return ListTile(
                                title: Text(
                                  "Quelle ${index + 1} : ${uri.host + uri.path}",
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                onTap: () async {
                                  await launchUrl(uri);
                                },
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const Divider(
                thickness: 1,
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(
                    paddingLeftRight, 10, paddingLeftRight, 10),
                child: Text("Kommentarbereich",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    paddingLeftRight, 5, paddingLeftRight, 0),
                child: ListView.builder(
                  itemCount: comments.length,
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar and Username
                          Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: SizedBox(
                                  width: 80,
                                  child: Tooltip(
                                    message: comments[index].getUsername,
                                    triggerMode: TooltipTriggerMode.tap,
                                    child: _buildCommentAvatarAndUsername(
                                        comments[index]),
                                  ))),
                          // Comment Text
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[200],
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dateFormat.format(
                                          comments[index].getCreationDate),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      comments[index].getContent,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: user.isGuest ? null : _showCommentDialog,
        backgroundColor:
            user.isGuest ? Colors.grey : Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildCommentAvatarAndUsername(NewsArticleComment comment) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: MyApp.secondaryColor,
          child: Icon(Icons.person, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 80,
          child: Text(
            comment.getUsername,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Uri? getUriByStringURL(String url) {
    try {
      return Uri.parse(url);
    } catch (e) {
      return null;
    }
  }

  void _showCommentDialog() async {
    final TextEditingController commentController = TextEditingController();
    final TextEditingController linkController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isTermsAccepted = false;
    bool isTermsAcceptedValid = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Kommentaranfrage versenden'),
              content: SingleChildScrollView(
                child: Form(
                  autovalidateMode: AutovalidateMode.disabled,
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: commentController,
                        decoration: const InputDecoration(
                            hintText: 'Ergänze den Artikel mit nützlichen Informationen oder Korrekturen...'),
                        validator: (value) => value?.isEmpty == true
                            ? "Sprachlos? Wohl kaum..."
                            : null,
                        maxLines: 5,
                        maxLength: 500,
                      ),
                      TextFormField(
                        controller: linkController,
                        decoration: const InputDecoration(
                            hintText: 'Link(s) zu den Quellen'),
                        validator: (value) => value?.isEmpty == true
                            ? "Keine Quelle? Keine sinnvoller Ergänzung!"
                            : null,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Flexible(
                            child: Text(
                                'Hiermit akzeptiere ich die Richtlinien und Regeln'),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: isTermsAcceptedValid
                                  ? null
                                  : Border.all(color: Colors.red),
                            ),
                            child: Checkbox(
                              value: isTermsAccepted,
                              onChanged: (bool? value) {
                                setState(() {
                                  isTermsAccepted = value!;
                                  isTermsAcceptedValid = isTermsAccepted;
                                });
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.info,
                                color: Theme.of(context).primaryColor),
                            onPressed: () {
                              _showTermsAndConditionsDialog(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      isTermsAcceptedValid = isTermsAccepted;
                    });

                    if (formKey.currentState!.validate() && isTermsAccepted) {
                      NewsArticleComment comment = NewsArticleComment();
                      comment.setAuthorId(user.getId);
                      comment.setContent(commentController.text);
                      comment.setLinks(linkController.text);

                      widget.onSendComments(comment);

                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text(
                    'Senden',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Abbrechen',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTermsAndConditionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Richtlinien und Regeln'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Um sicherzustellen, dass die Kommentarfunktion dieses Newsfeeds einen produktiven und informativen Raum darstellt, sind alle Benutzer verpflichtet, folgende Richtlinien und Regeln einzuhalten:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  '1. Kommentare als Ergänzungen: Kommentare sollen als konstruktive Ergänzungen zu den Artikeln fungieren und empirisch überprüfbare Fakten repräsentieren. Spekulative Aussagen, Vermutungen oder persönliche Interpretationen sind in diesem Kontext unzulässig.',
                ),
                SizedBox(height: 8),
                Text(
                  '2. Keine Meinungsäußerung: Da dieser Bereich primär den Zugang zu sachlichen Informationen anstrebt und ein gesondertes Forum für Diskussionen bereits bereitgestellt ist, ist die Verbreitung persönlicher Meinungen in den Kommentaren nicht gestattet.',
                ),
                SizedBox(height: 8),
                Text(
                  '3. Objektivität und Neutralität: Alle Beiträge müssen sich durch eine sachliche und neutrale Sprache auszeichnen. Kommentare dürfen keine Emotionen, Werturteile oder persönliche Angriffe enthalten.',
                ),
                SizedBox(height: 8),
                Text(
                  '4. Legitimierung durch Quellenangabe: Alle Fakten, Daten oder wissenschaftlichen Erkenntnisse, die in den Kommentaren präsentiert werden, müssen durch eine valide Quellenangabe legitimiert sein. Fehlende oder falsche Zitationen können zur Löschung des Kommentars führen.',
                ),
                SizedBox(height: 8),
                Text(
                  '5. Konsequenzen bei Missbrauch: Bei wiederholten Verstößen gegen diese Richtlinien behalten sich die Betreiber der Plattform das Recht vor, den Account des betreffenden Benutzers vorübergehend oder dauerhaft zu sperren.',
                ),
                SizedBox(height: 12),
                Text(
                  'Die Einhaltung dieser Bestimmungen gewährleistet eine produktive Diskussion und fördert den informierten Austausch unter den Benutzern. Wir danken Ihnen für Ihr Verständnis und Ihre Kooperation.',
                ),
                SizedBox(height: 8),
                Text(
                  'Indem Sie die Kommentarfunktion nutzen, akzeptieren Sie diese Bedingungen ausdrücklich und verpflichten sich, diese in vollem Umfang einzuhalten.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Verstanden',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }
}
