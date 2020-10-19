using System;
using System.Collections.Generic;
using System.Text;

namespace aes_test
{
    public class AES
    {
        byte[] state;

        public AES()
        {
            state = new byte[16];
        }

        public void KeyExpansion() { }

        public void SubBytes(byte[] state) {
            for(int i = 0; i < 16; i++)
            {
                // Substitute each byte in state for 
                state[i] = Const.sbox[state[i]];
            }
        }
        public void ShiftRows(byte[] state) {
            byte[] tmp = new byte[16];

            tmp[0] = state[0];
            tmp[1] = state[5];
            tmp[2] = state[10];
            tmp[3] = state[15];

            tmp[4] = state[4];
            tmp[5] = state[9];
            tmp[6] = state[14];
            tmp[7] = state[3];

            tmp[8] = state[8];
            tmp[9] = state[13];
            tmp[10] = state[2];
            tmp[11] = state[7];

            tmp[12] = state[12];
            tmp[13] = state[1];
            tmp[14] = state[6];
            tmp[15] = state[11];

            for(int i = 0; i < 16; i++)
            {
                state[i] = tmp[i];
            }

        }
        public void MixColumns() { }
        public void AddRoundKey(byte[] state, byte[] roundKey) {
            for(int i = 0; i < 16; i++)
            {
                state[i] ^= roundKey[i];
            }
        }

        public void Encrypt(byte[] message, byte[] key)
        {
            for(int i = 0; i < 16; i++)
            {
                state[i] = message[i];
            }
            int numberOfRounds = 1;

            KeyExpansion();
            AddRoundKey(state, key); // Initial round

            for(int i = 0; i< numberOfRounds; i++)
            {
                SubBytes(state);
                ShiftRows(state);
                MixColumns();
                AddRoundKey(state, key);
            }

            // Final round
            SubBytes(state);
            ShiftRows(state);
            AddRoundKey(state, key);
            
        }
        public void Decrypt()
        {

        }

        

    }
}
