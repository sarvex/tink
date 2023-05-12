# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""A client for AWS KMS."""

import binascii
import configparser
import re

from typing import Optional, Tuple, Any, Dict

import boto3
from botocore import exceptions

import tink
from tink import aead
from tink.aead import _kms_aead_key_manager


AWS_KEYURI_PREFIX = 'aws-kms://'


def _encryption_context(associated_data: bytes) -> Dict[str, str]:
  if associated_data:
    hex_associated_data = binascii.hexlify(associated_data).decode('utf-8')
    return {'associatedData': hex_associated_data}
  else:
    return {}


class _AwsKmsAead(aead.Aead):
  """Implements the Aead interface for AWS KMS."""

  def __init__(self, client: Any, key_arn: str) -> None:
    self.client = client
    self.key_arn = key_arn

  def encrypt(self, plaintext: bytes, associated_data: bytes) -> bytes:
    try:
      response = self.client.encrypt(
          KeyId=self.key_arn,
          Plaintext=plaintext,
          EncryptionContext=_encryption_context(associated_data),
      )
      return response['CiphertextBlob']
    except exceptions.ClientError as e:
      raise tink.TinkError(e)

  def decrypt(self, ciphertext: bytes, associated_data: bytes) -> bytes:
    try:
      response = self.client.decrypt(
          KeyId=self.key_arn,
          CiphertextBlob=ciphertext,
          EncryptionContext=_encryption_context(associated_data),
      )
      if response['KeyId'] != self.key_arn:
        raise tink.TinkError(
            f"invalid key id: got {self.key_arn}, want {response['KeyId']}")
      return response['Plaintext']
    except exceptions.ClientError as e:
      raise tink.TinkError(e)


def _key_uri_to_key_arn(key_uri: str) -> str:
  if not key_uri.startswith(AWS_KEYURI_PREFIX):
    raise tink.TinkError('invalid key URI')
  return key_uri[len(AWS_KEYURI_PREFIX) :]


def _parse_config(config_path: str) -> Tuple[str, str]:
  """Returns ('aws_access_key_id', 'aws_secret_access_key') from a config."""
  config = configparser.ConfigParser()
  config.read(config_path)
  if 'default' not in config:
    raise ValueError('invalid config: default not found')
  default = config['default']
  if 'aws_access_key_id' not in default:
    raise ValueError('invalid config: aws_access_key_id not found')
  if 'aws_secret_access_key' not in default:
    raise ValueError('invalid config: aws_secret_access_key not found')
  aws_access_key_id = default['aws_access_key_id']
  return aws_access_key_id, default['aws_secret_access_key']


def _get_region_from_key_arn(key_arn: str) -> str:
  # An AWS key ARN is of the form
  # arn:aws:kms:us-west-2:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab.
  key_arn_parts = key_arn.split(':')
  if len(key_arn_parts) < 6:
    raise tink.TinkError('invalid key id')
  return key_arn_parts[3]


class AwsKmsClient(_kms_aead_key_manager.KmsClient):
  """Basic AWS client for AEAD."""

  def __init__(self, key_uri: Optional[str], credentials_path: Optional[str]):
    """Creates a new AwsKmsClient that is bound to the key specified in 'key_uri'.

    For more information on credentials and in which order they are loaded see
    https://boto3.amazonaws.com/v1/documentation/api/latest/guide/configuration.html.

    Args:
      key_uri: The URI of the key the client should be bound to. If it is None
          or empty, then the client is not bound to any particular key.
      credentials_path: Path to the file with the access credentials. If it is
          None or empty, then default credentials will be used.

    Raises:
      ValueError: If the path or filename of the credentials is invalid.
      TinkError: If the key uri is not valid.
    """
    if not key_uri:
      self._key_arn = None
    elif match := re.match('aws-kms://arn:aws:kms:([a-z0-9-]+):', key_uri):
      self._key_arn = _key_uri_to_key_arn(key_uri)
    else:
      raise tink.TinkError('invalid key URI')
    if not credentials_path:
      self._aws_access_key_id = None
      self._aws_secret_access_key = None
    else:
      aws_access_key_id, aws_secret_access_key = _parse_config(credentials_path)
      self._aws_access_key_id = aws_access_key_id
      self._aws_secret_access_key = aws_secret_access_key

  def does_support(self, key_uri: str) -> bool:
    """Returns true if this client supports KMS key specified in 'key_uri'.

    Args:
      key_uri: Text, URI of the key to be checked.

    Returns: A boolean value which is true if the key is supported and false
      otherwise.
    """
    if not key_uri.startswith(AWS_KEYURI_PREFIX):
      return False
    return _key_uri_to_key_arn(key_uri) == self._key_arn if self._key_arn else True

  def get_aead(self, key_uri: str) -> aead.Aead:
    """Returns an Aead-primitive backed by KMS key specified by 'key_uri'.

    Args:
      key_uri: Text, URI of the key which should be used.

    Returns:
      An AEAD primitive which uses the specified key.

    Raises:
      TinkError: If the key_uri is not supported.
    """
    if not self.does_support(key_uri):
      if self._key_arn:
        raise tink.TinkError(
            f'This client is bound to {self._key_arn} and cannot use key {key_uri}'
        )
      raise tink.TinkError(f'This client does not support key {key_uri}')
    key_arn = _key_uri_to_key_arn(key_uri)
    session = boto3.session.Session(
        aws_access_key_id=self._aws_access_key_id,
        aws_secret_access_key=self._aws_secret_access_key,
        region_name=_get_region_from_key_arn(key_arn),
    )
    return _AwsKmsAead(session.client('kms'), key_arn)

  @classmethod
  def register_client(
      cls, key_uri: Optional[str], credentials_path: Optional[str]
  ) -> None:
    """Registers the KMS client internally."""
    _kms_aead_key_manager.register_kms_client(  # pylint: disable=protected-access
        AwsKmsClient(key_uri, credentials_path)
    )
