import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:study_aid/common/widgets/bannerbars/base_bannerbar.dart';

class InfoBannerbar extends BaseBanner {
  InfoBannerbar(BuildContext context, String message)
      : super(context, 'Info', message, ContentType.help);
}
