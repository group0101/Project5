import 'package:flutter/material.dart';
import 'package:blood_share/Services/chart.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

// Prediction of blood donation
class MLPrediction extends StatefulWidget {
  final double recency, frequency, time;
  MLPrediction({
    @required this.recency,
    @required this.frequency,
    @required this.time,
  });
  @override
  _MLPredictionState createState() => _MLPredictionState();
}

class _MLPredictionState extends State<MLPrediction> {
  double _will, _wont;
  Interpreter _interpreter;

  void initState() {
    // TODO: implement initState
    super.initState();
    // load ML interpreter from tflite model
    // from assets
    Interpreter.fromAsset('blood-donation-predictor.tflite')
        .then((Interpreter interpreter) {
      _interpreter = interpreter;
      if (widget.frequency != null &&
          widget.recency != null &&
          widget.time != null) _predict();
    });
  }

  /// predict probability of donation with tflite model
  void _predict() {
    var input = [
      [widget.recency, widget.frequency, widget.time],
    ];
    var output = List(1 * 2).reshape([1, 2]);

    _interpreter.run(input, output);

    setState(() {
      _wont = output[0][0];
      _will = output[0][1];
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _interpreter.close();
  }

  @override
  void didUpdateWidget(covariant MLPrediction oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.frequency != null &&
        widget.recency != null &&
        widget.time != null) _predict();
  }

  @override
  Widget build(BuildContext context) {
    return _will != null && _wont != null
        ? SizedBox(
            height: 350,
            child: Stack(
              children: [
                GaugeChart.withPredictions(_will, _wont),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Donation Prediction',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Will Donate : ${(_will * 100).toStringAsFixed(3)} %',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 45, 199, 118),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Won\'t Donate : ${(_wont * 100).toStringAsFixed(3)} %',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 255, 23, 68),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : SizedBox();
  }
}

// temporary page for donation chart
class MLPredictionTempPage extends StatefulWidget {
  @override
  _MLPredictionTempPageState createState() => _MLPredictionTempPageState();
}

class _MLPredictionTempPageState extends State<MLPredictionTempPage> {
  double _recency, _frequency, _time;
  bool _predict = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Color _primary = Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: Colors.transparent,
        height: double.infinity,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (String r) {
                      _recency = double.parse(r);
                    },
                    validator: (String r) {
                      double rec = double.tryParse(r);
                      if (rec == null) return "Enter a Number";
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Recency",
                      labelText: "Last Donated (in months)",
                      fillColor: Colors.blue,
                      suffixIcon: Icon(
                        Icons.calendar_today,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (String r) {
                      _frequency = double.parse(r);
                    },
                    validator: (String r) {
                      // if()
                      double rec = double.tryParse(r);
                      if (rec == null) return "Enter a Number";
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Frequency",
                      labelText: "No of Donations",
                      fillColor: Colors.blue,
                      suffixIcon: Icon(
                        Icons.confirmation_number,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (String r) {
                      _time = double.parse(r);
                    },
                    validator: (String r) {
                      double rec = double.tryParse(r);
                      if (rec == null) return "Enter a Number";
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Time",
                      labelText: "First Donated (in months)",
                      fillColor: Colors.blue,
                      suffixIcon: Icon(
                        Icons.calendar_today,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: FlatButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _predict = true;
                        });
                      }
                    },
                    child: Text(
                      "Get Probabilities",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    minWidth: double.infinity,
                    height: 50,
                    color: _primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // shape: StadiumBorder(),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                if (_predict)
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                    },
                    child: IgnorePointer(
                      child: MLPrediction(
                        frequency: _frequency,
                        recency: _recency,
                        time: _time,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
