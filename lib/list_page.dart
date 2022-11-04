import 'package:flutter/material.dart';
import 'package:word_learner/main.dart';
import 'dart:math';

import 'words.dart';

class ListPage extends StatefulWidget {
  const ListPage({Key? key, required this.cards, required this.cbs})
      : super(key: key);

  final ListPageCallbacks cbs;

  final List<Word> cards;

  @override
  State<ListPage> createState() => _ListPageState();
}

enum CardAction {
  normal,
  dontKnow,
  know,
}

class ListPageData {
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

class _ListPageState extends State<ListPage> {
  final _data = ListPageData();

  @override
  void initState() {
    super.initState();
  }

  // TODO: Modes:
  // - priority
  // - randomized
  // - original order

  @override
  Widget build(BuildContext context) {
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

class CardWidget extends StatefulWidget {
  const CardWidget(
      {Key? key, required this.data, required this.cards, required this.cbs})
      : super(key: key);

  final ListPageCallbacks cbs;

  final ListPageData data;
  final List<Word> cards;

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  Matrix4 _calcDragTransfMat(double xDrag, double yDrag) {
    return Matrix4.translationValues(ListPageData.cardW / 2 + xDrag,
            ListPageData.cardH.toDouble() + yDrag / 4, 0) *
        Matrix4.rotationZ(xDrag / 3000) *
        Matrix4.translationValues(
            -ListPageData.cardW / 2, -ListPageData.cardH.toDouble(), 0) *
        Matrix4.rotationY(widget.data.isFlipping ? pi / 2 : 0);
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.data.cardI != null);
    return AnimatedContainer(
        transformAlignment: Alignment.center,
        duration: Duration(milliseconds: widget.data.cardAnimDurMs),
        transform: _calcDragTransfMat(
            widget.data.cardXDrag * 1.2, widget.data.cardYDrag),
        width: ListPageData.cardW.toDouble(),
        height: ListPageData.cardH.toDouble(),
        child: Material(
          clipBehavior: Clip.antiAlias,
          color: ListPageData.cardColors[widget.data.cardAction.index],
          borderRadius: const BorderRadiusDirectional.all(Radius.circular(20)),
          shadowColor: Colors.red,
          child: GestureDetector(
            child: InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.white.withAlpha(10),
                child: Center(
                  child: Text(
                    (widget.data.isCardSide1
                        ? widget.cards.elementAt(widget.data.cardI!).side1
                        : widget.cards.elementAt(widget.data.cardI!).side2),
                    style:
                        const TextStyle(color: Color(0xffaaaaaa), fontSize: 30),
                  ),
                ),
                // Note: Use the InkWell's `onTap()` because it seems to get
                // executed earlier than the GestureDetector's
                onTap: () {
                  setState(() {
                    widget.data.cardAnimDurMs = 200;
                    widget.data.isFlipping = true;
                  });

                  Future.delayed(const Duration(milliseconds: 200), () {
                    setState(() {
                      widget.data.isCardSide1 = !widget.data.isCardSide1;
                      widget.data.isFlipping = false;
                    });
                  });
                }),
            onPanUpdate: (details) {
              if (widget.data.cardXDrag > ListPageData.cardW / 8) {
                setState(() {
                  widget.data.cardAction = CardAction.know;
                });
              } else if (widget.data.cardXDrag < -ListPageData.cardW / 8) {
                setState(() {
                  widget.data.cardAction = CardAction.dontKnow;
                });
              } else {
                setState(() {
                  widget.data.cardAction = CardAction.normal;
                });
              }
              setState(() {
                widget.data.cardXDrag += details.delta.dx;
                widget.data.cardYDrag += details.delta.dy;
                widget.data.cardAnimDurMs = 0;
              });
            },
            onPanEnd: (details) {
              if (widget.data.cardAction == CardAction.know) {
                widget.cbs.decCardPriorityCb(widget.data.cardI!);
                setState(() {
                  widget.data.cardI = getNextWordI(widget.cbs.getOrderMode(),
                      widget.cards, widget.data.cardI!);
                  widget.data.isCardSide1 = true; // Flip back the card
                });
              } else if (widget.data.cardAction == CardAction.dontKnow) {
                widget.cbs.incCardPriorityCb(widget.data.cardI!);
                setState(() {
                  widget.data.cardI = getNextWordI(widget.cbs.getOrderMode(),
                      widget.cards, widget.data.cardI!);
                  widget.data.isCardSide1 = true; // Flip back the card
                });
              }

              setState(() {
                widget.data.cardXDrag = 0;
                widget.data.cardYDrag = 0;
                // Animate when the card is moving back to center
                widget.data.cardAnimDurMs = 100;
                widget.data.cardAction = CardAction.normal;
              });
            },
          ),
        ));
  }
}
