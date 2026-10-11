import 'dart:convert';
import 'dart:typed_data';

/// Empty values preserve the default endpoint. Bare Host[:Port] uses wss://.
bool isValidWebSocketServer(String value) {
  value = value.trim();
  if (value.isEmpty) return true;
  if (RegExp(r'\s|\\').hasMatch(value)) return false;
  final explicitUrl = value.contains('://');
  if (!explicitUrl && RegExp(r'[/@?#]').hasMatch(value)) return false;
  try {
    final input = explicitUrl ? value : 'wss://$value';
    final authority = input
        .substring(input.indexOf('://') + 3)
        .split(RegExp(r'[/\?#]'))
        .first;
    final match = RegExp(r'^(?:\[[0-9a-fA-F:.]+\]|[^:/?#@\s]+)(?::([0-9]+))?$')
        .firstMatch(authority);
    if (match == null) return false;
    // Check the literal port before Uri normalizes an explicit :0 away.
    final port = match.group(1);
    if (port != null) {
      final number = int.tryParse(port);
      if (number == null || number < 1 || number > 65535) return false;
    }
    final uri = Uri.parse(input);
    return (uri.scheme == 'ws' || uri.scheme == 'wss') &&
        uri.host.isNotEmpty &&
        uri.userInfo.isEmpty &&
        !uri.hasFragment;
  } on FormatException {
    return false;
  }
}

class ServerConfig {
  late String idServer;
  late String relayServer;
  late String apiServer;
  late String key;
  late String websocketIdServer;
  late String websocketRelayServer;

  ServerConfig(
      {String? idServer,
      String? relayServer,
      String? apiServer,
      String? key,
      String? websocketIdServer,
      String? websocketRelayServer}) {
    this.idServer = idServer?.trim() ?? '';
    this.relayServer = relayServer?.trim() ?? '';
    this.apiServer = apiServer?.trim() ?? '';
    this.key = key?.trim() ?? '';
    this.websocketIdServer = websocketIdServer?.trim() ?? '';
    this.websocketRelayServer = websocketRelayServer?.trim() ?? '';
  }

  /// decode from shared string (from user shared or rustdesk-server generated)
  /// also see [encode]
  /// throw when decoding failure
  ServerConfig.decode(String msg) {
    var json = {};
    try {
      // back compatible
      json = jsonDecode(msg);
    } catch (err) {
      final input = msg.split('').reversed.join('');
      final bytes = base64Decode(base64.normalize(input));
      json = jsonDecode(utf8.decode(bytes, allowMalformed: true));
    }
    idServer = json['host'] ?? '';
    relayServer = json['relay'] ?? '';
    apiServer = json['api'] ?? '';
    key = json['key'] ?? '';
    websocketIdServer = json['websocket_id'] ?? '';
    websocketRelayServer = json['websocket_relay'] ?? '';
  }

  /// encode to shared string
  /// also see [ServerConfig.decode]
  String encode() {
    Map<String, String> config = {};
    config['host'] = idServer.trim();
    config['relay'] = relayServer.trim();
    config['api'] = apiServer.trim();
    config['key'] = key.trim();
    if (websocketIdServer.isNotEmpty) {
      config['websocket_id'] = websocketIdServer.trim();
    }
    if (websocketRelayServer.isNotEmpty) {
      config['websocket_relay'] = websocketRelayServer.trim();
    }
    return base64UrlEncode(Uint8List.fromList(jsonEncode(config).codeUnits))
        .split('')
        .reversed
        .join();
  }

  /// from local options
  ServerConfig.fromOptions(Map<String, dynamic> options)
      : idServer = options['custom-rendezvous-server'] ?? "",
        relayServer = options['relay-server'] ?? "",
        apiServer = options['api-server'] ?? "",
        key = options['key'] ?? "",
        websocketIdServer = options['websocket-id-server'] ?? "",
        websocketRelayServer = options['websocket-relay-server'] ?? "";
}
