import 'dart:io';
import 'dart:math';

import 'package:fl_pip/fl_pip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import '../common/app_localizations.dart';
import '../data/helper.dart';
import '../extensions/extensions.dart';
import '../model/chat_message_model.dart';
import '../routes/mirrorfly_navigation_observer.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';
import '../app_style_config.dart';
import '../common/constants.dart';
import '../common/main_controller.dart';
import '../stylesheet/stylesheet.dart';

part 'apputils.dart';
part 'date_utils.dart';
part 'dialog_utils.dart';
part 'media_utils.dart';
part 'message_utils.dart';
part 'nav_utils.dart';

