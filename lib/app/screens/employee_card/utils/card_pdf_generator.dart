import 'dart:typed_data';
import '../model/employee_card_model.dart';

/// Pure-Dart PDF 1.4 document generator for employee ID cards.
/// Creates a valid, well-formed binary PDF readable by any standard PDF viewer
/// on Android, iOS, Windows, macOS, and Linux.
class CardPdfGenerator {
  static Uint8List createCardPdfBytes(EmployeeCardDetails card) {
    final streamContent = StringBuffer();
    streamContent.writeln('q');

    // Top Header Banner (Corporate Navy: 0.004, 0.169, 0.263 -> #012B43)
    streamContent.writeln('0.004 0.169 0.263 rg');
    streamContent.writeln('0 530 400 70 re f');

    // Left Accent Strip (Corporate Teal: 0.051, 0.651, 0.639 -> #0DA6A3)
    streamContent.writeln('0.051 0.651 0.639 rg');
    streamContent.writeln('0 0 10 600 re f');

    // Text: Header Banner
    streamContent.writeln('BT');
    streamContent.writeln('/F1 18 Tf');
    streamContent.writeln('1 1 1 rg');
    streamContent.writeln('25 560 Td');
    streamContent.writeln('(EMPLOYEE ID CARD) Tj');
    streamContent.writeln('ET');

    // Company Name
    streamContent.writeln('BT');
    streamContent.writeln('/F1 22 Tf');
    streamContent.writeln('0.004 0.169 0.263 rg');
    streamContent.writeln('30 480 Td');
    streamContent.writeln('(${_cleanText(card.company.name.toUpperCase())}) Tj');
    streamContent.writeln('ET');

    // Employee Name
    streamContent.writeln('BT');
    streamContent.writeln('/F1 18 Tf');
    streamContent.writeln('0.05 0.05 0.1 rg');
    streamContent.writeln('30 435 Td');
    streamContent.writeln('(${_cleanText(card.name.toUpperCase())}) Tj');
    streamContent.writeln('ET');

    // Designation
    streamContent.writeln('BT');
    streamContent.writeln('/F1 13 Tf');
    streamContent.writeln('0.051 0.651 0.639 rg');
    streamContent.writeln('30 408 Td');
    streamContent.writeln('(${_cleanText(card.designation)}) Tj');
    streamContent.writeln('ET');

    // Key Details Table
    streamContent.writeln('BT');
    streamContent.writeln('/F1 11 Tf');
    streamContent.writeln('0.2 0.2 0.3 rg');
    streamContent.writeln('30 360 Td');
    streamContent.writeln('(Employee ID: ${_cleanText(card.employeeNumber)}) Tj');
    streamContent.writeln('0 -22 Td');
    streamContent.writeln('(Department: ${_cleanText(card.department)}) Tj');
    streamContent.writeln('0 -22 Td');
    streamContent.writeln('(Card Number: ${_cleanText(card.cardNo.toString())}) Tj');
    streamContent.writeln('0 -22 Td');
    streamContent.writeln('(Issued Date: ${_cleanText(card.formattedIssuedDate.isNotEmpty ? card.formattedIssuedDate : (card.issuedOn ?? "N/A"))}) Tj');
    if (card.bloodGroup != null && card.bloodGroup!.isNotEmpty) {
      streamContent.writeln('0 -22 Td');
      streamContent.writeln('(Blood Group: ${_cleanText(card.bloodGroup!)}) Tj');
    }
    if (card.emergencyContact.isNotEmpty) {
      streamContent.writeln('0 -22 Td');
      streamContent.writeln('(Emergency Phone: ${_cleanText(card.emergencyContact)}) Tj');
    }
    streamContent.writeln('0 -22 Td');
    streamContent.writeln('(Verification Status: Cryptographically Signed) Tj');
    streamContent.writeln('ET');

    // Separator line
    streamContent.writeln('0.85 0.88 0.92 RG');
    streamContent.writeln('1.5 w');
    streamContent.writeln('30 190 m 370 190 l S');

    // Legal / Compliance Terms
    streamContent.writeln('BT');
    streamContent.writeln('/F1 9 Tf');
    streamContent.writeln('0.4 0.45 0.5 rg');
    streamContent.writeln('30 155 Td');
    streamContent.writeln('(1. This card remains the exclusive property of ${_cleanText(card.company.name)}.) Tj');
    streamContent.writeln('0 -16 Td');
    streamContent.writeln('(2. If found, please return to: ${_cleanText(card.company.address ?? "Company HQ")}.) Tj');
    streamContent.writeln('0 -16 Td');
    streamContent.writeln('(3. Card holder is not authorized to collect company dues or payments.) Tj');
    streamContent.writeln('ET');

    // Contact Footer
    streamContent.writeln('BT');
    streamContent.writeln('/F1 8 Tf');
    streamContent.writeln('0.55 0.6 0.65 rg');
    streamContent.writeln('30 75 Td');
    streamContent.writeln('(Helpline: ${_cleanText(card.company.phone ?? "03155109822")} | Contact: siddique.softech@gmail.com) Tj');
    streamContent.writeln('0 -16 Td');
    streamContent.writeln('(Secure Token: ${_cleanText(card.qrPayload)}) Tj');
    streamContent.writeln('0 -18 Td');
    streamContent.writeln('(AMS 2.0 Corporate Identity Infrastructure - All Rights Reserved) Tj');
    streamContent.writeln('ET');

    streamContent.writeln('Q');

    final streamBytes = streamContent.toString();
    final streamLen = streamBytes.length;

    final doc = StringBuffer();
    doc.write('%PDF-1.4\n');

    final offsets = <int>[];

    // Obj 1: Catalog
    offsets.add(doc.length);
    doc.write('1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n');

    // Obj 2: Pages
    offsets.add(doc.length);
    doc.write('2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n');

    // Obj 3: Page
    offsets.add(doc.length);
    doc.write(
      '3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 400 600] '
      '/Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>\nendobj\n',
    );

    // Obj 4: Font
    offsets.add(doc.length);
    doc.write(
      '4 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>\nendobj\n',
    );

    // Obj 5: Stream
    offsets.add(doc.length);
    doc.write('5 0 obj\n<< /Length $streamLen >>\nstream\n');
    doc.write(streamBytes);
    doc.write('\nendstream\nendobj\n');

    // Xref
    final startXref = doc.length;
    doc.write('xref\n0 6\n0000000000 65535 f \n');
    for (final offset in offsets) {
      doc.write('${offset.toString().padLeft(10, '0')} 00000 n \n');
    }

    // Trailer
    doc.write('trailer\n<< /Size 6 /Root 1 0 R >>\nstartxref\n$startXref\n%%EOF\n');

    return Uint8List.fromList(doc.toString().codeUnits);
  }

  /// Escapes PDF literal string special characters
  static String _cleanText(String input) {
    return input
        .replaceAll('\\', '\\\\')
        .replaceAll('(', '\\(')
        .replaceAll(')', '\\)');
  }
}
