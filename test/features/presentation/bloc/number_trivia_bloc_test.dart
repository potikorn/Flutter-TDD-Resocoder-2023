import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_tdd/core/error/failures.dart';
import 'package:flutter_tdd/core/util/input_converter.dart';
import 'package:flutter_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_tdd/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:flutter_tdd/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:flutter_tdd/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'number_trivia_bloc_test.mocks.dart';

@GenerateMocks([
  GetConcreteNumberTrivia,
  GetRandomNumberTrivia,
  InputConverter,
])
void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();
    bloc = NumberTriviaBloc(
      getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
      getRandomNumberTrivia: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  const tNumberString = '1';
  final tNumberParsed = int.parse(tNumberString);
  const tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

  blocTest(
    'should be empty state',
    build: () => bloc,
    expect: () => [],
  );

  group('GetTriviaForConcreteNumber', () {
    void setUpMockInputConverterSuccess() =>
        when(mockInputConverter.stringToUnsignedInteger(any)).thenReturn(
          Right(tNumberParsed),
        );

    void setUpMockInputConverterFailure() =>
        when(mockInputConverter.stringToUnsignedInteger(any)).thenReturn(
          Left(InvalidInputFailure()),
        );

    void setUpMockGetConcreteTriviaSuccess() =>
        when(mockGetConcreteNumberTrivia(any)).thenAnswer(
          (_) async => const Right(tNumberTrivia),
        );

    void setUpMockGetConcreteTriviaServerFailure() =>
        when(mockGetConcreteNumberTrivia(any)).thenAnswer(
          (_) async => Left(ServerFailure()),
        );

    void setUpMockGetRandomTriviaCacheFailure() =>
        when(mockGetConcreteNumberTrivia(any)).thenAnswer(
          (_) async => Left(CacheFailure()),
        );

    blocTest('emits [Error] when invalid input',
        build: () => bloc,
        setUp: () {
          setUpMockInputConverterFailure();
        },
        act: (bloc) =>
            bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
        expect: () => [const Error(message: invalidInputFailureMessage)],
        verify: (bloc) {
          verifyZeroInteractions(mockGetConcreteNumberTrivia);
        });

    blocTest(
      'emits [Loading, Error] when fetch concert number which server failure',
      build: () => bloc,
      setUp: () {
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteTriviaServerFailure();
      },
      act: (bloc) => bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
      expect: () => [
        Loading(),
        const Error(message: serverFailureMessage),
      ],
    );

    blocTest(
      'emits [Loading, Loaded] when fetch concert number',
      build: () => bloc,
      setUp: () {
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteTriviaSuccess();
      },
      act: (bloc) => bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
      verify: (_) {
        verify(mockInputConverter.stringToUnsignedInteger(any)).called(1);
        verify(mockGetConcreteNumberTrivia(any)).called(1);
      },
      expect: () => [
        Loading(),
        const Loaded(trivia: tNumberTrivia),
      ],
    );

    blocTest(
      'emits [Loading, Error] when fetch concrete number which cache failure',
      build: () => bloc,
      setUp: () {
        setUpMockInputConverterSuccess();
        setUpMockGetRandomTriviaCacheFailure();
      },
      act: (bloc) => bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
      expect: () => [
        Loading(),
        const Error(message: cacheFailureMessage),
      ],
    );
  });

  group('GetTriviaForRandomNumber', () {
    void setUpMockGetRandomTriviaSuccess() =>
        when(mockGetRandomNumberTrivia(any)).thenAnswer(
          (_) async => const Right(tNumberTrivia),
        );

    void setUpMockGetRandomTriviaServerFailure() =>
        when(mockGetRandomNumberTrivia(any)).thenAnswer(
          (_) async => Left(ServerFailure()),
        );

    void setUpMockGetRandomTriviaCacheFailure() =>
        when(mockGetRandomNumberTrivia(any)).thenAnswer(
          (_) async => Left(CacheFailure()),
        );

    blocTest(
      'emits [Loading, Loaded] when fetch random number',
      build: () => bloc,
      setUp: () {
        setUpMockGetRandomTriviaSuccess();
      },
      act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
      verify: (_) {
        verify(mockGetRandomNumberTrivia(any)).called(1);
      },
      expect: () => [
        Loading(),
        const Loaded(trivia: tNumberTrivia),
      ],
    );

    blocTest(
      'emits [Loading, Error] when fetch random number which server failure',
      build: () => bloc,
      setUp: () {
        setUpMockGetRandomTriviaServerFailure();
      },
      act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
      expect: () => [
        Loading(),
        const Error(message: serverFailureMessage),
      ],
    );

    blocTest(
      'emits [Loading, Error] when fetch random number which cache failure',
      build: () => bloc,
      setUp: () {
        setUpMockGetRandomTriviaCacheFailure();
      },
      act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
      expect: () => [
        Loading(),
        const Error(message: cacheFailureMessage),
      ],
    );
  });
}
