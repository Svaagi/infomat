import 'package:flutter/material.dart';
import 'package:infomat/Colors.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'package:infomat/models/ClassModel.dart';
import 'package:infomat/models/UserModel.dart';
import 'package:infomat/controllers/convert.dart';
import 'package:infomat/controllers/userController.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:html' as html;


class Xlsx extends StatefulWidget {
  final UserData? currentUserData;
  final void Function(int) onNavigationItemSelected;
  String? selectedClass;
  ClassDataWithId currentClass;
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
  bool emailStudent = false;
  bool emailTeacher = false;
  List<String> classNames = [];


  Future<FileProcessingResult?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true);

    if (result != null) {
      loading = true;
      PlatformFile pickedFile = result.files.single;
      Uint8List fileBytes = pickedFile.bytes!;
      String fileName = pickedFile.name;
      String extension = fileName.split('.').last;

      return processFile(fileBytes, extension, widget.classes, loading, classNames);
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
      child: SingleChildScrollView(
        child:
      Container(
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
                    widget.onNavigationItemSelected(1);
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
                  'Prosím, skontrolujte správnosť údajov. Ak v údajoch nie sú chyby, stlačte tlačidlo “ULOŽIŤ”.',
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
                  'Údaje nahrajte prostredníctvom .xlsx súboru. Aplikácia vygeneruje pre študentov prihlasovacie údaje, ktoré vám budú zaslané na vašu e-mailovú adresu. Následne tieto údaje môžete môžete distribuovať študentom v triede.',
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
                      final byteData = await rootBundle.load('assets/ziaci-vzor.xlsx');
                      final blob = html.Blob([byteData.buffer.asUint8List()], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
                      final url = html.Url.createObjectUrlFromBlob(blob);
                      html.AnchorElement anchor = html.AnchorElement(href: url)
                        ..setAttribute("download", "ziaci-vzor.xlsx")
                        ..click();
                      html.Url.revokeObjectUrl(url);
                    },
                    child: Text(
                      'Stiahnuť vzorový súbor na import žiakov',
                      style: TextStyle(
                        color: Colors.blue[900],
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
               
                    Row(
                      children: <Widget>[
                        Checkbox(
                          value: emailTeacher,
                          onChanged: (value) {
                            setState(() {
                              emailTeacher = value!;
                            });
                          },
                        ),
                        Text(
                            'Doručiť na moju e-mailovú adresu (prihlasovacie údaje budem distribuovať žiakom individuálne).',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: AppColors.getColor('mono').grey,
                                ),
                          ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Checkbox(
                          value: emailStudent,
                          onChanged: (value) {
                            setState(() {
                              emailStudent = value!;
                            });
                          },
                        ),
                         Text(
                          textAlign: TextAlign.left,
                          'Doručiť každému žiakovi individuálne na jeho registrovanú adresu',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: AppColors.getColor('mono').grey,
                              ),
                        ),
                        
                      ],
                    ),
                    Text(
                          textAlign: TextAlign.left,
                          '(disponujem súhlasom žiakov s využitím ich e-mailových adries na doručenie prihlasovacích údajov).',
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
              child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () async {
                      final byteData = await rootBundle.load('assets/ziaci-vzor.xlsx');
                      final blob = html.Blob([byteData.buffer.asUint8List()], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
                      final url = html.Url.createObjectUrlFromBlob(blob);
                      html.AnchorElement anchor = html.AnchorElement(href: url)
                        ..setAttribute("download", "ziaci-vzor.xlsx")
                        ..click();
                      html.Url.revokeObjectUrl(url);
                    },
                    child: Image.asset('assets/import.png', width: 700, height: 300,),
                  ),
                ),
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
                        onTap: () async {
                            if (table!.errNum == 0 && ((emailStudent || emailTeacher))) {
                              setState(() {
                                loading = true;
                              });
                              await registerMultipleUsers(table!.data, widget.currentUserData!.school,widget.currentClass, widget.currentUserData!.email, widget.currentUserData!.name, emailTeacher, emailStudent, classNames,context, );
                              setState(() {
                                widget.currentClass.data.students = widget.currentClass.data.students;
                                loading = false;
                              });
                              widget.onNavigationItemSelected(1);
                              widget.selectedClass = null;
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
                      if (((emailStudent || emailTeacher))) {
                        setState(() {
                        loading = true;
                      });
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
                      
                    },
                  ),
              )
              
            ),
            SizedBox(height: 30,),
          ],
        ),
      ),
      )
    );
  }
}