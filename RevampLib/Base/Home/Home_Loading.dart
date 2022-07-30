///
/// Home's loading screens
///

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Skeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;

  const Skeleton({Key? key, this.width, this.height, required this.radius})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.all(Radius.circular(radius))));
  }
}

class LoadingHeader extends StatelessWidget {
  const LoadingHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      highlightColor: Colors.black.withOpacity(0.05),
      baseColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Skeleton(width: 100, height: 18, radius: 16,),
                SizedBox(height: 12),
                Skeleton(width: 160, height: 36, radius: 16,),
                SizedBox(height: 12),
                Skeleton(width: 180, height: 18, radius: 16)
              ],
            ),
            Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ))
          ],
        ),
      )
    );
  }
}

class LoadingReqs extends StatelessWidget {
  const LoadingReqs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      highlightColor: Colors.black.withOpacity(0.05),
      baseColor: Colors.black.withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 15, right: 15, left: 15),
            child: Skeleton(
              width: MediaQuery.of(context).size.width,
              height: 40,
              radius: 50,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(width: 25),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Skeleton(
                    height: 150,
                    width: 150,
                    radius: 15,
                  ),
                ),
              ),
              SizedBox(width: 25),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Skeleton(
                    height: 150,
                    width: 150,
                    radius: 15,
                  ),
                ),
              ),
              SizedBox(width: 25),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(width: 25),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Skeleton(
                    height: 150,
                    width: 150,
                    radius: 15,
                  ),
                ),
              ),
              SizedBox(width: 25),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Skeleton(
                    height: 150,
                    width: 150,
                    radius: 15,
                  ),
                ),
              ),
              SizedBox(width: 25),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(width: 25),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Skeleton(
                    height: 150,
                    width: 150,
                    radius: 15,
                  ),
                ),
              ),
              SizedBox(width: 25),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Skeleton(
                    height: 150,
                    width: 150,
                    radius: 15,
                  ),
                ),
              ),
              SizedBox(width: 25),
            ],
          )
        ],
      ),
    );
  }
}

class LoadingEvents extends StatelessWidget {
  const LoadingEvents({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      highlightColor: Colors.black.withOpacity(0.05),
      baseColor: Colors.black.withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 15, right: 15, left: 15),
            child: Skeleton(
              width: MediaQuery.of(context).size.width,
              height: 40,
              radius: 50,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 5, right: 0, left: 10),
              child: Skeleton(
                width: 80,
                height: 20,
                radius: 50,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 5, right: 25, left: 25),
            child: Skeleton(
              width: MediaQuery.of(context).size.width,
              height: 80,
              radius: 20,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 5, right: 25, left: 25),
            child: Skeleton(
              width: MediaQuery.of(context).size.width,
              height: 80,
              radius: 20,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 5, right: 25, left: 25),
            child: Skeleton(
              width: MediaQuery.of(context).size.width,
              height: 80,
              radius: 20,
            ),
          ),
        ],
      ),
    );
  }
}