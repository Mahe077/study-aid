// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:logger/logger.dart';
// import 'package:study_aid/features/authentication/domain/entities/user.dart';
// import 'package:study_aid/features/authentication/domain/usecases/load_user.dart';

// class UserState {
//   final User? user;
//   final bool isLoading;
//   final String? error;

//   UserState({
//     this.user,
//     this.isLoading = false,
//     this.error,
//   });

//   UserState copyWith({
//     User? user,
//     bool? isLoading,
//     String? error,
//   }) {
//     return UserState(
//       user: user ?? this.user,
//       isLoading: isLoading ?? this.isLoading,
//       error: error ?? this.error,
//     );
//   }
// }

// class UserNotifier extends StateNotifier<UserState> {
//   final LoadUser loadUser;
//   final String userId;
//   UserNotifier(this.loadUser, this.userId) : super(UserState()) {
//     fetchUser(); // Ensure user data is fetched upon initialization
//   }

//   Future<void> fetchUser() async {
//     state = UserState(isLoading: true);
//     try {
//       final result =
//           await loadUser(userId); // Replace with your actual API call

//       result.fold(
//         (failure) =>
//             state = state.copyWith(error: failure.message, isLoading: false),
//         (user) => {
//           Logger().i("UserNotifier:: $user"),
//           state = state.copyWith(user: user, isLoading: false)
//         },
//       );
//     } catch (e) {
//       state = UserState(error: e.toString()); // Handle error case
//     }
//   }
// }

// // class UserNotifier extends StateNotifier<UserState> {
// //   final LoadUser loadUser;

// //   UserNotifier(this.loadUser) : super(UserState());

// //   Future<void> fetchUser(String userId) async {
// //     state = state.copyWith(isLoading: true);
// //     final result = await loadUser(userId);
// //     result.fold(
// //       (failure) =>
// //           state = state.copyWith(error: failure.message, isLoading: false),
// //       (user) => {
// //         Logger().i("UserNotifier:: $user"),
// //         state = state.copyWith(user: user, isLoading: false)
// //       },
// //     );
// //   }
// // }
