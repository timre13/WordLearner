import 'dart:math';

import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:latext/latext.dart';
import 'package:provider/provider.dart';
import 'package:word_learner/settings.dart';
import 'package:word_learner/state.dart';
import 'package:word_learner/words.dart';

import 'card_page.dart';

class CardWidget extends StatefulWidget {
  const CardWidget({super.key, required this.data});

  final CardPageData data;

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  Matrix4 _calcDragTransfMat(double xDrag, double yDrag) {
    return Matrix4.translationValues(CardPageData.cardW / 2 + xDrag,
            CardPageData.cardH.toDouble() + yDrag / 4, 0) *
        Matrix4.rotationZ(xDrag / 3000) *
        Matrix4.translationValues(
            -CardPageData.cardW / 2, -CardPageData.cardH.toDouble(), 0) *
        Matrix4.rotationY(widget.data.isFlipping ? pi / 2 : 0);
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.data.cardI != null);
    final model = Provider.of<MainModel>(context);
    final settings = Provider.of<SettingsModel>(context);
    final card = model.activeDeck!.cards!.elementAt(widget.data.cardI!);
    var unescape = HtmlUnescape();
    return AnimatedContainer(
        transformAlignment: Alignment.center,
        duration: Duration(milliseconds: widget.data.cardAnimDurMs),
        transform: _calcDragTransfMat(
            widget.data.cardXDrag * 1.2, widget.data.cardYDrag),
        width: CardPageData.cardW.toDouble(),
        height: CardPageData.cardH.toDouble(),
        child: Material(
          clipBehavior: Clip.antiAlias,
          color: CardPageData.cardColors[widget.data.cardAction.index],
          borderRadius: const BorderRadiusDirectional.all(Radius.circular(20)),
          shadowColor: Colors.red,
          child: GestureDetector(
            child: InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.white.withAlpha(10),
                child: Center(
                  child: LaTexT(
                    laTeXCode: Text(
                      unescape.convert(widget.data.isCardSide1
                          ? card.side1
                          : card.side2
                              .replaceAll(r"\(", r"$")
                              .replaceAll(r"\)", r"$")
                              .replaceAll("&nbsp;", r"$\;$")
                              .replaceAll("<br>", r"$ \\ $")),
                      style: const TextStyle(color: Color(0xffaaaaaa)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                // Note: Use the InkWell's `onTap()` because it seems to get
                // executed earlier than the GestureDetector's
                onTap: () {
                  setState(() {
                    widget.data.cardAnimDurMs = 100;
                    widget.data.isFlipping = true;
                  });

                  Future.delayed(const Duration(milliseconds: 100), () {
                    setState(() {
                      widget.data.isCardSide1 = !widget.data.isCardSide1;
                      widget.data.isFlipping = false;
                    });
                  });
                }),
            onPanUpdate: (details) {
              if (widget.data.cardXDrag > CardPageData.cardW / 8) {
                setState(() {
                  widget.data.cardAction = CardAction.know;
                });
              } else if (widget.data.cardXDrag < -CardPageData.cardW / 8) {
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
                model.decCardPriority(widget.data.cardI!);
                setState(() {
                  widget.data.cardI = getNextWordI(settings.orderMode,
                      model.activeDeck!.cards!, widget.data.cardI!);
                  widget.data.isCardSide1 = true; // Flip back the card
                });
              } else if (widget.data.cardAction == CardAction.dontKnow) {
                model.incCardPriority(widget.data.cardI!);
                setState(() {
                  widget.data.cardI = getNextWordI(settings.orderMode,
                      model.activeDeck!.cards!, widget.data.cardI!);
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
