using cs_implementation;
using System;
using System.Collections.Generic;
using System.Text;

namespace openaes
{
    public class AesCSharp : IAes
    {
        AES _aes = new AES();

        public void Encrypt(byte[] message, byte[] key)
        {
            _aes.Encrypt(message, key);
        }
        public void Decrypt(byte[] message, byte[] key)
        {
            _aes.Decrypt(message, key);
        }
        public void KeyExpansion(byte[] inputKey, byte[] expandedKeys)
        {
            _aes.KeyExpansion(inputKey, expandedKeys);
        }
    }
}
