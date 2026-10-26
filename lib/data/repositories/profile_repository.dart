import '../models/profile.dart';
import '../supabase_client.dart';

class ProfileRepository {
  Future<Profile?> fetch(String userId) async {
    final row = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return row == null ? null : Profile.fromMap(row);
  }

  Future<Profile> update(Profile profile) async {
    final row = await supabase
        .from('profiles')
        .update(profile.toUpdateMap())
        .eq('id', profile.id)
        .select()
        .single();
    return Profile.fromMap(row);
  }

  Future<List<Profile>> fetchAll() async {
    final rows = await supabase
        .from('profiles')
        .select()
        .order('created_at', ascending: false);
    return rows.map(Profile.fromMap).toList();
  }

  Future<void> setRole(String userId, String role) async {
    await supabase.from('profiles').update({'role': role}).eq('id', userId);
  }
}
