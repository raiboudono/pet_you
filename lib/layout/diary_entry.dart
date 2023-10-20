import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/diary/ui/diary_list.dart';

class DiaryEntry extends ConsumerWidget {
  const DiaryEntry({super.key});

  @override
  Widget build(context, ref) {
    return Container(
      // color: Colors.blue,
      padding: const EdgeInsets.only(left: 0),
      height: 60,
      child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DiaryList()),
                );
              },
              child: Row(children: [
                CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(.12),
                    foregroundColor: Colors.black,
                    radius: 15,
                    child: const Icon(
                      size: 20,
                      Icons.create_outlined,
                      // color: Colors.white,
                    )),
                const SizedBox(width: 5),
                const Text("日記",
                    style: TextStyle(
                      fontSize: 9,
                      // color: Colors.black,
                    )),
                const SizedBox(width: 3),
              ]))),
    );
  }
}
