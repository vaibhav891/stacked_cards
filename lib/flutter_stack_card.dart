import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slider_indicator/flutter_slider_indicator.dart';
import 'package:stacked_cards/stack_type.dart';
import 'indicator_model.dart';
import 'stack_dimension.dart';

class StackCard extends StatefulWidget {
  StackCard.builder(
      {this.stackType = StackType.middle,
      @required this.itemBuilder,
      @required this.itemCount,
      this.dimension,
      this.stackOffset = const Offset(15, 15),
      this.onSwap,
      this.displayIndicator = false,
      this.displayIndicatorBuilder});

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ValueChanged<int> onSwap;
  final bool displayIndicator;
  final IndicatorBuilder displayIndicatorBuilder;
  final StackDimension dimension;
  final StackType stackType;
  final Offset stackOffset;

  @override
  _StackCardState createState() => _StackCardState();
}

class _StackCardState extends State<StackCard> {
  var _pageController = PageController(viewportFraction: 0.5);
  var _currentPage = 0.0;
  var _width, _height;

  @override
  Widget build(BuildContext context) {
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page;
      });
    });

    if (widget.dimension == null) {
      _height = MediaQuery.of(context).size.height;
      _width = MediaQuery.of(context).size.width;
    } else {
      assert(widget.dimension.width > 0);
      assert(widget.dimension.height > 0);
      _width = widget.dimension.width;
      _height = widget.dimension.height;
    }

    return Stack(fit: StackFit.expand, children: <Widget>[
      _cardStack(),
      widget.displayIndicator ? _cardIndicator() : Container(),
      PageView.builder(
        onPageChanged: widget.onSwap,
        physics: BouncingScrollPhysics(),
        controller: _pageController,
        itemCount: widget.itemCount,
        itemBuilder: (context, index) {
          return Container();
        },
      )
    ]);
  }

  Widget _cardStack() {
    List<Widget> _cards = [];
    for (int i = widget.itemCount - 1; i > _currentPage.round(); i--) {
      _cards.add(addToCards(i));
    }
    for (int i = 0; i < _currentPage.round(); i++) {
      _cards.add(addToCards(i));
    }

    _cards.add(addToCards(_currentPage.round()));

    return Stack(fit: StackFit.expand, children: _cards);
  }

  Widget addToCards(int index) {
    var leftOffset = (widget.stackOffset.dx * index) -
        (_currentPage * widget.stackOffset.dx);

    return Positioned.fill(
      child: _cardbuilder(
        index,
        widget.stackType == StackType.middle ? _width : _width,
        _height,
        _currentPage,
      ),
      top: 0, //topOffset,
      left: leftOffset,
    );
  }

  Widget _cardbuilder(
      int index, double width, double height, double currentPage) {
    return Align(
      alignment: Alignment.topCenter,
      child: Transform(
        alignment: (index - currentPage) < 0
            ? FractionalOffset.centerLeft
            : FractionalOffset.centerRight,
        transform: Matrix4.identity()
          ..setEntry(0, 3, 40 * (index - currentPage))
          ..setEntry(3, 0, -0.004 * (index - currentPage)),
        child: Container(
            width: width * .8,
            height: height * .8,
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(color: Colors.black38, spreadRadius: 1, blurRadius: 2)
            ], borderRadius: BorderRadius.all(Radius.circular(12))),
            child: widget.itemBuilder(context, index)),
      ),
    );
  }

  Widget _cardIndicator() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: SliderIndicator(
            length: widget.itemCount,
            activeIndex: _currentPage.round(),
            activeIndicator: Icon(
              Icons.ac_unit,
              size: 50,
            ),
            indicator: Icon(Icons.radio_button_unchecked),
          )),
    );
  }
}
