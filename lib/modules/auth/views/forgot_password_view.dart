import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:social_media_app/common/custom_app_bar.dart';
import 'package:social_media_app/common/primary_filled_btn.dart';
import 'package:social_media_app/common/primary_text_btn.dart';
import 'package:social_media_app/constants/colors.dart';
import 'package:social_media_app/constants/dimens.dart';
import 'package:social_media_app/constants/strings.dart';
import 'package:social_media_app/constants/styles.dart';
import 'package:social_media_app/modules/auth/controllers/password_controller.dart';
import 'package:social_media_app/routes/route_management.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: SizedBox(
            width: Dimens.screenWidth,
            height: Dimens.screenHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NxAppBar(
                  title: StringValues.forgotPassword,
                  padding: Dimens.edgeInsets8_16,
                ),
                _buildForgotPasswordFields(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordFields() => GetBuilder<PasswordController>(
        builder: (logic) => Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: Dimens.edgeInsets0_16,
              child: FocusScope(
                node: logic.focusNode,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Dimens.boxHeight32,
                    Text(
                      StringValues.forgotYourPassword,
                      style: AppStyles.style28Bold.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Dimens.boxHeight4,
                    Text(
                      StringValues.enterEmailForOtp,
                      style: AppStyles.style12Normal,
                    ),
                    Dimens.boxHeight32,
                    Container(
                      height: Dimens.fiftySix,
                      constraints: BoxConstraints(maxWidth: Dimens.screenWidth),
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(Dimens.eight),
                          ),
                          hintText: StringValues.enterEmail,
                          hintStyle: AppStyles.style14Normal.copyWith(
                            color: ColorValues.grayColor,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        maxLines: 1,
                        style: AppStyles.style14Normal.copyWith(
                          color:
                              Theme.of(Get.context!).textTheme.bodyText1!.color,
                        ),
                        controller: logic.emailTextController,
                        onEditingComplete: logic.focusNode.unfocus,
                      ),
                    ),
                    Dimens.boxHeight32,
                    const NxTextButton(
                      label: StringValues.loginToAccount,
                      onTap: RouteManagement.goToLoginView,
                    ),
                    Dimens.boxHeight32,
                    NxFilledButton(
                      onTap: () => logic.sendResetPasswordOTP(),
                      label: StringValues.sendOtp,
                    ),
                    Dimens.boxHeight48,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          StringValues.alreadyHaveOtp,
                          style: AppStyles.style14Normal,
                        ),
                        Dimens.boxWidth4,
                        const NxTextButton(
                          label: StringValues.resetPassword,
                          onTap: RouteManagement.goToResetPasswordView,
                        ),
                      ],
                    ),
                    Dimens.boxHeight32,
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
