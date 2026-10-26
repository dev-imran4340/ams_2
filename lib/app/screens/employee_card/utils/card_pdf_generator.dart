import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../model/employee_card_model.dart';

/// Professional multi-page PDF document generator for employee ID cards.
/// Page 1: Front Face (Maroon header, Avatar with Initials, Name, Designation, ID, Scannable QR code, Company)
/// Page 2: Back Face (Company, Building Emblem, Location Address, Terms & Conditions, Phone, Email, Issue Info)
/// Designed to exactly mirror the Laravel HR Portal card PDF layout.
class CardPdfGenerator {
  static Future<Uint8List> createCardPdfBytes(EmployeeCardDetails card) async {
    final pdf = pw.Document(
      title: 'ID card ${card.employeeNumber}',
      author: card.company.name,
      creator: 'AMS 2.0 Identity Infrastructure',
    );

    // Extract corporate brand color (#7f1d1d by default)
    PdfColor cardColor;
    try {
      final hex = card.colour.replaceAll('#', '');
      cardColor = PdfColor.fromHex(hex);
    } catch (_) {
      cardColor = PdfColor.fromHex('7f1d1d');
    }

    // Exact vertical ID card aspect ratio (270 x 430 pt)
    const cardPageFormat = PdfPageFormat(270, 430, marginAll: 0);

    // -------------------------------------------------------------
    // PAGE 1: FRONT FACE
    // -------------------------------------------------------------
    pdf.addPage(
      pw.Page(
        pageFormat: cardPageFormat,
        build: (pw.Context context) {
          return pw.Container(
            width: 270,
            height: 430,
            color: PdfColors.white,
            child: pw.Stack(
              children: [
                // Top Header Banner
                pw.Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: pw.Container(
                    height: 42,
                    color: cardColor,
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      'EMPLOYEE ID CARD',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                ),

                // Card Body
                pw.Positioned.fill(
                  top: 42,
                  bottom: 6,
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        // Avatar & Details Block
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.SizedBox(height: 8),

                            // Circular Avatar with Initials
                            pw.Container(
                              width: 74,
                              height: 74,
                              decoration: pw.BoxDecoration(
                                color: cardColor,
                                shape: pw.BoxShape.circle,
                              ),
                              alignment: pw.Alignment.center,
                              child: pw.Text(
                                card.initials,
                                style: pw.TextStyle(
                                  color: PdfColors.white,
                                  fontSize: 26,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),

                            pw.SizedBox(height: 12),

                            // Full Employee Name
                            pw.Text(
                              card.name.toUpperCase(),
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: 15,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromHex('111827'),
                                letterSpacing: 0.5,
                              ),
                            ),

                            pw.SizedBox(height: 3),

                            // Designation
                            pw.Text(
                              card.designation,
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: 11,
                                color: PdfColor.fromHex('475569'),
                              ),
                            ),

                            pw.SizedBox(height: 6),

                            // Employee ID
                            pw.Text(
                              'ID: ${card.employeeNumber}',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: 11,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromHex('1e293b'),
                              ),
                            ),
                          ],
                        ),

                        // Scannable QR Code generated from card.qrValue
                        pw.Container(
                          padding: const pw.EdgeInsets.all(6),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.white,
                            border: pw.Border.all(
                              color: PdfColor.fromHex('e2e8f0'),
                              width: 0.8,
                            ),
                            borderRadius: const pw.BorderRadius.all(
                              pw.Radius.circular(8),
                            ),
                          ),
                          child: pw.BarcodeWidget(
                            barcode: pw.Barcode.qrCode(
                              errorCorrectLevel:
                                  pw.BarcodeQRCorrectionLevel.medium,
                            ),
                            data: card.qrValue.isNotEmpty
                                ? card.qrValue
                                : 'AMS1:MX0zbHeRVbzPIlBb8SjAwBChWK0oZvsb',
                            width: 86,
                            height: 86,
                            color: PdfColor.fromHex('111827'),
                          ),
                        ),

                        // Company Name Footer
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 4),
                          child: pw.Text(
                            card.company.name.toUpperCase(),
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('1e293b'),
                              letterSpacing: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Accent Bar
                pw.Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: pw.Container(
                    height: 5,
                    color: cardColor,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // -------------------------------------------------------------
    // PAGE 2: BACK FACE
    // -------------------------------------------------------------
    pdf.addPage(
      pw.Page(
        pageFormat: cardPageFormat,
        build: (pw.Context context) {
          final company = card.company;
          final address = company.address ?? 'test ad 1, Islamabad, 44000';
          final phone = company.phone ?? card.phone ?? '03155109822';

          return pw.Container(
            width: 270,
            height: 430,
            color: PdfColors.white,
            child: pw.Stack(
              children: [
                pw.Positioned.fill(
                  bottom: 6,
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.fromLTRB(16, 20, 16, 12),
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        // Top Section: Company Name, Emblem & Location Address
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text(
                              company.name.toUpperCase(),
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromHex('1e293b'),
                                letterSpacing: 1.2,
                              ),
                            ),

                            pw.SizedBox(height: 8),

                            // Corporate Emblem / Building Svg Icon
                            pw.SvgImage(
                              svg:
                                  '<svg viewBox="0 0 24 24" width="32" height="32" fill="#334155"><path d="M12 2L4 6v2h16V6l-8-4zm-7 8v8h2v-8H5zm5 0v8h2v-8h-2zm5 0v8h2v-8h-2zm5 0v8h2v-8h-2zM3 20v2h18v-2H3z"/></svg>',
                              width: 32,
                              height: 32,
                            ),

                            pw.SizedBox(height: 8),

                            // Location Address
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.SvgImage(
                                  svg:
                                      '<svg viewBox="0 0 24 24" width="10" height="10" fill="#64748b"><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/></svg>',
                                  width: 10,
                                  height: 10,
                                ),
                                pw.SizedBox(width: 4),
                                pw.Flexible(
                                  child: pw.Text(
                                    address,
                                    textAlign: pw.TextAlign.center,
                                    maxLines: 2,
                                    style: pw.TextStyle(
                                      fontSize: 8.5,
                                      color: PdfColor.fromHex('64748b'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Middle Section: Terms & Conditions Bullets
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromHex('f8fafc'),
                            borderRadius: const pw.BorderRadius.all(
                              pw.Radius.circular(8),
                            ),
                            border: pw.Border.all(
                              color: PdfColor.fromHex('e2e8f0'),
                              width: 0.8,
                            ),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _buildBullet(
                                'This card remains the property of ${company.name}.',
                              ),
                              pw.SizedBox(height: 6),
                              _buildBullet(
                                'If found, please return it to the address above.',
                              ),
                              pw.SizedBox(height: 6),
                              _buildBullet(
                                'The card holder is not authorised to collect company dues or payments.',
                              ),
                            ],
                          ),
                        ),

                        // Bottom Section: Phone, Email, Issuance Subtitle
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.SvgImage(
                                  svg:
                                      '<svg viewBox="0 0 24 24" width="9" height="9" fill="#1e293b"><path d="M6.62 10.79c1.44 2.83 3.76 5.14 6.59 6.59l2.2-2.2c.27-.27.67-.36 1.02-.24 1.12.37 2.33.57 3.57.57.55 0 1 .45 1 1V20c0 .55-.45 1-1 1-9.39 0-17-7.61-17-17 0-.55.45-1 1-1h3.5c.55 0 1 .45 1 1 0 1.25.2 2.45.57 3.57.11.35.03.74-.25 1.02l-2.2 2.2z"/></svg>',
                                  width: 9,
                                  height: 9,
                                ),
                                pw.SizedBox(width: 5),
                                pw.Text(
                                  phone,
                                  style: pw.TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColor.fromHex('1e293b'),
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 4),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.SvgImage(
                                  svg:
                                      '<svg viewBox="0 0 24 24" width="9" height="9" fill="#64748b"><path d="M20 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/></svg>',
                                  width: 9,
                                  height: 9,
                                ),
                                pw.SizedBox(width: 5),
                                pw.Text(
                                  'siddique.softech@gmail.com',
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    color: PdfColor.fromHex('64748b'),
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 8),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(
                                  'Card ${card.cardNo}',
                                  style: pw.TextStyle(
                                    fontSize: 7.5,
                                    color: PdfColor.fromHex('94a3b8'),
                                  ),
                                ),
                                if (card.formattedIssuedDate.isNotEmpty) ...[
                                  pw.Container(
                                    margin: const pw.EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width: 2.5,
                                    height: 2.5,
                                    decoration: pw.BoxDecoration(
                                      color: PdfColor.fromHex('94a3b8'),
                                      shape: pw.BoxShape.circle,
                                    ),
                                  ),
                                  pw.Text(
                                    'Issued ${card.formattedIssuedDate}',
                                    style: pw.TextStyle(
                                      fontSize: 7.5,
                                      color: PdfColor.fromHex('94a3b8'),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Accent Bar
                pw.Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: pw.Container(
                    height: 5,
                    color: cardColor,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildBullet(String text) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 2.5, right: 6),
          width: 3,
          height: 3,
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('334155'),
            shape: pw.BoxShape.circle,
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            text,
            style: pw.TextStyle(
              fontSize: 7.5,
              color: PdfColor.fromHex('334155'),
              lineSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
