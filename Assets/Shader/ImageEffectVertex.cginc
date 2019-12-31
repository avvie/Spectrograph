// Upgrade NOTE: replaced 'defined IMAGE_EFFECT_VERTEX' with 'defined (IMAGE_EFFECT_VERTEX)'

#if !defined (IMAGE_EFFECT_VERTEX)
    #define IMAGE_EFFECT_VERTEX

    #define PI 3.14159265359
    struct VertexData {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
    };

    struct Interpolators {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
            float4 screenPos : TEXCOORD1;
    };

    Interpolators VertexProgram(VertexData v) {
            Interpolators i;
            i.pos = UnityObjectToClipPos (v.vertex);
            i.screenPos = ComputeScreenPos(i.pos);
            i.uv = v.uv;
            return i;
    }

    float2 glslmod(float2 x, float y){
        return x - y * floor(x/y);
    }

    float2 screenSpaceConversion(float4 screenPos){
        return (screenPos.xy / screenPos.w).xy;
    }

    float2 screenSpaceConversionCentered(float4 screenPos){
        return (screenPos.xy / screenPos.w).xy - 0.5;
    }
    
    float2 screenSpaceConversionCenteredLeft(float4 screenPos){
        float2 ret = (screenPos.xy / screenPos.w).xy;
        ret.y -= 0.5;
        return ret;
    }

#endif