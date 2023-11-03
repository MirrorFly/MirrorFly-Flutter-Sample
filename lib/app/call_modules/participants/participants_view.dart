import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';

import '../../common/app_theme.dart';
import '../../common/constants.dart';
import '../../data/helper.dart';
import '../call_utils.dart';
import '../call_widgets.dart';
import '../outgoing_call/call_controller.dart';

class ParticipantsView extends GetView<CallController> {
  const ParticipantsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
      child: DefaultTabController(
        length: 2,
        child: Builder(builder: (ctx) {
          return Scaffold(
              body: NestedScrollView(
                  headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        snap: false,
                        pinned: true,
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            Get.back();
                          },
                        ),
                        bottom: TabBar(
                            controller: controller.tabController,
                            indicatorColor: buttonBgColor,
                            labelColor: buttonBgColor,
                            unselectedLabelColor: appbarTextColor,
                            tabs: [tabItem(title: "PARTICIPANTS", count: "0"), tabItem(title: "ADD PARTICIPANTS", count: "0")]),
                      ),
                    ];
                  },
                  body: TabBarView(controller: controller.tabController, children: [callParticipantsView(context), addParticipants(context)])));
        }),
      ),
    );
  }

  Widget tabItem({required String title, required String count}) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          count != "0"
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: CircleAvatar(
                    radius: 9,
                    child: Text(
                      count.toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.white, fontFamily: 'sf_ui'),
                    ),
                  ),
                )
              : const SizedBox.shrink()
        ],
      ),
    );
  }

  Widget callParticipantsView(BuildContext context) {
    return Obx(() {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: controller.callList.length,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            debugPrint("call list length ${controller.callList.length}");
            return SessionManagement.getUserJID() == controller.callList[index].userJid.checkNull()
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        FutureBuilder(
                            future: getProfileDetails(controller.callList[index].userJid.checkNull()),
                            builder: (ctx, snap) {
                              return snap.hasData && snap.data != null ? buildProfileImage(snap.data!, size: 48) : const SizedBox.shrink();
                            }),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FutureBuilder(
                                  future: CallUtils.getNameOfJid(controller.callList[index].userJid.checkNull()),
                                  builder: (ctx, snap) {
                                    return snap.hasData && snap.data != null
                                        ? Text(
                                            snap.data!,
                                            maxLines: 1,
                                            style: Theme.of(context).textTheme.titleMedium,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        : const SizedBox.shrink();
                                  }),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Obx(() {
                            return controller.callList[index].isAudioMuted.value
                                ? CircleAvatar(backgroundColor: AppColors.participantUnMuteColor, child: SvgPicture.asset(participantMute))
                                : CircleAvatar(backgroundColor: Colors.transparent, child: SvgPicture.asset(participantUnMute));
                          }),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Obx(() {
                            return CircleAvatar(
                                backgroundColor:
                                    controller.callList[index].isVideoMuted.value ? AppColors.participantUnMuteColor : Colors.transparent,
                                child: SvgPicture.asset(
                                    controller.callList[index].isVideoMuted.value ? participantVideoDisabled : participantVideoEnabled));
                          }),
                        ),
                      ],
                    ),
                  );
          });
    });
  }

  Widget addParticipants(BuildContext context) {
    return const SizedBox();
  }
}
