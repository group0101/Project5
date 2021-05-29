import 'package:flutter/material.dart';
import 'package:blood_share/Pages/donations.dart';
import 'package:blood_share/Pages/search_page.dart';
import 'package:blood_share/Custom_Widgets/app_logo_animation.dart';

class HomeTab extends StatefulWidget {
  // view QR code function
  final Function showQRCode;
  // open QR code scanner
  final Function scanQRCode;
  // open about page
  final Function showAboutPage;
  HomeTab({
    this.scanQRCode,
    this.showAboutPage,
    this.showQRCode,
  });
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Size _size;
  int _r = 132, _g = 220, _b = 255;
  ScrollController _scrollController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  // update animation color on homepage
  _onScroll() {
    double d = _scrollController.offset / (_size.height * 0.4);
    if (d <= 1.0)
      setState(() {
        _r = 132 + (d * 45).floor();
        _g = 220 - (d * 99).floor();
      });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    Color _cardColor = Theme.of(context).dividerColor;
    Color _primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: _size.height * 0.4,
            flexibleSpace: Container(
              color: Color.fromARGB(255, _r, _g, _b),
              child: Image.asset("assets/blood_donation.png"),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Material(
                            color: _cardColor,
                            clipBehavior: Clip.hardEdge,
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return SearchPage(
                                        searchBloodbanks: false,
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Center(
                                child: Container(
                                  height: _size.height * 0.2,
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        flex: 2,
                                        child: Image.asset(
                                          "assets/donor.png",
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Flexible(
                                        child: Text(
                                          "Search Donor",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: _size.height * 0.02,
                                            fontWeight: FontWeight.bold,
                                            color: _primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Flexible(
                          child: Material(
                            color: _cardColor,
                            clipBehavior: Clip.hardEdge,
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return SearchPage(
                                        searchBloodbanks: true,
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Center(
                                child: Container(
                                  height: _size.height * 0.2,
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        flex: 2,
                                        child: Image.asset(
                                          "assets/bloodbank.png",
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Flexible(
                                        child: Text(
                                          "Search Bloodbank",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: _size.height * 0.02,
                                            fontWeight: FontWeight.bold,
                                            color: _primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Material(
                            color: _cardColor,
                            clipBehavior: Clip.hardEdge,
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              onTap: () {
                                widget.scanQRCode();
                              },
                              child: Center(
                                child: Container(
                                  height: _size.height * 0.2,
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        flex: 2,
                                        child: Image.asset(
                                          "assets/scanqrcode.png",
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Flexible(
                                        child: Text(
                                          "Scan QR Code\n(Donor)",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: _size.height * 0.02,
                                            fontWeight: FontWeight.bold,
                                            color: _primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Flexible(
                          child: Material(
                            color: _cardColor,
                            clipBehavior: Clip.hardEdge,
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              onTap: () {
                                widget.showQRCode();
                              },
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  height: _size.height * 0.2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        flex: 2,
                                        child: Image.asset(
                                          "assets/showqrcode.png",
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Flexible(
                                        child: Text(
                                          "Show QR Code\n(Recepient)",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: _size.height * 0.02,
                                            fontWeight: FontWeight.bold,
                                            color: _primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Material(
                            color: _cardColor,
                            clipBehavior: Clip.hardEdge,
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return Donations();
                                    },
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      height: _size.height * 0.2,
                                      child: Image.asset("assets/donation.png"),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 2,
                                    child: Container(
                                      child: Center(
                                        child: Text(
                                          "My Donations History",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: _size.height * 0.035,
                                            fontWeight: FontWeight.bold,
                                            color: _primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8.0,
                      right: 8.0,
                      bottom: 8.0,
                    ),
                    child: Material(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(10),
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              SizedBox(
                                height: _size.height * 0.3,
                                child: RiveAnimation(),
                              ),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: "Blood",
                                  style: TextStyle(
                                    color: Color(0xFFFF0000),
                                    fontSize: _size.height * 0.035,
                                    fontFamily: "georgia",
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 1,
                                        offset: Offset(1, 1),
                                        color: Colors.black38,
                                      ),
                                    ],
                                  ),
                                  children: [
                                    TextSpan(
                                      text: " Share",
                                      style: TextStyle(
                                        color: Color(0xFF1DCA6B),
                                        fontSize: _size.height * 0.035,
                                        fontFamily: "georgia",
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 1,
                                            offset: Offset(1, 1),
                                            color: Colors.black38,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              childCount: 1,
            ),
          ),
        ],
      ),
    );
  }
}
