import 'package:flutter/material.dart';
import 'package:myapp/result.dart';
import 'dart:convert';
import 'entities/footprint.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fx_stepper/fx_stepper.dart';


import 'main.dart';
import 'noti.dart';

class FootprintWidget extends StatefulWidget {
  const FootprintWidget({super.key});

  @override
  _FootprintWidgetState createState() => _FootprintWidgetState();
}

class _FootprintWidgetState extends State<FootprintWidget> {
  int _currentStep = 0;
  FxStepperType stepperType = FxStepperType.horizontal;

  //Essen
  List<String> choicesSaison = ['Weniger als ein Viertel', 'Etwa ein Viertel', 'Etwa die Hälfte', 'Etwa drei Viertel', 'Der Großteil ist saisonal'];
  List<String> choicesMilk = ['2-4 Mal täglich', '1-2 Mal täglich', '4-6 Mal pro Woche', '1-3 Mal pro Woche', 'Weniger als einmal pro Woche', 'Nie'];
  List<String> choicesEggs = ['Mehr als 2 Mal pro Tag', '5-6 Mal pro Woche', '3-4 Mal pro Woche', '1-2 Mal pro Woche', 'Nie'];
  List<String> choicesMeat = ['2-3 Mal pro Tag', 'Einmal täglich', '4-6 Mal pro Woche', '1-3 Mal pro Woche', 'Weniger als einmal pro Woche', 'Nie'];
  List<String> choicesFair = ['Gleich null', 'Etwa ein Viertel', 'Etwa die Hälfte', 'Etwa drei Viertel', 'Fast nur Label-Produkte'];
  List<String> choicesTrash = ['Mehrmals pro Woche', 'Gelegentlich', 'Quasi nie'];
  int choiceSaison = 0;
  int choiceMilk = 0;
  int choiceEggs = 0;
  int choiceMeat = 0;
  int choiceFair = 0;
  int choiceTrash = 0;

  //Mobilität
  List<String> choicesCar = ['Mehr als 30000km', '12500 - 30000km', '7500 - 12500km', '2000 - 7500km', 'Weniger als 2000km', '0km'];
  List<String> choicesFuel = ['Benzin/Diesel/Hybrid', 'Elektrisch', 'Erdgas', 'Biogas'];
  List<String> choicesFuelUse = ['Mehr als 12l/100km', '9 – 12l/100km', '4,5 – 6l/100km', 'Weniger als 4,5l/100km'];
  List<String> choicesOffi = ['Mehr als 600km', '360 - 600km', '240 - 360km', '80 - 240km','Weniger als 60km', 'Nie'];
  List<String> choicesPlane = ['über 50 Stunden/Jahr', '25 – 50 Stunden/Jahr', '15 – 25 Stunden/Jahr', '8 – 15 Stunden/Jahr','2 - 8 Stunden/Jahr', 'weniger als 2 Stunden/Jahr', 'Garnicht'];
  List<String> choicesCruise = ['mehr als 2 Wochen', '1 – 2 Wochen', '4 – 6 Tage', '1 – 3 Tage','Garnicht'];
  int choiceCar = 0;
  int choiceFuel = 0;
  int choiceFuelUse = 0;
  int choiceOffi = 0;
  int choicePlane = 0;
  int choiceCruise = 0;

