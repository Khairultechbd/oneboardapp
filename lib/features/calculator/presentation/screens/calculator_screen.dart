import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../providers/calculator_provider.dart';

class CalculatorScreen extends ConsumerWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              _showHistory(context, ref);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDisplay(context, state),
          Expanded(
            child: _buildKeypad(context, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplay(BuildContext context, CalculatorState state) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            state.input.isEmpty ? '0' : state.input,
            style: Theme.of(context).textTheme.headlineMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            state.output.isEmpty ? '0' : state.output,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: state.isError ? Theme.of(context).colorScheme.error : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad(BuildContext context, CalculatorNotifier notifier) {
    return GridView.count(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      crossAxisCount: 4,
      mainAxisSpacing: AppConstants.smallPadding,
      crossAxisSpacing: AppConstants.smallPadding,
      children: [
        _buildButton(context, 'C', () => notifier.clearInput(), isOperator: true),
        _buildButton(context, '⌫', () => notifier.deleteLastChar(), isOperator: true),
        _buildButton(context, '%', () => notifier.appendInput('%'), isOperator: true),
        _buildButton(context, '÷', () => notifier.appendInput('/'), isOperator: true),
        _buildButton(context, '7', () => notifier.appendInput('7')),
        _buildButton(context, '8', () => notifier.appendInput('8')),
        _buildButton(context, '9', () => notifier.appendInput('9')),
        _buildButton(context, '×', () => notifier.appendInput('*'), isOperator: true),
        _buildButton(context, '4', () => notifier.appendInput('4')),
        _buildButton(context, '5', () => notifier.appendInput('5')),
        _buildButton(context, '6', () => notifier.appendInput('6')),
        _buildButton(context, '-', () => notifier.appendInput('-'), isOperator: true),
        _buildButton(context, '1', () => notifier.appendInput('1')),
        _buildButton(context, '2', () => notifier.appendInput('2')),
        _buildButton(context, '3', () => notifier.appendInput('3')),
        _buildButton(context, '+', () => notifier.appendInput('+'), isOperator: true),
        _buildButton(context, '0', () => notifier.appendInput('0')),
        _buildButton(context, '.', () => notifier.appendInput('.')),
        _buildButton(context, '(', () => notifier.appendInput('(')),
        _buildButton(context, ')', () => notifier.appendInput(')')),
        _buildButton(context, 'sin', () => notifier.appendInput('sin('), isOperator: true),
        _buildButton(context, 'cos', () => notifier.appendInput('cos('), isOperator: true),
        _buildButton(context, 'tan', () => notifier.appendInput('tan('), isOperator: true),
        _buildButton(context, '=', () => notifier.calculate(), isOperator: true),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context,
    String text,
    VoidCallback onPressed, {
    bool isOperator = false,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: isOperator ? Theme.of(context).colorScheme.primary : null,
      textColor: isOperator ? Theme.of(context).colorScheme.onPrimary : null,
    );
  }

  void _showHistory(BuildContext context, WidgetRef ref) {
    final state = ref.read(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'History',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      notifier.clearHistory();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Expanded(
                child: state.history.isEmpty
                    ? Center(
                        child: Text(
                          'No calculations yet',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : ListView.builder(
                        itemCount: state.history.length,
                        itemBuilder: (context, index) {
                          final calc = state.history[index];
                          return CustomCard(
                            margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        calc.expression,
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => notifier.deleteHistoryItem(index),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppConstants.smallPadding),
                                Text(
                                  '= ${calc.result}',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: AppConstants.smallPadding),
                                Text(
                                  DateFormat('MMM d, y HH:mm').format(calc.timestamp),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
} 