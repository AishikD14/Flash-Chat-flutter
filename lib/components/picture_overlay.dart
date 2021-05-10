import 'package:flutter/material.dart';

class PictureOverlay extends StatefulWidget {
  final ImageProvider profileImage;
  final String contactName;

  PictureOverlay({this.profileImage, this.contactName});

  @override
  _PictureOverlayState createState() => _PictureOverlayState();
}

class _PictureOverlayState extends State<PictureOverlay>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.decelerate);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: OrientationBuilder(
            builder: (context, orientation) {
              if (orientation == Orientation.portrait) {
                return FractionallySizedBox(
                  widthFactor: 0.7,
                  heightFactor: 0.4,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                shape: BoxShape.rectangle,
                                image: DecorationImage(
                                    image: widget.profileImage,
                                    fit: BoxFit.fitHeight),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              color: Colors.black.withOpacity(0.3),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  widget.contactName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              color: Colors.lightBlueAccent,
                              child: IconButton(
                                color: Colors.white,
                                icon: Icon(Icons.message),
                                onPressed: () {
                                  Navigator.pop(context, "goToChat");
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              color: Colors.lightBlueAccent,
                              child: IconButton(
                                color: Colors.white,
                                icon: Icon(Icons.info),
                                onPressed: () {},
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              } else {
                return FractionallySizedBox(
                  widthFactor: 0.4,
                  heightFactor: 0.8,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                shape: BoxShape.rectangle,
                                image: DecorationImage(
                                    image: widget.profileImage,
                                    fit: BoxFit.fitHeight),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              color: Colors.black.withOpacity(0.3),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  widget.contactName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              color: Colors.lightBlueAccent,
                              child: IconButton(
                                color: Colors.white,
                                icon: Icon(Icons.message),
                                onPressed: () {},
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              color: Colors.lightBlueAccent,
                              child: IconButton(
                                color: Colors.white,
                                icon: Icon(Icons.info),
                                onPressed: () {},
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
