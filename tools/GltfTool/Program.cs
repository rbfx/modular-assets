using Cocona;

namespace GltfTool
{
    class Program
    {
        static int Main(string[] args)
        {
            CoconaLiteApp.Run(new[] {
                typeof(ConvertCommand),
            });

            return 0;
        }
    }
}