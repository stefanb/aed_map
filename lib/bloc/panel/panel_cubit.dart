import 'package:aed_map/bloc/panel/panel_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils.dart';

class PanelCubit extends Cubit<PanelState> {
  PanelCubit()
      : super(PanelState(
            open: false, visible: true, hash: generateRandomString(32)));

  open() => emit(state.copyWith(open: true, hash: generateRandomString(32)));

  cancel() => emit(state.copyWith(open: false, hash: generateRandomString(32)));

  show() => emit(state.copyWith(visible: true, hash: generateRandomString(32)));

  hide() =>
      emit(state.copyWith(visible: false, hash: generateRandomString(32)));
}
