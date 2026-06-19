import Foundation
import CryptoKit

/// Validates server certificates against known public key hashes.
/// Add gmec.vn's SHA-256 public key hash to `pinnedHashes`.
struct CertificatePinner {
    // SHA-256 hash of gmec.vn's public key (base64-encoded)
    // Update this when the certificate is rotated.
    // To get the hash: openssl s_client -connect gmec.vn:443 | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | base64
    static let pinnedHashes: Set<String> = [
        // gmec.vn public key hash — retrieved 2026-03-15
        // Regenerate with: openssl s_client -connect gmec.vn:443 2>/dev/null | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | base64
        "uCKG3IqfAOm4KRMX+XurtRXorejgb6TwApD64JM9b30="
    ]

    static func validate(challenge: URLAuthenticationChallenge) -> Bool {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust,
              let certificate = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
              let leaf = certificate.first else { return false }

        // Extract public key from leaf certificate
        guard let publicKey = SecCertificateCopyKey(leaf),
              let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data? else {
            return false
        }

        // Hash the public key data
        let hash = SHA256.hash(data: publicKeyData)
        let hashBase64 = Data(hash).base64EncodedString()

        return pinnedHashes.contains(hashBase64)
    }
}
