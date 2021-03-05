//import 'dart:convert';
import 'dart:developer';
//import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
//import 'dart:math' hide log;
import 'package:shared_preferences/shared_preferences.dart';

//import 'dart:io';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fake Contacts 2',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Fake Contacts 2'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String sPhoneNumberTemplate = "";
  String sEmailAddressTemplate = "";
  var arrbFieldSelections = [
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ]; // aray of bools
  static const FIELD_PHONES = 0;
  static const FIELD_POSTALADDRESSES = 1;
  static const FIELD_EMAILS = 2;
  static const FIELD_COMPANYANDTITLE = 3;
  static const FIELD_MESSENGERS = 4;
  static const FIELD_AVATAR = 5;
  static const FIELD_DATES = 6;

  Key keyPhoneNumberTemplate = Key("PhoneNumberTemplate");
  Key keyEmailAddressTemplate = Key("EmailAddressTemplate");

  TextEditingController phoneNumberTemplateController = TextEditingController();
  TextEditingController emailAddressTemplateController =
      TextEditingController();

  Future<void> getStoredSettings() async {
    log("getStoredSettings: called");
    SharedPreferences prefs;

    prefs = await SharedPreferences.getInstance();
    sPhoneNumberTemplate = prefs.getString('sPhoneNumberTemplate');
    //log("getStoredSettings: retrieved last names " + (sListOfLastNames ?? "null"));
    if (sPhoneNumberTemplate == null) {
      sPhoneNumberTemplate = "+2134567nnnn";
      sEmailAddressTemplate = "FIRST.LAST@example.com";
      arrbFieldSelections = [false, false, false, false, false, false, false];
      savePhoneNumberTemplate();
      saveEmailAddressTemplate();
      saveFieldSelections(true);
    } else {
      sPhoneNumberTemplate = prefs.getString('sPhoneNumberTemplate');
      sEmailAddressTemplate = prefs.getString('sEmailAddressTemplate');
      arrbFieldSelections[0] = prefs.getBool('bFieldSelection0');
      arrbFieldSelections[1] = prefs.getBool('bFieldSelection1');
      arrbFieldSelections[2] = prefs.getBool('bFieldSelection2');
      arrbFieldSelections[3] = prefs.getBool('bFieldSelection3');
      arrbFieldSelections[4] = prefs.getBool('bFieldSelection4');
      arrbFieldSelections[5] = prefs.getBool('bFieldSelection5');
      arrbFieldSelections[6] = prefs.getBool('bFieldSelection6');
    }

    phoneNumberTemplateController.text = sPhoneNumberTemplate;
    emailAddressTemplateController.text = sEmailAddressTemplate;
  }

  void saveFieldSelections(bool bIgnored) async {
    log("saveFieldSelections: called");

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("bFieldSelection0", arrbFieldSelections[0]);
    await prefs.setBool("bFieldSelection1", arrbFieldSelections[1]);
    await prefs.setBool("bFieldSelection2", arrbFieldSelections[2]);
    await prefs.setBool("bFieldSelection3", arrbFieldSelections[3]);
    await prefs.setBool("bFieldSelection4", arrbFieldSelections[4]);
    await prefs.setBool("bFieldSelection5", arrbFieldSelections[5]);
    await prefs.setBool("bFieldSelection6", arrbFieldSelections[6]);
  }

  void savePhoneNumberTemplate() async {
    log("savePhoneNumberTemplate: called");

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("sPhoneNumberTemplate", sPhoneNumberTemplate);
  }

  void saveEmailAddressTemplate() async {
    log("saveEmailAddressTemplate: called");

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("sEmailAddressTemplate", sEmailAddressTemplate);
  }

  String generatePhoneNumber(String sLastName) {
    log("generatePhoneNumber: called, sPhoneNumberTemplate " +
        sPhoneNumberTemplate +
        ", sLastName " +
        sLastName);
    String sNumber = "";
    int nNext = 0; // next char to use in sLastName

    for (var i = 0; i < sPhoneNumberTemplate.length; i++) {
      //log("generatePhoneNumber: i " + i.toString() + ", sPhoneNumberTemplate[i] " + sPhoneNumberTemplate[i] + ", nNext " + nNext.toString());
      if (sPhoneNumberTemplate[i] != 'n') {
        sNumber += sPhoneNumberTemplate[i];
      } else {
        if (nNext >= sLastName.length)
          sNumber += "0";
        else {
          sNumber += (String.fromCharCode(
              "0".codeUnitAt(0) + (sLastName.codeUnitAt(nNext) % 10)));
          nNext++;
        }
      }
    }

    log("generatePhoneNumber: returning, sNumber " + sNumber);
    return sNumber;
  }

  String generateEmailAddress(String sLastName, String sFirstName) {
    return sEmailAddressTemplate
        .replaceAll("FIRST", sFirstName)
        .replaceAll("LAST", sLastName);
  }

  Future<void> _scanFieldsOfAllContacts() async {
    log("_scanFieldsOfAllContacts: about to call Permission.contacts.request");
    PermissionStatus permission = await Permission.contacts.request();
    if (!permission.isGranted) {
      log("_scanFieldsOfAllContacts: no permission");
    } else {
      // Either the permission was already granted before or the user just granted it.
      log("_scanFieldsOfAllContacts: about to call ContactsService.getContacts");
      Iterable<Contact> iContacts = await ContactsService.getContacts();
      log("_scanFieldsOfAllContacts: iContacts.length " + iContacts.length.toString());
      for (var c in iContacts) {
        log("_scanFieldsOfAllContacts: givenName " + c.givenName);
        Iterable<Item> iEmails = c.emails;
        log("_scanFieldsOfAllContacts: iEmails " + iEmails.toString());
        Iterable<Item> iPhones = c.phones;
        Iterable<PostalAddress> iAddresses = c.postalAddresses;
        String sCompany = c.company;
        String sTitle = c.jobTitle;
        //List<Uint8> uAvatar = c.avatar;
        //Uint8List lAvatar = c.avatar.;
      }
    }
    log("_scanFieldsOfAllContacts: about to return");
  }

  Future<void> _setFieldsOfAllContacts(bool bSet) async {
    log("_setFieldsOfAllContacts: about to call Permission.contacts.request");
    PermissionStatus permission = await Permission.contacts.request();
    if (!permission.isGranted) {
      log("_setFieldsOfAllContacts: no permission");
    } else {
      // Either the permission was already granted before or the user just granted it.
      log("_setFieldsOfAllContacts: about to call ContactsService.getContacts");
      //Iterable<Contact> iContacts = await ContactsService.getContacts();
      Iterable<Contact> iContacts = null;
      for (var c in iContacts) {
        log("_setFieldsOfAllContacts: 1 !!!");
        //await ContactsService.deleteContact(c); // !!!
      }
    }
    log("_setFieldsOfAllContacts: about to return");
  }

  // this gets called every time a char gets changed in the field
  void _changedPhoneNumberTemplate(String sNewValue) {
    log("_changedPhoneNumberTemplate: called, " + sNewValue);
    sPhoneNumberTemplate = sNewValue;

    savePhoneNumberTemplate();
  }

  // this gets called every time a char gets changed in the field
  void _changedEmailAddressTemplate(String sNewValue) {
    log("_changedEmailAddressTemplate: called, " + sNewValue);
    sEmailAddressTemplate = sNewValue;

    saveEmailAddressTemplate();
  }

  // this gets called every time a check-box gets changed
  void _changedFieldSelections(int nIndex, bool bNewValue) {
    log("_changedEmailAddressTemplate: called, nIndex " +
        nIndex.toString() +
        ", bNewValue " +
        bNewValue.toString());
    arrbFieldSelections[nIndex] = bNewValue;

    saveFieldSelections(true);
  }

  void onPhonesCheckboxChanged(bool bNewValue) {
    log("onPhonesCheckboxChanged: called, bNewValue " + bNewValue.toString());
    arrbFieldSelections[FIELD_PHONES] = bNewValue;
    saveFieldSelections(true);
  }

  void onAddressesCheckboxChanged(bool bNewValue) {
    log("onAddressesCheckboxChanged: called, bNewValue " + bNewValue.toString());
    arrbFieldSelections[FIELD_POSTALADDRESSES] = bNewValue;
    saveFieldSelections(true);
  }

  void onEmailsCheckboxChanged(bool bNewValue) {
    log("onEmailsCheckboxChanged: called, bNewValue " + bNewValue.toString());
    arrbFieldSelections[FIELD_EMAILS] = bNewValue;
    saveFieldSelections(true);
  }

  void onCompanyAndTitleCheckboxChanged(bool bNewValue) {
    log("onCompanyAndTitleCheckboxChanged: called, bNewValue " + bNewValue.toString());
    arrbFieldSelections[FIELD_COMPANYANDTITLE] = bNewValue;
    saveFieldSelections(true);
  }

  void onMessengersCheckboxChanged(bool bNewValue) {
    log("onMessengersCheckboxChanged: called, bNewValue " + bNewValue.toString());
    arrbFieldSelections[FIELD_MESSENGERS] = bNewValue;
    saveFieldSelections(true);
  }

  void onAvatarCheckboxChanged(bool bNewValue) {
    log("onAvatarCheckboxChanged: called, bNewValue " + bNewValue.toString());
    arrbFieldSelections[FIELD_AVATAR] = bNewValue;
    saveFieldSelections(true);
  }

  void onDatesCheckboxChanged(bool bNewValue) {
    log("onDatesCheckboxChanged: called, bNewValue " + bNewValue.toString());
    arrbFieldSelections[FIELD_DATES] = bNewValue;
    saveFieldSelections(true);
  }



  static const ROWHEIGHT = 25.0;
  static const TEXTBOXWIDTH = 225.0;
  static const TEXTSIZE = 17.0;
  static const BEFORECHECKBOX = 5.0;
  static const AFTERCHECKBOX = 2.0;

  @override
  Widget build(BuildContext context) {
    getStoredSettings(); // need to wait for it, but can't !!!
    //Future.wait(getStoredSettings());   // illegal ?
    //final int number = waitFor<int>(getStoredSettings());

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _scanFieldsOfAllContacts(),
              child: Text("Select Unused Fields"),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green)),
            ),
            SizedBox(height: 10),
            Container(
              height: ROWHEIGHT,
              child: Row(
                children: <Widget>[
                  SizedBox(width: BEFORECHECKBOX), //SizedBox
                  Checkbox(
                    value: arrbFieldSelections[FIELD_PHONES],
                    onChanged: (bool value) {
                      setState(() {
                        onPhonesCheckboxChanged(value);
                      });
                    },
                  ), //Checkbox
                  SizedBox(width: AFTERCHECKBOX), //SizedBox
                  Text(
                    'Faxes and Secondary Phones',
                    style: TextStyle(fontSize: TEXTSIZE),
                  ), //Text
                ], //<Widget>[]
              ), //Row
            ),
            SizedBox(height: 5),
            Container(
              height: ROWHEIGHT,
              width: TEXTBOXWIDTH,
              child: TextFormField(
                key: keyPhoneNumberTemplate,
                onChanged: _changedPhoneNumberTemplate,
                controller: phoneNumberTemplateController,
                maxLines: 1,
                initialValue: sPhoneNumberTemplate,
                decoration: new InputDecoration(
                  labelText: 'Phone number template',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 5.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.greenAccent, width: 5.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: ROWHEIGHT,
              child: Row(
                children: <Widget>[
                  SizedBox(width: BEFORECHECKBOX), //SizedBox
                  Checkbox(
                    value: arrbFieldSelections[FIELD_EMAILS],
                    onChanged: (bool value) {
                      setState(() {
                        onEmailsCheckboxChanged(value);
                      });
                    },
                  ), //Checkbox
                  SizedBox(width: AFTERCHECKBOX), //SizedBox
                  Text(
                    'Secondary Emails',
                    style: TextStyle(fontSize: TEXTSIZE),
                  ), //Text
                ], //<Widget>[]
              ), //Row
            ),
            SizedBox(height: 5),
            Container(
              height: ROWHEIGHT,
              width: TEXTBOXWIDTH,
              child: TextFormField(
                key: keyEmailAddressTemplate,
                onChanged: _changedEmailAddressTemplate,
                maxLines: 1,
                initialValue: sEmailAddressTemplate,
                controller: emailAddressTemplateController,
                decoration: new InputDecoration(
                  labelText: 'Email address template',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 5.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.greenAccent, width: 5.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: ROWHEIGHT,
              child: Row(
                children: <Widget>[
                  SizedBox(width: BEFORECHECKBOX), //SizedBox
                  Checkbox(
                    value: arrbFieldSelections[FIELD_COMPANYANDTITLE],
                    onChanged: (bool value) {
                      setState(() {
                        onCompanyAndTitleCheckboxChanged(value);
                      });
                    },
                  ), //Checkbox
                  SizedBox(width: AFTERCHECKBOX), //SizedBox
                  Text(
                    'Company and Title',
                    style: TextStyle(fontSize: TEXTSIZE),
                  ), //Text
                ], //<Widget>[]
              ), //Row
            ),
            SizedBox(height: 10),
            Container(
              height: ROWHEIGHT,
              child: Row(
                children: <Widget>[
                  SizedBox(width: BEFORECHECKBOX), //SizedBox
                  Checkbox(
                    value: arrbFieldSelections[FIELD_POSTALADDRESSES],
                    onChanged: (bool value) {
                      setState(() {
                        onAddressesCheckboxChanged(value);
                      });
                    },
                  ), //Checkbox
                  SizedBox(width: AFTERCHECKBOX), //SizedBox
                  Text(
                    'Postal Addresses',
                    style: TextStyle(fontSize: TEXTSIZE),
                  ), //Text
                ], //<Widget>[]
              ), //Row
            ),
            SizedBox(height: 10),
            Container(
              height: ROWHEIGHT,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: BEFORECHECKBOX,
                  ), //SizedBox
                  /** Checkbox Widget **/
                  Checkbox(
                    value: arrbFieldSelections[FIELD_MESSENGERS],
                    onChanged: (bool value) {
                      setState(() {
                        onMessengersCheckboxChanged(value);
                      });
                    },
                  ), //Checkbox
                  SizedBox(width: AFTERCHECKBOX), //SizedBox
                  Text(
                    'Messengers',
                    style: TextStyle(fontSize: TEXTSIZE),
                  ), //Text
                ], //<Widget>[]
              ), //Row
            ),
            SizedBox(height: 10),
            Container(
              height: ROWHEIGHT,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: BEFORECHECKBOX,
                  ), //SizedBox
                  /** Checkbox Widget **/
                  Checkbox(
                    value: arrbFieldSelections[FIELD_AVATAR],
                    onChanged: (bool value) {
                      setState(() {
                        onAvatarCheckboxChanged(value);
                      });
                    },
                  ), //Checkbox
                  SizedBox(width: AFTERCHECKBOX), //SizedBox
                  Text(
                    'Avatar',
                    style: TextStyle(fontSize: TEXTSIZE),
                  ), //Text
                ], //<Widget>[]
              ), //Row
            ),
            SizedBox(height: 10),
            Container(
              height: ROWHEIGHT,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: BEFORECHECKBOX,
                  ), //SizedBox
                  /** Checkbox Widget **/
                  Checkbox(
                    value: arrbFieldSelections[FIELD_DATES],
                    onChanged: (bool value) {
                      setState(() {
                        onDatesCheckboxChanged(value);
                      });
                    },
                  ), //Checkbox
                  SizedBox(width: AFTERCHECKBOX), //SizedBox
                  Text(
                    'Dates: Birthday, Anniversary',
                    style: TextStyle(fontSize: TEXTSIZE),
                  ), //Text
                ], //<Widget>[]
              ), //Row
            ),
            SizedBox(
              height: 25,
            ),
            ElevatedButton(
              onPressed: () => _setFieldsOfAllContacts(true),
              child: Text("Fill Selected Fields"),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.orange)),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () => _setFieldsOfAllContacts(true),
              child: Text("Clear Selected Fields"),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.pink)),
            ),
          ],
        ),
      ),
    );
  }
}
