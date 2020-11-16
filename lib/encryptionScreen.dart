import 'dart:io';
import 'dart:ui';

import 'package:encryption/customButton.dart';
import 'package:encryption/customText.dart';
import 'package:encryption/loading.dart';
import 'package:encryption/styling.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aes_crypt/aes_crypt.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:permission_handler/permission_handler.dart';

class EncryptionScreen extends StatefulWidget {
  @override
  _EncryptionScreenState createState() => _EncryptionScreenState();
}

class _EncryptionScreenState extends State<EncryptionScreen> {
  String encFilepath;
  String encMultiplePath;
  String decFilepath;
  // FilePickerResult result;
  FilePicker picker;
  var crypt = AesCrypt();
  File encryptedImage;
  String fileToEncrypt = '/data/user/0';
  String decryptionPassword = '123456';
  List<File> encryptedImages = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String dirPath = '';
  Permission permission;
  List<StorageInfo> _storageInfo = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    crypt.setPassword(decryptionPassword);
    crypt.setOverwriteMode(AesCryptOwMode.on);
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: CustomText(text: 'File Encryption', size: 20, color: white),
      ),
      body: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            child: ListView(
              // mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: CustomFlatButton(
                    callback: () => pickFile(),
                    color: primaryColor,
                    textColor: white,
                    text: 'Choose File to encrypt',
                    radius: 40,
                    width: 100,
                    // height: 50,
                  ),
                ),
                SizedBox(height: 20),
                CustomRichText(
                  lightColor: grey[700],
                  boldColor: black.withOpacity(.9),
                  boldFontSize: 15,
                  lightFontSize: 13,
                  lightFont: 'The file to encrypt is: ',
                  boldFont: fileToEncrypt == '/data/user/0'
                      ? ''
                      : fileToEncrypt.replaceAll('/data/user/0/com.example.encryption/cache/',
                          '${_storageInfo[_storageInfo.length - 1].rootDir}/Encryption/'),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: CustomFlatButton(
                    color: primaryColor,
                    textColor: white,
                    text: 'Encrypt the File',
                    radius: 40,
                    width: 100,
                    callback: () => encryptFile().then((value) => Future.delayed(Duration(seconds: 1))).then((value) => File(
                            fileToEncrypt.replaceAll('/data/user/0/com.example.encryption/cache/',
                                '${_storageInfo[_storageInfo.length - 1].rootDir}/Encryption/'))
                        .delete()),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: CustomFlatButton(
                    color: primaryColor,
                    textColor: white,
                    text: 'Pick Encrypted Image',
                    radius: 40,
                    width: 100,
                    callback: () => pickEncryptedFile().then((value) => Future.delayed(Duration(seconds: 1)).then((value) {
                          try {
                            File(decFilepath).delete();
                          } catch (e) {
                            print(e.toString());
                          }
                        })),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: grey[300],
                  ),
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  child: userImage(),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomText(text: 'Load Image list', textAlign: TextAlign.center),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: CustomFlatButton(
                    color: primaryColor,
                    textColor: white,
                    text: 'Pick A list of encrypted images',
                    radius: 40,
                    width: 100,
                    callback: () => pickMultiple().then((value) => Future.delayed(Duration(seconds: 1))).then((value) {
                      for (int i = 0; i < encryptedImages.length; i++) {
                        encryptedImages.forEach((element) {
                          File(decryptMultipleFile(element.path)).delete();
                        });
                      }
                    }),
                  ),
                ),
                Column(
                    children: encryptedImages.length > 1
                        ? encryptedImages
                            .map((e) => Column(
                                  children: [
                                    CustomText(
                                        text: e.path, maxLines: 2, size: 13, color: grey[400], overflow: TextOverflow.visible),
                                    SizedBox(height: 10),
                                    ClipRRect(
                                        borderRadius: BorderRadius.all(Radius.circular(9)),
                                        child: Image.file(File(decryptMultipleFile(e.path)),
                                            fit: BoxFit.cover, height: 200, width: MediaQuery.of(context).size.width))
                                  ],
                                ))
                            .toList()
                        : [
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CustomText(
                                  text: 'YOUR ENCRYPTED LIST IS EMPTY',
                                  color: black,
                                ))
                          ])
              ],
            ),
          ),
          Visibility(
              visible: loading = true,
              child: Loading(
                text: 'Encrypting\nPlease wait...',
              ))
        ],
      ),
    );
  }

  pickFile() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    } else {
      File file = await FilePicker.getFile();
      if (file != null) {
        print('the file to encrypt is ' +
            file.path.replaceAll(
                '/data/user/0/com.example.encryption/cache/', '${_storageInfo[_storageInfo.length - 1].rootDir}/Encryption/'));
        setState(() {
          fileToEncrypt = file.path;
        });
      } else {
        throw Exception('USER CANCELLED THE FILE PICKING');
      }
    }
  }

  Future encryptFile() async {
    setState(() {
      loading = true;
    });
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    } else {
      try {
        encFilepath = crypt.encryptFileSync(fileToEncrypt.replaceAll(
            '/data/user/0/com.example.encryption/cache/', '${_storageInfo[_storageInfo.length - 1].rootDir}/Encryption/'));
        print('The encryption has been completed successfully.');
        print('Encrypted file: $encFilepath');
        scaffoldKey.currentState.showSnackBar(
            SnackBar(content: CustomText(text: 'Encryption successful', textAlign: TextAlign.center, color: white)));
      } on AesCryptException catch (e) {
        print('The encryption process has failed.' + e.message);
        Fluttertoast.showToast(msg: e.message);
        print(encFilepath);
        scaffoldKey.currentState.showSnackBar(
            SnackBar(content: CustomText(text: 'ENCRYPTION FAILED', textAlign: TextAlign.center, color: Colors.red)));
        return;
      }
    }
    setState(() {
      loading = false;
    });
  }

  Future pickEncryptedFile() async {
    try {
      await FilePicker.getFile().then((value) {
        setState(() {
          encryptedImage = value;
        });
      }).then((value) => decryptFile(encryptedImage.path));
      print('THE SINGLE IMAGE PATH IS ' + encryptedImage.path);
    } catch (e) {
      print('No image has been selected');
    }
  }

  decryptFile(String path) {
    setState(() {
      loading = true;
    });
    decFilepath = crypt.decryptFileSync(path);
    scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: white,
        content: CustomText(text: 'Decryption successful', textAlign: TextAlign.center, color: Colors.green)));
    setState(() {
      encFilepath = decFilepath;
    });
    setState(() {
      loading = false;
    });
    print('Decrypted file 1: $decFilepath');
  }

  Future pickMultiple() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    } else {
      await FilePicker.getMultiFile().then((value) {
        // setState(() {
        encryptedImages = value;
        // });
      });
      try {
        encryptedImages.forEach((element) {
          setState(() {
            decryptMultipleFile(element.path);
          });
        });
        scaffoldKey.currentState.showSnackBar(SnackBar(
            backgroundColor: white,
            content: CustomText(text: 'Decryption successful', textAlign: TextAlign.center, color: Colors.green)));
      } catch (e) {
        print('the error' + e.toString());
      }
    }
  }

  decryptMultipleFile(String path) {
    try {
      decFilepath = crypt.decryptFileSync(path, dirPath);
      encryptedImages.forEach((element) {
        // setState(() {
        encMultiplePath = decFilepath;
        // });
      });
    } catch (e) {
      print('THE ERROR IS ' + e.toString());
    }
    return encMultiplePath;
  }

  Widget userImage() {
    return encFilepath == null || encryptedImage == null
        ? Icon(Icons.image)
        : ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(9)),
            child: Image.file(File(encFilepath), fit: BoxFit.cover, height: 100, width: 100));
  }

  Future<void> initPlatformState() async {
    List<StorageInfo> storageInfo;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      storageInfo = await PathProviderEx.getStorageInfo();
    } on PlatformException {}

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _storageInfo = storageInfo;
    });
    print('THE PATH TO EXTERNAL STORAGE IS ' + _storageInfo[_storageInfo.length - 1].rootDir);
  }
}
