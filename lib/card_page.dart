import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:word_learner/main.dart';

import 'card_widget.dart';
import 'deck.dart';
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
  Deck? lastUsedDeck;
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
    var deck = widget.cbs.getActiveDeck();

    Widget w;
    if (deck == null) {
      w = const Text("No list open");
      _data.cardI = null;
    } else {
      if (_data.lastUsedDeck != deck) {
        _data.cardI = null;
        _data.lastUsedDeck = deck;
        if (kDebugMode) {
          print("Deck was switched, resetting card index");
        }
      }

      _data.cardI ??= getNextWordI(widget.cbs.getOrderMode(), deck.cards!);
      w = CardWidget(data: _data, cbs: widget.cbs);
    }
    return Center(child: w);
  }
}
