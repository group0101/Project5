import 'package:flutter/material.dart';
import 'package:blood_share/Custom_Widgets/expansion_tile.dart';

// blood donation info page
class InfoTab extends StatefulWidget {
  @override
  _InfoTabState createState() => _InfoTabState();
}

class _InfoTabState extends State<InfoTab> {
  // blood group compatibiity
  List<Map<String, dynamic>> bloodGroups = [
    {
      "bloodGroup": "O+",
      "percentage": "37%",
      "donate": ["O+", "A+", "B+", "AB+"],
      "recieve": ["O+", "O-"],
    },
    {
      "bloodGroup": "O-",
      "percentage": "6%",
      "donate": ["Everyone"],
      "recieve": ["O-"],
    },
    {
      "bloodGroup": "A+",
      "percentage": "34%",
      "donate": ["A+", "AB+"],
      "recieve": ["O+", "O-", "A+", "A-"],
    },
    {
      "bloodGroup": "A-",
      "percentage": "6%",
      "donate": ["A+", "A-", "AB+", "AB-"],
      "recieve": ["O-", "A-"],
    },
    {
      "bloodGroup": "B+",
      "percentage": "10%",
      "donate": ["B+", "AB+"],
      "recieve": ["O+", "O-", "B+", "B-"],
    },
    {
      "bloodGroup": "B-",
      "percentage": "2%",
      "donate": ["B+", "B-", "AB+", "AB-"],
      "recieve": ["O-", "B-"],
    },
    {
      "bloodGroup": "AB+",
      "percentage": "4%",
      "donate": ["AB+"],
      "recieve": ["Everyone"],
    },
    {
      "bloodGroup": "AB-",
      "percentage": "1%",
      "donate": ["AB+", "AB-"],
      "recieve": ["O-", "A-", "B-", "AB-"],
    },
  ];

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    Color _primaryColor = Theme.of(context).primaryColor;
    Color _cardColor = Theme.of(context).dividerColor;

