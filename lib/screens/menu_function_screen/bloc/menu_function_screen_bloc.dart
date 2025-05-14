import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:developer' as log;
import 'package:app_pickleball/services/repositories/work_time_repository.dart';
import 'package:app_pickleball/services/repositories/choose_repository.dart';
import 'package:app_pickleball/services/channel_sync_service.dart';
import 'package:app_pickleball/services/repositories/userPermissions_repository.dart';

part 'menu_function_screen_event.dart';
part 'menu_function_screen_state.dart';

class MenuFunctionScreenBloc
    extends Bloc<MenuFunctionScreenEvent, MenuFunctionScreenState> {
  final WorkTimeRepository _workTimeRepository;
  final ChooseRepository _chooseRepository;
  final ChannelSyncService _channelSyncService = ChannelSyncService.instance;
  final UserPermissionsRepository _permissionsRepository;

  MenuFunctionScreenBloc({
    WorkTimeRepository? workTimeRepository,
    ChooseRepository? chooseRepository,
    UserPermissionsRepository? permissionsRepository,
  }) : _workTimeRepository = workTimeRepository ?? WorkTimeRepository(),
       _chooseRepository = chooseRepository ?? ChooseRepository(),
       _permissionsRepository =
           permissionsRepository ?? UserPermissionsRepository(),
       super(MenuFunctionScreenInitial()) {
    on<SelectPeriodicBookingEvent>(_onSelectPeriodicBooking);
    on<SelectRetailBookingEvent>(_onSelectRetailBooking);
  }

  void _onSelectPeriodicBooking(
    SelectPeriodicBookingEvent event,
    Emitter<MenuFunctionScreenState> emit,
  ) {
    emit(PeriodicBookingSelectedState());
  }

  void _onSelectRetailBooking(
    SelectRetailBookingEvent event,
    Emitter<MenuFunctionScreenState> emit,
  ) async {
    try {
      // Emit loading state
      emit(MenuFunctionScreenLoading());

      // Get the currently selected channel and its token
      String? channelToken;
      final selectedChannel = _channelSyncService.selectedChannel;

      if (selectedChannel.isNotEmpty) {
        log.log('Getting data for channel: $selectedChannel');

        // If channel is Pikachu, use special token
        if (selectedChannel == 'Pikachu Pickleball Xuân Hoà') {
          channelToken = 'pikachu';
        } else {
          // Get token for the selected channel
          channelToken = await _permissionsRepository.getChannelToken(
            selectedChannel,
          );
        }

        log.log('Using channel token: $channelToken');
      }

      // Call WorkTimeRepository's API with the channel token
      final workTimeResult = await _workTimeRepository.getStartAndEndTime(
        channelToken: channelToken,
      );
      log.log(
        'Work Time API result for channel $selectedChannel: $workTimeResult',
      );

      // Call ChooseRepository's API with the same channel token
      final productsResult = await _chooseRepository.getProductsWithCourts(
        channelToken: channelToken,
      );
      log.log(
        'Products with Courts API result for channel $selectedChannel: $productsResult',
      );

      emit(RetailBookingSelectedState());
    } catch (e) {
      log.log('Error fetching data: $e');
      emit(RetailBookingSelectedState());
    }
  }
}
