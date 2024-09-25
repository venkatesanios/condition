import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../screens/customer/Planning/NewIrrigationProgram/irrigation_program_main.dart';
import 'custom_drop_down.dart';
import 'custom_native_time_picker.dart';

class CustomSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showSubTitle;
  final bool value;
  final Function(bool) onChanged;
  final IconData? icon;
  final bool showCircleAvatar;
  final BorderRadius? borderRadius;

  const CustomSwitchTile({super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.icon,
    this.borderRadius,
    this.subtitle,
    this.showSubTitle = false,
    this.showCircleAvatar = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      subtitle: showSubTitle ? Text(subtitle ?? '') : null,
      contentPadding: showSubTitle ? const EdgeInsets.symmetric(horizontal: 10) : const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      leading: showCircleAvatar ? Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: linearGradientLeading,
          ),
          child: CircleAvatar(backgroundColor: Colors.transparent, child: Icon(icon, color: Colors.white))) : null,
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      trailing: SizedBox(
        width: MediaQuery.of(context).size.width < 550 ? 80 : 100,
        child: Center(
          child: Switch(
            value: value,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

class CustomTimerTile extends StatelessWidget {
  final String subtitle;
  final bool showSubTitle;
  final String? subtitle2;
  final String initialValue;
  final Widget? leading;
  final Function(String) onChanged;
  final IconData? icon;
  final bool isSeconds;
  final bool isNative;
  final Color? tileColor;
  final BorderRadius? borderRadius;
  final bool is24HourMode;
  final bool isNewTimePicker;

  const CustomTimerTile({
    Key? key,
    required this.subtitle,
    required this.initialValue,
    required this.onChanged,
    this.icon,
    this.borderRadius,
    required this.isSeconds,
    this.is24HourMode = false,
    this.tileColor,
    this.leading,
    this.isNative = false,
    this.showSubTitle = false,
    this.subtitle2,
    this.isNewTimePicker = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, BoxConstraints constraints) {
          return ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.zero,
            ),
            contentPadding: showSubTitle ? const EdgeInsets.symmetric(horizontal: 10) : const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            leading: leading ??
                Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: linearGradientLeading,
                    ),
                    child: CircleAvatar(backgroundColor: Colors.transparent, child: Icon(icon, color: Colors.white))),
            title: Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
            subtitle: showSubTitle ? Text(subtitle2 ?? '') : null,
            trailing: SizedBox(
              width: constraints.maxWidth < 550 ? 80 : 100,
              child: Center(
                child: CustomNativeTimePicker(
                  initialValue: initialValue,
                  is24HourMode: is24HourMode,
                  onChanged: onChanged,
                  isNewTimePicker: isNewTimePicker,
                ),
              ),
            ),
            tileColor: tileColor,
          );
        }
    );
  }
}

class CustomTextFormTile extends StatelessWidget {
  final String subtitle;
  final String hintText;
  final String? errorText;
  final String? initialValue;
  final TextEditingController? controller;
  final Function(String) onChanged;
  final IconData? icon;
  final BorderRadius? borderRadius;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Color? tileColor;
  final bool trailing;
  final String? trailingText;
  final String? subtitle2;

  const CustomTextFormTile({super.key,
    required this.subtitle,
    required this.hintText,
    this.controller,
    required this.onChanged,
    this.icon,
    this.borderRadius,
    this.keyboardType,
    this.inputFormatters,
    this.errorText,
    this.initialValue,
    this.tileColor,
    this.trailing = false,
    this.trailingText,
    this.subtitle2
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, BoxConstraints constraints) {
          return  ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.zero,
            ),
            contentPadding: subtitle2 != null ? const EdgeInsets.symmetric(horizontal: 10) : const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            leading: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: linearGradientLeading,
                ),
                child: CircleAvatar(backgroundColor: Colors.transparent, child: Icon(icon, color: Colors.white))),
            title: Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
            subtitle: subtitle2 != null ? Text(subtitle2 ?? "") : errorText != null ? Text(errorText!, style: const TextStyle(color: Colors.red, fontSize: 12),) : null,
            trailing: SizedBox(
              width: constraints.maxWidth < 550 ? 80 : 80,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: initialValue,
                        textAlign: TextAlign.center,
                        controller: controller,
                        keyboardType: keyboardType,
                        inputFormatters: inputFormatters,
                        enableInteractiveSelection: false,
                        decoration: InputDecoration(
                          hintText: hintText,
                          contentPadding: const EdgeInsets.symmetric(vertical: 5),
                          // errorText: errorText
                        ),
                        onChanged: onChanged,
                      ),
                    ),
                    if (trailing) Text(trailingText ?? "", style: Theme.of(context).textTheme.bodyMedium,),
                  ],
                ),
              ),
            ),
            tileColor: tileColor,
          );
        }
    );
  }
}

