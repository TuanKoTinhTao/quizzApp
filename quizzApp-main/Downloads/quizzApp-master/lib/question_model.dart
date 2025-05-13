class Question {
  final String questionText;
  final List<Answer> answersList;

  Question(this.questionText, this.answersList);

  Map<String, dynamic> toJson() => {
        'questionText': questionText,
        'answersList': answersList.map((a) => a.toJson()).toList(),
      };

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        json['questionText'],
        (json['answersList'] as List)
            .map((a) => Answer.fromJson(a))
            .toList(),
      );
}

class Answer {
  final String answerText;
  final bool isCorrect;

  Answer(this.answerText, this.isCorrect);

  Map<String, dynamic> toJson() => {
        'answerText': answerText,
        'isCorrect': isCorrect,
      };

  factory Answer.fromJson(Map<String, dynamic> json) =>
      Answer(json['answerText'], json['isCorrect']);
}
