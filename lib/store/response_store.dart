import '../db/database_helper.dart';
import '../models/form_response.dart';

class ResponseStore {
  static final ResponseStore _instance = ResponseStore._internal();
  factory ResponseStore() => _instance;
  ResponseStore._internal();

  final List<FormResponse> responses = [];
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    final fetchedResponses = await DatabaseHelper.instance.fetchResponses();
    responses
      ..clear()
      ..addAll(fetchedResponses);
    _initialized = true;
  }

  Future<void> refresh() async {
    final fetchedResponses = await DatabaseHelper.instance.fetchResponses();
    responses
      ..clear()
      ..addAll(fetchedResponses);
    _initialized = true;
  }

  Future<FormResponse> add(FormResponse response) async {
    if (!_initialized) {
      await init();
    }
    final localId = await DatabaseHelper.instance.insertResponse(response);
    final savedResponse = response.copyWith(id: localId);
    responses.insert(0, savedResponse);
    return savedResponse;
  }

  Future<void> delete(int index) async {
    if (index < 0 || index >= responses.length) return;
    final response = responses[index];
    if (response.id != null) {
      await DatabaseHelper.instance.deleteResponse(response.id!);
    }
    responses.removeAt(index);
  }
}
