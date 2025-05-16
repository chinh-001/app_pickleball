import 'dart:developer' as log;

/// A callback function type for channel change events
typedef ChannelChangeCallback = void Function(String newChannel);

/// Service to synchronize channel selection between screens
class ChannelSyncService {
  // Singleton pattern
  static final ChannelSyncService _instance = ChannelSyncService._internal();
  factory ChannelSyncService() => _instance;
  ChannelSyncService._internal();

  static ChannelSyncService get instance => _instance;

  // Currently selected channel
  String _selectedChannel = '';

  // Map of listeners - using a map to ensure each listener is unique
  final Map<String, ChannelChangeCallback> _listeners = {};

  // Getter for selected channel
  String get selectedChannel => _selectedChannel;

  // Setter for selected channel
  set selectedChannel(String channel) {
    if (_selectedChannel != channel) {
      // log.log(
      //   'ChannelSyncService: Channel changed from "$_selectedChannel" to "$channel"',
      // );
      _selectedChannel = channel;

      // Notify all listeners of the channel change
      _notifyListeners();
    }
  }

  // Add a listener with a unique id
  void addListener(String id, ChannelChangeCallback callback) {
    _listeners[id] = callback;
    // log.log('ChannelSyncService: Added listener with id: $id');
  }

  // Remove a listener by id
  void removeListener(String id) {
    _listeners.remove(id);
    log.log('ChannelSyncService: Removed listener with id: $id');
  }

  // Notify all listeners of the channel change
  void _notifyListeners() {
    log.log(
      'ChannelSyncService: Notifying ${_listeners.length} listeners of channel change to "$_selectedChannel"',
    );
    for (final callback in _listeners.values) {
      callback(_selectedChannel);
    }
  }
}
