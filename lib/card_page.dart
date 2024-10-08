import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:word_learner/settings.dart';
import 'package:word_learner/state.dart';

import 'card_widget.dart';
import 'deck.dart';
import 'words.dart';

class CardPage extends StatefulWidget {
  const CardPage({super.key});

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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final model = Provider.of<MainModel>(context);
    final settings = Provider.of<SettingsModel>(context);
    var deck = model.activeDeck;

    Widget w;
    if (deck == null) {
      w = const Text("No deck open");
      _data.cardI = null;
    } else if (deck.cards!.isEmpty) {
      w = const Text("Deck is empty");
    } else {
      if (_data.lastUsedDeck != deck) {
        _data.cardI = null;
        _data.lastUsedDeck = deck;
        if (kDebugMode) {
          print("Deck was switched, resetting card index");
        }
      }

      _data.cardI ??= getNextWordI(settings.orderMode, deck.cards!);
      w = CardWidget(data: _data);
    }
    return Center(child: w);
  }
}
