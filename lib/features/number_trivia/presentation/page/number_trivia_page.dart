import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tdd/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:flutter_tdd/features/number_trivia/presentation/widgets/widgets.dart';
import 'package:flutter_tdd/injection_container.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Trivia'),
      ),
      body: SingleChildScrollView(
        child: BlocProvider(
          create: (context) => serviceLocator<NumberTriviaBloc>(),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 3,
                    child: BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
                      builder: (context, state) {
                        if (state is Empty) {
                          return const MessageDisplay(
                            message: 'Start searching!',
                          );
                        } else if (state is Loading) {
                          return const LoadingWidget();
                        } else if (state is Loaded) {
                          return TriviaDisplay(
                            numberTrivia: state.trivia,
                          );
                        } else if (state is Error) {
                          return MessageDisplay(message: state.message);
                        }
                        return Container();
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const TriviaControls(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
