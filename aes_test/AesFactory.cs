using System;
using System.Collections.Generic;
using System.Text;

namespace openaes
{
    public enum AesImplementation
    {
        Asm,
        CSharp
    }

    public class AesFactory
    {
        public IAes GetAes(AesImplementation implementation)
        {
            switch(implementation)
            {
                case AesImplementation.Asm:
                    return new AesAsm();
                case AesImplementation.CSharp:
                    return new AesCSharp();
                default:
                    return new AesAsm();
            }
        }
    }
}
