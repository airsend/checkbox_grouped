import 'package:auto_size_text/auto_size_text.dart';
import 'package:checkbox_grouped/src/controller/group_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import './circulaire_checkbox.dart';
import './item.dart';
import 'StateGroup.dart';

typedef onChanged = Function(dynamic selected);

/// display  simple groupedCheckbox
/// [controller] :  (required) Group Controller to recuperate selectionItems and disable or enableItems
/// [itemsTitle] :  (required) A list of strings that describes each checkbox button
/// [values] : list of values
/// [onItemSelected] : list of initial values that you want to be selected
/// [itemsSubTitle] : A list of strings that describes second Text
/// [groupTitle] : Text Widget that describe Title of group checkbox
/// [groupTitleStyle] : Text Style  that describe style of title of group checkbox
/// [activeColor] : the color to use when this checkbox button is selected
/// [disableItems] : specifies which item should be disabled
/// [preSelection] :  A list of values that you want to be initially selected
/// [checkFirstElement] : make first element in list checked
/// [isCirculaire] : enable to use circulaire checkbox
/// [isLeading] : same as [itemExtent] of [ListView]
/// [isExpandableTitle] : enable group checkbox to be expandable
/// [helperGroupTitle] : (bool) hide/show checkbox in title to help all selection or deselection,use it when you want to disable checkbox in groupTitle default:`true`
/// [groupTitleAlignment] : (Alignment) align title of checkbox group checkbox default:`Alignment.center`
/// [multiSelection] : enable multiple selection groupedCheckbox
class SimpleGroupedCheckbox<T> extends StatefulWidget {
  final GroupController controller;
  final List<String> itemsTitle;
  final onChanged onItemSelected;
  final String groupTitle;
  final AlignmentGeometry groupTitleAlignment;
  final TextStyle groupTitleStyle;
  final List<String> itemsSubTitle;
  final Color activeColor;
  final List<T> values;
  final List<String> disableItems;
  final List<T> preSelection;
  final bool checkFirstElement;
  final bool isCirculaire;
  final bool multiSelection;
  final bool isLeading;
  final bool isExpandableTitle;
  final bool helperGroupTitle;

  SimpleGroupedCheckbox({
    Key key,
    @required this.controller,
    @required this.itemsTitle,
    @required this.values,
    this.onItemSelected,
    this.groupTitle,
    this.groupTitleAlignment = Alignment.center,
    this.groupTitleStyle,
    this.itemsSubTitle,
    this.disableItems,
    this.activeColor,
    this.checkFirstElement = false,
    this.preSelection,
    this.isCirculaire = false,
    this.isLeading = false,
    this.multiSelection = false,
    this.isExpandableTitle = false,
    this.helperGroupTitle = true,
  })  : assert(values != null),
        assert(values.length == itemsTitle.length),
        assert(
            multiSelection == false &&
                    preSelection != null &&
                    (preSelection.length > 1 || checkFirstElement == true)
                ? false
                : true,
            "you cannot make multiple selection in single selection"),
        assert(itemsSubTitle != null
            ? itemsSubTitle.length == itemsTitle.length
            : true),
        assert(
            (groupTitle == null && !isExpandableTitle) ||
                (groupTitle != null && isExpandableTitle ||
                    groupTitle != null && !isExpandableTitle),
            "you cannot make isExpandable without textTitle"),
        assert(
            disableItems == null ||
                disableItems.isEmpty ||
                disableItems
                    .takeWhile((c) => itemsTitle.contains(c))
                    .isNotEmpty,
            "you cannot disable items doesn't exist in itemsTitle"),
        super(key: key);

  static SimpleGroupedCheckboxState of<T>(BuildContext context,
      {bool nullOk = false}) {
    assert(context != null);
    assert(nullOk != null);
    final SimpleGroupedCheckboxState<T> result =
        context.findAncestorStateOfType<SimpleGroupedCheckboxState<T>>();
    if (nullOk || result != null) return result;
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
          'SimpleGroupedCheckbox.of() called with a context that does not contain an SimpleGroupedCheckbox.'),
      ErrorDescription(
          'No SimpleGroupedCheckbox ancestor could be found starting from the context that was passed to SimpleGroupedCheckbox.of().'),
      context.describeElement('The context used was')
    ]);
  }

  @override
  SimpleGroupedCheckboxState<T> createState() =>
      SimpleGroupedCheckboxState<T>();
}

