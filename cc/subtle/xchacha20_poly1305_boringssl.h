// Copyright 2018 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
///////////////////////////////////////////////////////////////////////////////

#ifndef TINK_SUBTLE_XCHACHA20_POLY1305_BORINGSSL_H_
#define TINK_SUBTLE_XCHACHA20_POLY1305_BORINGSSL_H_

#include <memory>
#include <utility>

#include "absl/strings/string_view.h"
#include "openssl/base.h"
#include "tink/aead.h"
#include "tink/util/secret_data.h"
#include "tink/util/status.h"
#include "tink/util/statusor.h"

namespace crypto {
namespace tink {
namespace subtle {

class XChacha20Poly1305BoringSsl : public Aead {
 public:
  // Constructs a new Aead cipher for XChacha20-Poly1305.
  // Currently supported key size is 256 bits.
  // Currently supported nonce size is 24 bytes.
  // The tag size is fixed to 16 bytes.
  static crypto::tink::util::StatusOr<std::unique_ptr<Aead>> New(
      util::SecretData key);

  crypto::tink::util::StatusOr<std::string> Encrypt(
      absl::string_view plaintext,
      absl::string_view additional_data) const override;

  crypto::tink::util::StatusOr<std::string> Decrypt(
      absl::string_view ciphertext,
      absl::string_view additional_data) const override;

 private:
  // The following constants are in bytes.
  static constexpr int kNonceSize = 24;
  static constexpr int kTagSize = 16;

  XChacha20Poly1305BoringSsl(util::SecretData key, const EVP_AEAD* aead)
      : key_(std::move(key)), aead_(aead) {}

  const util::SecretData key_;
  const EVP_AEAD* const aead_;
};

}  // namespace subtle
}  // namespace tink
}  // namespace crypto

#endif  // TINK_SUBTLE_XCHACHA20_POLY1305_BORINGSSL_H_
