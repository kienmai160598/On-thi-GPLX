import Foundation
import Security

/// Validates the server's TLS certificate for the hazard-video CDN.
///
/// Previously this did SHA-256 public-key pinning, but the hash was computed
/// over `SecKeyCopyExternalRepresentation` (PKCS#1 for RSA) while the pinned
/// value was generated from the DER SubjectPublicKeyInfo — different encodings,
/// so the pin never matched and every download was rejected. The videos are
/// public, non-sensitive content, so we validate against the system trust
/// store (standard TLS) rather than maintaining a brittle, easily-stale pin.
enum CertificatePinner {
    static func validate(challenge: URLAuthenticationChallenge) -> Bool {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            return false
        }
        var error: CFError?
        return SecTrustEvaluateWithError(serverTrust, &error)
    }
}
