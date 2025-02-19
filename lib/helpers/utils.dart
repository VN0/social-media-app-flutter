import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:social_media_app/common/asset_image.dart';
import 'package:social_media_app/constants/assets.dart';
import 'package:social_media_app/constants/colors.dart';
import 'package:social_media_app/constants/dimens.dart';
import 'package:social_media_app/constants/strings.dart';
import 'package:social_media_app/constants/styles.dart';

abstract class AppUtils {
  static final storage = GetStorage();

  static void showLoadingDialog() {
    closeDialog();
    Get.dialog<void>(
      WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: CupertinoTheme(
              data: CupertinoTheme.of(Get.context!).copyWith(
                brightness: Brightness.dark,
                primaryColor: Colors.white,
              ),
              child: const CircularProgressIndicator(),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void showError(String message) {
    closeSnackBar();
    closeDialog();
    closeBottomSheet();
    if (message.isEmpty) return;
    Get.rawSnackbar(
      messageText: Text(
        message,
      ),
      mainButton: TextButton(
        onPressed: () {
          if (Get.isSnackbarOpen) {
            Get.back<void>();
          }
        },
        child: const Text(
          StringValues.okay,
        ),
      ),
      backgroundColor: const Color(0xFF503E9D),
      margin: Dimens.edgeInsets16,
      borderRadius: Dimens.fifteen,
      snackStyle: SnackStyle.FLOATING,
    );
  }

  static void showNoInternetDialog() {
    closeDialog();
    Get.dialog<void>(
      WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.black26,
          body: Padding(
            padding: Dimens.edgeInsets16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NxAssetImage(
                  imgAsset: AssetValues.error,
                  width: Dimens.hundred * 2,
                  height: Dimens.hundred * 2,
                ),
                Dimens.boxHeight8,
                Text(
                  'No Internet!',
                  textAlign: TextAlign.center,
                  style: AppStyles.style24Bold.copyWith(
                    color: ColorValues.whiteColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void showBottomSheet(List<Widget> children, {double? borderRadius}) {
    closeBottomSheet();
    Get.bottomSheet(
      Padding(
        padding: Dimens.edgeInsets8_0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius ?? Dimens.zero),
          topRight: Radius.circular(borderRadius ?? Dimens.zero),
        ),
      ),
      barrierColor:
          Theme.of(Get.context!).textTheme.bodyText1!.color!.withAlpha(90),
      backgroundColor: Theme.of(Get.context!).bottomSheetTheme.backgroundColor,
    );
  }

  static void showOverlay(Function func) {
    Get.showOverlay(
      loadingWidget: const CupertinoActivityIndicator(),
      opacityColor: Theme.of(Get.context!).bottomSheetTheme.backgroundColor!,
      opacity: 0.5,
      asyncFunction: () async {
        await func();
      },
    );
  }

  static void showSnackBar(String message, String type, {int? duration}) {
    closeSnackBar();
    Get.showSnackbar(
      GetSnackBar(
        margin: EdgeInsets.only(
          left: Dimens.sixTeen,
          right: Dimens.sixTeen,
          bottom: Dimens.thirtyTwo,
        ),
        borderRadius: Dimens.four,
        padding: Dimens.edgeInsets16,
        snackStyle: SnackStyle.FLOATING,
        messageText: Text(
          message,
          style: TextStyle(
            color: Theme.of(Get.context!).scaffoldBackgroundColor,
          ),
        ),
        icon: Icon(
          type == StringValues.error
              ? CupertinoIcons.clear_circled_solid
              : type == StringValues.success
                  ? CupertinoIcons.check_mark_circled_solid
                  : CupertinoIcons.info_circle_fill,
          color: type == StringValues.error
              ? ColorValues.errorColor
              : type == StringValues.success
                  ? ColorValues.successColor
                  : type == StringValues.warning
                      ? ColorValues.warningColor
                      : Theme.of(Get.context!).iconTheme.color,
        ),
        shouldIconPulse: false,
        backgroundColor: Theme.of(Get.context!).snackBarTheme.backgroundColor!,
        duration: Duration(seconds: duration ?? 2),
      ),
    );
  }

  /// Close any open snack bar.
  static void closeSnackBar() {
    if (Get.isSnackbarOpen) Get.back<void>();
  }

  /// Close any open dialog.
  static void closeDialog() {
    if (Get.isDialogOpen ?? false) Get.back<void>();
  }

  /// Close any open bottom sheet.
  static void closeBottomSheet() {
    if (Get.isBottomSheetOpen ?? false) Get.back<void>();
  }

  static void closeFocus() {
    if (FocusManager.instance.primaryFocus!.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  static Future<void> saveLoginDataToLocalStorage(token, expiresAt) async {
    if (token!.isNotEmpty && expiresAt!.isNotEmpty) {
      final data = jsonEncode({
        StringValues.token: token,
        StringValues.expiresAt: expiresAt,
      });

      await storage.write(StringValues.loginData, data);
      printLog(StringValues.authDetailsSaved);
    } else {
      printLog(StringValues.authDetailsNotSaved);
    }
  }

  static Future<dynamic> readLoginDataFromLocalStorage() async {
    if (storage.hasData(StringValues.loginData)) {
      final data = await storage.read(StringValues.loginData);
      var decodedData = jsonDecode(data) as Map<String, dynamic>;
      printLog(StringValues.authDetailsFound);
      return decodedData;
    }
    printLog(StringValues.authDetailsNotFound);
    return null;
  }

  static Future<void> saveProfileDataToLocalStorage(response) async {
    if (response != null) {
      final data = jsonEncode(response);

      await storage.write(StringValues.profileData, data);
      printLog(StringValues.profileDetailsSaved);
    } else {
      printLog(StringValues.profileDetailsNotSaved);
    }
  }

  static Future<dynamic> readProfileDataFromLocalStorage() async {
    if (storage.hasData(StringValues.profileData)) {
      final data = await storage.read(StringValues.profileData);
      var decodedData = jsonDecode(data);
      printLog(StringValues.profileDetailsFound);
      return decodedData;
    }
    printLog(StringValues.profileDetailsNotFound);
    return null;
  }

  static Future<void> clearLoginDataFromLocalStorage() async {
    await storage.remove(StringValues.loginData);
    await storage.remove(StringValues.profileData);
    printLog(StringValues.authDetailsRemoved);
    printLog(StringValues.profileDetailsRemoved);
  }

  static void printLog(message) {
    debugPrint(
        "=======================================================================");
    debugPrint(message.toString(), wrapWidth: 1024);
    debugPrint(
        "=======================================================================");
  }

  static Future<dynamic> selectSingleImage({ImageSource? imageSource}) async {
    final imagePicker = ImagePicker();
    final imageCropper = ImageCropper();
    final pickedImage = await imagePicker.pickImage(
      maxWidth: 1920.0,
      maxHeight: 1920.0,
      source: imageSource ?? ImageSource.gallery,
    );

    if (pickedImage != null) {
      var croppedFile = await imageCropper.cropImage(
        maxWidth: 1920,
        maxHeight: 1920,
        sourcePath: pickedImage.path,
        aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        cropStyle: CropStyle.circle,
        uiSettings: [
          AndroidUiSettings(
            toolbarColor: Theme.of(Get.context!).scaffoldBackgroundColor,
            toolbarTitle: StringValues.cropImage,
            toolbarWidgetColor: Theme.of(Get.context!).colorScheme.primary,
            backgroundColor: Theme.of(Get.context!).scaffoldBackgroundColor,
          ),
          IOSUiSettings(
            title: StringValues.cropImage,
            minimumAspectRatio: 1.0,
          ),
        ],
        compressQuality: 70,
      );

      return File(croppedFile!.path);
    }

    return null;
  }

  static Future<dynamic> selectMultipleImage() async {
    final imagePicker = ImagePicker();
    final imageCropper = ImageCropper();
    var imageList = <File>[];
    final pickedImages = await imagePicker.pickMultiImage(
      maxWidth: 1920.0,
      maxHeight: 1920.0,
    );

    if (pickedImages != null) {
      for (var pickedImage in pickedImages) {
        var croppedFile = await imageCropper.cropImage(
          maxWidth: 1920,
          maxHeight: 1920,
          sourcePath: pickedImage.path,
          aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
          uiSettings: [
            AndroidUiSettings(
              toolbarColor: Theme.of(Get.context!).scaffoldBackgroundColor,
              toolbarTitle: StringValues.cropImage,
              toolbarWidgetColor: Theme.of(Get.context!).colorScheme.primary,
              backgroundColor: Theme.of(Get.context!).scaffoldBackgroundColor,
            ),
            IOSUiSettings(
              title: StringValues.cropImage,
              minimumAspectRatio: 1.0,
            ),
          ],
          compressQuality: 70,
        );
        imageList.add(File(croppedFile!.path));
      }
    }

    return imageList;
  }

  static Future<dynamic> selectMultipleFiles() async {
    final filePicker = FilePicker.platform;
    final imageCropper = ImageCropper();
    var fileList = <PlatformFile>[];
    var resultList = <File>[];
    final pickedFiles = await filePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'mp4', 'mkv'],
      allowCompression: true,
    );

    if (pickedFiles != null) {
      fileList = pickedFiles.files;

      for (var pickedImage in fileList) {
        var fileExt = pickedImage.extension;

        if (['png', 'jpg', 'jpeg'].contains(fileExt)) {
          var croppedFile = await imageCropper.cropImage(
            maxWidth: 1920,
            maxHeight: 1920,
            sourcePath: pickedImage.path!,
            aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
            uiSettings: [
              AndroidUiSettings(
                toolbarColor: Theme.of(Get.context!).scaffoldBackgroundColor,
                toolbarTitle: StringValues.cropImage,
                toolbarWidgetColor: Theme.of(Get.context!).colorScheme.primary,
                backgroundColor: Theme.of(Get.context!).scaffoldBackgroundColor,
              ),
              IOSUiSettings(
                title: StringValues.cropImage,
                minimumAspectRatio: 1.0,
              ),
            ],
            compressQuality: 70,
          );
          resultList.add(File(croppedFile!.path));
        } else {
          resultList.add(File(pickedImage.path!));
        }
      }
    }

    return resultList;
  }

  static bool isVideoFile(String path) {
    final mimeType = lookupMimeType(path);

    return mimeType!.startsWith('video/');
  }
}
