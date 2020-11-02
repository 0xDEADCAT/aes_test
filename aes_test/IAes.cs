using System;
using System.Collections.Generic;
using System.Text;

namespace openaes
{
    public interface IAes
    {
        public void Encrypt(byte[] message, byte[] key);
        public void Decrypt(byte[] message, byte[] key);
        public void KeyExpansion(byte[] inputKey, byte[] expandedKeys);
    }
}
