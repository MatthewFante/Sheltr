import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:untitled/models/meet_and_greet_request.dart';
import 'package:untitled/models/pet.dart';

class NewMeetAndGreetRequestModal extends StatefulWidget {
  final Pet pet;

  const NewMeetAndGreetRequestModal({Key? key, required this.pet})
      : super(key: key);

  @override
  _NewMeetAndGreetRequestModalState createState() =>
      _NewMeetAndGreetRequestModalState();
}

class _NewMeetAndGreetRequestModalState
    extends State<NewMeetAndGreetRequestModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _notesController;
  late DateTime selectedDate;
  late TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    _timeController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        _dateController.text = DateFormat.yMd().format(pickedDate);
      });
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
        _timeController.text = pickedTime.format(context);
      });
    }
  }

  Future<void> _createMeetAndGreetRequest() async {
    if (_formKey.currentState!.validate()) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Please sign in to request a meet and greet")),
        );
        return;
      }

      final requesterId = currentUser.uid;
      final petId = widget.pet.documentId;
      final meetDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
      final meetTime = _timeController.text;
      final notes = _notesController.text;

      try {
        await MeetAndGreetRequest.createMeetAndGreetRequest(
          requesterId: requesterId,
          petId: petId,
          meetDate: meetDate,
          meetTime: meetTime,
          notes: notes,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Meet and Greet request submitted!")),
        );

        Navigator.pop(context); // Close the modal after submitting
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error submitting request: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Request a Meet & Greet",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              // Date Picker
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Meet Date",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: _pickDate,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a date";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              // Time Picker
              TextFormField(
                controller: _timeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Meet Time",
                  suffixIcon: Icon(Icons.access_time),
                ),
                onTap: _pickTime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a time";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              // Notes Field
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: "Notes (optional)",
                ),
                maxLines: 2,
              ),
              SizedBox(height: 16.0),
              // Submit Button
              ElevatedButton(
                onPressed: _createMeetAndGreetRequest,
                child: Text("Submit Request"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
