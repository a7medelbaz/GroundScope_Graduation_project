import 'package:ground_scope/core/error/types/error_handler.dart';
import 'package:ground_scope/core/networking/supabase_service.dart';

import '../models/unit_member_model.dart';

class UnitMemberRemoteDs {
  const UnitMemberRemoteDs({required this.supabaseService});

  final SupabaseService supabaseService;

  Future<List<UnitMemberModel>> fetchUnitMembers(String unitId) async {
    try {
      final response = await supabaseService.client
          .from('unit_members')
          .select('*')
          .eq('unit_id', unitId)
          .eq('is_active', true)
          .order('created_at');
      return (response as List<dynamic>)
          .map((e) => UnitMemberModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
