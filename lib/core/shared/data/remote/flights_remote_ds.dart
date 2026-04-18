import '../../../error/types/error_handler.dart';
import '../../../networking/supabase_service.dart';
import '../models/flight_model.dart';

class FlightsRemoteDs {
  final SupabaseService supabaseService;

  FlightsRemoteDs({required this.supabaseService});

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
