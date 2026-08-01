import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:animations_in_flutter/model/trip.dart';

class PdfExportService {
  static Future<void> exportTrip(Trip trip) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              trip.title,
              style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '${trip.date.day}/${trip.date.month}/${trip.date.year} · ${trip.nights} nights · ${trip.currency}',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue100,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  trip.category.name.toUpperCase(),
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.SizedBox(width: 8),
              if (trip.rating > 0)
                pw.Text(
                  '★ ${trip.rating.toStringAsFixed(1)}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              pw.SizedBox(width: 8),
              pw.Text(
                '${trip.price.toStringAsFixed(0)} ${trip.currency}',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          if (trip.description.isNotEmpty) ...[
            pw.Text(
              'Description',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(trip.description),
            pw.SizedBox(height: 16),
          ],
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Text(
            'Exported from Trip Recorder',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
          ),
        ],
      ),
    );
    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
      name: '${trip.title} - Trip Recorder',
    );
  }

  static Future<void> exportReport(List<Trip> trips, String year) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Annual Travel Report $year',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '${trips.length} trips',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 12),
          pw.Divider(),
          ...trips.map((trip) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 16),
                pw.Text(
                  trip.title,
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '${trip.date.day}/${trip.date.month}/${trip.date.year} · ${trip.nights} nights · ${trip.currency}',
                  style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue100,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        trip.category.name.toUpperCase(),
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    if (trip.rating > 0)
                      pw.Text(
                        '★ ${trip.rating.toStringAsFixed(1)}',
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    pw.SizedBox(width: 8),
                    pw.Text(
                      '${trip.price.toStringAsFixed(0)} ${trip.currency}',
                      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                if (trip.description.isNotEmpty) ...[
                  pw.SizedBox(height: 6),
                  pw.Text(trip.description, style: const pw.TextStyle(fontSize: 11)),
                ],
                pw.SizedBox(height: 8),
                pw.Divider(),
              ],
            );
          }),
          pw.SizedBox(height: 8),
          pw.Text(
            'Exported from Trip Recorder',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
          ),
        ],
      ),
    );
    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
      name: 'Annual Report $year - Trip Recorder',
    );
  }
}