  //Wohnen
  List<String> choicesHeiz = ['Erdöl', 'Erdgas', 'Fernwärme', 'Wärmepumpe','Holz'];
  List<String> choicesBaujahr = ['Baujahr vor 1980', 'Baujahr 1980 - 1990', 'Baujahr 1991 - 2008','Baujahr nach 2009'];
  List<String> choicesLivingarea = ['Mehr als 300m2', '201 - 300m2', '151-200m2', '126-150m2','101-125m2', '76-100m2', '51-75m2', '30-50m2', 'Kleiner als 30m2'];
  List<String> choicesPersons = ['1 Person', '2 Personen', '3 Personen', '4 Personen','5 Personen'];
  List<String> choicesTemperature = ['Über 23 Grad', 'Etwa 21 Grad', 'Maximal 19 Grad', 'Maximal 17 Grad'];
  List<String> choicesType = ['Einfamilienhaus', 'Mehrfamilienhaus'];
  List<String> choicesClass = ['Schlechter als A', 'A und besser', 'A+ und besser', 'A++ und besser', 'Keine Ahnung - Geräte meist älter als 10 Jahre', 'Keine Ahnung - Geräte meist jünger als 10 Jahre'];
  List<String> choicesCool = ['Mehrere Kühlschränke/Tiefkühltruhen', 'Kühlschrank in Kombination mit Tiefkühler', 'Ein Kühlschrank mit kleinem Gefrierfach'];
  List<String> choicesWash = ['Auf der maximal vorgesehenen Waschtemperatur ', 'Grossteil bei 40 °C, etwa ein Drittel bei 60 °C, keine Kochwäsche (95 °C)', 'Mehr als die Hälfte bei 30 °C und weniger, nur ganz selten 60 °C'];
  List<String> choicesDry = ['Im Raum mit Lufttrockner', 'Teils Lufttrockner und teils Wäscheleine', 'Nur Wäscheleine'];
  int choiceHeiz = 0;
  int choiceBaujahr = 0;
  int choiceLivingarea = 0;
  int choicePersons = 0;
  int choiceTemperature = 0;
  int choiceType = 0;
  int choiceClass = 0;
  int choiceCool = 0;
  int choiceWash = 0;
  int choiceDry = 0;

