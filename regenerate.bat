dotnet build -c Release "tools/GltfTool"
dotnet "tools/GltfTool/bin/Release/net9.0/GltfTool.dll" convert -i "src/Env/BrickFloor01.glb" --align 0.5,1.0,0.5 -o "rbfx/Data/Models/Env/BrickFloor01.mdl"
dotnet "tools/GltfTool/bin/Release/net9.0/GltfTool.dll" convert -i "src/Env/BrickWall01.glb" --align 0.5,0.0,0.5 -o "rbfx/Data/Models/Env/BrickWall01.mdl"
dotnet "tools/GltfTool/bin/Release/net9.0/GltfTool.dll" convert -i "src/Env/BrickWallArch01.glb" -t -n --align 0.5,0.0,0.5 -o "rbfx/Data/Models/Env/BrickWallArch01.mdl"