class SimpleGroupedCheckboxState<T>
    extends StateGroup<T, SimpleGroupedCheckbox> {
  @override
  void initState() {
    super.initState();
    init(
      values: widget.values,
      checkFirstElement: widget.checkFirstElement,
      disableItems: widget.disableItems,
      itemsTitle: widget.itemsTitle,
      multiSelection: widget.controller.isMultipleSelection,
      preSelection: widget.controller.initSelectedItem,
    );
    widget.controller.init(this);
  }

  /// [items]: A list of values that you want to be disabled
  /// disable items that match with list of strings
  @override
  void disabledItemsByValues(List<T> itemsValues) {
    assert(itemsValues.takeWhile((c) => !widget.values.contains(c)).isEmpty,
        "some of items doesn't exist");
    var items = _recuperateTitleFromValues(itemsValues);
    _itemStatus(items, true);
  }

  /// [items]: A list of strings that describes titles
  /// disable items that match with list of strings
  @override
  void disabledItemsByTitles(List<String> items) {
    assert(items.takeWhile((c) => !widget.itemsTitle.contains(c)).isEmpty,
        "some of items doesn't exist");
    _itemStatus(items, true);
  }

  /// [items]: A list of strings that describes titles
  /// disable items that match with list of strings
  @Deprecated("use disabledItemsByTitles,will be remove in future version")
  disabledItems(List<String> items) {
    assert(items.takeWhile((c) => !widget.itemsTitle.contains(c)).isEmpty,
        "some of items doesn't exist");
    _itemStatus(items, true);
  }

  /// [items]: A list of strings that describes titles
  /// enable items that match with list of strings
  @Deprecated("use enabledItemsByTitles,will be removed in future version")
  void enabledItems(List<String> items) {
    assert(items.takeWhile((c) => !widget.itemsTitle.contains(c)).isEmpty,
        "some of items doesn't exist");
    _itemStatus(items, false);
  }

  /// [items]: A list of values
  /// enable items that match with list of dynamics
  @override
  void enabledItemsByValues(List<T> itemsValues) {
    assert(itemsValues.takeWhile((c) => !widget.values.contains(c)).isEmpty,
        "some of items doesn't exist");
    var items = _recuperateTitleFromValues(itemsValues);
    _itemStatus(items, false);
  }

  /// [items]: A list of strings that describes titles
  /// enable items that match with list of strings
  @override
  void enabledItemsByTitles(List<String> items) {
    assert(items.takeWhile((c) => !widget.itemsTitle.contains(c)).isEmpty,
        "some of items doesn't exist");
    _itemStatus(items, false);
  }

  List<String> _recuperateTitleFromValues(List<T> itemsValues) {
    return itemsValues.map((e) {
      var indexOfItem = widget.values.indexOf(e);
      return widget.itemsTitle[indexOfItem];
    }).toList();
  }

  void _itemStatus(List<String> items, bool isDisabled) {
    notifierItems
        .where((element) => items.contains(element.value.title))
        .toList()
        .asMap()
        .forEach((key, notifierItem) {
      var index = notifierItems.indexOf(notifierItem);
      Item item = Item(
          isDisabled: notifierItem.value.isDisabled,
          checked: notifierItem.value.checked,
          title: notifierItem.value.title);
      item.isDisabled = isDisabled;
      notifierItems[index].value = item;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget childListChecks = ListView.builder(
      itemCount: notifierItems.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemBuilder: (ctx, i) {
        return ValueListenableBuilder<Item>(
          valueListenable: notifierItems[i],
          builder: (ctx, item, child) {
            return _CheckboxItem<T>(
              index: i,
              item: item,
              onChangedCheckBox: (index, v) {
                onChanged(i, v);
              },
              selectedValue: selectedValue.value,
              value: widget.values[i],
              activeColor: widget.activeColor,
              isCirculaire: widget.isCirculaire,
              isLeading: widget.isLeading,
              itemSubTitle: widget.itemsSubTitle != null &&
                      widget.itemsSubTitle.isNotEmpty
                  ? widget.itemsSubTitle[i]
                  : null,
              isMultpileSelection: widget.multiSelection,
            );
          },
        );
      },
    );
    if (widget.groupTitle != null && widget.isExpandableTitle) {
      return _ExpansionCheckBoxList(
        listChild: childListChecks,
        titleWidget: _TitleGroupedCheckbox(
          title: widget.groupTitle,
          titleStyle: widget.groupTitleStyle,
          isMultiSelection: widget.multiSelection,
          alignment: widget.groupTitleAlignment,
          checkboxTitle: widget.helperGroupTitle
              ? ValueListenableBuilder(
                  valueListenable: valueTitle,
                  builder: (ctx, selected, _) {
                    return Checkbox(
                      tristate: true,
                      value: selected,
                      activeColor: widget.activeColor,
                      onChanged: (v) {
                        setState(() {
                          if (v != null) valueTitle.value = v;
                        });
                      },
                    );
                  },
                )
              : null,
          callback: setChangedCallback,
        ),
      );
    }
    if (widget.groupTitle != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _TitleGroupedCheckbox(
            title: widget.groupTitle,
            titleStyle: widget.groupTitleStyle,
            isMultiSelection: widget.multiSelection,
            checkboxTitle: widget.helperGroupTitle
                ? ValueListenableBuilder(
                    valueListenable: valueTitle,
                    builder: (ctx, selected, _) {
                      return Checkbox(
                        tristate: true,
                        value: selected,
                        activeColor: widget.activeColor,
                        onChanged: (v) {
                          setState(
                            () {
                              if (v != null) valueTitle.value = v;
                            },
                          );
                        },
                      );
                    },
                  )
                : null,
            callback: setChangedCallback,
          ),
          childListChecks,
        ],
      );
    }
    return childListChecks;
  }

  /// callback title grouped when clicked it disabled all selected or select all elements
  void setChangedCallback() {
    setState(() {
      if (valueTitle.value == null) {
        valueTitle.value = true;
        selectionsValue.addAll(widget.values
            .where((elem) => selectionsValue.contains(elem) == false));
      } else if (valueTitle.value) {
        valueTitle.value = false;
        selectionsValue.clear();
      } else if (!valueTitle.value) {
        valueTitle.value = true;
        selectionsValue.addAll(widget.values as List<T>);
      } else {
        valueTitle.value = true;
      }
      //callback
      if (widget.onItemSelected != null) widget.onItemSelected(selectionsValue);
    });
    notifierItems
        .where((e) => e.value.checked != valueTitle.value)
        .toList()
        .forEach((element) {
      Item item = element.value;
      item.checked = valueTitle.value;
      element.value = item;
    });
  }

  void onChanged(int i, dynamic v) {
    Item item = Item(
      title: notifierItems[i].value.title,
      checked: notifierItems[i].value.checked,
      isDisabled: notifierItems[i].value.isDisabled,
    );
    if (widget.multiSelection) {
      if (!selectionsValue.contains(widget.values[i])) {
        if (v) {
          selectionsValue.add(widget.values[i]);
        }
      } else {
        if (!v) {
          selectionsValue.remove(widget.values[i]);
        }
      }
      if (selectionsValue.length == widget.values.length) {
        valueTitle.value = true;
      } else if (selectionsValue.length == 0) {
        valueTitle.value = false;
      } else {
        valueTitle.value = null;
      }
      //_items[i].checked = v;

      if (widget.onItemSelected != null) widget.onItemSelected(selectionsValue);

      item.checked = v;
    } else {
      selectedValue.value = v;
      /*if (_previousActive != null) {
        _previousActive.checked = false;
      }
      _items[i].checked = true;
      _previousActive = _items[i];*/
      var notifierPrevious = notifierItems
          .firstWhere((element) => element.value.checked, orElse: () => null);
      if (notifierPrevious != null) {
        var indexPrevious = notifierItems.indexOf(notifierPrevious);
        var previous = Item(
          title: notifierPrevious.value.title,
          checked: notifierPrevious.value.checked,
          isDisabled: notifierPrevious.value.isDisabled,
        );
        previous.checked = false;
        notifierItems[indexPrevious].value = previous;
      }
      item.checked = true;
      notifierItems[i].value = item;
      if (widget.onItemSelected != null)
        widget.onItemSelected(selectedValue.value);
    }
    notifierItems[i].value = item;
  }

  @override
  selection() {
    if (widget.multiSelection) {
      return selectionsValue;
    }
    return selectedValue.value;
  }
}