class CustomCheckBoxListTile extends StatelessWidget {
  final String subtitle;
  final String? subtitle2;
  final bool value;
  final Function(bool?) onChanged;
  final IconData? icon;
  final dynamic content;
  final Widget? image;
  final bool showCircleAvatar;
  final BorderRadius? borderRadius;

  const CustomCheckBoxListTile({super.key,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon,
    this.borderRadius,
    this.image,
    this.content,
    this.showCircleAvatar = true,
    this.subtitle2
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      contentPadding: const EdgeInsets.all(8),
      leading: showCircleAvatar
          ? Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: linearGradientLeading,
          ),
          child: CircleAvatar(backgroundColor: Colors.transparent, child: Icon(content, color: Colors.white))) : null,
      subtitle: subtitle2 != null ? Text(subtitle): null,
      title: Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
      trailing: SizedBox(
        width: MediaQuery.of(context).size.width < 550 ? 80 : 100,
        child: Center(
          child: Checkbox(
            value: value,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

class CustomTile extends StatelessWidget {
  final dynamic content;
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final BorderRadius? borderRadius;
  final Color? tileColor;
  final TextAlign? textAlign;
  final TextStyle? titleColor;
  final bool showCircleAvatar;
  final bool showSubTitle;
  final EdgeInsets contentPadding;

  const CustomTile({
    Key? key,
    required this.title,
    this.trailing,
    this.borderRadius,
    this.content,
    this.tileColor,
    this.textAlign,
    this.titleColor,
    this.leading,
    this.showCircleAvatar = true,
    this.showSubTitle = false,
    this.subtitle,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      subtitle: showSubTitle ? Text(subtitle ?? '') : null,
      contentPadding: showSubTitle ? const EdgeInsets.symmetric(horizontal: 10) : contentPadding,
      horizontalTitleGap: 30,
      leading: showCircleAvatar ? Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: linearGradientLeading,
        ),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: content is IconData
              ? Icon(content, color: Colors.white)
              : Text(
            content,
            style: TextStyle(
                color: Colors.white,
                fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize
            ),
          ),
        ),
      ) : null,
      title: Text(title, style: titleColor ?? Theme.of(context).textTheme.bodyLarge, textAlign: textAlign,),
      trailing: trailing,
      tileColor: tileColor,
    );
  }
}

class CustomDropdownTile extends StatelessWidget {
  final dynamic content;
  final String title;
  final String? subtitle;
  final bool showSubTitle;
  final double width;
  final Widget? trailing;
  final BorderRadius? borderRadius;
  final Color? tileColor;
  final TextAlign? textAlign;
  final TextStyle? titleColor;
  final List<String> dropdownItems;
  final String selectedValue;
  final bool includeNoneOption;
  final void Function(String?) onChanged;
  final bool showCircleAvatar;

  const CustomDropdownTile({
    Key? key,
    required this.title,
    this.trailing,
    this.borderRadius,
    this.content,
    this.tileColor,
    this.textAlign,
    this.titleColor,
    required this.dropdownItems,
    required this.selectedValue,
    required this.onChanged,
    this.includeNoneOption = true,
    this.showCircleAvatar = true,
    this.subtitle,
    this.showSubTitle = false,
    this.width = 130,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      subtitle: showSubTitle ? Text(subtitle ?? '') : null,
      contentPadding: showSubTitle ? const EdgeInsets.symmetric(horizontal: 10) : const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      leading: showCircleAvatar
          ? Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: linearGradientLeading,
        ),
            child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: content is IconData
              ? Icon(content, color: Colors.white)
              : Text(
            content,
            style: TextStyle(
              color: Colors.white,
              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
            ),
                    ),
                  ),
          ) : null,
      title: Text(title, style: titleColor ?? Theme.of(context).textTheme.bodyLarge, textAlign: textAlign),
      trailing: SizedBox(
        width: width,
        child: Center(
          child: CustomDropdownWidget(
            dropdownItems: dropdownItems,
            selectedValue: selectedValue,
            onChanged: onChanged,
            includeNoneOption: includeNoneOption,
          ),
        ),
      ),
      tileColor: tileColor,
    );
  }
}