import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // Added import for Icons

enum DocumentType { contract, certificate, payslip, policy, other }

class DocumentMetadataModel {
  final String id;
  final String userId; // Which user this document belongs to
  final String documentName; // e.g., "Contrat de travail 2024"
  final DocumentType type;
  final Timestamp uploadDate;
  final Timestamp? expiryDate; // Optional, e.g., for certificates
  final String uploadedByUid; // User who added the metadata entry
  // NO file path or download URL needed as we are not using Storage

  DocumentMetadataModel({
    required this.id,
    required this.userId,
    required this.documentName,
    required this.type,
    required this.uploadDate,
    this.expiryDate,
    required this.uploadedByUid,
  });

   factory DocumentMetadataModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
     if (data == null) throw Exception("Document metadata is null!");

    return DocumentMetadataModel(
      id: snapshot.id,
      userId: data['userId'] ?? '',
      documentName: data['documentName'] ?? '',
      type: _typeFromString(data['type']),
      uploadDate: data['uploadDate'] ?? Timestamp.now(),
      expiryDate: data['expiryDate'], // Can be null
      uploadedByUid: data['uploadedByUid'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'documentName': documentName,
      'type': _typeToString(type),
      'uploadDate': uploadDate,
      if (expiryDate != null) 'expiryDate': expiryDate,
      'uploadedByUid': uploadedByUid,
    };
  }

   static DocumentType _typeFromString(String? typeStr) {
    switch(typeStr) {
      case 'contract': return DocumentType.contract;
      case 'certificate': return DocumentType.certificate;
      case 'payslip': return DocumentType.payslip;
      case 'policy': return DocumentType.policy;
      case 'other': return DocumentType.other;
      default: return DocumentType.other;
    }
  }

   static String _typeToString(DocumentType type) => type.name;

   // --- Helpers for display ---
   String get typeDisplay {
     switch (type) {
       case DocumentType.contract: return 'Contrat';
       case DocumentType.certificate: return 'Certificat / Attestation';
       case DocumentType.payslip: return 'Fiche de paie';
       case DocumentType.policy: return 'Politique interne';
       case DocumentType.other: return 'Autre';
     }
   }

    IconData get typeIcon {
      switch (type) {
        case DocumentType.contract: return Icons.description_outlined;
        case DocumentType.certificate: return Icons.school_outlined;
        case DocumentType.payslip: return Icons.receipt_long_outlined;
        case DocumentType.policy: return Icons.policy_outlined;
        case DocumentType.other: return Icons.attach_file;
      }
    }

}