class _TitleGroupedCheckbox extends StatelessWidget {
  final String title;
  final TextStyle titleStyle;
  final AlignmentGeometry alignment;
  final bool isMultiSelection;
  final VoidCallback callback;
  final Widget checkboxTitle;

  _TitleGroupedCheckbox({
    this.title,
    this.titleStyle,
    this.isMultiSelection,
    this.callback,
    this.checkboxTitle,
    this.alignment = Alignment.center,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleWidget = Text(
      title,
      style: titleStyle ??
          TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
    );
    if (isMultiSelection && title != null && checkboxTitle != null) {
      return ListTile(
        title: titleWidget,
        onTap: () {
          callback();
        },
        leading: AbsorbPointer(
          child: Container(
            width: 32,
            height: 32,
            child: checkboxTitle,
          ),
        ),
      );
    }
    if (title != null)
      return Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 5.0,
            right: 5.0,
          ),
          child: titleWidget,
        ),
      );

    return Container();
  }
}

class _CheckboxItem<T> extends StatelessWidget {
  final bool isCirculaire;
  final bool isMultpileSelection;
  final bool isLeading;
  final T value;
  final T selectedValue;
  final Item item;
  final String itemSubTitle;
  final int index;
  final Color activeColor;
  final Function(int i, dynamic v) onChangedCheckBox;

