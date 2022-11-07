import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/modules/group/controllers/groupcreation_controller.dart';

class AddParticipantsView extends GetView<GroupCreationController> {
  const AddParticipantsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Participants',
        ),
        actions: [
          IconButton(onPressed: (){}, icon: SvgPicture.asset(searchicon)),
          TextButton(
              onPressed: () {
              },
              child: const Text("CREATE",style: TextStyle(color: Colors.black),)),
          PopupMenuButton<int>(
            icon: SvgPicture.asset(moreicon, width: 3.66, height: 16.31),
            color: Colors.white,
            itemBuilder: (context) => [
              // PopupMenuItem 1
              PopupMenuItem(
                value: 2,
                // row with 2 children
                child: Text(
                  "Settings",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
            offset: const Offset(0, 20),
            elevation: 2,
            // on selected we show the dialog box
            onSelected: (value) {
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Container(),
      ),
    );
  }
}
