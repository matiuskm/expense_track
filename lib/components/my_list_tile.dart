// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyListTile extends StatelessWidget {
  final String title;
  final String date;
  final String trailing;
  final void Function(BuildContext) onEditPressed;
  final void Function(BuildContext) onDeletePressed;

  const MyListTile({
    super.key,
    required this.title,
    required this.date,
    required this.trailing,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(motion: const StretchMotion(), children: [
        // settings option
        SlidableAction(
          onPressed: onEditPressed,
          icon: Icons.edit,
          foregroundColor: Colors.white,
          backgroundColor: Colors.grey,
        ),
        // delete option
        SlidableAction(
          onPressed: onDeletePressed,
          icon: Icons.delete,
          foregroundColor: Colors.white,
          backgroundColor: Colors.red,
        )
      ]),
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            Text(
              date,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        trailing: Text(trailing),
      ),
    );
  }
}