    return ListView(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          child: Text(
            " Note Before Donating Blood",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: _size.width * 0.055,
              color: _primaryColor,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 16.0,
          ),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                ''' As a donor, it is your responsibility to ensure the quality of blood you're donating.''',
                style: TextStyle(
                  fontSize: _size.width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '''
                \n\u{2605} You must be in good health at the time you donate.
                      \n\u{2605} You must be above 18 years of age.
                      \n\u{2605} You should not be underweight.Usually donors weighing more than 45-50kg are acceptable.
                      \n\u{2605} You should not be suffering from any infectious diseases (such as cold, flu, sore throat, cold sore, stomach bug or any other infection.) or chronic diseases (such as diabetes).
                      \n\u{2605} You must not donate blood If you do not meet the minimum haemoglobin level for blood donation.
                      \n\u{2605} If you have recently had a tattoo or body piercing you cannot donate for 6 months from the date of the procedure.
                      \n\u{2605} If the body piercing was performed by a registered health professional and any inflammation has settled completely, you can donate blood after 12 hours.
                      \n\u{2605} You should not have taken any intoxicating drugs, orally or otherwise, within 48 hours prior to donating blood.
                      \n\u{2605} If you have visited the dentist for a minor procedure you must wait 24 hours before donating; for major work wait a month.
                      \n\u{2605} You should not have high blood pressure.
                      \n\u{2605} You should not be pregnant.
                      ''',
                style: TextStyle(
                  fontSize: _size.width * 0.045,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8.0),
          padding: const EdgeInsets.all(8.0),
          child: Text(
            " Importance of Blood Donation",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: _size.width * 0.055,
              color: _primaryColor,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 16.0,
          ),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                '''Blood is the most essential thing for human life. It is an in human body fluid that delivers necessary substances such as nutrients and oxygen to the cells. Blood brings oxygen and nutrients to all the parts of the body so they can keep working. Blood carries carbon dioxide and other waste materials to the lungs, kidneys, and digestive system to be removed from the body. Blood also fights infections and carries hormones around the body.''',
                style: TextStyle(
                  fontSize: _size.width * 0.045,
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Text(
                  '''\nBlood transfusion is needed for:''',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: _size.width * 0.045,
                  ),
                ),
              ),
              Text(
                '''\n\u{2605} women with complications of pregnancy, such as ectopic pregnancies and haemorrhage before, during or after childbirth.\n\u{2605} children with severe anaemia often resulting from malaria or malnutrition.\n\u{2605} people with severe trauma following man-made and natural disasters.\n\u{2605} many complex medical and surgical procedures and cancer patients.\n\u{2605} It is also needed for regular transfusions for people with conditions such as thalassaemia and sickle cell disease and is used to make products such as clotting factors for people with haemophilia.''',
                style: TextStyle(
                  fontSize: _size.width * 0.045,
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Text(
                  '''\nHealth Benefits Of Donating Blood:''',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: _size.width * 0.045,
                  ),
                ),
              ),
              Text(
                '''\nBlood donation not only makes the receiver’s life good but also helps the donor to maintain good health. The health benefits of donating blood are mentioned below.
                    \n\u{2605} PREVENTS HEMOCHROMATOSIS
                    \nHealth benefits of blood donation include reduced risk of hemochromatosis. Hemochromatosis is a health condition that arises due to excess absorption of iron by the body. This may be inherited or may be caused due to alcoholism, anemia or other disorders. Regular blood donation may help in reducing iron overload. Make sure that the donor meets the standard blood donation eligibility criteria.
                    \n\u{2605} ANTI-CANCER BENEFITS
                    \nBlood donation helps in lowering the risk of cancer. By donating blood the iron stores in the body are maintained at healthy levels. A reduction in the iron level in the body is linked with low cancer risk.
                    \n\u{2605} MAINTAINS HEALTHY HEART & LIVER
                    \nBlood donation is beneficial in reducing the risk of heart and liver ailments caused by the iron overload in the body. Intake of iron-rich diet may increase the iron levels in the body, and since only limited proportions can be absorbed, excess iron gets stored in heart, liver, and pancreas. This, in turn, increases the risk of cirrhosis, liver failure, damage to the pancreas, and heart abnormalities like irregular heart rhythms. Blood donation helps in maintaining the iron levels and reduces the risk of various health ailments.
                    \n\u{2605} WEIGHT LOSS
                    \nRegular blood donation reduces the weight of the donors.  This is helpful to those who are obese and are at higher risk of cardiovascular diseases and other health disorders. However, blood donation should not be very frequent and you may consult your doctor before donating blood to avoid any health issues.
                    \n\u{2605} STIMULATES BLOOD CELL PRODUCTION
                    \nAfter donating blood, the body works to replenish the blood loss. This stimulates the production of new blood cells and in turn, helps in maintaining good health.
                    ''',
                style: TextStyle(
                  fontSize: _size.width * 0.045,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          child: Text(
            " Types of Donation",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: _size.width * 0.055,
              color: _primaryColor,
            ),
          ),
        ),
        CustomExpansionTile(
          expand: false,
          title: "Whole Blood",
          info: '''Whole blood is the most common type of donation.
            \nBlood from one donation can be divided into two components: red blood cells and plasma.
            \nThe average adult has about 10 pints of blood, but a typical whole-blood donation is only 1 pint.
            \nRed blood cells have a short shelf life. They only last for 6 weeks (42 days).
            \nDonating whole blood takes only about 10-15 minutes.
            \nYou can donate whole blood every 56 days and we encourage you to donate as often as possible.''',
        ),
        CustomExpansionTile(
          expand: false,
          title: "Platelets",
          info:
              '''Platelets are small, disc-shaped cells that aid in blood clotting.
                \nThey are donated most often to cancer patients, organ recipients and those undergoing heart surgeries.
                \nPatients who need platelets often require multiple transfusions. That's why it's so important to donate as often as you can.
                \nPlatelets do not last long. They have a shelf life of just 5 days.
                \nThose who have A, A-negative, B, B-negative, AB or AB-negative blood types are strongly encouraged to donate platelets.
                \nDonors are connected to a machine that separates platelets and some plasma from the blood and returns the red cells (and most of the plasma) back to the donor.
                \nDonating platelets takes approximately 90 minutes.
                \nYou can donate platelets every 7 days, up to 24 times a year.''',
        ),
        CustomExpansionTile(
          expand: false,
          title: "Plasma",
          info:
              '''Plasma is the light yellow liquid in your blood that makes up 50% of total blood volume.
                \nIt contains proteins that help control bleeding and fight infections.
                \nIt's used to treat various types of bleeding disorders. It's also given to patients who have suffered major traumatic injuries.
                \nPlasma can be frozen for up to a year.
                \nIf you have type AB blood, you are a universal plasma donor.
                \nPeople who have blood types AB, AB-negative, A, A-negative, B or B-negative also are ideal donors for platelets.
                \nDonors are connected to a machine that separates out plasma and returns red cells to the body.
                \nPlasma donation takes about 40 minutes. You may donate plasma every 28 days.''',
        ),
        CustomExpansionTile(
          expand: false,
          title: "Double Red Cells",
          info:
              '''Red blood cells are the most commonly transfused blood component.
                \nDonors are hooked up to a machine that collects the red cells and returns most of the plasma and platelets to the body.
                \nDonations from type O donors are crucial to maintaining blood levels in the body.
                \nDouble red-cell donors with type O, O-negative, B or B-negative types, as well as donors with Rh-negative blood are in short supply.
                \nYou must meet higher hemoglobin and height-to-weight requirements to donate double red cells.
                \nDouble red cell donations take approximately 40 minutes.
                \nYou can donate double red blood cells once every 16 weeks (112 days).''',
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          child: Text(
            " Blood Type Compatibility",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: _size.width * 0.055,
              color: _primaryColor,
            ),
          ),
        ),
        Container(
          height: _size.width * 0.6,
          child: ListView.builder(
            primary: false,
            itemCount: bloodGroups.length,
            clipBehavior: Clip.hardEdge,
            itemExtent: _size.width * 0.7,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8.0),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Material(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(10),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: () {},
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          flex: 2,
                          child: Text(
                            bloodGroups[index]["bloodGroup"],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: _size.width * 0.15,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            "can Donate to:",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: _size.width * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            "${bloodGroups[index]["donate"].join(", ")}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: _size.width * 0.05,
                              color: _primaryColor,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            "can Recieve from:",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: _size.width * 0.05,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            "${bloodGroups[index]["recieve"].join(", ")}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: _size.width * 0.05,
                              color: _primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
