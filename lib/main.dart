//import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';

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
  String sLabel = "";
  String sPhoneNumberTemplate = "";
  String sEmailAddressTemplate = "";
  String sStreetTemplate = "";
  String sCityTemplate = "";
  String sRegionTemplate = "";
  var arrbFieldSelections = [false, false, false]; // aray of bools
  static const FIELD_COMPANYANDTITLE = 0;
  static const FIELD_AVATAR = 1;
  static const FIELD_DATES = 2;

  Key keyLabel = Key("Label");
  Key keyPhoneNumberTemplate = Key("PhoneNumberTemplate");
  Key keyEmailAddressTemplate = Key("EmailAddressTemplate");
  Key keyStreetTemplate = Key("StreetTemplate");
  Key keyCityTemplate = Key("CityTemplate");
  Key keyRegionTemplate = Key("RegionTemplate");

  TextEditingController labelController = TextEditingController();
  TextEditingController phoneNumberTemplateController = TextEditingController();
  TextEditingController emailAddressTemplateController =
      TextEditingController();
  TextEditingController streetTemplateController = TextEditingController();
  TextEditingController cityTemplateController = TextEditingController();
  TextEditingController regionTemplateController = TextEditingController();
  Checkbox wCompany = null;
  Checkbox wAvatar = null;
  Checkbox wDate = null;

  SharedPreferences prefs = null;

  Future<void> getStoredSettings() async {
    log("getStoredSettings: called");

    if (prefs == null)
      prefs = await SharedPreferences.getInstance();

    sPhoneNumberTemplate = prefs.getString('sPhoneNumberTemplate');
    if (sPhoneNumberTemplate == null) {
      sLabel = "private";
      sPhoneNumberTemplate = "+2134567nnnn";
      sEmailAddressTemplate = "FIRST.LAST@example.com";
      sStreetTemplate = "123 FIRST St";
      sCityTemplate = "New York";
      sRegionTemplate = "NY";
      arrbFieldSelections = [false, false, false];
      savePhoneNumberTemplate();
      saveEmailAddressTemplate();
      saveStreetTemplate();
      saveCityTemplate();
      saveRegionTemplate();
      saveCompanySelection(true);
      saveAvatarSelection(true);
      saveDateSelection(true);
    } else {
      sLabel = prefs.getString('sLabel');
      sPhoneNumberTemplate = prefs.getString('sPhoneNumberTemplate');
      sEmailAddressTemplate = prefs.getString('sEmailAddressTemplate');
      sStreetTemplate = prefs.getString('sStreetTemplate');
      sCityTemplate = prefs.getString('sCityTemplate');
      sRegionTemplate = prefs.getString('sRegionTemplate');
      arrbFieldSelections[0] = prefs.getBool('bFieldSelection0');
      arrbFieldSelections[1] = prefs.getBool('bFieldSelection1');
      arrbFieldSelections[2] = prefs.getBool('bFieldSelection2');
      log("getStoredSettings: retrieved " +
          arrbFieldSelections[0].toString() +
          arrbFieldSelections[1].toString() +
          arrbFieldSelections[2].toString());
    }

    labelController.text = sLabel;
    phoneNumberTemplateController.text = sPhoneNumberTemplate;
    emailAddressTemplateController.text = sEmailAddressTemplate;
    streetTemplateController.text = sStreetTemplate;
    cityTemplateController.text = sCityTemplate;
    regionTemplateController.text = sRegionTemplate;
  }

  void saveCompanySelection(bool bIgnored) async {
    log("saveCompanySelection: called");

    //wCompany.value = true;
    await prefs.setBool("bFieldSelection" + FIELD_COMPANYANDTITLE.toString(), arrbFieldSelections[FIELD_COMPANYANDTITLE]);
  }

  void saveAvatarSelection(bool bIgnored) async {
    log("saveAvatarSelection: called");

    await prefs.setBool("bFieldSelection" + FIELD_AVATAR.toString(), arrbFieldSelections[FIELD_AVATAR]);
  }

  void saveDateSelection(bool bIgnored) async {
    log("saveDateSelection: called");

    await prefs.setBool("bFieldSelection" + FIELD_DATES.toString(), arrbFieldSelections[FIELD_DATES]);
  }

  void saveLabel() async {
    log("saveLabel: called");

    await prefs.setString("sLabel", sLabel);
  }

  void savePhoneNumberTemplate() async {
    log("savePhoneNumberTemplate: called");

    await prefs.setString("sPhoneNumberTemplate", sPhoneNumberTemplate);
  }

  void saveEmailAddressTemplate() async {
    log("saveEmailAddressTemplate: called");

    await prefs.setString("sEmailAddressTemplate", sEmailAddressTemplate);
  }

  void saveStreetTemplate() async {
    log("saveStreetTemplate: called");

    await prefs.setString("sStreetTemplate", sStreetTemplate);
  }

  void saveCityTemplate() async {
    log("saveCityTemplate: called");

    await prefs.setString("sCityTemplate", sCityTemplate);
  }

  void saveRegionTemplate() async {
    log("saveRegionTemplate: called");

    await prefs.setString("sRegionTemplate", sRegionTemplate);
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

  String generatePostalAddress(String sLastName, String sFirstName) {
    return (sStreetTemplate
            .replaceAll("FIRST", sFirstName)
            .replaceAll("LAST", sLastName)) +
        ", " +
        (sCityTemplate
            .replaceAll("FIRST", sFirstName)
            .replaceAll("LAST", sLastName)) +
        " " +
        (sRegionTemplate
            .replaceAll("FIRST", sFirstName)
            .replaceAll("LAST", sLastName));
  }

  Future<void> _scanFieldsOfAllContacts() async {
    log("_scanFieldsOfAllContacts: about to call Permission.contacts.request");
    PermissionStatus permission = await Permission.contacts.request();
    if (!permission.isGranted) {
      log("_scanFieldsOfAllContacts: no permission");
    } else {
      // Either the permission was already granted before or the user just granted it.
      arrbFieldSelections = [
        true,
        true,
        true,
      ];
      log("_scanFieldsOfAllContacts: about to call ContactsService.getContacts");
      Iterable<Contact> iContacts = await ContactsService.getContacts();
      log("_scanFieldsOfAllContacts: iContacts.length " +
          iContacts.length.toString());
      for (var c in iContacts) {
        log("_scanFieldsOfAllContacts: identifier " + c.identifier);
        log("_scanFieldsOfAllContacts: givenName " + c.givenName);
        Iterable<Item> iEmails = c.emails;
        for (var e in iEmails) {
          log("_scanFieldsOfAllContacts: e.label " +
              e.label +
              ", e.value " +
              e.value);
        }
        Iterable<Item> iPhones = c.phones;
        for (var p in iPhones) {
          log("_scanFieldsOfAllContacts: p.label " +
              p.label +
              ", p.value " +
              p.value);
        }
        Iterable<PostalAddress> iAddresses = c.postalAddresses;
        for (var a in iAddresses) {
          log("_scanFieldsOfAllContacts: a.label " +
              a.label +
              ", a.city " +
              a.city);
        }
        String sCompany = c.company;
        if (c.company != null)
          arrbFieldSelections[FIELD_COMPANYANDTITLE] = false;
        String sTitle = c.jobTitle;
        if (c.jobTitle != null)
          arrbFieldSelections[FIELD_COMPANYANDTITLE] = false;
        //List<Uint8> uAvatar = c.avatar;
        //Uint8List lAvatar = c.avatar;
        if (c.avatar != null) {
          // https://api.flutter.dev/flutter/painting/MemoryImage-class.html
          var _image = MemoryImage(c.avatar);
          log("_scanFieldsOfAllContacts: _image " + _image.toString());
          arrbFieldSelections[FIELD_AVATAR] = false;
        }
      }
    }
    log("_scanFieldsOfAllContacts: setting " +
      arrbFieldSelections[0].toString() +
      arrbFieldSelections[1].toString() +
      arrbFieldSelections[2].toString());
    saveCompanySelection(true);
    saveAvatarSelection(true);
    saveDateSelection(true);
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
      Iterable<Contact> iContacts = await ContactsService.getContacts();
      for (var c in iContacts) {
        // remove any existing fields that match settings
        List<Item> iEmails = c.emails.toList();
        log("_setFieldsOfAllContacts: emails before remove " + iEmails.toString());
        iEmails.removeWhere((element) => (element.label == sLabel));
        log("_setFieldsOfAllContacts: emails after remove " + iEmails.toString());
        if (bSet) {
          var sEmail = generateEmailAddress(c.familyName, c.givenName);
          iEmails.add(Item(label: sLabel, value: sEmail));
          log("_setFieldsOfAllContacts: emails after add " + iEmails.toString());
        }
        c.emails = iEmails;
        log("_setFieldsOfAllContacts: about to call ContactsService.updateContact");
        await ContactsService.updateContact(c);
      }
    }
    log("_setFieldsOfAllContacts: about to return");
  }

  // this gets called every time a char gets changed in the field
  void _changedLabel(String sNewValue) {
    log("_changedLabel: called, " + sNewValue);
    sLabel = sNewValue;

    saveLabel();
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

  // this gets called every time a char gets changed in the field
  void _changedStreetTemplate(String sNewValue) {
    log("_changedStreetTemplate: called, " + sNewValue);
    sStreetTemplate = sNewValue;

    saveStreetTemplate();
  }

  // this gets called every time a char gets changed in the field
  void _changedCityTemplate(String sNewValue) {
    log("_changedCityTemplate: called, " + sNewValue);
    sCityTemplate = sNewValue;

    saveCityTemplate();
  }

  // this gets called every time a char gets changed in the field
  void _changedRegionTemplate(String sNewValue) {
    log("_changedRegionTemplate: called, " + sNewValue);
    sRegionTemplate = sNewValue;

    saveRegionTemplate();
  }

  void onCompanyAndTitleCheckboxChanged(bool bNewValue) {
    log("onCompanyAndTitleCheckboxChanged: called, bNewValue " +
        bNewValue.toString());
    arrbFieldSelections[FIELD_COMPANYANDTITLE] = bNewValue;
    saveCompanySelection(true);
  }

  void onAvatarCheckboxChanged(bool bNewValue) {
    log("onAvatarCheckboxChanged: called, bNewValue " + bNewValue.toString());
    arrbFieldSelections[FIELD_AVATAR] = bNewValue;
    saveAvatarSelection(true);
  }

  void onDatesCheckboxChanged(bool bNewValue) {
    log("onDatesCheckboxChanged: called, bNewValue " + bNewValue.toString());
    arrbFieldSelections[FIELD_DATES] = bNewValue;
    saveDateSelection(true);
  }

  static const ROWHEIGHT = 25.0;
  static const TEXTBOXWIDTH = 225.0;
  static const TEXTSIZE = 17.0;
  static const BEFORECHECKBOX = 10.0;
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
            Container(
              height: ROWHEIGHT,
              width: TEXTBOXWIDTH,
              child: TextFormField(
                key: keyLabel,
                onChanged: _changedLabel,
                controller: labelController,
                maxLines: 1,
                decoration: new InputDecoration(
                  labelText: 'Label for all fields',
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
            SizedBox(height: 15),
            Container(
              height: ROWHEIGHT,
              width: TEXTBOXWIDTH,
              child: TextFormField(
                key: keyPhoneNumberTemplate,
                onChanged: _changedPhoneNumberTemplate,
                controller: phoneNumberTemplateController,
                maxLines: 1,
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
            SizedBox(height: 15),
            Container(
              height: ROWHEIGHT,
              width: TEXTBOXWIDTH,
              child: TextFormField(
                key: keyEmailAddressTemplate,
                onChanged: _changedEmailAddressTemplate,
                maxLines: 1,
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
            SizedBox(height: 15),
            Container(
              height: ROWHEIGHT,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 10), //SizedBox
                    Container(
                      width: 135,
                      child: TextFormField(
                        key: keyStreetTemplate,
                        onChanged: _changedStreetTemplate,
                        maxLines: 1,
                        controller: streetTemplateController,
                        decoration: new InputDecoration(
                          labelText: 'Street',
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.red, width: 5.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.greenAccent, width: 5.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 5), //SizedBox
                    Container(
                      width: 80,
                      child: TextFormField(
                        key: keyCityTemplate,
                        onChanged: _changedCityTemplate,
                        maxLines: 1,
                        controller: cityTemplateController,
                        decoration: new InputDecoration(
                          labelText: 'City',
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.red, width: 5.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.greenAccent, width: 5.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 5), //SizedBox
                    Container(
                      width: 70,
                      child: TextFormField(
                        key: keyRegionTemplate,
                        onChanged: _changedRegionTemplate,
                        maxLines: 1,
                        controller: regionTemplateController,
                        decoration: new InputDecoration(
                          labelText: 'Region',
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.red, width: 5.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.greenAccent, width: 5.0),
                          ),
                        ),
                      ),
                    ),
                  ]),
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () => _scanFieldsOfAllContacts(),
              child: Text("Scan Fields of All Contacts"),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.lightGreen)),
            ),
            SizedBox(height: 15),
            Container(
              height: ROWHEIGHT,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: BEFORECHECKBOX,
                  ), //SizedBox
                  /** Checkbox Widget **/
                  wCompany = Checkbox(
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
            SizedBox(height: 15),
            Container(
              height: ROWHEIGHT,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: BEFORECHECKBOX,
                  ), //SizedBox
                  /** Checkbox Widget **/
                  wAvatar = Checkbox(
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
            SizedBox(height: 15),
            Container(
              height: ROWHEIGHT,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: BEFORECHECKBOX,
                  ), //SizedBox
                  /** Checkbox Widget **/
                  wDate = Checkbox(
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
              height: 40,
            ),
            ElevatedButton(
              onPressed: () => _setFieldsOfAllContacts(true),
              child: Text("Fill Fields"),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.orange)),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () => _setFieldsOfAllContacts(false),
              child: Text("Clear Fields"),
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
