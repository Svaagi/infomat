import 'package:excel/excel.dart';
import 'package:infomat/controllers/ClassController.dart';
import 'package:infomat/auth/auth.dart';
import 'dart:typed_data';


class ConvertTable {
  String name;
  String email;
  String classValue;
  String classId;

  ConvertTable({required this.name, required this.email, required this.classValue, required this.classId});
}

class IncorrectRow {
  int index;
  String error;

  IncorrectRow({required this.index,  required this.error});
}

class FileProcessingResult {
  List<IncorrectRow> incorrectRows;
  List<ConvertTable> data;
  int errNum;

  FileProcessingResult({required this.incorrectRows, required this.data, required this.errNum});
}



Future<FileProcessingResult?> processFile(Uint8List fileBytes, String extension, List<String> classIds, bool loading) async {
  FileProcessingResult? result;

  switch (extension) {
    case 'xlsx':
      result = await processXLSX(fileBytes, classIds, loading);
      break;
    default:
      print('Unsupported file type');
      return null;
  }

  return result;
}

// Existing isValidEmail function
bool isValidEmail(String email) {
  final emailRegex = RegExp(
    r'^[^@]+@[^@]+\.[^@]+',
  );
  return emailRegex.hasMatch(email);
}

// Modified check that combines both validations
Future<bool> isValidAndUnusedEmail(String email) async {
  return isValidEmail(email) && !(await isEmailAlreadyUsed(email));
}



Future<FileProcessingResult> processXLSX(Uint8List fileBytes, List<String> classIds, bool loading) async {
  var excel = Excel.decodeBytes(fileBytes);
  final classes = await fetchClasses(classIds);
  List<IncorrectRow> incorrectRows = [];
  List<ConvertTable> processedData = [];
  Set<String> seenEmails = Set<String>(); // Set to track seen emails
  int errNum = 0;

  for (var table in excel.tables.keys) {
    for (int i = 1; i < excel.tables[table]!.rows.length; i++) {
      var row = excel.tables[table]!.rows[i];

      // Check if all fields in the row are empty
      bool allFieldsEmpty = row.every((cell) => cell?.value == null || cell!.value.toString().isEmpty);
      if (allFieldsEmpty) {
        continue; // Skip this row
      }

      String getCellValue(dynamic cell) => cell?.value?.toString() ?? "";

      String name = getCellValue(row[0]);
      String email = getCellValue(row[1]);
      String classValue = getCellValue(row[2]);

      bool classExists = false;
      String classId = '';

      for (int j = 0; j < classes.length; j++) {
        if (classes[j].name == classValue) {
          classExists = true;
          classId = classIds[j];
        }
      }

      
      bool emailIsValid = isValidEmail(email);
      bool emailAlreadySeen = !seenEmails.add(email); // returns false if email is new

      List<String> errors = [];
      if (!classExists) {
        errors.add('Trieda neexistuje');
      }
      print('HERE${await isEmailAlreadyUsed(email)}');
      if (!emailIsValid || await isEmailAlreadyUsed(email) || emailAlreadySeen) {
        errors.add(emailAlreadySeen ? 'Email sa už vyskytol v zozname' : 'Email je používaný alebo v zlom formáte');
      }

      if (errors.isNotEmpty) {
        incorrectRows.add(IncorrectRow(index: i - 1, error: errors.join(' a ')));
        processedData.add(ConvertTable(name: name, email: email, classValue: classValue, classId: classId));
        errNum++;
      } else {
        incorrectRows.add(IncorrectRow(index: -1, error: errors.join(' a ')));
        processedData.add(ConvertTable(name: name, email: email, classValue: classValue, classId: classId));
      }
    }
  }

  loading = false;

  return FileProcessingResult(incorrectRows: incorrectRows, data: processedData, errNum: errNum);
}












