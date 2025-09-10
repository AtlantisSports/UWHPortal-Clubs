import "package:flutter/material.dart";
import "../../base/widgets/phone_modal_utils.dart";

class BulkRSVPScreen extends StatelessWidget {
  final String? clubId;
  
  const BulkRSVPScreen({super.key, this.clubId});
  
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PhoneModalUtils.showPhoneModal(
        context: context,
        child: const BulkRSVPModal(),
      );
    });
    
    return Scaffold(
      appBar: AppBar(title: const Text("Bulk RSVP")),
      body: const Center(child: Text("Loading Bulk RSVP...")),
    );
  }
}

class BulkRSVPModal extends StatelessWidget {
  const BulkRSVPModal({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 600,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text("Bulk RSVP Modal - Fixed!", 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
