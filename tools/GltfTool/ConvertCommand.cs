using Cocona;
using MeshTopologyToolkit;
using MeshTopologyToolkit.Gltf;
using MeshTopologyToolkit.Urho3D;
using System.Globalization;
using System.Numerics;

namespace GltfTool
{
    public class ConvertCommand
    {
        [Command("convert", Description = "Convert file with transform.")]
        public void Build(
            [Option('i', Description = "Input GLTF file name")] string input,
            [Option('r', Description = "Rotate mesh according to Euler angles defined in degrees \"x,y,z\".")] string? rotate = null,
            [Option('a', Description = "Align output mesh in Vector3 format \"x,y,z\". Use 0.5,0.5,0.5 to move pivot point to mesh center.")] string? align = null,
            [Option('o', Description = "Output MDL file name. By default it takes input file name and replace extension with mdl.")] string? output = null
        )
        {
            if (string.IsNullOrEmpty(output))
            {
                output = Path.Combine(Path.GetDirectoryName(input) ?? "", Path.GetFileNameWithoutExtension(input) + ".mdl");
            }

            var fileFormat = new FileFormatCollection(
                new FormatAndSpace(new GltfFileFormat(), SpaceTransform.Identity),
                new FormatAndSpace(new Urho3DFileFormat(), SpaceTransform.Identity)
                );

            if (!fileFormat.TryRead(new FileSystemEntry(input), out var model))
            {
                throw new Exception($"Failed to read file {input}");
            }

            if (rotate != null)
            {
                var radians = ParseVec3(rotate) * (MathF.PI / 180.0f);
                var rotation = Quaternion.CreateFromYawPitchRoll(radians.Y, radians.X, radians.Z);
                //model.AlignPivot(alignVec.Value);
            }

            if (align != null)
            {
                var alignVec = ParseVec3(align);
                //model.AlignPivot(alignVec.Value);
            }

            if (!fileFormat.TryWrite(new FileSystemEntry(output), model))
            {
                throw new Exception($"Failed to write file {output}");
            }
        }

        Vector3 ParseVec3(string str)
        {
            var parts = str.Split(',');
            if (parts.Length != 3)
            {
                throw new Exception($"Invalid Vector3 format: {str}");
            }
            return new Vector3(
                float.Parse(parts[0], CultureInfo.InvariantCulture),
                float.Parse(parts[1], CultureInfo.InvariantCulture),
                float.Parse(parts[2], CultureInfo.InvariantCulture)
                );
        }
    }
}