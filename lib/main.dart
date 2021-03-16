//import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'dart:typed_data';

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
  Checkbox wCompany;
  Checkbox wAvatar;
  Checkbox wDate;

  SharedPreferences prefs;

  Future<void> getStoredSettings() async {
    log("getStoredSettings: called");

    if (prefs == null)
      prefs = await SharedPreferences.getInstance();

    sPhoneNumberTemplate = prefs.getString('sPhoneNumberTemplate');
    if (sPhoneNumberTemplate == null) {
      sLabel = "other";
      sPhoneNumberTemplate = "+2134567nnnn";
      sEmailAddressTemplate = "FIRST.LAST@example.com";
      sStreetTemplate = "123 FIRST St";
      sCityTemplate = "NY";
      sRegionTemplate = "NY";
      arrbFieldSelections = [false, false, false];
      saveLabel();
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
        .replaceAll("LAST", sLastName)
        .replaceAll(" ", "");
  }

  PostalAddress generatePostalAddress(String sLastName, String sFirstName) {
    PostalAddress a = new PostalAddress();
    a.street = sStreetTemplate
            .replaceAll("FIRST", sFirstName)
            .replaceAll("LAST", sLastName);
    a.city = sCityTemplate
            .replaceAll("FIRST", sFirstName)
            .replaceAll("LAST", sLastName);
    a.region = sRegionTemplate
            .replaceAll("FIRST", sFirstName)
            .replaceAll("LAST", sLastName);
    return a;
  }

  String generateCompany(String sLastName, String sFirstName) {
    if (sLastName != "")
      return sLastName + " Co.";
    if (sFirstName != "")
      return sFirstName + " Co.";
    return "Acme Corp.";
  }

  DateTime generateBirthday(String sLastName, String sFirstName) {
    int nLastName = 0;
    int nFirstName = 0;

    if (sLastName != "")
      nLastName = sLastName.codeUnitAt(sLastName.length-1);
    if (sFirstName != "")
      nFirstName = sFirstName.codeUnitAt(sFirstName.length-1);

    int nYear = 1960 + (nLastName % 40);
    int nMonth = (nFirstName % 12) + 1;
    int nDay = (nFirstName % 28) + 1;

    return new DateTime(nYear, nMonth, nDay);
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

        log("_setFieldsOfAllContacts: identifier " + c.identifier);
        String sFirstName = c.givenName;
        if (sFirstName == null)
          sFirstName = "";
        log("_setFieldsOfAllContacts: givenName " + sFirstName);
        String sLastName = c.familyName;
        if (sLastName == null)
          sLastName = "";
        log("_setFieldsOfAllContacts: familyName " + sLastName);

        if ((sLabel.length > 0) && (sPhoneNumberTemplate.length > 0)) {
          List<Item> lOldPhones = c.phones.toList();
          List<Item> lNewPhones = [];
          log("_setFieldsOfAllContacts: before remove sLabel " + sLabel + " == " + lOldPhones.length.toString());
          for (var p in lOldPhones) {
            log("_setFieldsOfAllContacts: old " + p.label + ", " + p.value);
            if (p.label != sLabel)
              lNewPhones.add(p);
          }
          log("_setFieldsOfAllContacts: phones after remove == " + lNewPhones.length.toString());
          if (bSet) {
            var sPhone = generatePhoneNumber(sLastName);
            lNewPhones.add(Item(label: sLabel, value: sPhone));
            log("_setFieldsOfAllContacts: phones after add " + lNewPhones.length.toString());
          }
          c.phones = lNewPhones;
        }

        if ((sLabel.length > 0) && (sEmailAddressTemplate.length > 0)) {
          List<Item> lOldEmails = c.emails.toList();
          List<Item> lNewEmails = [];
          log("_setFieldsOfAllContacts: before remove sLabel " + sLabel + " == " + lOldEmails.length.toString());
          for (var e in lOldEmails) {
            log("_setFieldsOfAllContacts: old " + e.label + ", " + e.value);
            if (e.label != sLabel)
              lNewEmails.add(e);
          }
          log("_setFieldsOfAllContacts: emails after remove == " + lNewEmails.length.toString());
          if (bSet) {
            var sEmail = generateEmailAddress(sLastName, sFirstName);
            lNewEmails.add(Item(label: sLabel, value: sEmail));
            log("_setFieldsOfAllContacts: emails after add " + lNewEmails.length.toString());
          }
          c.emails = lNewEmails;
        }

        if ((sLabel.length > 0) && (sStreetTemplate.length > 0) && (sCityTemplate.length > 0) && (sRegionTemplate.length > 0)) {
          List<PostalAddress> lOldAddresses = c.postalAddresses.toList();
          List<PostalAddress> lNewAddresses = [];
          log("_setFieldsOfAllContacts: before remove sLabel " + sLabel + " == " + lOldAddresses.length.toString());
          for (var a in lOldAddresses) {
            log("_setFieldsOfAllContacts: old " + a.label + ", " + a.street + ", " + a.city + ", " + a.region);
            if (a.label != sLabel)
              lNewAddresses.add(a);
          }
          log("_setFieldsOfAllContacts: addresses after remove == " + lNewAddresses.length.toString());
          if (bSet) {
            PostalAddress oAddress = generatePostalAddress(sLastName, sFirstName);
            lNewAddresses.add(PostalAddress(label: sLabel, street: oAddress.street, city: oAddress.city, region: oAddress.region));
            log("_setFieldsOfAllContacts: addresses after add " + lNewAddresses.length.toString());
          }
          c.postalAddresses = lNewAddresses;
        }

        if (arrbFieldSelections[FIELD_COMPANYANDTITLE]) {
          String sCompany = "";
          String sTitle = "";
          if (bSet) {
            sCompany = generateCompany(sLastName, sFirstName);
            log("_setFieldsOfAllContacts: sCompany " + sCompany);
            sTitle = "CEO";
          }
          c.company = sCompany;
          c.jobTitle = sTitle;
        }

        if (arrbFieldSelections[FIELD_AVATAR]) {
          // Android only: Get thumbnail for an avatar afterwards
          // (only necessary if `withThumbnails: false` is used)
          //Uint8List avatar = await ContactsService.getAvatar(contact);
          // https://api.dart.dev/stable/2.12.1/dart-typed_data/Uint8List-class.html
          // https://api.dart.dev/stable/2.12.1/dart-typed_data/dart-typed_data-library.html
        }

        if (arrbFieldSelections[FIELD_DATES]) {
          DateTime oBirthday;
          if (bSet) {
            oBirthday = generateBirthday(sLastName, sFirstName);
            log("_setFieldsOfAllContacts: oBirthday " + oBirthday.toString());
          }
          c.birthday = oBirthday;
          // doesn't work !!!
        }

        log("_setFieldsOfAllContacts: about to call ContactsService.updateContact");
        await ContactsService.updateContact(c);

        log("_setFieldsOfAllContacts: return after first");
        return;   // temp !!!
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
