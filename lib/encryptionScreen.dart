import 'dart:io';
import 'dart:ui';

import 'package:encryption/customButton.dart';
import 'package:encryption/customText.dart';
import 'package:encryption/styling.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aes_crypt/aes_crypt.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

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
  @override
  void initState() {
    super.initState();
    // print(encryptinDir);
    getExternalStoragePicturesDirectory();
  }

  @override
  Widget build(BuildContext context) {
    crypt.setPassword(decryptionPassword);
    crypt.setOverwriteMode(AesCryptOwMode.rename);
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: CustomText(text: 'File Encryption', size: 20, color: white),
      ),
      body: Container(
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
              boldFont: fileToEncrypt == '/data/user/0' ? '' : fileToEncrypt,
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
                callback: () => encryptFile(),
              ),
            ),
            // SizedBox(height: 20),
            // CustomFlatButton(
            //   color: primaryColor,
            //   textColor: white,
            //   text: 'Decrypt the File',
            //   radius: 40,
            //   width: 100,
            //   callback: () => decryptFile(),
            // ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: CustomFlatButton(
                color: primaryColor,
                textColor: white,
                text: 'Pick Encrypted Image',
                radius: 40,
                width: 100,
                callback: () => pickEncryptedFile(),
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
                callback: () => pickMultiple(),
              ),
            ),
            Column(
              children: encryptedImages != null
                  ? encryptedImages
                      .map((e) => Column(
                            children: [
                              CustomText(text: e.path, maxLines: 2, size: 13, color: grey[400], overflow: TextOverflow.visible),
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
                        child: CustomText(text: 'YOUR ENCRYPTED LIST IS EMPTY'),
                      )
                    ],
            )
          ],
        ),
      ),
    );
  }

  pickFile() async {
    File file = await FilePicker.getFile();
    if (file != null) {
      print('the file to encrypt is ' + file.path);
      setState(() {
        fileToEncrypt = file.path;
      });
    } else {
      throw Exception('USER CANCELLED THE FILE PICKING');
    }
  }

  encryptFile() {
    try {
      encFilepath = crypt.encryptFileSync(fileToEncrypt);
      print(encFilepath);

      print('The encryption has been completed successfully.');
      print('Encrypted file: $encFilepath');
      scaffoldKey.currentState
          .showSnackBar(SnackBar(content: CustomText(text: 'Encryption successful', textAlign: TextAlign.center, color: white)));
    } catch (e) {
      print('The encryption process has failed.' + e.message);
      Fluttertoast.showToast(msg: e.message);
      print(encFilepath);
      scaffoldKey.currentState
          .showSnackBar(SnackBar(content: CustomText(text: 'ENCRYPTION FAILED', textAlign: TextAlign.center, color: Colors.red)));
      return;
    }
  }

  pickEncryptedFile() async {
    await FilePicker.getFile().then((value) {
      setState(() {
        encryptedImage = value;
      });
    });
    decryptFile(encryptedImage.path);

    print('THE SINGLE IMAGE PATH IS ' + encryptedImage.path);
  }

  decryptFile(String path) {
    setState(() {});
    decFilepath = crypt.decryptFileSync(path);
    scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: white,
        content: CustomText(text: 'Decryption successful', textAlign: TextAlign.center, color: Colors.green)));
    setState(() {
      encFilepath = decFilepath;
    });
    print('Decrypted file 1: $decFilepath');
  }

  pickMultiple() async {
    await FilePicker.getMultiFile().then((value) {
      setState(() {
        encryptedImages = value;
      });
    });
    // decryptFile(encryptedImage.path);
    try {
      encryptedImages.forEach((element) {
        decryptMultipleFile(element.path);
      });
      scaffoldKey.currentState.showSnackBar(SnackBar(
          backgroundColor: white,
          content: CustomText(text: 'Decryption successful', textAlign: TextAlign.center, color: Colors.green)));
    } catch (e) {
      print('the error' + e.toString());
    }
  }

  decryptMultipleFile(String path) {
    try {
      decFilepath = crypt.decryptFileSync(path,dirPath);
      encryptedImages.forEach((element) {
        setState(() {
          encMultiplePath = decFilepath;
        });
      });
    } catch (e) {
      print('THE ExRROR IS ' + e.toString());
    }
    return encMultiplePath;
  }

  Widget userImage() {
    return encFilepath == null
        ? Icon(Icons.image)
        : ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(9)),
            child: Image.file(File(encFilepath), fit: BoxFit.cover, height: 100, width: 100));
  }

  // fetchEncryptedImages() async {
  //   Directory encryptDir = await getExternalStorageDirectory();
  //   print('the encrypted path is\n\n\n\n\n' +
  //       encryptDir.toString().replaceAll('Android/data/com.example.encryption/files', 'Downloads'));
  //   await Directory(encryptinDir).create(recursive: true);
  //   setState(() {
  //     encryptinDir = '${encryptDir.toString().replaceAll('Android/data/com.example.encryption/files', 'Pictures')}';
  //   });

  //   return encryptinDir;
  // }
  Future<String> getExternalStoragePicturesDirectory() async {
    final Directory extDir = await getExternalStorageDirectory();
    dirPath = '${extDir.path}/Download/ENCRYPTION';
    setState(() {
      dirPath = dirPath.replaceAll("Android/data/com.example.encryption/files/", "");
    });
    print(dirPath);
    await Directory(dirPath).create(recursive: true);
    return dirPath;
  }
}
