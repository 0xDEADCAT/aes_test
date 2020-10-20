using System;
using System.CommandLine;
using System.CommandLine.Invocation;
using System.IO;
using System.Threading.Tasks;

namespace aes_test
{
    class Program
    {
        public static async Task<int> Main(params string[] args)
        {
            RootCommand rootCommand = new RootCommand(
                description: "Encrypts (default) or decrypts a file using Advanced Encryption Standard (AES).");
            Option inputOption = new Option(
                aliases: new string[] { "--input", "-i" },
                description: "The path to the file that is to be encrypted/decrypted.");
            inputOption.Argument = new Argument<FileInfo>();
            inputOption.IsRequired = true;
            rootCommand.AddOption(inputOption);
            Option outputOption = new Option(
                aliases: new string[] { "--output", "-o" },
                description: "The target name of the output file after encryption/decryption.");
            outputOption.Argument = new Argument<FileInfo>();
            outputOption.IsRequired = true;
            rootCommand.AddOption(outputOption);
            Option decryptOption = new Option(
                aliases: new string[] { "--decrypt", "-d" },
                description: "Decrypt the input data.");
            decryptOption.Argument = new Argument<bool>();
            rootCommand.AddOption(decryptOption);
            rootCommand.Handler =
              CommandHandler.Create<FileInfo, FileInfo, bool>(RunAES);
            return await rootCommand.InvokeAsync(args);
        }

        public static void RunAES(FileInfo input, FileInfo output, bool decrypt)
        {
            if(!input.Exists)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.Error.WriteLine("Input file doesn't exist, exiting.");
                Console.ResetColor();
                return;
            }

            AES aes = new AES();

            if(!decrypt)
            {
                using (FileStream fs = input.OpenRead())
                using (FileStream fsOut = output.OpenWrite())
                {
                    byte[] message = new byte[16];
                    byte[] key = new byte[16] {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15};

                    byte[] expandedKey = new byte[176];

                    aes.KeyExpansion(key, expandedKey);

                    bool ended = false;

                    while(!ended)
                    {
                        int readBytes = fs.Read(message, 0, 16);
                        if(readBytes == 0) // pad 16 byte block
                        {
                            ended = true;
                            for (int i = 0; i < 16; i++)
                                message[i] = 16;
                        }
                        else if (readBytes % 16 != 0) // pad missing bytes according to PKCS#7
                        {
                            ended = true;
                            for(int i = 0; i < 16 - readBytes; i++)
                            {
                                message[readBytes + i] = (byte)(16 - readBytes);
                            }
                        }
                        aes.Encrypt(message, expandedKey);

                        for (int i = 0; i < 16; i++)
                        {
                            Console.Write($"{message[i]:X2}");
                            Console.Write(' ');
                        }

                        Console.WriteLine();

                        fsOut.Write(message, 0, 16);
                    }
                }
                
            } else {
                aes.Decrypt(); 
            }
        }
    }
}
