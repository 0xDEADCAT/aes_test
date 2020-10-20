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

        public void KeyExpansionCore(byte[] input, int i)
        {
            // Rotate left
            byte t = input[0];
            input[0] = input[1];
            input[1] = input[2];
            input[2] = input[3];
            input[3] = t;

            // S-Box four bytes
            input[0] = Const.sbox[input[0]];
            input[1] = Const.sbox[input[1]];
            input[2] = Const.sbox[input[2]];
            input[3] = Const.sbox[input[3]];

            // RCon
            input[0] ^= Const.rcon[i];
        }

        public void KeyExpansion(byte[] inputKey, byte[] expandedKeys) {
            // The first 16 bytes are the original key
            for(int i = 0; i < 16; i++)
            {
                expandedKeys[i] = inputKey[i];
            }

            int bytesGenerated = 16;
            int rconIteration = 1;
            byte[] temp = new byte[4];

            while(bytesGenerated < 176)
            {
                // Read 4 bytes for the core
                for(int i = 0; i < 4; i++)
                {
                    temp[i] = expandedKeys[i + bytesGenerated - 4];
                }

                // Perform core once for each 16 byte key
                if (bytesGenerated % 16 == 0)
                    KeyExpansionCore(temp, rconIteration++);

                for(int i = 0; i < 4; i++)
                {
                    expandedKeys[bytesGenerated] = (byte)(expandedKeys[bytesGenerated - 16] ^ temp[i]);
                    bytesGenerated++;
                }
            }
        }

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
        public void MixColumns(byte[] state) {
            byte[] tmp = new byte[16];

            tmp[0] = (byte)(Const.gMulBy2[state[0]] ^ Const.gMulBy3[state[1]] ^ state[2] ^ state[3]);
            tmp[1] = (byte)(state[0] ^ Const.gMulBy2[state[1]] ^ Const.gMulBy3[state[2]] ^ state[3]);
            tmp[2] = (byte)(state[0] ^ state[1] ^ Const.gMulBy2[state[2]] ^ Const.gMulBy3[state[3]]);
            tmp[3] = (byte)(Const.gMulBy3[state[0]] ^ state[1] ^ state[2] ^ Const.gMulBy2[state[3]]);

            tmp[4] = (byte)(Const.gMulBy2[state[4]] ^ Const.gMulBy3[state[5]] ^ state[6] ^ state[7]);
            tmp[5] = (byte)(state[4] ^ Const.gMulBy2[state[5]] ^ Const.gMulBy3[state[6]] ^ state[7]);
            tmp[6] = (byte)(state[4] ^ state[5] ^ Const.gMulBy2[state[6]] ^ Const.gMulBy3[state[7]]);
            tmp[7] = (byte)(Const.gMulBy3[state[4]] ^ state[5] ^ state[6] ^ Const.gMulBy2[state[7]]);

            tmp[8] = (byte)(Const.gMulBy2[state[8]] ^ Const.gMulBy3[state[9]] ^ state[10] ^ state[11]);
            tmp[9] = (byte)(state[8] ^ Const.gMulBy2[state[9]] ^ Const.gMulBy3[state[10]] ^ state[11]);
            tmp[10] = (byte)(state[8] ^ state[9] ^ Const.gMulBy2[state[10]] ^ Const.gMulBy3[state[11]]);
            tmp[11] = (byte)(Const.gMulBy3[state[8]] ^ state[9] ^ state[10] ^ Const.gMulBy2[state[11]]);

            tmp[12] = (byte)(Const.gMulBy2[state[12]] ^ Const.gMulBy3[state[13]] ^ state[14] ^ state[15]);
            tmp[13] = (byte)(state[12] ^ Const.gMulBy2[state[13]] ^ Const.gMulBy3[state[14]] ^ state[15]);
            tmp[14] = (byte)(state[12] ^ state[13] ^ Const.gMulBy2[state[14]] ^ Const.gMulBy3[state[15]]);
            tmp[15] = (byte)(Const.gMulBy3[state[12]] ^ state[13] ^ state[14] ^ Const.gMulBy2[state[15]]);

            for(int i = 0; i < 16; i++)
            {
                state[i] = tmp[i];
            }
        }
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
            int numberOfRounds = 9;

            AddRoundKey(state, key); // Initial round

            for(int i = 0; i < numberOfRounds; i++)
            {
                SubBytes(state);
                ShiftRows(state);
                MixColumns(state);
                AddRoundKey(state, new ArraySegment<byte>(key, 16 * (i + 1), 16).ToArray());
            }

            // Final round
            SubBytes(state);
            ShiftRows(state);
            AddRoundKey(state, new ArraySegment<byte>(key, 160, 16).ToArray());

            for(int i = 0; i < 16; i++)
            {
                message[i] = state[i];
            }
            
        }
        public void Decrypt()
        {

        }

        

    }
}
