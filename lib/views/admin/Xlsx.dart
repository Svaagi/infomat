import 'package:flutter/material.dart';
import 'package:infomat/Colors.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'package:infomat/models/ClassModel.dart';
import 'package:infomat/models/UserModel.dart';
import 'package:infomat/controllers/convert.dart';
import 'package:infomat/controllers/userController.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class Xlsx extends StatefulWidget {
  final UserData? currentUserData;
  final void Function(int) onNavigationItemSelected;
  String? selectedClass;
  final ClassDataWithId? currentClass;
  final List<String> classes;

  Xlsx(
    {
      Key? key, 
      required this.currentUserData,
      required this.onNavigationItemSelected,
      required this.selectedClass,
      required this.currentClass,
      required this.classes,
    }
  );

  @override
  State<Xlsx> createState() => _XlsxState();
}

class _XlsxState extends State<Xlsx> {
  FileProcessingResult? table;
  bool showTable = true;
  bool loading = false;

  Future<FileProcessingResult?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true);

    if (result != null) {
      loading = true;
      PlatformFile pickedFile = result.files.single;
      Uint8List fileBytes = pickedFile.bytes!;
      String fileName = pickedFile.name;
      String extension = fileName.split('.').last;

      return processFile(fileBytes, extension, widget.classes, loading);
    } else {
      // User canceled the picker
      return null;
    }
  }



  @override
  Widget build(BuildContext context) {
    if (loading) return Center(
      child: CircularProgressIndicator(),
    ); 
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.all(8),
        width: 900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppColors.getColor('mono').darkGrey,
                  ),
                  onPressed: () { 
                    widget.onNavigationItemSelected(0);
                    widget.selectedClass = null;
                  },
                ),
                Text(
                  'Späť',
                  style: TextStyle(color: AppColors.getColor('mono').darkGrey),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Pridať žiakov',
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                    ),
                  ),
                ),
                SizedBox(width: 100,)
              ],
            ),
            showTable && table != null
          ? Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                SizedBox(height: 40,),
                Text(
                  'Súbor sa nahral',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: AppColors.getColor('mono').black,
                      ),
                ),
                SizedBox(height: 10,),
                Text(
                  'Skontrolujte prosím správnosť údajov. Ak v údajoch nie sú chyby, stlačte “ULOŽIŤ”.',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.getColor('mono').grey,
                    ),
                ),
              ],
            )
            : Column(
               mainAxisAlignment: MainAxisAlignment.start,
               crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40,),
                Text(
                  'Importovať údaje žiakov',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: AppColors.getColor('mono').black,
                      ),
                ),
                SizedBox(height: 10,),
                Text(
                  'Údaje nahrajte prostredníctvom .xlsx súboru. Aplikácia každému žiakovi vygeneruje a pošle prihlasovacie údaje.',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.getColor('mono').grey,
                    ),
                ),
                SizedBox(height: 30,),
              
                  Text(
                  'Súbor musí byť formátovaný nasledovne: ',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: AppColors.getColor('mono').black,
                      ),
                ),
                
                Text(
                  '3 stĺplce pomenované ako:',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.getColor('mono').grey,
                      ),
                ),
                Text(
                  '- “Meno Priezvisko”',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.getColor('mono').grey,
                      ),
                ),
                Text(
                  '- “Email”',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.getColor('mono').grey,
                      ),
                ),
                Text(
                  '- “Trieda”',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.getColor('mono').grey,
                      ),
                ),
                MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () async {
                          // Load the file
                          final byteData = await rootBundle.load('assets/Žiaci.xlsx');
                          final directory = await getApplicationDocumentsDirectory();
                          final file = File('${directory.path}/Žiaci.xlsx');

                          // Write the file
                          await file.writeAsBytes(
                              byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

                          // Notify user
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('File downloaded successfully!')),
                          );
                        },
                        child: Text(
                          'Stiahnuť vzorový súbor na import žiakov',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                SizedBox(height: 30,),
                  Text(
                  'Názvy tried v súbore sa musia zhodovať s názvami, ktoré ste zadali v aplikácii.',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.getColor('mono').grey,
                      ),
                ),
              ],
            ),
            
            const SizedBox(height: 10,),
            showTable && table != null
          ? Expanded( 
            child: ListView.separated(
                itemCount: table!.data.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(table!.data[index].name),
                    subtitle: table!.incorrectRows[index].index == index ? Text('${table!.data[index].email}, ${table!.data[index].classValue} - ${table!.incorrectRows[index].error}') : Text('${table!.data[index].email}, ${table!.data[index].classValue}'),
                    textColor: table!.incorrectRows[index].index == index ? Colors.red : Colors.black,
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              )
            ) : Center(
              child: Image.asset('assets/import.png', width: 700, height: 300,),
            ),
            const SizedBox(height: 30,),
            Align(
              alignment: Alignment.center,
              child: showTable && table != null ? 
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ReButton(
                        color: "grey", 
                        text: 'SKÚSIŤ ZNOVA',
                        onTap: () async {
                          FileProcessingResult? result = await pickFile();
                          setState(() {
                            loading = false;
                          });
                          if (result != null) {
                            setState(() {
                              table = result;
                              showTable = true;
                            });
                          }
                        }
                      ),
                      const SizedBox(width: 5,),
                      ReButton(
                        color: "green",  
                        text: 'ULOŽIŤ', 
                        onTap: () {
                            if (table!.errNum == 0) {
                              setState(() {
                                loading = true;
                              });
                              registerMultipleUsers(table!.data, widget.currentUserData!.school, false, context);
                              setState(() {
                                loading = false;
                              });
                            }
                          }
                      ),
                    ],
                  )
                : Container(
                width: 277,
                child: 
                    ReButton(
                    color: "green", 
                    text: 'XLSX SÚBOR', 
                    onTap: () async {

                      FileProcessingResult? result = await pickFile();
                      setState(() {
                        loading = false;
                      });
                      if (result != null) {
                        setState(() {
                          table = result;
                          showTable = true;
                        });
                      }
                    },
                  ),
              )
              
            ),
            SizedBox(height: 30,),
          ],
        ),
      ),
    );
  }
}