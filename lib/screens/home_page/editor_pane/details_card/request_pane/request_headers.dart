import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:davi/davi.dart';
import 'package:apidash/providers/providers.dart';
import 'package:apidash/widgets/widgets.dart';
import 'package:apidash/models/models.dart';
import 'package:apidash/consts.dart';

class EditRequestHeaders extends ConsumerStatefulWidget {
  const EditRequestHeaders({super.key});

  @override
  ConsumerState<EditRequestHeaders> createState() => EditRequestHeadersState();
}

class EditRequestHeadersState extends ConsumerState<EditRequestHeaders> {
  final random = Random.secure();
  late List<NameValueModel> rows;
  late List<bool> isRowEnabledList;
  late int seed;

  @override
  void initState() {
    super.initState();
    seed = random.nextInt(kRandMax);
  }

  void _onFieldChange(String selectedId) {
    ref.read(collectionStateNotifierProvider.notifier).update(
          selectedId,
          requestHeaders: rows,
          isHeaderEnabledList: isRowEnabledList,
        );
  }

  @override
  Widget build(BuildContext context) {
    final selectedId = ref.watch(selectedIdStateProvider);
    ref.watch(selectedRequestModelProvider
        .select((value) => value?.requestHeaders?.length));
    var rH = ref.read(selectedRequestModelProvider)?.requestHeaders;
    bool isHeadersEmpty = rH == null || rH.isEmpty;
    rows = (isHeadersEmpty)
        ? [
            kNameValueEmptyModel,
          ]
        : rH;
    isRowEnabledList = ref
            .read(selectedRequestModelProvider)
            ?.isHeaderEnabledList ??
        List.filled(rows.length, isHeadersEmpty ? false : true, growable: true);

    DaviModel<NameValueModel> model = DaviModel<NameValueModel>(
      rows: rows,
      columns: [
        DaviColumn(
          name: 'Checkbox',
          width: 30,
          cellBuilder: (_, row) {
            int idx = row.index;
            return CheckBox(
              keyId: "$selectedId-$idx-headers-c-$seed",
              value: isRowEnabledList[idx],
              onChanged: rows.length == 1 &&
                      idx == 0 &&
                      rows[idx].name.isEmpty &&
                      rows[idx].value.isEmpty
                  ? null
                  : (value) {
                      setState(() {
                        isRowEnabledList[idx] = value!;
                      });
                      _onFieldChange(selectedId!);
                    },
              colorScheme: Theme.of(context).colorScheme,
            );
          },
        ),
        DaviColumn(
          name: 'Header Name',
          width: 70,
          grow: 1,
          cellBuilder: (_, row) {
            int idx = row.index;
            return HeaderField(
              keyId: "$selectedId-$idx-headers-k-$seed",
              initialValue: rows[idx].name,
              hintText: "Add Header Name",
              onChanged: (value) {
                isRowEnabledList[idx] = true;
                rows[idx] = rows[idx].copyWith(name: value);
                if (idx == rows.length - 1) {
                  rows.add(kNameValueEmptyModel);
                  isRowEnabledList.add(false);
                }
                _onFieldChange(selectedId!);
              },
              colorScheme: Theme.of(context).colorScheme,
            );
          },
          sortable: false,
        ),
        DaviColumn(
          width: 30,
          cellBuilder: (_, row) {
            return Text(
              "=",
              style: kCodeStyle,
            );
          },
        ),
        DaviColumn(
          name: 'Header Value',
          grow: 1,
          cellBuilder: (_, row) {
            int idx = row.index;
            return CellField(
              keyId: "$selectedId-$idx-headers-v-$seed",
              initialValue: rows[idx].value,
              hintText: " Add Header Value",
              onChanged: (value) {
                rows[idx] = rows[idx].copyWith(value: value);
                if (idx == rows.length - 1) {
                  rows.add(kNameValueEmptyModel);
                  isRowEnabledList.add(false);
                }
                _onFieldChange(selectedId!);
              },
              colorScheme: Theme.of(context).colorScheme,
            );
          },
          sortable: false,
        ),
        DaviColumn(
          pinStatus: PinStatus.none,
          width: 30,
          cellBuilder: (_, row) {
            return InkWell(
              child: Theme.of(context).brightness == Brightness.dark
                  ? kIconRemoveDark
                  : kIconRemoveLight,
              onTap: () {
                seed = random.nextInt(kRandMax);
                if (rows.length == 1) {
                  setState(() {
                    rows = [
                      kNameValueEmptyModel,
                    ];
                    isRowEnabledList = [false];
                  });
                } else {
                  rows.removeAt(row.index);
                  isRowEnabledList.removeAt(row.index);
                }
                _onFieldChange(selectedId!);
              },
            );
          },
        ),
      ],
    );
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: kBorderRadius12,
      ),
      margin: kP10,
      child: Column(
        children: [
          Expanded(
            child: DaviTheme(
              data: kTableThemeData,
              child: Davi<NameValueModel>(model),
            ),
          ),
        ],
      ),
    );
  }
}
