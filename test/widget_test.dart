import 'package:ams_2/app/core/widgets/custom_button.dart';
import 'package:ams_2/app/core/widgets/custom_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'CustomButton and CustomStateView render inside IntrinsicHeight without throwing',
      (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    CustomButton(
                      text: 'Test Button',
                      onPressed: () {},
                    ),
                    Expanded(
                      child: CustomStateView.empty(
                        title: 'No Data',
                        message: 'Nothing here',
                        buttonText: 'Refresh',
                        onAction: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Test Button'), findsOneWidget);
    expect(find.text('No Data'), findsOneWidget);
    expect(find.text('Refresh'), findsOneWidget);
  });
}