  _CheckboxItem({
    this.isCirculaire = false,
    this.isMultpileSelection = false,
    this.isLeading = false,
    this.activeColor,
    @required this.item,
    this.itemSubTitle,
    @required this.value,
    @required this.selectedValue,
    @required this.index,
    @required this.onChangedCheckBox,
  });

  @override
  Widget build(BuildContext context) {
    if (isCirculaire) {
      Widget circulaireWidget = CirculaireCheckbox(
        isChecked: item.checked,
        color: activeColor,
      );
      return ListTile(
        onTap: item.isDisabled
            ? null
            : () {
                onChangedCheckBox(index, value);
                /*setState(() {
            onChanged(i, widget.values[i]);
          });*/
              },
        title: AutoSizeText(
          "${item.title}",
          minFontSize: 12,
        ),
        subtitle: itemSubTitle != null
            ? AutoSizeText(
                itemSubTitle,
                minFontSize: 11,
              )
            : null,
        leading: isLeading ? circulaireWidget : null,
        trailing: !isLeading ? circulaireWidget : null,
      );
    }
    if (!isMultpileSelection) {
      return RadioListTile<T>(
        groupValue: selectedValue,
        onChanged: item.isDisabled
            ? null
            : (v) {
                onChangedCheckBox(index, v);
              },
        activeColor: activeColor ?? Theme.of(context).primaryColor,
        title: AutoSizeText(
          "${item.title}",
          minFontSize: 12,
        ),
        subtitle: itemSubTitle != null
            ? AutoSizeText(
                itemSubTitle,
                minFontSize: 11,
              )
            : null,
        value: value,
        selected: item.checked,
        dense: itemSubTitle != null ? true : false,
        isThreeLine: itemSubTitle != null ? true : false,
        controlAffinity: isLeading
            ? ListTileControlAffinity.leading
            : ListTileControlAffinity.trailing,
      );
    }

    return CheckboxListTile(
      onChanged: item.isDisabled
          ? null
          : (v) {
              //setState(() {
              onChangedCheckBox(index, v);
              //});
            },
      activeColor: activeColor ?? Theme.of(context).primaryColor,
      title: AutoSizeText(
        item.title,
        minFontSize: 12,
      ),
      subtitle: itemSubTitle != null
          ? AutoSizeText(
              itemSubTitle,
              minFontSize: 11,
            )
          : null,
      value: item.checked,
      dense: itemSubTitle != null ? true : false,
      isThreeLine: itemSubTitle != null ? true : false,
      controlAffinity: isLeading
          ? ListTileControlAffinity.leading
          : ListTileControlAffinity.trailing,
    );
  }
}

class _ExpansionCheckBoxList extends StatefulWidget {
  final Widget listChild;
  final Widget titleWidget;

  _ExpansionCheckBoxList({
    this.listChild,
    this.titleWidget,
  });

  @override
  State<StatefulWidget> createState() => _ExpansionCheckBoxListState();
}

class _ExpansionCheckBoxListState extends State<_ExpansionCheckBoxList> {
  bool isExpanded;

  @override
  void initState() {
    super.initState();
    isExpanded = false;
  }

  @override
  void didUpdateWidget(_ExpansionCheckBoxList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listChild != widget.listChild) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      expansionCallback: (index, value) {
        setState(() {
          isExpanded = !value;
        });
      },
      children: [
        ExpansionPanel(
          isExpanded: isExpanded,
          headerBuilder: (ctx, value) {
            return widget.titleWidget;
          },
          body: widget.listChild,
        ),
      ],
    );
  }
}
