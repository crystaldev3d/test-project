#include "_Config.glsl"
#include "_Uniforms.glsl"
#include "_InternalSamplers.glsl"
#include "_VertexLayout.glsl"
#include "_VertexTransform.glsl"
#include "_VertexScreenPos.glsl"
#include "_GammaCorrection.glsl"
#include "_DefaultSamplers.glsl"
#include "_SamplerUtils.glsl"
#include "_DirectLighting.glsl"
#include "_Shadow.glsl"
#include "_Fog.glsl"
#include "_DeferredLighting.glsl"
#include "_BRDF.glsl"

VERTEX_OUTPUT_HIGHP(vec4 vScreenPos)
VERTEX_OUTPUT_HIGHP(vec3 vFarRay)
#ifdef URHO3D_ORTHOGRAPHIC_DEPTH
    VERTEX_OUTPUT_HIGHP(vec3 vNearRay)
#endif

#ifdef URHO3D_VERTEX_SHADER
void main()
{
    VertexTransform vertexTransform = GetVertexTransform();
    vec3 worldPos = vertexTransform.position.xyz;
    gl_Position = WorldToClipSpace(worldPos);

    vScreenPos = GetDeferredScreenPos(gl_Position);
    vFarRay = GetDeferredFarRay(gl_Position);
    #ifdef URHO3D_ORTHOGRAPHIC_DEPTH
        vNearRay = GetDeferredNearRay(gl_Position);
    #endif
}
#endif

#ifdef URHO3D_PIXEL_SHADER
void main()
{
    float depth = ReconstructDepth(SampleGeometryBuffer(sDepthBuffer, vScreenPos).r);
    half4 albedoInput = SampleGeometryBuffer(sAlbedo, vScreenPos);
    half4 specularInput = SampleGeometryBuffer(sProperties, vScreenPos);
    half4 normalInput = SampleGeometryBuffer(sNormal, vScreenPos);

    vec4 worldPos = GetDeferredWorldPos(vScreenPos, depth);
    half3 eyeVec = normalize(-worldPos.xyz);
    worldPos.xyz += STEREO_VAR(cCameraPos).xyz;

    half3 normal = DecodeNormal(normalInput);
    #ifdef URHO3D_PHYSICAL_MATERIAL
        half roughness = specularInput.a;
    #else
        half specularPower = RoughnessToSpecularPower(specularInput.a);
    #endif

    DirectLightData lightData = GetDeferredDirectLightData(worldPos, depth);

    #if defined(URHO3D_PHYSICAL_MATERIAL) || URHO3D_SPECULAR > 0
        half3 halfVec = normalize(eyeVec + lightData.lightVec.xyz);
    #endif

    #ifdef URHO3D_PHYSICAL_MATERIAL
        half3 lightColor = Direct_PBR(lightData.lightColor, albedoInput.rgb, specularInput.rgb, roughness,
            lightData.lightVec.xyz, normal, eyeVec, halfVec);
    #else
        #if URHO3D_SPECULAR > 0
            half3 lightColor = Direct_SimpleSpecular(lightData.lightColor,
                albedoInput.rgb, specularInput.rgb,
                lightData.lightVec.xyz, normal, halfVec, specularPower, cLightColor.a);
        #else
            half3 lightColor = Direct_Simple(lightData.lightColor,
                albedoInput.rgb, lightData.lightVec.xyz, normal);
        #endif
    #endif

    half3 finalColor = lightColor * GetDirectLightAttenuation(lightData);
    gl_FragColor = vec4(finalColor, 0.0);
}
#endif
