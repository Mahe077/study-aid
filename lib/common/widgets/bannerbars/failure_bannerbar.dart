import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:study_aid/common/widgets/bannerbars/base_bannerbar.dart';

class FailureBannerbar extends BaseBanner {
  FailureBannerbar(BuildContext context, String message)
      : super(context, 'Failure!', message, ContentType.failure);
}
