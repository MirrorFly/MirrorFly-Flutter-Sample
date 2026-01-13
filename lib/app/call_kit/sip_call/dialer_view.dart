import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_kit/sip_call/sip_call_controller.dart';

import '../../extensions/extensions.dart';

class DialerView extends NavViewStateful<SipCallController> {
  const DialerView({super.key});

  @override
  SipCallController createController({String? tag}) =>
      Get.put(SipCallController(), tag: key?.hashCode.toString());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('SIP Call'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: controller.cancelCallTimeout,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 25),
                Obx(() {
                  return GestureDetector(
                    onTap: () => controller.showCountryCodePicker(),
                    child: Text(
                      controller.selectedCountry.value.dialCode ?? '+91',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        letterSpacing: 1.2,
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(() {
                    final value = controller.sipNumber.value;
                    return TextField(
                      controller: controller.dialTextController,
                      readOnly: true,
                      enableInteractiveSelection: true,
                      showCursor: false,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                        color: value.isEmpty ? Colors.grey : Colors.black,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Enter number',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    );
                  }),
                ),

                /// BACKSPACE
                GestureDetector(
                  onTap: controller.removeLastDigit,
                  onLongPress: controller.clearDialPad,
                  child: const Icon(
                    Icons.backspace_outlined,
                    size: 26,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),

            /// NUMBER DISPLAY

            const SizedBox(height: 32),

            /// DIAL PAD
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _DialPad(
                  onTap: controller.addDialledNumber,
                ),
              ),
            ),

            /// CALL + BACKSPACE
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// CALL BUTTON
                  GestureDetector(
                    onTap: controller.makeSIPCall,
                    child: Container(
                      width: 65,
                      height: 65,
                      decoration: const BoxDecoration(
                        color: Color(0xFF25D366), // WhatsApp green
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.call,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialPad extends StatelessWidget {
  final Function(String) onTap;

  const _DialPad({required this.onTap});

  static const keys = [
    ['1', ''],
    ['2', 'ABC'],
    ['3', 'DEF'],
    ['4', 'GHI'],
    ['5', 'JKL'],
    ['6', 'MNO'],
    ['7', 'PQRS'],
    ['8', 'TUV'],
    ['9', 'WXYZ'],
    ['*', ''],
    ['0', '+'],
    ['#', ''],
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: keys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 18,
        crossAxisSpacing: 18,
      ),
      itemBuilder: (_, index) {
        final digit = keys[index][0];
        final letters = keys[index][1];

        return GestureDetector(
          onTap: () => onTap(digit),
          // onLongPress: digit == '0' ? () => onTap('+') : null,
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                digit,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (letters.isNotEmpty)
                Text(
                  letters,
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    color: Colors.black54,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
