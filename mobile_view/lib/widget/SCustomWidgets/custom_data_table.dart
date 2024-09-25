import 'package:flutter/material.dart';

import 'custom_paginated_data_table.dart';
 class CustomDataTable extends StatelessWidget {
  final String? headerText;
  final List<DataColumn> columns;
  final List<dynamic> dataList;
  final int rowsPerPage;
  final List<DataRow> rows;
  final IconData? icon;
  final List<DataCell>? dataCell;
  final List<DataCell Function(Map<String, dynamic>, int)> cellBuilders;
  final double dataRowMaxHeight;
  final double dataRowMinHeight;
  final double columnSpacing;

  CustomDataTable({
    Key? key,
    this.headerText,
    required this.columns,
    required this.dataList,
    required this.rowsPerPage,
    required this.cellBuilders,
    this.icon,
    this.dataCell,
    this.dataRowMaxHeight = 50,
    this.dataRowMinHeight = 30,
    this.columnSpacing = 10,
  }) : rows = dataList.asMap().entries.map((entry) {
    int index = entry.key;
    dynamic data = entry.value;
    return DataRow(
      color: const MaterialStatePropertyAll<Color>(Colors.white),
      cells: List.generate(columns.length, (cellIndex) {
        return cellBuilders[cellIndex](data, index);
      }),
    );
  }).toList(),
        super(key: key);

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: scrollController,
      child: CustomPaginatedDataTable(
        controller: scrollController,
        columnSpacing: columnSpacing,
        arrowHeadColor: Theme.of(context).primaryColor,
        headingRowColor: MaterialStatePropertyAll<Color>(Theme.of(context).primaryColor),
        headingRowHeight: 40,
        showFirstLastButtons: rowsPerPage > rows.length ? true : false,
        dataRowMaxHeight: dataRowMaxHeight,
        dataRowMinHeight: dataRowMinHeight,
        header: headerText != null ?Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 20),
            Text(headerText ?? "", style: TextStyle(color: Theme.of(context).primaryColor)),
          ],
        ): null,
        rowsPerPage: rowsPerPage,
        columns: columns,
        source: CustomDataTableSource(rows),
      ),
    );
  }
}

class CustomDataTableSource extends DataTableSource {
  final List<DataRow> _rows;

  CustomDataTableSource(this._rows);

  @override
  DataRow getRow(int index) => _rows[index];

  @override
  int get rowCount => _rows.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
