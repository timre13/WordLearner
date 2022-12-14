import 'package:flutter/material.dart';
import 'package:word_learner/main.dart';

import 'card_widget.dart';
import 'words.dart';

class CardPage extends StatefulWidget {
  const CardPage({Key? key, required this.cards, required this.cbs})
      : super(key: key);

  final CardPageCallbacks cbs;

  final List<Word> cards;

  @override
  State<CardPage> createState() => _CardPageState();
}

enum CardAction {
  normal,
  dontKnow,
  know,
}

class CardPageData {
  static const cardColors = [
    Color(0xff202020), // Normal
    Color(0xff251b1b), // Dontknow
    Color(0xff222a1e), // Know
  ];

  int? cardI;
  var isCardSide1 = true;
  double cardXDrag = 0.0;
  double cardYDrag = 0.0;
  int cardAnimDurMs = 0;
  var isFlipping = false;

  CardAction cardAction = CardAction.normal;

  static const cardW = 250;
  static const cardH = 500;
}

class _CardPageState extends State<CardPage>
    with AutomaticKeepAliveClientMixin {
  final _data = CardPageData();

  @override
  void initState() {
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget w;
    if (widget.cards.isEmpty) {
      w = const Text("No list open");
    } else {
      _data.cardI ??= getNextWordI(widget.cbs.getOrderMode(), widget.cards);
      w = CardWidget(data: _data, cards: widget.cards, cbs: widget.cbs);
    }
    return Center(child: w);
  }
}
