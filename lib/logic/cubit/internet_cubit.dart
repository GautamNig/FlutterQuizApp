import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_quiz_app/constants/enums.dart';

import 'internet_state.dart';

class InternetCubit extends Cubit<InternetState>{
  InternetCubit({required this.connectivity}) : super(InternetLoading()){
    monitorInternetConnection();
  }

  void monitorInternetConnection() {
    connectivityStreamSubscription = connectivity.onConnectivityChanged.listen((connectivityResult){
      if(connectivityResult == ConnectivityResult.wifi)
        emitInternetConnected(ConnectionType.Wifi);
      else if(connectivityResult == ConnectivityResult.mobile)
        emitInternetConnected(ConnectionType.Mobile);
      else if(connectivityResult == ConnectivityResult.none)
        emitInternetDisconnected();
    });
  }

  final Connectivity connectivity;
  late StreamSubscription connectivityStreamSubscription;

  void emitInternetConnected(ConnectionType _connectionType) =>
      emit(InternetConnected(connectionType: _connectionType));

  void emitInternetDisconnected() => emit(InternetDisconnected());

  @override
  Future<void> close() {
    // TODO: implement close
    connectivityStreamSubscription.cancel();
    return super.close();
  }
}