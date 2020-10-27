using System.Runtime.InteropServices;

namespace openaes
{
    public unsafe class AesAsm
    {
        [DllImport("asm.dll")]
        private static extern int asmAddTwoInts(int a, int b);

        public int executeAsmAddTwoInts(int a, int b)
        {
            return asmAddTwoInts(a, b);
        }
    }
}
