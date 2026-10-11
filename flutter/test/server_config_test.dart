import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_hbb/common/server_config.dart';

void main() {
  test('WebSocket endpoints survive export and import', () {
    final config = ServerConfig(
      idServer: 'id.example:35016',
      relayServer: 'relay.example:35017',
      key: 'AbCdR1c1E=',
      websocketIdServer: 'wss://ws-id.example:35018/ws/id',
      websocketRelayServer: 'ws://127.0.0.1:21119/',
    );
    final restored = ServerConfig.decode(config.encode());
    expect(restored.idServer, config.idServer);
    expect(restored.relayServer, config.relayServer);
    expect(restored.key, config.key);
    expect(restored.websocketIdServer, config.websocketIdServer);
    expect(restored.websocketRelayServer, config.websocketRelayServer);
  });

  test('legacy JSON and encoded configurations leave overrides empty', () {
    final json = jsonEncode({'host': 'id.example', 'key': 'test-key'});
    for (final config in [
      ServerConfig.decode(json),
      ServerConfig.decode(ServerConfig(idServer: 'id.example').encode()),
    ]) {
      expect(config.idServer, 'id.example');
      expect(config.websocketIdServer, '');
      expect(config.websocketRelayServer, '');
    }
  });

  test('server configuration loads and clears saved WebSocket options', () {
    final config = ServerConfig.fromOptions({
      'websocket-id-server': 'id.example:35018',
      'websocket-relay-server': 'relay.example:35019',
    });
    expect(config.websocketIdServer, 'id.example:35018');
    expect(config.websocketRelayServer, 'relay.example:35019');
    config.websocketIdServer = '';
    config.websocketRelayServer = '';
    final restored = ServerConfig.decode(config.encode());
    expect(restored.websocketIdServer, '');
    expect(restored.websocketRelayServer, '');
  });

  test('valid WebSocket authorities and full URLs', () {
    for (final value in [
      '',
      'id.example',
      'id.example:35018',
      '[::1]:35018',
      ' ws://127.0.0.1:21118/ ',
      'wss://id.example:35018/ws/id',
      'wss://relay.example:35019/custom/relay?token=x',
    ]) {
      expect(isValidWebSocketServer(value), isTrue, reason: value);
    }
  });

  test('invalid WebSocket endpoints are rejected before saving', () {
    for (final value in [
      'https://id.example:35018',
      'wss://',
      'id.example:0',
      'id.example:65536',
      'id.example:abc',
      'id.example:',
      'id.example/ws/id',
      'id .example:35018',
      'wss://user:pass@id.example/ws/id',
      'wss://id.example/#fragment',
      r'wss://id.example\path',
    ]) {
      expect(isValidWebSocketServer(value), isFalse, reason: value);
    }
  });
}
