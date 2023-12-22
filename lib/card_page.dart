import 'package:flutter/material.dart';
import 'package:word_learner/main.dart';

import 'card_widget.dart';
import 'words.dart';

class CardPage extends StatefulWidget {
  const CardPage({super.key, required this.cbs});

  final CardPageCallbacks cbs;

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
    if (widget.cbs.getActiveDeck() == null) {
      w = const Text("No list open");
    } else {
      _data.cardI ??= getNextWordI(
          widget.cbs.getOrderMode(), widget.cbs.getActiveDeck()!.cards!);
      w = CardWidget(data: _data, cbs: widget.cbs);
    }
    return Center(child: w);
  }
}
