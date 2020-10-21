import 'dart:io';
import 'dart:ui';

import 'package:encryption/customButton.dart';
import 'package:encryption/customText.dart';
import 'package:encryption/styling.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aes_crypt/aes_crypt.dart';

class EncryptionScreen extends StatefulWidget {
  @override
  _EncryptionScreenState createState() => _EncryptionScreenState();
}

class _EncryptionScreenState extends State<EncryptionScreen> {
  String encFilepath;
  String decFilepath;
  // FilePickerResult result;
  FilePicker picker;
  var crypt = AesCrypt();
  File encryptedImage;
  String fileToEncrypt = '/data/user/0';
  String decryptionPassword = '123456';
  final scaffoldKey = GlobalKey<ScaffoldState>();
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
      body: Container(
        alignment: Alignment.center,
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomFlatButton(
              callback: () => pickFile(),
              color: primaryColor,
              textColor: white,
              text: 'Choose File',
              radius: 40,
              width: 100,
              // height: 50,
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
            CustomFlatButton(
              color: primaryColor,
              textColor: white,
              text: 'Encrypt the File',
              radius: 40,
              width: 100,
              callback: () => encryptFile(),
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
            CustomFlatButton(
              color: primaryColor,
              textColor: white,
              text: 'Pick Encrypted Image',
              radius: 40,
              width: 100,
              callback: () => pickEncryptedFile(),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: grey[300],
                ),
                // height: 200,
                width: MediaQuery.of(context).size.width,
                child: userImage(),
              ),
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
      // encFilepath = crypt.encryptFileSync(fileToEncrypt);
      print('The encryption has been completed successfully.');
      print('Encrypted file: $encFilepath');
      scaffoldKey.currentState
          .showSnackBar(SnackBar(content: CustomText(text: 'Encryption successful', textAlign: TextAlign.center, color: white)));
    } on AesCryptException catch (e) {
      if (e.type == AesCryptExceptionType.destFileExists) {
        print('The encryption process has failed.');
        throw Exception(e.message);
      }
      scaffoldKey.currentState.showSnackBar(SnackBar(
          content: CustomText(
        text: 'ENCRYPTION FAILED',
        textAlign: TextAlign.center,
        color: Colors.red,
      )));
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
  }

  decryptFile(String path) {
    try {
      decFilepath = crypt.decryptFileSync(path);

      scaffoldKey.currentState.showSnackBar(SnackBar(
          backgroundColor: white,
          content: CustomText(text: 'Decryption successful', textAlign: TextAlign.center, color: Colors.green)));
      setState(() {
        encFilepath = decFilepath;
      });
      print('Decrypted file 1: $decFilepath');
      print('File content: ' + File(decFilepath).readAsStringSync() + '\n');
    } catch (e) {
      print('THE ERROR IS ' + e.toString());
    }
  }

  Widget userImage() {
    return encFilepath == null
        ? Icon(Icons.image)
        : ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(9)),
            child: Image.asset(encFilepath, fit: BoxFit.cover, height: 100, width: 100));
  }
}
