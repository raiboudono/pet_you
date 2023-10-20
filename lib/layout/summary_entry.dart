import 'package:flutter/material.dart';
import 'summary.dart';

class SummaryEntry extends StatelessWidget {
  const SummaryEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.blue.withOpacity(.3),
      padding: const EdgeInsets.only(right: 0),
      height: 70,
      child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
              onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Summary()),
                  ),
              child: Row(children: [
                CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(.12),
                    foregroundColor: Colors.black,
                    radius: 15,
                    child: const Icon(
                      size: 20,
                      Icons.summarize_outlined,
                      // color: Colors.white,
                    )),
                const SizedBox(width: 5),
                const Text("まとめ",
                    style: TextStyle(
                      fontSize: 9,
                      // color: Colors.black,
                    )),
                const SizedBox(width: 3),
              ]))),
    );
  }
}
