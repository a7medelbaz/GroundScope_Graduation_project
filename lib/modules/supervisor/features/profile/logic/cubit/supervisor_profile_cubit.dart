import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/networking/supabase_service.dart';
import 'package:ground_scope/core/service/user_service.dart';

part 'supervisor_profile_state.dart';

class SupervisorProfileCubit extends Cubit<SupervisorProfileState> {
  SupervisorProfileCubit({
    required UserService userService,
    required SupabaseService supabaseService,
  })  : _userService = userService,
        _supabase = supabaseService,
        super(const SupervisorProfileState());

  final UserService _userService;
  final SupabaseService _supabase;

  Future<void> loadProfile() async {
    emit(state.copyWith(status: SupervisorProfileStatus.loading));
    try {
      final user = await _userService.getUser();
      if (user == null) throw AppError.unauthorized();

      String? serviceTypeName;
      int unitCount = 0;
      int memberCount = 0;

      if (user.serviceTypeId != null) {
        // Fetch service type name and unit/member counts concurrently.
        final results = await Future.wait([
          _fetchServiceTypeName(user.serviceTypeId!),
          _fetchUnitAndMemberCounts(user.serviceTypeId!),
        ]);
        serviceTypeName = results[0] as String?;
        final counts = results[1] as (int, int);
        unitCount = counts.$1;
        memberCount = counts.$2;
      }

      emit(state.copyWith(
        status: SupervisorProfileStatus.loaded,
        user: user,
        serviceTypeName: serviceTypeName,
        unitCount: unitCount,
        memberCount: memberCount,
      ));
    } on AppError catch (e) {
      emit(state.copyWith(status: SupervisorProfileStatus.failure, error: e));
    } catch (_) {
      emit(state.copyWith(
        status: SupervisorProfileStatus.failure,
        error: AppError.unknown(),
      ));
    }
  }

  Future<String?> _fetchServiceTypeName(String serviceTypeId) async {
    try {
      final row = await _supabase.client
          .from('service_types')
          .select('name')
          .eq('id', serviceTypeId)
          .single();
      return row['name'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<(int, int)> _fetchUnitAndMemberCounts(String serviceTypeId) async {
    try {
      final rows = await _supabase.client
          .from('units')
          .select('id, unit_members(id)')
          .eq('service_type_id', serviceTypeId);
      final unitCount = rows.length;
      final memberCount = rows.fold<int>(
        0,
        (sum, u) => sum + ((u['unit_members'] as List?)?.length ?? 0),
      );
      return (unitCount, memberCount);
    } catch (_) {
      return (0, 0);
    }
  }
}
