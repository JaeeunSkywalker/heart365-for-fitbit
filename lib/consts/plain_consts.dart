import 'package:flutter/material.dart';

//수정할 거 없음. 검토 완료.

//앱 테마

//앱 이름.
const String appname = "Heart365";

//앱 테마.
final ThemeData appTheme = ThemeData(
  // 기본적인 배경색은 조금 더 부드러운 검은색으로 설정.
  primaryColor: const Color(0xFF1A1A1A),
  scaffoldBackgroundColor: const Color(0xFF1A1A1A),
  // 부가적인 배경색은 조금 밝게 설정하여 계층 감을 주어 사용자에게 포커스를 줍니다.
  secondaryHeaderColor: const Color(0xFF2E2E2E),
  hintColor: const Color(0xFF454545),
  appBarTheme: const AppBarTheme(
    color: Color(0xFF2E2E2E),
    iconTheme: IconThemeData(
      color: Colors.white70,
    ),
    titleTextStyle: TextStyle(
      color: Colors.white70,
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    ),
  ),
  cardTheme: const CardTheme(
    color: Color(0xFF2E2E2E),
    shadowColor: Color(0xFF121212),
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Color(0xFF4A89DC), // 푸른색은 의료계통에서 신뢰와 전문성을 상징합니다.
    textTheme: ButtonTextTheme.primary,
  ),
  iconTheme: const IconThemeData(
    color: Color(0xFF4A89DC),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
        fontSize: 96, fontWeight: FontWeight.w300, color: Colors.white),
    displayMedium: TextStyle(
        fontSize: 60, fontWeight: FontWeight.w300, color: Colors.white),
    displaySmall: TextStyle(
        fontSize: 48, fontWeight: FontWeight.w400, color: Colors.white),
    headlineMedium: TextStyle(
        fontSize: 34, fontWeight: FontWeight.w400, color: Colors.white),
    headlineSmall: TextStyle(
        fontSize: 24, fontWeight: FontWeight.w400, color: Colors.white),
    titleLarge: TextStyle(
        fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
    titleMedium: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
    titleSmall: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70),
    bodyLarge: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
    bodyMedium: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white70),
    labelLarge: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
    bodySmall: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white60),
    labelSmall: TextStyle(
        fontSize: 10, fontWeight: FontWeight.w400, color: Colors.white54),
  ),
);
