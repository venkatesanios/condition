import 'package:flutter/material.dart';

class DetailsSection extends StatelessWidget {
final Map<String, dynamic> data;
final VoidCallback onClose;
List<List<String>> valveNames = [];


DetailsSection({required this.data, required this.onClose}) {
  extractValveNames();
}

void extractValveNames() {

  Map<String, List<String>> valveNamesMap = {};

  for (var group in data['group']) {
    List<String> names = [];
    for (var valve in group['valve']) {
      names.add(valve['name']);
    }
    valveNamesMap[group['name']] = names;
  }

  valveNames = valveNamesMap.values.toList();
}

@override
Widget build(BuildContext context) {
  return Stack(
    children: [
      GestureDetector(
        onTap: onClose,
        child: Container(
          color: Colors.transparent,
          constraints: const BoxConstraints.expand(),
        ),
      ),
      Center(
        child: Container(
          // width: MediaQuery.of(context).size.width * 0.8,
          // height: 300,
          color: Colors.grey[200],
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Spacer(),
                  const Text(
                    'Group Details',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.red,
                    ),
                    onPressed: onClose,
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const <DataColumn>[
                      DataColumn(
                        label: Text(
                          'Sno',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Group',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Line',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Valve',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                    rows: List.generate(data['group'].length, (index) {

                      return DataRow(cells: [
                        DataCell(Text(data['group'][index]['sNo'].toString())),
                        DataCell(Text(data['group'][index]['name'].toString())),
                        DataCell(Text(data['group'][index]['location'].toString())),
                        DataCell(Text(valveNames[index].toString())),
                      ]);
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
}

