import 'dart:io';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class ExportService {
  static const String _dateTimeFormat = 'yyyy-MM-dd HH:mm';

  /// Export data to Excel
  Future<void> exportToExcel({
    required String title,
    required List<String> headers,
    required List<List<dynamic>> data,
    String? sheetName,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel[sheetName ?? 'Sheet1'];

    // Add Title
    sheet.merge(CellIndex.indexByString("A1"), CellIndex.indexByString("D1"), customValue: TextCellValue(title));
    final titleCell = sheet.cell(CellIndex.indexByString("A1"));
    titleCell.value = TextCellValue(title);
    titleCell.cellStyle = CellStyle(
      bold: true, 
      fontSize: 16, 
      horizontalAlign: HorizontalAlign.Center
    );

    // Add Headers
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 2));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(bold: true);
    }

    // Add Data
    for (var rowIdx = 0; rowIdx < data.length; rowIdx++) {
      final row = data[rowIdx];
      for (var colIdx = 0; colIdx < row.length; colIdx++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIdx, rowIndex: rowIdx + 3));
        final value = row[colIdx];
        if (value is num) {
           cell.value = DoubleCellValue(value.toDouble());
        } else {
           cell.value = TextCellValue(value.toString());
        }
      }
    }

    // Save File
    final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final String fileName = '${title.replaceAll(' ', '_')}_$timestamp.xlsx';
    
    // For Desktop (Windows) use FilePicker to save
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Excel File',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    
    if (outputFile != null) {
      if (!outputFile.endsWith('.xlsx')) outputFile += '.xlsx'; // Ensure extension
      final file = File(outputFile);
      await file.writeAsBytes(excel.save()!);
    }
  }

  /// Export data to PDF
  Future<void> exportToPdf({
    required String title,
    required List<String> headers,
    required List<List<dynamic>> data,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                   pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                   pw.Text(DateFormat(_dateTimeFormat).format(DateTime.now())),
                ]
              )
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              context: context,
              headers: headers,
              data: data.map((row) => row.map((e) => e.toString()).toList()).toList(),
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 30,
              cellAlignments: {
                // Default alignment can be tweaked if needed
                for (var i = 0; i < headers.length; i++) i: pw.Alignment.centerLeft,
              },
            ),
          ];
        },
      ),
    );

    // Prompt user to save
    final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final String fileName = '${title.replaceAll(' ', '_')}_$timestamp.pdf';

    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save PDF File',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (outputFile != null) {
      if (!outputFile.endsWith('.pdf')) outputFile += '.pdf'; 
      final file = File(outputFile);
      await file.writeAsBytes(await pdf.save());
    }
  }
}
