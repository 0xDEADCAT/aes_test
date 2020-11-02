using cs_implementation;
using System.Runtime.InteropServices;

namespace openaes
{
    public unsafe class AesAsm
    {
        [DllImport("asm.dll")]
        private static extern void asmEncrypt(byte* message, byte* key);

        [DllImport("asm.dll")]
        private static extern void asmDecrypt(byte* message, byte* key);

        [DllImport("asm.dll")]
        private static extern void asmKeyExpansion(byte* message, byte* expandedKeys);

        public void Encrypt(byte[] message, byte[] key)
        {
            fixed (byte* msg = message, k = key)
            {
                asmEncrypt(msg, k);
            }
        }

        public void Decrypt(byte[] message, byte[] key)
        {
            fixed(byte* msg = message, k = key)
            {
                asmDecrypt(msg, k);
            }
        }

        public void KeyExpansion(byte[] inputKey, byte[] expandedKeys)
        {
            fixed(byte* key = inputKey, expKeys = expandedKeys)
            {
                asmKeyExpansion(key, expKeys);
            }

        }
    }
}
