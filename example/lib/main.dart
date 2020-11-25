import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libphonenumber/libphonenumber.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _textController = TextEditingController();
  bool _isValid = false;
  String _normalized = '';
  RegionInfo _regionInfo;
  String _carrierName = '';
  String _formatted = '';
  String _regionIso = 'US';
  TextEditingController _regionIsoController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _regionIsoController = TextEditingController(text: _regionIso);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  _showDetails() async {
    var s = _textController.text;

    bool isValid = await PhoneNumberUtil.isValidPhoneNumber(phoneNumber: s, isoCode: _regionIso);
    String normalizedNumber = await PhoneNumberUtil.normalizePhoneNumber(phoneNumber: s, isoCode: _regionIso);
    RegionInfo regionInfo = await PhoneNumberUtil.getRegionInfo(phoneNumber: s, isoCode: _regionIso);
    String carrierName =
        await PhoneNumberUtil.getNameForNumber(phoneNumber: s, isoCode: 'US');
    String formatted = await PhoneNumberUtil.formatPhone(phone: s, regionIsoCode: _regionIso);
    setState(() {
      _isValid = isValid;
      _normalized = normalizedNumber;
      _regionInfo = regionInfo;
      _carrierName = carrierName;
      _formatted = formatted;
    });
  }

  @override
  Widget build(BuildContext context) {
    var phoneText = Padding(
      padding: EdgeInsets.all(16.0),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: "Phone Number",
        ),
        controller: _textController,
        keyboardType: TextInputType.phone,
      ),
    );

    var submitButton = MaterialButton(
      color: Colors.blueAccent,
      textColor: Colors.white,
      onPressed: _showDetails,
      child: Text('Show Details'),
    );

    var outputTexts = Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Is Valid?'),
            Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Text(
                _isValid ? 'YES' : 'NO',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('E164 Format:'),
            Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Text(
                _normalized,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Formatted:'),
            Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Text(
                _formatted,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Region Info:'),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 12.0),
                child: Text(
                  'Prefix=${_regionInfo?.regionPrefix}, ISO=${_regionInfo?.isoCode}, Formatted=${_regionInfo?.nationalFormat}, Valid=${_regionInfo?.isValid}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Region Code:'),
            Container(
              width: 80,
              padding: EdgeInsets.only(left: 12.0),
              child: TextField(
                controller: _regionIsoController,
                onChanged: (val) {
                  setState(() {
                    _regionIso = val;
                  });
                },
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Carrier'),
            Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Text(
                'Carrier Name=${_carrierName}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Plugin example app'),
        ),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              phoneText,
              submitButton,
              Padding(padding: EdgeInsets.all(10.0)),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Details for ${_textController.text}',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ),
              outputTexts,
            ],
          ),
        ),
      ),
    );
  }
}