  //Konsum
  List<String> choicesKleider = ['Mehr als 250€ pro Monat', 'ca. 125€ pro Monat', 'ca. 100€ pro Monat', 'ca. 50€ pro Monat', 'Weniger als 20€ pro Monat'];
  List<String> choicesHobbies = ['Mehr als 600€ pro Monat', 'ca. 400€ pro Monat', 'ca. 260€ pro Monat', 'ca. 150€ pro Monat', 'Weniger als 50€ pro Monat'];
  List<String> choicesDevices = ['Mehr als 300€ pro Monat', 'ca. 200€ pro Monat', 'ca. 125€ pro Monat', 'ca. 75€ pro Monat', 'Weniger als 25€ pro Monat'];
  List<String> choicesEat = ['Mehr als 600€ pro Monat', 'ca. 400€ pro Monat', 'ca. 250€ pro Monat', 'ca. 100€ pro Monat', 'Weniger als 50€ pro Monat'];
  int choiceKleider = 0;
  int choiceHobbies = 0;
  int choiceDevices = 0;
  int choiceEat = 0;


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Dein ökologischer Fußabdruck'),
        centerTitle: true,
      ),
      body:  Column(
        children: [
          Expanded(
            child: FxStepper(
              type: stepperType,
              physics: const ScrollPhysics(),
              currentStep: _currentStep,
              onStepTapped: (step) => tapped(step),
              onStepContinue:  continued,
              onStepCancel: cancel,
              steps: <FxStep>[
                FxStep(
                  title: const Text('Essen'),
                  content: Column(
                    children: <Widget>[
                  Container(
                  margin: const EdgeInsets.all(5.0),
      padding: const EdgeInsets.all(5.0),
       child: Column(
        children: [Text('Wie viel saisonales Obst und Gemüse kaufst du ein?',
            textAlign: TextAlign.center,
          style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold, fontSize: 20)),
          Wrap(
            spacing: 4,
            alignment: WrapAlignment.center,
            children: List.generate(choicesSaison.length, (index) {
              return ChoiceChip(
                labelPadding: const EdgeInsets.all(1.0),
                label: Text(
                  choicesSaison[index],
                ),
                selected: choiceSaison == index,
                selectedColor: Colors.lightGreen,
                onSelected: (value) {
                  setState(() {
                    choiceSaison = value ? index : choiceSaison;
                  });
                },
                //backgroundColor: Colors.pink,
                elevation: 1,
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0
                ),
              );
            }),
          ),
          const SizedBox(height: 30),
          Text('Wie oft konsumiest du Milch und Milchprodukte wie Joghurt, Käse, Butter oder Rahm?',
            textAlign: TextAlign.center,
            style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold, fontSize: 20)),
          Wrap(
            spacing: 4,
            alignment: WrapAlignment.center,
            children: List.generate(choicesMilk.length, (index) {
              return ChoiceChip(
                labelPadding: const EdgeInsets.all(1.0),
                label: Text(
                  choicesMilk[index],
                ),
                selected: choiceMilk == index,
                selectedColor: Colors.lightGreen,
                onSelected: (value) {
                  setState(() {
                    choiceMilk = value ? index : choiceMilk;
                  });
                },
                //backgroundColor: Colors.pink,
                elevation: 1,
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0
                ),
              );
            }),
          ),
          const SizedBox(height: 30),
          Text('Wie oft isst du Eier oder Lebensmittel, die Eier enthalten',
            textAlign: TextAlign.center,
            style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold, fontSize: 20)),
          Wrap(
            spacing: 4,
            alignment: WrapAlignment.center,
            children: List.generate(choicesEggs.length, (index) {
              return ChoiceChip(
                labelPadding: const EdgeInsets.all(1.0),
                label: Text(
                  choicesEggs[index],
                ),
                selected: choiceEggs == index,
                selectedColor: Colors.lightGreen,
                onSelected: (value) {
                  setState(() {
                    choiceEggs = value ? index : choiceEggs;
                  });
                },
                //backgroundColor: Colors.pink,
                elevation: 1,
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0
                ),
              );
            }),
          ),
          const SizedBox(height: 30),
          Text('Wie oft isst du Gerichte, die Fleisch oder Fisch enthalten?',
            textAlign: TextAlign.center,
            style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold, fontSize: 20)),
          Wrap(
            spacing: 4,
            alignment: WrapAlignment.center,
            children: List.generate(choicesMeat.length, (index) {
              return ChoiceChip(
                labelPadding: const EdgeInsets.all(1.0),
                label: Text(
                  choicesMeat[index],
                ),
                selected: choiceMeat == index,
                selectedColor: Colors.lightGreen,
                onSelected: (value) {
                  setState(() {
                    choiceMeat = value ? index : choiceMeat;
                  });
                },
                //backgroundColor: Colors.pink,
                elevation: 1,
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0
                ),
              );
            }),
          ),
          const SizedBox(height: 30),
          Text('Welchen Anteil haben Label-Produkte (Bio, MSC, Fair Trade) an deinem Einkauf?',
            textAlign: TextAlign.center,
            style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold, fontSize: 20)),
          Wrap(
            spacing: 4,
            alignment: WrapAlignment.center,
            children: List.generate(choicesFair.length, (index) {
              return ChoiceChip(
                labelPadding: const EdgeInsets.all(1.0),
                label: Text(
                  choicesFair[index],
                ),
                selected: choiceFair == index,
                selectedColor: Colors.lightGreen,
                onSelected: (value) {
                  setState(() {
                    choiceFair = value ? index : choiceFair;
                  });
                },
                //backgroundColor: Colors.pink,
                elevation: 1,
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0
                ),
              );
            }),
          ),
          const SizedBox(height: 30),
          Text('Wie oft wirfst du Lebensmittel weg?',
            textAlign: TextAlign.center,
            style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold, fontSize: 20)),
          Wrap(
            spacing: 4,
            alignment: WrapAlignment.center,
            children: List.generate(choicesTrash.length, (index) {
              return ChoiceChip(
                labelPadding: const EdgeInsets.all(1.0),
                label: Text(
                  choicesTrash[index],
                ),
                selected: choiceTrash == index,
                selectedColor: Colors.lightGreen,
                onSelected: (value) {
                  setState(() {
                    choiceTrash = value ? index : choiceTrash;
                  });
                },
                //backgroundColor: Colors.pink,
                elevation: 1,
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0
                ),
              );
            }),
          )]),
      ),
                  ]),
                  isActive: _currentStep >= 0,
                  state: _currentStep >= 0 ? FxStepState.complete : FxStepState.disabled
                ),
                FxStep(
                  title: const Text('Mobilität'),
                  content: Column(
                    children: <Widget>[
                      Text('Wie viele Kilometer legst du jährlich per Auto oder Motorrad zurück? ',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold, fontSize: 20)),
                      Wrap(
                        spacing: 4,
                        alignment: WrapAlignment.center,
                        children: List.generate(choicesCar.length, (index) {
                          return ChoiceChip(
                            labelPadding: const EdgeInsets.all(1.0),
                            label: Text(
                              choicesCar[index],
                            ),
                            selected: choiceCar == index,
                            selectedColor: Colors.lightGreen,
                            onSelected: (value) {
                              setState(() {
                                choiceCar = value ? index : choiceCar;
                              });
                            },
                            //backgroundColor: Colors.pink,
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 30),
                      Text('Mit welchem Treibstoff fährt das Auto, das du in der Regel benutzt?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold, fontSize: 20)),
                      Wrap(
                        spacing: 4,
                        alignment: WrapAlignment.center,
                        children: List.generate(choicesFuel.length, (index) {
                          return ChoiceChip(
                            labelPadding: const EdgeInsets.all(1.0),
                            label: Text(
                              choicesFuel[index],
                            ),
                            selected: choiceFuel == index,
                            selectedColor: Colors.lightGreen,
                            onSelected: (value) {
                              setState(() {
                                choiceFuel = value ? index : choiceFuel;
                              });
                            },
                            //backgroundColor: Colors.pink,
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 30),
                      Text('Wie hoch ist der Treibstoffverbrauch deines privaten Autos?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold, fontSize: 20)),
                      Wrap(
                        spacing: 4,
                        alignment: WrapAlignment.center,
                        children: List.generate(choicesFuelUse.length, (index) {
                          return ChoiceChip(
                            labelPadding: const EdgeInsets.all(1.0),
                            label: Text(
                              choicesFuelUse[index],
                            ),
                            selected: choiceFuelUse == index,
                            selectedColor: Colors.lightGreen,
                            onSelected: (value) {
                              setState(() {
                                choiceFuelUse = value ? index : choiceFuelUse;
                              });
                            },
                            //backgroundColor: Colors.pink,
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 30),
                      Text('Wie viele Kilometer legst du wöchentlich mit öffentlichen Verkehrsmitteln oder mit einem E-Bike zurück?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold, fontSize: 20)),
                      Wrap(
                        spacing: 4,
                        alignment: WrapAlignment.center,
                        children: List.generate(choicesOffi.length, (index) {
                          return ChoiceChip(
                            labelPadding: const EdgeInsets.all(1.0),
                            label: Text(
                              choicesOffi[index],
                            ),
                            selected: choiceOffi == index,
                            selectedColor: Colors.lightGreen,
                            onSelected: (value) {
                              setState(() {
                                choiceOffi = value ? index : choiceOffi;
                              });
                            },
                            //backgroundColor: Colors.pink,
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 30),
                      Text('Wie viele Stunden bist du in den letzten fünf Jahren durchschnittlich mit dem Flugzeug privat gereist?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold, fontSize: 20)),
                      Wrap(
                        spacing: 4,
                        alignment: WrapAlignment.center,
                        children: List.generate(choicesPlane.length, (index) {
                          return ChoiceChip(
                            labelPadding: const EdgeInsets.all(1.0),
                            label: Text(
                              choicesPlane[index],
                            ),
                            selected: choicePlane == index,
                            selectedColor: Colors.lightGreen,
                            onSelected: (value) {
                              setState(() {
                                choicePlane = value ? index : choicePlane;
                              });
                            },
                            //backgroundColor: Colors.pink,
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 30),
                      Text('Wie viele Tage hast du in den letzten fünf Jahren durchschnittlich auf einer Kreuzfahrt verbracht?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold, fontSize: 20)),
                      Wrap(
                        spacing: 4,
                        alignment: WrapAlignment.center,
                        children: List.generate(choicesCruise.length, (index) {
                          return ChoiceChip(
                            labelPadding: const EdgeInsets.all(1.0),
                            label: Text(
                              choicesCruise[index],
                            ),
                            selected: choiceCruise == index,
                            selectedColor: Colors.lightGreen,
                            onSelected: (value) {
                              setState(() {
                                choiceCruise = value ? index : choiceCruise;
                              });
                            },
                            //backgroundColor: Colors.pink,
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0
                            ),
                          );
                        }),
                      )
                    ],
                  ),
                  isActive: _currentStep >= 0,
                  state: _currentStep >= 1 ?
                  FxStepState.complete : FxStepState.disabled,
                ),
                FxStep(
                  title: const Text('Wohnen'),
                  content: Column(
                    children: <Widget>[
                      Text('Womit wird dein Zuhause im Winter hauptsächlich beheizt?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold, fontSize: 20)),
                      Wrap(
                        spacing: 4,
                        alignment: WrapAlignment.center,
                        children: List.generate(choicesHeiz.length, (index) {
                          return ChoiceChip(
                            labelPadding: const EdgeInsets.all(1.0),
                            label: Text(
                              choicesHeiz[index],
                            ),
                            selected: choiceHeiz == index,
                            selectedColor: Colors.lightGreen,
                            onSelected: (value) {
                              setState(() {
                                choiceHeiz = value ? index : choiceHeiz;
                              });
                            },
                            //backgroundColor: Colors.pink,
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 30),
                      Text('Welchem Standard entspricht dein Wohnhaus?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold, fontSize: 20)),
                      Wrap(
                        spacing: 4,
                        alignment: WrapAlignment.center,
                        children: List.generate(choicesBaujahr.length, (index) {
                          return ChoiceChip(
                            labelPadding: const EdgeInsets.all(1.0),
                            label: Text(
                              choicesBaujahr[index],
                            ),
                            selected: choiceBaujahr == index,
                            selectedColor: Colors.lightGreen,
                            onSelected: (value) {
                              setState(() {
                                choiceBaujahr = value ? index : choiceBaujahr;
                              });
                            },
                            //backgroundColor: Colors.pink,
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 30),
                      Text('Wie groß ist deine beheizte Wohnfläche?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold, fontSize: 20)),
                      Wrap(
                        spacing: 4,
                        alignment: WrapAlignment.center,
                        children: List.generate(choicesLivingarea.length, (index) {
                          return ChoiceChip(
                            labelPadding: const EdgeInsets.all(1.0),
                            label: Text(
                              choicesLivingarea[index],
                            ),
                            selected: choiceLivingarea == index,
                            selectedColor: Colors.lightGreen,
                            onSelected: (value) {
                              setState(() {
                                choiceLivingarea = value ? index : choiceLivingarea;
                              });
                            },
                            //backgroundColor: Colors.pink,
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 30),
                      Text('Wieviele Personen leben in deinem Haushalt?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold, fontSize: 20)),
                      Wrap(
                        spacing: 4,
                        alignment: WrapAlignment.center,
                        children: List.generate(choicesPersons.length, (index) {
                          return ChoiceChip(
                            labelPadding: const EdgeInsets.all(1.0),
                            label: Text(
                              choicesPersons[index],
                            ),
                            selected: choicePersons == index,
                            selectedColor: Colors.lightGreen,
                            onSelected: (value) {
                              setState(() {
                                choicePersons = value ? index : choicePersons;
                              });
                            },
                            //backgroundColor: Colors.pink,
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 30),
                      Text('Auf wie viel Grad heizt du dein Zuhause?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold, fontSize: 20)),
                      Wrap(
                        spacing: 4,
                        alignment: WrapAlignment.center,
                        children: List.generate(choicesTemperature.length, (index) {
                          return ChoiceChip(
                            labelPadding: const EdgeInsets.all(1.0),
                            label: Text(
                              choicesTemperature[index],
                            ),
                            selected: choiceTemperature == index,
                            selectedColor: Colors.lightGreen,
                            onSelected: (value) {
                              setState(() {
                                choiceTemperature = value ? index : choiceTemperature;
                              });
                            },
                            //backgroundColor: Colors.pink,
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 30),
                      Text('In welchem Haustyp wohnst du?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold, fontSize: 20)),
                      Wrap(
                        spacing: 4,
                        alignment: WrapAlignment.center,
                        children: List.generate(choicesType.length, (index) {
                          return ChoiceChip(
                            labelPadding: const EdgeInsets.all(1.0),
                            label: Text(
                              choicesType[index],
                            ),
                            selected: choiceType == index,
                            selectedColor: Colors.lightGreen,
                            onSelected: (value) {
                              setState(() {
                                choiceType = value ? index : choiceType;
                              });
                            },
                            //backgroundColor: Colors.pink,
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 30),
                      Text('Welche Effizienzklassen haben deine Beleuchtung und großen Haushaltgeräte?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold, fontSize: 20)),
                      Wrap(
                        spacing: 4,
                        alignment: WrapAlignment.center,
                        children: List.generate(choicesClass.length, (index) {
                          return ChoiceChip(
                            labelPadding: const EdgeInsets.all(1.0),
                            label: Text(
                              choicesClass[index],
                            ),
                            selected: choiceClass == index,
                            selectedColor: Colors.lightGreen,
                            onSelected: (value) {
                              setState(() {
                                choiceClass = value ? index : choiceClass;
                              });
                            },
                            //backgroundColor: Colors.pink,
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 30),
                      Text('Welche Kühlgeräte hast du?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold, fontSize: 20)),
                      Wrap(
                        spacing: 4,
                        alignment: WrapAlignment.center,
                        children: List.generate(choicesCool.length, (index) {
                          return ChoiceChip(
                            labelPadding: const EdgeInsets.all(1.0),
                            label: Text(
                              choicesCool[index],
                            ),
                            selected: choiceCool == index,
                            selectedColor: Colors.lightGreen,
                            onSelected: (value) {
                              setState(() {
                                choiceCool = value ? index : choiceCool;
                              });
                            },
                            //backgroundColor: Colors.pink,
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 30),
                      Text('Wie wäscht du deine Wäsche?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold, fontSize: 20)),
                      Wrap(
                        spacing: 4,
                        alignment: WrapAlignment.center,
                        children: List.generate(choicesWash.length, (index) {
                          return ChoiceChip(
                            labelPadding: const EdgeInsets.all(1.0),
                            label: Text(
                              choicesWash[index],
                            ),
                            selected: choiceWash == index,
                            selectedColor: Colors.lightGreen,
                            onSelected: (value) {
                              setState(() {
                                choiceWash = value ? index : choiceWash;
                              });
                            },
                            //backgroundColor: Colors.pink,
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 30),
                      Text('Wie trocknest du deine Wäsche?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold, fontSize: 20)),
                      Wrap(
                        spacing: 4,
                        alignment: WrapAlignment.center,
                        children: List.generate(choicesDry.length, (index) {
                          return ChoiceChip(
                            labelPadding: const EdgeInsets.all(1.0),
                            label: Text(
                              choicesDry[index],
                            ),
                            selected: choiceDry == index,
                            selectedColor: Colors.lightGreen,
                            onSelected: (value) {
                              setState(() {
                                choiceDry = value ? index : choiceDry;
                              });
                            },
                            //backgroundColor: Colors.pink,
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0
                            ),
                          );
                        }),
                      )
                    ],
                  ),
                  isActive:_currentStep >= 0,
                  state: _currentStep >= 2 ?
                  FxStepState.complete : FxStepState.disabled,
                ),
                FxStep(
                  title: const Text('Konsum'),
                  content: Column(
                    children: <Widget>[
                      Text('Wieviel gibst du monatlich für Kleider und Schuhe aus?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold, fontSize: 20)),
                      Wrap(
                        spacing: 4,
                        alignment: WrapAlignment.center,
                        children: List.generate(choicesKleider.length, (index) {
                          return ChoiceChip(
                            labelPadding: const EdgeInsets.all(1.0),
                            label: Text(
                              choicesKleider[index],
                            ),
                            selected: choiceKleider == index,
                            selectedColor: Colors.lightGreen,
                            onSelected: (value) {
                              setState(() {
                                choiceKleider = value ? index : choiceKleider;
                              });
                            },
                            //backgroundColor: Colors.pink,
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 30),
                      Text('Wie viel gibst du monatlich für Freizeit und Kultur aus?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold, fontSize: 20)),
                      Wrap(
                        spacing: 4,
                        alignment: WrapAlignment.center,
                        children: List.generate(choicesHobbies.length, (index) {
                          return ChoiceChip(
                            labelPadding: const EdgeInsets.all(1.0),
                            label: Text(
                              choicesHobbies[index],
                            ),
                            selected: choiceHobbies == index,
                            selectedColor: Colors.lightGreen,
                            onSelected: (value) {
                              setState(() {
                                choiceHobbies = value ? index : choiceHobbies;
                              });
                            },
                            //backgroundColor: Colors.pink,
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 30),
                      Text('Wie viel gibst du monatlich für Möbel und Haushaltsgeräte aus?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold, fontSize: 20)),
                      Wrap(
                        spacing: 4,
                        alignment: WrapAlignment.center,
                        children: List.generate(choicesDevices.length, (index) {
                          return ChoiceChip(
                            labelPadding: const EdgeInsets.all(1.0),
                            label: Text(
                              choicesDevices[index],
                            ),
                            selected: choiceDevices == index,
                            selectedColor: Colors.lightGreen,
                            onSelected: (value) {
                              setState(() {
                                choiceDevices = value ? index : choiceDevices;
                              });
                            },
                            //backgroundColor: Colors.pink,
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 30),
                      Text('Wie viel Geld gebst du monatlich für Essen in Restaurants sowie für auswärtige Übernachtungen aus?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold, fontSize: 20)),
                      Wrap(
                        spacing: 4,
                        alignment: WrapAlignment.center,
                        children: List.generate(choicesEat.length, (index) {
                          return ChoiceChip(
                            labelPadding: const EdgeInsets.all(1.0),
                            label: Text(
                              choicesEat[index],
                            ),
                            selected: choiceEat == index,
                            selectedColor: Colors.lightGreen,
                            onSelected: (value) {
                              setState(() {
                                choiceEat = value ? index : choiceEat;
                              });
                            },
                            //backgroundColor: Colors.pink,
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0
                            ),
                          );
                        }),
                      )
                    ],
                  ),
                  isActive:_currentStep >= 0,
                  state: _currentStep >= 3 ?
                  FxStepState.complete : FxStepState.disabled,
                )
              ],
            ),
          ),
          ElevatedButton(
            child: Text('Test Startseite!'),
            onPressed: () {
              /*NotificationService().scheduleNotification(
                  title: 'Scheduled Notification',
                  body: 'It works!',
                  scheduledNotificationDateTime: DateTime.now().add(const Duration(seconds: 3)));*/
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage(
                    title: "oekoApp",
                  )
                  ));
            },
          )
        ],
      ),
    );
  }

  tapped(int step){
    setState(() => _currentStep = step);
  }

  continued() async {
    if(_currentStep == 3) {
      var uuid = const Uuid();
      var newuserid = uuid.v4();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      //TODO CHANGE NEXT LINE!!!
      //await prefs.setString("userid", "34d9bc7a-fe89-463c-9537-dbe7471b9485");
      await prefs.setString("userid", newuserid);
      await prefs.setInt("initScreen", 1);
      createFootprint(Footprint(choiceSaison,
          choiceMilk,
          choiceEggs,
          choiceMeat,
          choiceFair,
          choiceTrash,
          choiceCar,
          choiceFuel,
          choiceFuelUse,
          choiceOffi,
          choicePlane,
          choiceCruise,
          choiceHeiz,
          choiceBaujahr,
          choiceLivingarea,
          choicePersons,
          choiceTemperature,
          choiceType,
          choiceClass,
          choiceCool,
          choiceWash,
          choiceDry,
          choiceKleider,
          choiceHobbies,
          choiceDevices,
          choiceEat,
      newuserid));
      await Future.delayed(const Duration(seconds: 1));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResultWidget()
      ));
    }
    _currentStep < 3 ? setState(() => _currentStep += 1): null;
  }
  cancel(){
    _currentStep > 0 ?
    setState(() => _currentStep -= 1) : null;
  }

  void createFootprint(Footprint footprint) async {
    await http.post(
        //Uri.parse('http://10.0.2.2:8080/api/savefootprint'),
        Uri.parse('http://masterbackend.fly.dev/api/savefootprint'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(footprint.toJson())
    );

  }

}