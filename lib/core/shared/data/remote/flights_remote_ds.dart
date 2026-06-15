import '../../../error/types/error_handler.dart';
import '../../../networking/supabase_service.dart';
import '../models/flight_model.dart';

class FlightsRemoteDs {
  final SupabaseService supabaseService;

  FlightsRemoteDs({required this.supabaseService});

  Future<int> countActiveFlightsToday() async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final data = await supabaseService.client
          .from('flights')
          .select('id')
          .inFilter('status', ['active', 'scheduled'])
          .gte('scheduled_arrival', '${today}T00:00:00')
          .lte('scheduled_arrival', '${today}T23:59:59');
      return (data as List).length;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Fetches flight details including the stand information
  Future<FlightModel?> fetchFlightById(String flightId) async {
    try {
      final response = await supabaseService.client
          .from('flights')
          .select('*, stands (*)') // Join with stands table
          .eq('id', flightId) // Primary key is 'id' in your SQL
          .maybeSingle();

      if (response == null) return null;

      return FlightModel.fromMap(response);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
