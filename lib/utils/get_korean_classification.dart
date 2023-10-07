//특정 영어를 특정 한글로 매핑해 주는 함수.
//심방세동: 심장 상부에 위치한 심방이 빠르고 불규칙하게 떨리는 상태.
//이로 인해 심방과 심실 사이의 전기 신호 전달이 불규칙해져 심장의 펌핑 기능이 제대로 이루어지지 않을 수 있다.
//심방세동은 뇌졸중, 심부전, 기타 심장 관련 질환의 위험을 높일 수 있다.
//정상 부비동: 심장의 정상적인 리듬이다.
//이는 심장의 자연 페이스메이커인 부비동에서 시작되며, 규칙적으로 심방과 심실을 통해 전달되는 전기 신호에 의해 일어난다.
//정상 부비동에서는 심장이 규칙적으로 박동하며, 대개 분당 60~100회의 박동을 보인다.
String getKoreanClassification(String resultClassification) {
  const Map<String, String> classificationMap = {
    'Atrial Fibrillation': '심방세동(Atrial Fibrillation)',
    'Normal Sinus Rhythm': '정상 부비동(Normal Sinus Rhythm)',
    'Inconclusive': '결론이 나지 않음, 불확정(Inconclusive)',
    'Inconclusive: High heart rate':
        '불확정: 심박수 증가(Inconclusive: High heart rate)',
    'Inconclusive: Low heart rate': '불확정: 심박수 감소(Inconclusive: Low heart rate)',
  };

  return classificationMap[resultClassification] ?? resultClassification;
}
