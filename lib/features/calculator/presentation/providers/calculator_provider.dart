import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/models/calculation.dart';
import '../../../../core/constants/app_constants.dart';

final calculatorProvider = StateNotifierProvider<CalculatorNotifier, CalculatorState>((ref) {
  return CalculatorNotifier();
});

class CalculatorState {
  final String input;
  final String output;
  final bool isError;
  final List<Calculation> history;

  CalculatorState({
    this.input = '',
    this.output = '',
    this.isError = false,
    this.history = const [],
  });

  CalculatorState copyWith({
    String? input,
    String? output,
    bool? isError,
    List<Calculation>? history,
  }) {
    return CalculatorState(
      input: input ?? this.input,
      output: output ?? this.output,
      isError: isError ?? this.isError,
      history: history ?? this.history,
    );
  }
}

class Calculation {
  final String expression;
  final String result;
  final DateTime timestamp;

  Calculation({
    required this.expression,
    required this.result,
    required this.timestamp,
  });
}

class CalculatorNotifier extends StateNotifier<CalculatorState> {
  CalculatorNotifier() : super(CalculatorState());

  void appendInput(String value) {
    if (state.isError) {
      state = state.copyWith(
        input: value,
        output: '',
        isError: false,
      );
      return;
    }

    state = state.copyWith(
      input: state.input + value,
    );
  }

  void deleteLastChar() {
    if (state.input.isEmpty) return;

    state = state.copyWith(
      input: state.input.substring(0, state.input.length - 1),
    );
  }

  void clearInput() {
    state = state.copyWith(
      input: '',
      output: '',
      isError: false,
    );
  }

  void calculate() {
    if (state.input.isEmpty) return;

    try {
      final expression = _parseExpression(state.input);
      final result = expression.evaluate(EvaluationType.REAL, ContextModel());
      
      final formattedResult = _formatResult(result);
      
      state = state.copyWith(
        output: formattedResult,
        history: [
          Calculation(
            expression: state.input,
            result: formattedResult,
            timestamp: DateTime.now(),
          ),
          ...state.history,
        ],
      );
    } catch (e) {
      state = state.copyWith(
        output: 'Error',
        isError: true,
      );
    }
  }

  void clearHistory() {
    state = state.copyWith(history: []);
  }

  void deleteHistoryItem(int index) {
    final newHistory = List<Calculation>.from(state.history);
    newHistory.removeAt(index);
    state = state.copyWith(history: newHistory);
  }

  Expression _parseExpression(String input) {
    // Replace mathematical symbols with their corresponding operators
    input = input
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('sin', 'sin')
        .replaceAll('cos', 'cos')
        .replaceAll('tan', 'tan');

    final parser = Parser();
    return parser.parse(input);
  }

  String _formatResult(double result) {
    if (result == result.toInt()) {
      return result.toInt().toString();
    }
    return result.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '');
  }
} 