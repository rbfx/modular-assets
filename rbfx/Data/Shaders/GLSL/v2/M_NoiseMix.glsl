#define URHO3D_PIXEL_NEED_TEXCOORD

#define URHO3D_MATERIAL_ALBEDO URHO3D_TEXTURE_ALBEDO
#define URHO3D_MATERIAL_NORMAL URHO3D_TEXTURE_NORMAL
#define URHO3D_MATERIAL_PROPERTIES URHO3D_TEXTURE_PROPERTIES
#define URHO3D_MATERIAL_EMISSION URHO3D_TEXTURE_EMISSION

#define URHO3D_CUSTOM_MATERIAL_UNIFORMS

#include "_Config.glsl"
#include "_Uniforms.glsl"
#include "_DefaultSamplers.glsl"

UNIFORM_BUFFER_BEGIN(4, Material)
    DEFAULT_MATERIAL_UNIFORMS
    UNIFORM(half4 cMatDiffColor2)
    UNIFORM(float cNoiseScale)
UNIFORM_BUFFER_END(4, Material)

VERTEX_OUTPUT_HIGHP(vec3 vWorldPos)

#ifndef NONOISE
SAMPLER(11, sampler3D sVolumeNoise)
#endif

#include "_Material.glsl"

#ifdef URHO3D_VERTEX_SHADER
void main()
{
    VertexTransform vertexTransform = GetVertexTransform();
    vWorldPos = vertexTransform.position.xyz * (1.0 / cNoiseScale);
    Vertex_SetAll(vertexTransform, cNormalScale, cUOffset, cVOffset, cLMOffset);
}
#endif

#ifdef URHO3D_PIXEL_SHADER
void main()
{
#ifdef URHO3D_DEPTH_ONLY_PASS
    Pixel_DepthOnly(sAlbedo, vTexCoord);
#else
    SurfaceData surfaceData;

    Surface_SetCommon(surfaceData);
    Surface_SetAmbient(surfaceData, sEmission, vTexCoord2);
    Surface_SetNormal(surfaceData, vNormal, sNormal, vTexCoord, vTangent, vBitangentXY);
    Surface_SetPhysicalProperties(surfaceData, cRoughness, cMetallic, cDielectricReflectance, sProperties, vTexCoord);
    Surface_SetLegacyProperties(surfaceData, cMatSpecColor.a, sEmission, vTexCoord);
    Surface_SetCubeReflection(surfaceData, sReflection0, sReflection1, vReflectionVec, vWorldPos);
    Surface_SetPlanarReflection(surfaceData, sReflection0, cReflectionPlaneX, cReflectionPlaneY);
    Surface_SetBackground(surfaceData, sEmission, sDepthBuffer);

    half4 albedoInput = texture(sAlbedo, vTexCoord);
#ifdef NONOISE
    half mixFactor = (albedoInput.r + 0.5) * 0.5;
#else
    half3 colorNoise = texture(sVolumeNoise, vWorldPos).rgb;
    half mixFactor = (albedoInput.r + colorNoise.r) * 0.5;
#endif

    half4 matDiffColor = mix(cMatDiffColor, cMatDiffColor2, mixFactor);

    //Surface_SetBaseAlbedo(surfaceData, madDiffColor, cAlphaCutoff, vColor, sAlbedo, vTexCoord, URHO3D_MATERIAL_ALBEDO);
    {
        CutoutByAlpha(GetCutoutAlpha(1.0, vColor.a), cAlphaCutoff);
        surfaceData.albedo = GammaToLightSpaceAlpha(matDiffColor);
        ModulateAlbedoByVertexColor(surfaceData.albedo, vColor);
    }

    Surface_SetBaseSpecular(surfaceData, cMatSpecColor, cMatEnvMapColor, sProperties, vTexCoord);
    Surface_SetAlbedoSpecular(surfaceData);
    Surface_SetEmission(surfaceData, cMatEmissiveColor, sEmission, vTexCoord, URHO3D_MATERIAL_EMISSION);
    Surface_ApplySoftFadeOut(surfaceData, vWorldDepth, cFadeOffsetScale);

    half3 surfaceColor = GetSurfaceColor(surfaceData);
    gl_FragColor = GetFragmentColorAlpha(surfaceColor, surfaceData.albedo.a, surfaceData.fogFactor);
#endif
}
#endif
