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
          .order('full_name', ascending: true);
      return (response as List<dynamic>)
          .map((e) => UnitMemberModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<UnitMemberModel> create(UnitMemberModel model) async {
    try {
      final response = await supabaseService.client
          .from('unit_members')
          .insert(model.toMap())
          .select()
          .single();
      return UnitMemberModel.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<UnitMemberModel> update(UnitMemberModel model) async {
    try {
      final response = await supabaseService.client
          .from('unit_members')
          .update(model.toMap())
          .eq('id', model.id)
          .select()
          .single();
      return UnitMemberModel.fromMap(response);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> deactivate(String memberId) async {
    try {
      await supabaseService.client
          .from('unit_members')
          .update({'is_active': false})
          .eq('id', memberId);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
