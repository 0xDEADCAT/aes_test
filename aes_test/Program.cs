using System;
using System.CommandLine;
using System.CommandLine.Invocation;
using System.IO;
using System.Net.Security;
using System.Text;
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

            Aes aes = new Aes();

            if(!decrypt)
            {
                aes.Encrypt();
            } else {
                aes.Decrypt(); 
            }
        }
    }
}
