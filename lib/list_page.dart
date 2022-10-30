import 'package:flutter/material.dart';
import 'dart:math';

import 'words.dart';

class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  State<ListPage> createState() => _ListPageState();
}

enum CardAction {
  normal,
  dontKnow,
  know,
}

class _ListPageState extends State<ListPage> {
  final _cards = [
    Word("Alma", "Apple"),
    Word("Banán", "Banana"),
    Word("Citrom", "Lemon"),
  ];

  final _cardColors = const [
    Color(0xff202020), // Normal
    Color(0xff251b1b), // Dontknow
    Color(0xff222a1e), // Know
  ];

  late int _cardI;
  var _isCardSide1 = true;
  double _cardXDrag = 0.0;
  double _cardYDrag = 0.0;
  int _cardAnimDurMs = 0;
  var _isFlipping = false;

  CardAction _cardAction = CardAction.normal;

  static const _cardW = 250;
  static const _cardH = 500;

  @override
  void initState() {
    super.initState();
    _cardI = getRandomWordI(_cards);
  }

  Matrix4 _calcDragTransfMat(double xDrag, double yDrag) {
    return Matrix4.translationValues(
            _cardW / 2 + xDrag, _cardH.toDouble() + yDrag / 4, 0) *
        Matrix4.rotationZ(xDrag / 3000) *
        Matrix4.translationValues(-_cardW / 2, -_cardH.toDouble(), 0) *
        Matrix4.rotationY(_isFlipping ? pi / 2 : 0);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: AnimatedContainer(
            transformAlignment: Alignment.center,
            duration: Duration(milliseconds: _cardAnimDurMs),
            transform: _calcDragTransfMat(_cardXDrag * 1.2, _cardYDrag),
            width: _cardW.toDouble(),
            height: _cardH.toDouble(),
            child: Material(
              clipBehavior: Clip.antiAlias,
              color: _cardColors[_cardAction.index],
              borderRadius:
                  const BorderRadiusDirectional.all(Radius.circular(20)),
              shadowColor: Colors.red,
              child: GestureDetector(
                child: InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.white.withAlpha(10),
                    child: Center(
                      child: Text(
                        (_isCardSide1
                            ? _cards.elementAt(_cardI).side1
                            : _cards.elementAt(_cardI).side2),
                        style: const TextStyle(
                            color: Color(0xffaaaaaa), fontSize: 30),
                      ),
                    ),
                    // Note: Use the InkWell's `onTap()` because it seems to get
                    // executed earlier than the GestureDetector's
                    onTap: () {
                      setState(() {
                        _cardAnimDurMs = 200;
                        _isFlipping = true;
                      });

                      Future.delayed(const Duration(milliseconds: 200), () {
                        setState(() {
                          _isCardSide1 = !_isCardSide1;
                          _isFlipping = false;
                        });
                      });
                    }),
                onPanUpdate: (details) {
                  if (_cardXDrag > _cardW / 8) {
                    setState(() {
                      _cardAction = CardAction.know;
                    });
                  } else if (_cardXDrag < -_cardW / 8) {
                    setState(() {
                      _cardAction = CardAction.dontKnow;
                    });
                  } else {
                    setState(() {
                      _cardAction = CardAction.normal;
                    });
                  }
                  setState(() {
                    _cardXDrag += details.delta.dx;
                    _cardYDrag += details.delta.dy;
                    _cardAnimDurMs = 0;
                  });
                },
                onPanEnd: (details) {
                  if (_cardAction == CardAction.know) {
                    _cards.elementAt(_cardI).decPriority();
                    setState(() {
                      _cardI = getRandomWordI(_cards, _cardI);
                      _isCardSide1 = true; // Flip back the card
                    });
                  }
                  /* else if (_cardAction == CardAction.dontKnow) {
                    _cards.elementAt(_cardI).incPriority();
                  }*/

                  setState(() {
                    _cardXDrag = 0;
                    _cardYDrag = 0;
                    // Animate when the card is moving back to center
                    _cardAnimDurMs = 100;
                    _cardAction = CardAction.normal;
                  });
                },
              ),
            )));
  }
}
