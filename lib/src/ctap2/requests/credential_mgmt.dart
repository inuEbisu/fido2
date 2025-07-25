import 'package:cbor/cbor.dart';
import 'package:fido2/src/cose.dart';
import '../constants.dart';
import '../entities/credential_entities.dart';

class CredentialManagementRequest {
  final int subCommand;
  final CborMap? params;
  final int? pinUvAuthProtocol;
  final List<int>? pinUvAuthParam;

  CredentialManagementRequest({
    required this.subCommand,
    this.params,
    this.pinUvAuthProtocol,
    this.pinUvAuthParam,
  });
}

class CredentialManagementResponse {
  final int? existingResidentCredentialsCount;
  final int? maxPossibleRemainingResidentCredentialsCount;
  final PublicKeyCredentialRpEntity? rp;
  final List<int>? rpIdHash;
  final int? totalRPs;
  final PublicKeyCredentialUserEntity? user;
  final PublicKeyCredentialDescriptor? credentialId;
  final CoseKey? publicKey;
  final int? totalCredentials;
  final int? credProtect;
  final List<int>? largeBlobKey;

  CredentialManagementResponse({
    this.existingResidentCredentialsCount,
    this.maxPossibleRemainingResidentCredentialsCount,
    this.rp,
    this.rpIdHash,
    this.totalRPs,
    this.user,
    this.credentialId,
    this.publicKey,
    this.totalCredentials,
    this.credProtect,
    this.largeBlobKey,
  });
}

class CredentialManagementUtils {
  /// Make the request to credentialManagement.
  static List<int> makeCredentialManagementRequest(
      CredentialManagementRequest request) {
    final map = <int, dynamic>{};
    map[1] = request.subCommand;
    if (request.params != null) {
      map[2] = request.params;
    }
    if (request.pinUvAuthProtocol != null) {
      map[3] = request.pinUvAuthProtocol!;
    }
    if (request.pinUvAuthParam != null) {
      map[4] = CborBytes(request.pinUvAuthParam!);
    }
    return [Ctap2Commands.credentialManagement.value] +
        cbor.encode(CborValue(map));
  }

  /// Parse the response from credentialManagement.
  static CredentialManagementResponse parseCredentialManagementResponse(
      List<int> data) {
    final map = cbor.decode(data).toObject() as Map;
    final rpMap = (map[3] as Map?)?.cast<String, dynamic>();
    final userMap = (map[6] as Map?)?.cast<String, dynamic>();
    final credentialIdMap = (map[7] as Map?)?.cast<String, dynamic>();
    final publicKeyMap = (map[8] as Map?)?.cast<int, dynamic>();
    return CredentialManagementResponse(
      existingResidentCredentialsCount: map[1] as int?,
      maxPossibleRemainingResidentCredentialsCount: map[2] as int?,
      rp: rpMap != null
          ? PublicKeyCredentialRpEntity(id: rpMap['id'] as String)
          : null,
      rpIdHash: (map[4] as List?)?.cast<int>(),
      totalRPs: map[5] as int?,
      user: userMap != null
          ? PublicKeyCredentialUserEntity(
              id: CborBytes(userMap['id']).bytes,
              name: userMap['name'] as String,
              displayName: userMap['displayName'] as String,
            )
          : null,
      credentialId: credentialIdMap != null
          ? PublicKeyCredentialDescriptor(
              type: credentialIdMap['type'] as String,
              id: CborBytes(credentialIdMap['id']).bytes,
            )
          : null,
      publicKey: publicKeyMap != null ? CoseKey.parse(publicKeyMap) : null,
      totalCredentials: map[9] as int?,
      credProtect: map[10] as int?,
      largeBlobKey: (map[11] as List?)?.cast<int>(),
    );
  }
} 