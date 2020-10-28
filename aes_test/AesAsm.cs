using cs_implementation;
using System.Runtime.InteropServices;

namespace openaes
{
    public unsafe class AesAsm
    {
        [DllImport("asm.dll")]
        private static extern void asmEncrypt(byte[] message, byte[] key);

        public void Encrypt(byte[] message, byte[] key)
        {
            asmEncrypt(message, key);
        }

        public void Decrypt(byte[] message, byte[] key)
        {
        }

        public void KeyExpansion(byte[] inputKey, byte[] expandedKey)
        {
            AES aes = new AES();
            aes.KeyExpansion(inputKey, expandedKey);
        }
    }
}
